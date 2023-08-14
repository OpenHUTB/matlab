classdef OptionsDataFactory<handle






    methods
        function optionsData=getOptionsDataFromOptions(~,options)
            optionsData=FunctionApproximation.internal.option.OptionsData();
            mc=metaclass(optionsData);
            propList=mc.Properties;
            for k=1:length(propList)
                if~propList{k}.Dependent&&~propList{k}.Constant
                    optionsData.(propList{k}.Name)=options.(propList{k}.Name);
                end
            end
        end
    end
end