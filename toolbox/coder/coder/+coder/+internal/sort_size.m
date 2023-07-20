function sortedSizeVector=sort_size(part,varargin)








    sortedSizeVector=part;
    sizeLen=nargin-1;
    fixed_indices=zeros(sizeLen,1);
    variable_indices=zeros(sizeLen,1);
    fInc=1;
    vInc=1;
    for i=1:sizeLen

        if~any(varargin{i}.VariableDims)
            fixed_indices(fInc)=i;
            fInc=fInc+1;
        else
            variable_indices(vInc)=i;
            vInc=vInc+1;
        end
    end

    fixedLength=sum(fixed_indices>0);

    for i=1:sizeLen
        if(i<=fixedLength)
            sortedSizeVector{i}=part{fixed_indices(i)};
        else
            sortedSizeVector{i}=part{variable_indices(i-fixedLength)};
        end
    end


end
