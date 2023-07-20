function[out,is_uniform_type]=flattenVariable(value)




    out=[];
    is_uniform_type=true;
    if iscell(value)

        for i=1:numel(value)
            [r1,r2]=slci.internal.flattenVariable(value{i});
            if~isempty(out)
                is_uniform_type=is_uniform_type&&r2&&strcmp(class(out),class(r1));
            else
                is_uniform_type=r2;
            end
            out=[out,r1];%#ok
        end
    elseif Simulink.data.isSupportedEnumClass(class(value))

        out=reshape(double(value),1,numel(value));
    elseif numel(value)>1

        if isnumeric(value)
            out=reshape(double(value),1,numel(value));
        else
            for i=1:numel(value)
                [r1,r2]=slci.internal.flattenVariable(value(i));
                if~isempty(out)
                    is_uniform_type=is_uniform_type&&r2&&strcmp(class(out),class(r1));
                else
                    is_uniform_type=r2;
                end
                out=[out,r1];%#ok                
            end
        end
    elseif isstruct(value)

        cellArray=struct2cell(value);
        [tmp,is_uniform_type]=slci.internal.flattenVariable(cellArray);
        out=[out,double(tmp)];
    elseif slcifeature('MdlRefLUTObjSupport')==1&&isa(value,'Simulink.LookupTable')

        type='';
        order=strsplit(get_param(bdroot,'LUTObjectStructOrderExplicitValues'),',');
        for i=1:numel(order)
            switch order{i}
            case 'Size'
                [out,is_uniform_type,type]=flattenLUTObjTunableSize(value,out,is_uniform_type,type);
            case 'Table'
                [out,is_uniform_type,type]=flattenLUTObjTable(value,out,is_uniform_type,type);
            otherwise
                assert(strcmp(order{i},'Breakpoints'));
                [out,is_uniform_type,type]=flattenLUTObjBreakpoints(value,out,is_uniform_type,type);
            end
        end
    else

        out=[out,double(value)];
    end
end


function[out,is_uniform_type,type]=flattenLUTObjTunableSize(value,out,is_uniform_type,type)
    if value.SupportTunableSize
        for i=1:numel(value.Breakpoints)
            [r1,~]=slci.internal.flattenVariable(numel(value.Breakpoints(i).Value));
            out=[out,r1];%#ok<AGROW>
        end
        if isempty(type)
            type='uint32';
        else
            is_uniform_type=is_uniform_type&&strcmp(type,'uint32');
        end
    end
end


function[out,is_uniform_type,type]=flattenLUTObjBreakpoints(value,out,is_uniform_type,type)
    for i=1:numel(value.Breakpoints)
        [r1,~]=slci.internal.flattenVariable(value.Breakpoints(i).Value);
        if isempty(type)
            type=value.Breakpoints(i).DataType;
        else
            is_uniform_type=is_uniform_type&&strcmp(type,value.Breakpoints(i).DataType);
        end
        out=[out,r1];%#ok<AGROW>
    end
end


function[out,is_uniform_type,type]=flattenLUTObjTable(value,out,is_uniform_type,type)
    [r1,~]=slci.internal.flattenVariable(value.Table.Value);
    if isempty(type)
        type=value.Table.DataType;
    else
        is_uniform_type=is_uniform_type&&strcmp(type,value.Table.DataType);
    end
    out=[out,r1];
end
