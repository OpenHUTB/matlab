function s=formatConstValStr(value)





    if ischar(value)

        s=['''',value,''''];
    elseif isa(value,'embedded.numerictype')||isa(value,'embedded.fi')||...
        isa(value,'embedded.fimath')
        s=value.tostring;
    elseif isa(value,'struct')
        if~isscalar(value)

            s='[';
            [length_x,length_y]=size(value);
            for ii=1:length_x
                for jj=1:length_y
                    s=strcat(s,internal.mtree.formatConstValStr(value(ii,jj)));
                    if jj~=length_y
                        s=strcat(s,',');
                    end
                end
                if ii~=length_x
                    s=strcat(s,';');
                end
            end
            s=strcat(s,']');
        else
            fieldNames=fields(value);
            fieldStrs=cell(1,numel(fieldNames));

            for i=1:numel(fieldNames)
                fieldValStr=internal.mtree.formatConstValStr(value.(fieldNames{i}));
                fieldStrs{i}=sprintf('''%s'', %s',fieldNames{i},fieldValStr);
            end

            s=sprintf('struct(%s)',strjoin(fieldStrs,', '));
        end
    elseif iscell(value)
        cellStrs=cell(1,numel(value));

        for i=1:numel(value)
            cellStrs{i}=internal.mtree.formatConstValStr(value{i});
        end

        s=sprintf('{%s}',strjoin(cellStrs,', '));
    else
        if isa(value,'half')
            s=formatNumericValue('half',single(value));
        else
            s=formatNumericValue(class(value),value);
        end
    end
end

function str=formatNumericValue(valClass,val)
    valSize=size(val);



    if~isempty(val)&&~isscalar(val)&&...
        all(val(1)==val,'all')
        firstValStr=formatNumericValue(valClass,val(1));
        str=sprintf('repmat(%s, %s)',firstValStr,mat2str(valSize));
        return
    end




    if numel(valSize)>2
        numVals=numel(val);
        valStr1D=formatNumericValue(valClass,reshape(val,1,numVals));
        str=sprintf('reshape(%s, %s)',valStr1D,mat2str(valSize));
        return
    end


    lowerPrecisionStr=sprintf('%s(%s)',valClass,mat2str(val));
    if isequal(cast(val,valClass),eval(lowerPrecisionStr))
        str=lowerPrecisionStr;
        return
    end




    if isscalar(val)
        str=sprintf('%s(%s)',valClass,coder.internal.compactButAccurateNum2Str(val));
        return;
    end



    [nRows,nCols]=size(val);
    rowStrs=cell(1,nRows);
    for i=1:nRows
        colStrs=cell(1,nCols);

        for j=1:nCols
            colStrs{j}=coder.internal.compactButAccurateNum2Str(val(i,j));
        end

        rowStrs{i}=strjoin(colStrs,', ');
    end

    str=sprintf('%s([%s])',valClass,strjoin(rowStrs,'; '));
end
