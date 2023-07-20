classdef(Abstract)AbstractHighlighter<handle


    properties(SetAccess=protected)
Data
        IsDataEmpty=false;
    end

    properties
HLOptions
Description
    end

    properties(Access=protected)
style
    end

    methods(Abstract)
        highlight(this)
        removehighlight(this)
    end
end