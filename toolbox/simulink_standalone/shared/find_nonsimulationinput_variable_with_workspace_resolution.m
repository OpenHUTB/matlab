function[varValue,varWasFound]=find_nonsimulationinput_variable_with_workspace_resolution(varName,model)
    try
        varValue=findVariableInModelWorkspace(model,varName);
        varWasFound=true;
    catch
        try
            varValue=findVariableInDataDictionary(model,varName);
            varWasFound=true;
        catch
            try
                varValue=evalin('base',varName);
                varWasFound=true;
            catch
                varValue=[];
                varWasFound=false;
                return
            end
        end
    end
end



function result=findVariableInModelWorkspace(model,varName)
    if~Simulink.isRaccelDeployed
        mdlWS=get_param(model,'ModelWorkspace');
        mdlWSIsDirty=mdlWS.isDirty;
        oc1=onCleanup(@()set(mdlWS,'isDirty',mdlWSIsDirty));
        result=evalin(mdlWS,varName);
    else
        mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
        modelWorkspaceStruct=mi.getModelWorkspaceStruct();
        result=modelWorkspaceStruct.(varName);
    end
end



function result=findVariableInDataDictionary(model,varName)
    dataDictionaryName=get_param(model,'DataDictionary');
    dataDictionary=Simulink.data.dictionary.open(dataDictionaryName);
    designData=getSection(dataDictionary,'Design Data');
    result=evalin(designData,varName);
end
