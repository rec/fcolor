### comment
"""Basic methods for classes with a variable length (like a List)."""

### declare

cdef extern from "<$include_file>" namespace "$namespace":
    ctypedef vector[$itemclass] C$classname

    string toString(C$classname&)
    C$classname sliceOut(C$classname&, int begin, int end, int step)
    $itemclass max_cpp(C$classname&)
    $itemclass min_cpp(C$classname&)

    bool cmpToRichcmp(float cmp, int richcmp)
    $number_type compare(C$classname&, C$classname&)
    $number_type compare($itemclass&, C$classname&)
    $number_type compare($number_type, C$classname&)
    bool pop(C$classname&, int key, $itemclass&)
    bool resolvePythonIndex(int& index, size_t size)
    bool sliceInto(C$classname&, C$classname&, int begin, int end, int step)

    int index(C$classname&, $itemclass&)

    size_t count(C$classname&, $itemclass&)

    void erase(int key, C$classname&)
    void extend(C$classname&, C$classname&)
    void insert(int key, $itemclass&, C$classname)
    void rotate(C$classname&, int pos)
    void rotate(C$classname&, C$classname&, int pos)
    void sliceDelete(C$classname&, int begin, int end, int step)
    void sort(C$classname&)
    void sort(C$classname&, C$classname&, bool reverse)

### define
    def __init__($classname self, items=None):
        """Construct a $classname with an iterator of items, each of which looks
           like a $sampleclass."""
        cdef $sampleclass s
        cdef size_t i
        if items is not None:
            if isinstance(items, $classname):
                self.cdata = (<$classname> items).cdata
            else:
                # A list of tuples, $classname or strings.
                self.cdata.resize(len(items))
                for i, item in enumerate(items):
                    self.cdata[i] = $itemmaker(item)$itemgetter

    def __setitem__($classname self, object key, object x):
        cdef size_t length, slice_length
        cdef int begin, end, step, index
        cdef $classname cl
        if isinstance(key, slice):
            begin, end, step = key.indices(self.cdata.size())
            cl = x if isinstance(x, $classname) else $classname(x)
            if sliceInto(cl.cdata, self.cdata, begin, end, step):
                return
            raise ValueError('attempt to assign sequence of one size '
                             'to extended slice of another size')
        index = key
        if not resolvePythonIndex(index, self.cdata.size()):
            raise IndexError('$classname index out of range %s' % key)
        self.cdata[index] = $itemmaker(x)$itemgetter

    def __getitem__($classname self, object key):
        cdef $sampleclass s
        cdef $classname cl
        cdef int k, begin, end, step
        if isinstance(key, slice):
            begin, end, step = key.indices(self.cdata.size())
            cl = $classname()
            cl.cdata = sliceOut(self.cdata, begin, end, step)
            return cl
        k = key
        if not resolvePythonIndex(k, self.cdata.size()):
            raise IndexError('$classname index out of range %s' % key)
        s = $emptyitem
        s$itemgetter = self.cdata[k]
        return s

    def __delitem__($classname self, object key):
        cdef int k, begin, end, step
        if isinstance(key, slice):
            begin, end, step = key.indices(self.cdata.size())
            sliceDelete(self.cdata, begin, end, step)
        else:
            k = key
            if not resolvePythonIndex(k, self.cdata.size()):
                raise IndexError('$classname index out of range %s' % key)
            erase(k, self.cdata)

    def __len__($classname self):
        return self.cdata.size()

    def __richcmp__(object self, object other, int rcmp):
        cdef bool inv = not isinstance(self, $classname)
        cdef $number_type c, mult = 1
        if not inv:
            self, other = other, self
            mult = -1
        c = self._compare(other)
        return cmpToRichcmp(mult * c, rcmp)

    cpdef size_t count(self, $sampleclass sample):
        """Return the number of times a sample appears in this list."""
        return count(self.cdata, sample$itemgetter)

    cpdef $classname extend($classname self, object values):
        """Extend the samples from an iterator."""
        if isinstance(values, $classname):
            extend(self.cdata, (<$classname> values).cdata)
        else:
            for v in values:
                self.append(v)
        return self

    cpdef index($classname self, $sampleclass sample):
        """Returns an index to the first occurance of that Sample, or
           raises a ValueError if that Sample isn't there."""
        cdef int id = index(self.cdata, sample$itemgetter)
        if id >= 0:
            return id
        raise ValueError('Can\'t find sample %s' % sample)

    cpdef $classname insert($classname self, int key,
                           $sampleclass sample):
        """Insert a sample before key."""
        insert(key, sample$itemgetter, self.cdata)
        return self

    cpdef $sampleclass pop($classname self, int key = -1):
        """Pop the sample at key."""
        cdef $sampleclass result = $emptyitem
        if pop(self.cdata, key, result$itemgetter):
            return result
        raise IndexError('pop index out of range')

    cpdef $classname remove(self, $sampleclass sample):
        """Find and remove a specific sample."""
        self.pop(self.index(sample))
        return self

    cpdef $classname resize($classname self, size_t size):
        """Set the size of the SampleList, filling with black if needed."""
        self.cdata.resize(size)
        return self

    cpdef $classname rotate(self, int pos):
        """Return a new $classname with the samples rotated forward by `pos` positions."""
        cdef $classname out = $classname()
        rotate(self.cdata, out.cdata, pos)
        return out

    cpdef $classname rotate_into(self, int pos):
        """In-place rotation of the samples forward by `pos` positions."""
        rotate(self.cdata, pos)
        return self

    cpdef $classname rotate_to(self, int pos, $classname out):
        """Rotate the samples forward by `pos` positions to another $classname"""
        rotate(self.cdata, out.cdata, pos)
        return out

    def sort($classname self, object key=None, bool reverse=False):
        """Sort."""
        if key is None:
            sort(self.cdata)
            if reverse:
                self.reverse()
        else:
            # Use Python.
            self[:] = sorted(self, key=key, reverse=reverse)
        return self

    def sort_to($classname self, $classname out,
                object key=None, bool reverse=False):
        """Sort to another vector."""
        if key is None:
            sort(self.cdata, out.cdata, reverse)
        else:
            # Use Python.
            out[:] = sorted(self, key=key, reverse=reverse)
        return out