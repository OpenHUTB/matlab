function dataHandler=convertDataTypeToLabelDataHandler(dataType)









    import com.mathworks.toolbox.slproject.project.metadata.label.data.implementations.*;

    persistent pDataHandlers pAvailableTypes pAvailableTypesString
    if isempty(pDataHandlers)

        pDataHandlers=[DoubleLabelDataHandler,...
        IntegerLabelDataHandler,...
        LogicalDataHandler,...
        StringLabelDataHandler];

        pAvailableTypesString='';
        commaSpace=', ';
        pAvailableTypes=cell(size(pDataHandlers));
        for idx=1:numel(pDataHandlers)
            pAvailableTypes{idx}=char(pDataHandlers(idx).getMatlabDataType());
            pAvailableTypesString=[pAvailableTypesString,...
            ', ',pAvailableTypes{idx}];%#ok<AGROW>
        end
        if~isempty(pAvailableTypesString)
            pAvailableTypesString=pAvailableTypesString(length(commaSpace)+1:end);
        end
    end

    [valid,ind]=ismember(dataType,pAvailableTypes);
    if valid
        dataHandler=pDataHandlers(ind);
        return
    end


    error(message('MATLAB:project:api:WrongLabelDataType',...
    dataType,pAvailableTypesString));

end
