#!/usr/bin/env python3
import base64
import hashlib
import os
import re

PAT_TAG = re.compile(r'<[^>]+>')
PAT_STATIC = re.compile(r'^.+\.(?:css|js|jpg|jpeg|png|ico)$')
PAT_NEEDS_FIXUP = re.compile(r'^.+\.(?:html|xml)$')


def generate_shorthash(data: bytes) -> str:
    return str(base64.urlsafe_b64encode(hashlib.sha512(data).digest()[:12]), 'utf-8')


def transform_file(path: str, mapping) -> None:
    def replace(match):
        tag_text = match.group(0)
        for key, value in mapping:
            tag_text = tag_text.replace(key, value)

        return tag_text

    with open(path, 'r') as f:
        data = f.read()

    data = PAT_TAG.sub(replace, data)

    with open(path, 'w') as f:
        f.write(data)


def walk(root: str, filter):
    for root, dirs, files in os.walk('./'):
        for filename in files:
            if not filter(filename):
                continue

            yield os.path.join(root, filename)


def main() -> None:
    immutable = []
    for filename in walk('./', lambda filename: PAT_STATIC.match(filename)):
        immutable.append(filename)

    mapping = []
    for path in immutable:
        with open(path, 'rb') as f:
            shorthash = generate_shorthash(f.read())

        path_sans_ext, ext = os.path.splitext(path)
        filename = os.path.basename(path)
        new_filename = '{}-{}{}'.format(path_sans_ext, shorthash, ext)
        mapping.append((filename, os.path.basename(new_filename)))
        try:
            os.link(path, new_filename)
        except FileExistsError:
            pass

    # Ensure that longest keys come first to avoid replacing substrings
    mapping.sort(key=lambda x: len(x[0]), reverse=True)

    for filename in walk('./', lambda filename: PAT_NEEDS_FIXUP.match(filename)):
        transform_file(filename, mapping)

if __name__ == '__main__':
    main()
