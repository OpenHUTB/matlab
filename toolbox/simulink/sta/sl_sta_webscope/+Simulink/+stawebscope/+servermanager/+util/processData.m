function out=processData(data,metaStruct)







    if isstruct(data)
        data=data.value;
    end

    if iscell(data)
        data=data{1};
    end

    if ischar(data)&&~any(strcmp(metaStruct.DataType,{'logical','boolean'}))
        if isfield(metaStruct,'isEnum')&&metaStruct.isEnum


            castFcn=str2func(metaStruct.DataType);
            out=double(castFcn(data));
        elseif metaStruct.isString
            out=data;
        else
            out=str2double(data);
        end
    elseif isstring(data)&&metaStruct.isString
        out=data;
    elseif any(strcmp(metaStruct.DataType,{'logical','boolean'}))

        if ischar(data)
            data=str2num(data);
        end

        diff_1=abs(data-1);
        diff_0=abs(data);
        if diff_0<diff_1

            out=false;
        else

            out=true;
        end
    elseif strcmp(metaStruct.DataType,'fcn_call')
        out=double(uint32(data));
    else
        out=double(slwebwidgets.doSLCast(data,metaStruct.DataType));
    end

end
