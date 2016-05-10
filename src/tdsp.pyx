from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

ctypedef unsigned int uint
ctypedef unsigned char uint8_t

include "tdsp/base/wrapper.pyx"
include "tdsp/color/_combiner.pyx"
include "tdsp/color/_fade.pyx"
include "tdsp/color/_render3.pyx"
include "tdsp/color/_stripe.pyx"
include "tdsp/color/color.pyx"
include "tdsp/color/color_list.pyx"
include "tdsp/color/renderer.pyx"
