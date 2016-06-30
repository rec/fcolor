#pragma once

#include <timedata/base/enum.h>
#include <timedata/base/rotate.h>
#include <timedata/signal/sample.h>

namespace timedata {

enum class RGB { red, green, blue, last = blue };
enum class RGBW { red, green, blue, white, last = white };
enum class HSB { hue, saturation, brightness, last = brightness };

using Color = Sample<RGB, Normal<float>>;
using Color256 = Sample<RGB, EightBit<float>>;
using Color255 = Sample<RGB, Range255<float>>;

// Everything below this point is DEPRECATED.

/** Computational base - 0..1 float or 0..255 integer?
    TODO: needs to be replaced by a Range generic type!
*/
enum class Base {normal, integer, last = integer};

template <typename Number>
struct EnumFields<RGB, Number> {
    Number red = 0, green = 0, blue = 0;

    EnumFields() = default;
    EnumFields(Number r, Number g, Number b) : red(r), green(g), blue(b) {}

    EnumFields(Color const& c) : red(c[0]), green(c[1]), blue(c[2]) {}
    operator Color() const { return {{red, green, blue}}; }
};

struct OldColorS {
    float red = 0, green = 0, blue = 0;

    OldColorS() = default;
    OldColorS(float r, float g, float b) : red(r), green(g), blue(b) {}
    OldColorS(Color const& c) : red(c[0]), green(c[1]), blue(c[2]) {}

    operator Color() const { return {red, green, blue}; }
};

inline OldColorS rotate(OldColorS c, int positions) {
    Color co = c;
    rotate(co, positions);
    return co;
}

inline void minInto(OldColorS const& in, OldColorS& out) {
    out.red = std::min(in.red, out.red);
    out.green = std::min(in.green, out.green);
    out.blue = std::min(in.blue, out.blue);
}

inline void maxInto(OldColorS const& in, OldColorS& out) {
    out.red = std::max(in.red, out.red);
    out.green = std::max(in.green, out.green);
    out.blue = std::max(in.blue, out.blue);
}

inline float cmp(OldColorS const& x, OldColorS const& y) {
    if (auto d = x.red - y.red)
        return d;
    if (auto d = x.green - y.green)
        return d;
    return x.blue - y.blue;
}

inline float distance2(Color const& x, Color const& y) {
    auto dr = x[0] - y[0], dg = x[1] - y[1], db = x[2] - y[2];
    return dr * dr + dg * dg + db * db;
}

inline float distance(Color const& x, Color const& y) {
    return sqrt(distance2(x, y));
}

} // timedata
