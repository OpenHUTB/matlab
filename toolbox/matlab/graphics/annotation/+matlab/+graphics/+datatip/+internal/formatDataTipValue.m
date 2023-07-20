function formattedValue=formatDataTipValue(value,format)


    if isnumeric(value)


        valueToDisplay=[];
        for i=1:numel(value)
            if strcmpi(format,'auto')
                valueToDisplay(i)=string(sprintf('%g',value(i)));
            else
                valueToDisplay(i)=string(sprintf(format,value(i)));
            end
        end
        formattedValue=mat2str(valueToDisplay);
    elseif isstring(value)
        formattedValue=char(value);
    elseif iscategorical(value)
        formattedValue=char(value);
    elseif isdatetime(value)
        if~strcmpi(format,'auto')
            for i=1:numel(value)


                value(i)=datetime(value(i),'Format',format);
            end
        end
        formattedValue=datestr(value);
    elseif isduration(value)
        if~strcmpi(format,'auto')
            for i=1:numel(value)


                value(i)=duration(value(i),'Format',format);
            end
        end
        formattedValue=char(value);
    elseif islogical(value)
        formattedValue=char(string(value));
    elseif iscell(value)
        value=value{:};


        if~ischar(value)&&~isstring(value)&&numel(value)>1
            fdu=internal.matlab.datatoolsservices.FormatDataUtils;
            formattedValue=fdu.formatSingleDataForMixedView(value);
        else
            formattedValue=value;
        end
    elseif isobject(value)

        className=split(class(value),'.');
        objectDisplayName=className{end};
        if isprop(value,'DisplayName')&&~isempty(value.DisplayName)
            objectDisplayName=value.DisplayName;
        end
        formattedValue=objectDisplayName;
    else
        formattedValue=char(value);
    end
end