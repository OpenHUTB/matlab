function out=formatDDGSchema(schema)



    out=loc_format(schema);

    function schema=loc_format(schema)

        if isfield(schema,'Items')
            for i=1:length(schema.Items)
                item=schema.Items{i};
                schema.Items{i}=loc_format(item);
            end
        elseif isfield(schema,'Tabs')
            for i=1:length(schema.Tabs)
                tab=schema.Tabs{i};
                schema.Tabs{i}=loc_format(tab);
            end
        elseif isfield(schema,'Value')&&isfield(schema,'Type')
            type=schema.Type;
            value=schema.Value;


            if strcmp(type,'checkbox')
                if ischar(value)
                    if strcmp(value,'0')||strcmp(value,'off')
                        value=false;
                    else
                        value=true;
                    end
                end
            end




            if strcmp(type,'edit')
                if isnumeric(value)&&isscalar(value)
                    str=sprintf('%.6g',value);
                    value=str2double(str);
                end
            end

            schema.Value=value;
        end
