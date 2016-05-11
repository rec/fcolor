#pragma once

#include <tdsp/base/math.h>
#include <tdsp/base/enum.h>

namespace tdsp {

struct Fade {
    enum class Type {linear, sqr, sqrt, size};

    float begin = 0, end = 1, fader = 0;
    Type type = Type::linear;

    float operator()(float x, float y) const {
        auto xratio = begin + fader * (end - begin);
        auto yratio = begin + invert(fader) * (end - begin);

        switch (type) {
            default:
                break;
            case Fade::Type::sqr:
                xratio = xratio * xratio * signum(xratio);
                yratio = yratio * yratio * signum(yratio);
                break;
            case Fade::Type::sqrt:
                xratio = sqrt(std::abs(xratio)) * signum(xratio);
                yratio = sqrt(std::abs(yratio)) * signum(yratio);
                break;
        }

        // TODO: perhaps we should be applying end and begin after this step?
        return xratio * x + yratio + y;
    }
};

template <typename Coll>
void applySame(Fade const& fade, Coll const& in1, Coll const& in2, Coll& out) {
    for (size_t i = 0; i < out.size(); ++i)
        out[i] = fade(in1[i], in2[i]);
}

template <typename Coll>
void applyExtend(Fade const& fade, Coll const& in1, Coll const& in2, Coll& out) {
    // This is wrong - I shouldn't be changing the size.
    auto size = std::max(in1.size(), in2.size());
    out.resize(size);
    decltype(in1[0]) zero = {{0}};
    auto get = [&] (Coll const& c, size_t i) {
        return i < c.size() ? c[i] : zero;
    };

    for (size_t i = 0; i < size; ++i)
        applySame(fade, get(in1, i), get(in2, i), out[i]);
}

} // tdsp