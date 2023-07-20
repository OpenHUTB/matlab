classdef DataSource<handle




    methods(Static,Access=public)
        function obj=create(modelName)
            dictionaryFile=get_param(modelName,'DataDictionary');
            if isempty(dictionaryFile)
                obj=Simulink.data.BaseWorkspace;
            else
                obj=Simulink.data.DataDictionary(dictionaryFile);
            end
        end
    end
end
