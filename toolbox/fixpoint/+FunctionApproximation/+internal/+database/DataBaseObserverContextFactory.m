classdef DataBaseObserverContextFactory<handle




    methods
        function context=getContextFromOptionsData(~,optionsData)



            context=FunctionApproximation.internal.database.DataBaseObserverContext();
            mc=metaclass(context);
            propList=mc.Properties;
            for k=1:length(propList)
                if~propList{k}.Dependent&&~propList{k}.Constant
                    context.(propList{k}.Name)=optionsData.(propList{k}.Name);
                end
            end
        end
    end
end