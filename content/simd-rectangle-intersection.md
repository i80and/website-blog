+++
title = "SIMD Rectangle Intersection"
date = "2017-01-31 20:50:05"
+++

[SIMD.js](https://github.com/tc39/ecmascript_simd) is cool. You can use it with Firefox or Edge nightly.

Can we speed up rectangle intersection checks? Yes we can!

    class Rectangle {
      constructor(x1, y1, x2, y2) {
        this.items = new Float32Array(4)
        this.items[0] = x1
        this.items[1] = y1
        this.items[2] = x2
        this.items[3] = y2
      }

      get x1() { return this.items[0] }
      get y1() { return this.items[1] }
      get x2() { return this.items[2] }
      get y2() { return this.items[3] }
    }

    function rectIntersectsScaler(r1, r2) {
      return r1.x1 <= r2.x2 &&
             r1.y1 <= r2.y2 &&
             r2.x1 < r1.x2 &&
             r2.y1 < r1.y2
    }

    function rectIntersectsSIMD(r1, r2) {
      const a = SIMD.Float32x4.load(r1.items, 0)
      const b = SIMD.Float32x4.load(r2.items, 0)

      // r1.x1 r1.y1 r1.x2 r1.y2    r2.x1 r2.y1 r2.x2 r2.y2
      // 0     1     2     3        4     5     6     7
      const c = SIMD.Float32x4.shuffle(a, b, 0, 1, 4, 5)
      const d = SIMD.Float32x4.shuffle(a, b, 6, 7, 2, 3)
      const maskLT = SIMD.Float32x4.lessThanOrEqual(c, d)

      return SIMD.Bool32x4.allTrue(maskLT)
    }

#Caveats
`rectIntersectsSIMD()` yields a false positive if `r2.x1 == r1.x2` or `r2.y1 == r1.y2`. This is because the `<` is transformed into `<=` so we can use a single SIMD op.

#Results
Benchmark run using [jsperf](https://jsperf.com/simdrectanglegniwer) on Firefox Nightly 53.0a2 (2017-01-30).

<table>
<tr><td>Scaler</td><td><tt>  792,398,034 ±0.74%</tt> ops/s</td></tr>
<tr><td>SIMD</td><td><tt>1,508,427,115 ±2.40%</tt> ops/s</td></tr>
</table>
