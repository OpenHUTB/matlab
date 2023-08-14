function out=removeProtectedParams(model,params)




    import Simulink.ModelReference.ProtectedModel.*;
    out={};
    if~isempty(model)&&bdIsLoaded(model)
        creator=getCreatorDuringProtection(model);



        currentMode=getCurrentModeIfDoingCodegen(model);
        if~isempty(creator)&&~creator.AreAllParameterAccessible()&&...
            strcmp(currentMode,'RTW')||strcmp(currentMode,'NONE')

            accessibleVar=creator.getAccessibleParameters();
            for i=1:length(params)
                if isempty(intersect(params{i}.Identifier,accessibleVar))
                    out{end+1}=params{i};%#ok<AGROW>
                end
            end
            return;
        end
    end
    out=params;
end
