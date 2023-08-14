function this=addElementWithoutChecking(this,varargin)

















































    [varargin{:}]=convertStringsToChars(varargin{:});


    max_idx=this.numElements()+1;
    narginchk(2,4);
    if length(varargin)==1

        idx=max_idx;
        element=varargin{1};
        opts={};
    elseif isscalar(varargin{1})&&isnumeric(varargin{1})



        if length(varargin)==2&&ischar(varargin{2})
            idx=max_idx;
            element=varargin{1};
            opts=varargin(2:end);
        else
            idx=varargin{1};
            element=varargin{2};
            opts=varargin(3:end);
        end
    else


        idx=max_idx;
        element=varargin{1};
        opts=varargin(2:end);
    end

    element=this.convertToTransparentElementIfNeeded(element,opts);

    try
        this=copyStorageIfNeededBeforeWrite(this);
        this.Storage_=this.Storage_.addElements(idx,element);
    catch me
        throwAsCaller(me);
    end
end
