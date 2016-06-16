from numbers import Number

cdef class ColorList{suffix}:
    """A list of RGB floating point Colors, with many mutating functions.

       A ColorList looks quite like a Python list of Colors (which look like
       tuples) with the big interface difference that operations like + and *
       perform arithmetic and not list construction.

       Written in C++, this class should consume significantly fewer memory and
       CPU resources than a corresponding Python list, as well as providing a
       range of useful facilities.

       While ColorList provides a full set of functions and operations that
       create new ColorLists, in each case there is a corresponding mutating
       function or operation that works "in-place" with no heap allocations
       at all, for best performance.

       The base class ColorList is a list of Color, which are normalized to
       [0, 1]; the derived class ColorList256 is a list of Color256, which
       are normalized to [0, 255].
"""
    cdef ColorVector colors

    # Magic methods.
    def __cinit__(self, items=None):
        """Construct a ColorList with an iterator of items, each of which looks
           like a Color."""
        if items is not None:
            if isinstance(items, ColorList{suffix}):
                self.colors = (<ColorList{suffix}> items).colors
            else:
                # A list of tuples, Colors or strings.
                self.colors.resize(len(items))
                for i, item in enumerate(items):
                    self[i] = item

    def __setitem__(self, object key, object x):
        cdef size_t length, slice_length
        cdef int begin, end, step, index
        cdef float r, g, b
        cdef ColorList{suffix} cl
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            if isinstance(x, ColorList{suffix}):
                cl = <ColorList{suffix}> x
            else:
                cl = ColorList{suffix}(x)
            if sliceIntoVector(cl.colors, self.colors, begin, end, step):
                return
            raise ValueError('attempt to assign sequence of one size '
                             'to extended slice of another size')
        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(index))
        try:
            if isinstance(x, str):
                x = Color{suffix}(x)
            r, g, b = x
            self.colors.setColor(index, r, g, b)
        except:
            raise ValueError('Can\'t convert ' + str(x) + ' to a color')

    def __getitem__(self, object key):
        cdef ColorS c
        cdef int index
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            cl = ColorList{suffix}()
            cl.colors = sliceVector(self.colors, begin, end, step)
            return cl

        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(key))

        c = self.colors[index]
        return Color{suffix}(c.red, c.green, c.blue)

    def __add__(ColorList{suffix} self, ColorList{suffix} cl):
        cdef ColorList{suffix} result = ColorList{suffix}()
        result.colors = self.colors
        appendInto(cl.colors, result.colors)
        return result

    def __iadd__(ColorList{suffix} self, ColorList{suffix} cl):
        appendInto(cl.colors, self.colors)
        return self

    def __mul__(object self, object other):
        # A little tricky because ColorList can appear on the left or the
        # right side of the argument.
        cdef size_t mult
        cdef ColorList{suffix} cl = ColorList{suffix}()
        if isinstance(self, ColorList{suffix}):
            cl.colors = (<ColorList{suffix}> self).colors
            mult = <size_t> other
        else:
            cl.colors = (<ColorList{suffix}> other).colors
            mult = <size_t> self
        duplicateInto(mult, cl.colors)
        return cl

    def __imul__(ColorList{suffix} self, size_t mult):
        duplicateInto(mult, self.colors)
        return self

    def __len__(self):
        return self.colors.size()

    def __repr__(self):
        return 'ColorList{suffix}(%s)' % str(self)

    def __richcmp__(ColorList{suffix} self, ColorList{suffix} other, int rcmp):
        return cmpToRichcmp(compareContainers(self.colors, other.colors), rcmp)

    def __sizeof__(ColorList{suffix} self):
        return self.colors.getSizeOf()

    def __str__(ColorList{suffix} self):
        return toString(self.colors).decode('ascii')

    # List operations.
    cpdef ColorList{suffix} append(ColorList{suffix} self, Color{suffix} c):
        """Append to the list of colors."""
        self.colors.push_back(c.color)
        return self

    cpdef ColorList{suffix} clear(self):
        """Resize the list of colors to 0."""
        self.colors.clear()
        return self

    cpdef ColorList{suffix} copy(self):
        """Resize a copy of this list."""
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        return cl

    cpdef size_t count(self, Color{suffix} color):
        """Return the number of times a color appears in this list."""
        return count(self.colors, color.color)

    cpdef ColorList{suffix} extend(ColorList{suffix} self, object values):
        """Extend the colors from an iterator."""
        appendInto(ColorList{suffix}(values).colors, self.colors)
        return self

    cpdef index(ColorList{suffix} self, Color{suffix} color):
        """Returns an index to the first occurance of that Color, or
           raises a ValueError if that Color isn't there."""
        cdef int id = indexOf(self.colors, color.color)
        if id >= 0:
            return id
        raise ValueError('Can\'t find color %s' % color)

    cpdef ColorList{suffix} insert(ColorList{suffix} self, int key,
                                   Color{suffix} color):
        """Insert a color before key."""
        insertBefore(self.colors, key, color.color)
        return self

    cpdef Color{suffix} pop(ColorList{suffix} self, int key = -1):
        """Pop the color at key."""
        cdef Color{suffix} result = Color{suffix}()
        if popAt(self.colors, key, result.color):
            return result
        raise IndexError('pop index out of range')

    cpdef ColorList{suffix} remove(self, Color{suffix} color):
        """Find and remove a specific color."""
        self.pop(self.index(color))
        return self

    cpdef ColorList{suffix} resize(ColorList{suffix} self, size_t size):
        """Set the size of the ColorList, filling with black if needed."""
        self.colors.resize(size)
        return self

    cpdef ColorList{suffix} reverse(self):
        """Reverse the colors in place."""
        reverse(self.colors)
        return self

    cpdef ColorList{suffix} rotate(self, int pos):
        """In-place rotation of the colors forward by `pos` positions."""
        rotate(self.colors, pos)
        return self

    cpdef ColorList{suffix} sort(self, object key=None, bool reverse=False):
        """Sort items."""
        if key is None:
            sortColors(self.colors)
            if reverse:
                self.reverse()
        else:
            self[:] = sorted(self, key=key, reverse=reverse)
        return self

    # Basic arithmetic operations.
    cpdef ColorList{suffix} add(ColorList{suffix} self, c):
        """Add into colors from either a number or a ColorList."""
        if isinstance(c, Number):
            addInto(<float> c, self.colors)
        else:
            addInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} div(ColorList{suffix} self, c):
        """Divide colors by either a number or a ColorList."""
        if isinstance(c, Number):
            divideInto(<float> c, self.colors)
        else:
            divideInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} mul(ColorList{suffix} self, c):
        """Multiply colors by either a number or a ColorList."""
        if isinstance(c, Number):
            multiplyInto(<float> c, self.colors)
        else:
            multiplyInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} pow(ColorList{suffix} self, float c):
        """Raise each color to the given power (gamma correction)."""
        if isinstance(c, Number):
            powInto(<float> c, self.colors)
        else:
            powInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} sub(ColorList{suffix} self, c):
        """Subtract either a number or a ColorList from the colors."""
        if isinstance(c, Number):
             subtractInto(<float> c, self.colors)
        else:
             subtractInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    # Arithmetic where "self" is on the right side.
    cpdef ColorList{suffix} rdiv(ColorList{suffix} self, c):
        """Right-side divide colors by either a number or a ColorList."""
        if isinstance(c, Number):
            rdivideInto(<float> c, self.colors)
        else:
            rdivideInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} rpow(ColorList{suffix} self, c):
        """Right-hand (reversed) call of pow()."""
        if isinstance(c, Number):
            rpowInto(<float> c, self.colors)
        else:
            rpowInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    cpdef ColorList{suffix} rsub(ColorList{suffix} self, c):
        """Right-side subtract either a number or a ColorList."""
        if isinstance(c, Number):
             rsubtractInto(<float> c, self.colors)
        else:
             rsubtractInto((<ColorList{suffix}> c).colors, self.colors)
        return self

    # Mutators corresponding to built-in operations.
    cpdef ColorList{suffix} abs(self):
        """Replace each color by its absolute value."""
        absInto(self.colors)
        return self

    cpdef ColorList{suffix} ceil(self):
        """Replace each color by its integer ceiling."""
        ceilInto(self.colors)
        return self

    cpdef ColorList{suffix} floor(self):
        """Replace each color by its integer floor."""
        floorInto(self.colors)
        return self

    cpdef ColorList{suffix} invert(self):
        """Replace each color by its complementary color."""
        invertColor(self.colors)
        return self

    cpdef ColorList{suffix} neg(self):
        """Negate each color in the list."""
        negateColor(self.colors)
        return self

    cpdef ColorList{suffix} round(self, uint digits=0):
        """Round each element in each color to the nearest integer."""
        roundColor(self.colors, digits)
        return self

    # Other mutators.
    cpdef ColorList{suffix} trunc(self):
        """Truncate each value to an integer."""
        truncColor(self.colors)
        return self

    cpdef ColorList{suffix} hsv_to_rgb(self):
        """Convert each color in the list from HSV to RBG."""
        hsvToRgbInto(self.colors, {base})
        return self

    cpdef ColorList{suffix} max_limit(self, float max):
        """Limit each color to be not greater than max."""
        if isinstance(max, Number):
            minInto(<float> max, self.colors)
        else:
            minInto((<ColorList{suffix}> max).colors, self.colors)
        return self

    cpdef ColorList{suffix} min_limit(self, float min):
        """Limit each color to be not less than min."""
        if isinstance(min, Number):
            maxInto(<float> min, self.colors)
        else:
            maxInto((<ColorList{suffix}> min).colors, self.colors)
        return self

    cpdef ColorList{suffix} rgb_to_hsv(self):
        """Convert each color in the list from RBG to HSV."""
        rgbToHsvInto(self.colors, {base})
        return self

    cpdef ColorList{suffix} zero(self):
        """Set all colors to black."""
        clearInto(self.colors)
        return self

    # Methods that do not change this ColorList.
    cpdef float distance2(ColorList{suffix} self, ColorList{suffix} x):
        """Return the square of the cartestian distance to another ColorList."""
        return distance2(self.colors, x.colors)

    cpdef float distance(ColorList{suffix} self, ColorList{suffix} x):
        """Return the cartestian distance to another ColorList."""
        return distance(self.colors, x.colors)

    cpdef Color{suffix} max(self):
        """Return the maximum values of each component."""
        cdef ColorS c = maxColor(self.colors)
        return Color{suffix}(c.red, c.green, c.blue)

    cpdef Color{suffix} min(self):
        """Return the minimum values of each component/"""
        cdef ColorS c = minColor(self.colors)
        return Color{suffix}(c.red, c.green, c.blue)

    @staticmethod
    def spread(*args):
        """Spreads!"""
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cdef Color{suffix} color
        cdef size_t last_number = 0

        def spread_append(item):
            nonlocal last_number
            if last_number:
                color = _toColor{suffix}(item)
                spreadAppend(cl.colors, last_number - 1, color.color)
                last_number = 0

        for a in args:
            if isinstance(a, Number):
                last_number += a
            else:
                last_number += 1
                spread_append(a)

        spread_append(None)
        return cl
