function checkElementSpacing(obj,varargin)
    if nargin>1
        checkspacingdims(obj,varargin{1},obj.NumElements,'ElementSpacing');
    else
        checkspacingdims(obj,obj.ElementSpacing,obj.NumElements,'ElementSpacing');
    end
end