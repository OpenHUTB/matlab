

classdef(Sealed)BindableRow<handle

    properties
        isConnected logical;
        bindableTypeChar char;
        bindableName char;
        bindableMetaData BindMode.BindableMetaData;
    end
    properties(Hidden)
        bindableType BindMode.BindableTypeEnum;
    end
    methods
        function row=BindableRow(isConnected,bindableType,bindableName,bindableMetaData)
            row.isConnected=isConnected;
            row.bindableType=bindableType;
            row.bindableTypeChar=row.bindableType.char;
            if(~isempty(bindableName))
                row.bindableName=bindableName;
            else
                row.bindableName=bindableMetaData.name;
            end
            row.bindableMetaData=bindableMetaData;
        end
    end
end