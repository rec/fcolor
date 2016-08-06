### define
cdef extern from "<$header_file>" namespace "$namespace":
$struct_definition

cdef class _$classname(_Wrapper):
    cdef $classname cdata;
$enum_pyx
    def __cinit__(self):
        clearStruct(self.cdata)

    def clear(self):
        """Clear the $classname to its initial state."""
        clearStruct(self.cdata)

    def __str__(self):
        return "($str_format)" % (
            $variable_names)

$property_list
