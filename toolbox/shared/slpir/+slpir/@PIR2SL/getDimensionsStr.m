
function dims=getDimensionsStr(~,hT)
    dims=[];
    if hT.isRecordType


        return;
    end

    dim=hT.getDimensions;
    if dim<=0
        return;
    end

    if length(dim)>1
        dims='[';
        for i=1:length(dim)
            if i>1
                dims=[dims,','];%#ok<AGROW>
            end
            dims=[dims,sprintf('%d',dim(i))];%#ok<AGROW>
        end
        dims=[dims,']'];
        return;
    end

    if hT.isArrayType
        if hT.isColumnVector
            dims=sprintf('[%d, 1]',dim);
            return;
        elseif hT.isRowVector
            dims=sprintf('[1, %d]',dim);
            return;
        end
    end

    dims=sprintf('%d',dim);
end