function isMatch=isFixedSize(varargin)



    nElements=nargin;





    flag=false(nElements,1);

    for i=1:nElements
        flag(i)=any(varargin{i}.VariableDims);
    end

    if any(flag)
        isMatch=true;
        return;
    end

    isMatch=isequal(varargin{:});

end
