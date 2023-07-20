

function[checks,tasks]=applyProcessCallback(checks,tasks)
    cm=DAStudio.CustomizationManager;

    processCallBackFunList=cm.getModelAdvisorProcessFcns;
    if length(processCallBackFunList)>1
        MSLDiagnostic('Simulink:tools:MADupProcessCallback').reportAsWarning;
    end

    if~isempty(processCallBackFunList)
        if isempty(bdroot)
            temp_system=new_system('','model');
            [checks,tasks]=processCallBackFunList{1}('configure',temp_system,checks,tasks);
            close_system(temp_system);
        else

            activeMAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if isa(activeMAObj,'Simulink.ModelAdvisor')
                systemName=activeMAObj.SystemName;
            else
                systemName=bdroot;
            end
            [checks,tasks]=processCallBackFunList{1}('configure',systemName,checks,tasks);
        end
    end
end