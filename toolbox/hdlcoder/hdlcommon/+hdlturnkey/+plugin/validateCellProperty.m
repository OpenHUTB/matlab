function validateCellProperty(value,propertyName,example)




    if iscell(value)
        if~isempty(value)
            for ii=1:length(value)
                a_value=value{ii};
                if~ischar(a_value)
                    error(message('hdlcommon:plugin:CellProperty',...
                    propertyName,example));
                end
            end
        end
    else
        error(message('hdlcommon:plugin:CellProperty',...
        propertyName,example));
    end
end