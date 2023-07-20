
function[labelDefTable,customLabelDef]=splitCustomLabelDefinitions(definitions)










    customLabelDef=struct('CustomLabelName',{},'CustomLabelGroup',{},'CustomLabelDesc',{});
    labelDefTable=table();
    if isempty(definitions)
        return
    end

    tableHeading=string(definitions.Properties.VariableNames);
    labelTypeColNames=["Type","LabelType"];
    labelTyleCol=labelTypeColNames(ismember(labelTypeColNames,tableHeading));

    for idx=1:height(definitions)

        if(definitions.(labelTyleCol)(idx)==labelType.Custom)


            if any(strcmp(definitions.Properties.VariableNames,'Description'))
                description=definitions.Description(idx);
            else
                description='';
            end
            customLabelDef(end+1)=struct('CustomLabelName',definitions.Name(idx),'CustomLabelGroup','None','CustomLabelDesc',description);%#ok<AGROW>
        else
            labelDefTable=[labelDefTable;definitions(idx,:)];%#ok<AGROW>
        end
    end
end