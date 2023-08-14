classdef DataDictionaryState<handle


    properties(SetAccess=immutable,GetAccess=public)
        DataDictionary;
        Dirty;
    end

    methods(Static)
        function obj=DataDictionaryState(dataDictionary)
            obj.DataDictionary=dataDictionary;
            try
                obj.Dirty=dataDictionary.HasUnsavedChanges;
            catch
                obj.Dirty=dataDictionary.hasUnsavedChanges;
            end
        end
    end
end
