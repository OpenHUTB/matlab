







function badLabelNames=invalidNames(labelNames)
    reservedNames={...
    'pixellabeldata',...
    'defaultvalue',...
    'type',...
    'position',...
    'listitems',...
    'description',...
    'labelcolor',...
    };

    if~iscell(labelNames)&&ischar(labelNames)


        labelNames=cellstr(labelNames);
    end

    badLabelNames="";
    for nameIdx=1:size(labelNames)
        if ismember(lower(labelNames{nameIdx}),reservedNames)
            badLabelNames=badLabelNames+string(labelNames{nameIdx})+", ";
        end
    end

    if badLabelNames==""

        badLabelNames=[];
    end
end