
function allParameters=getAllParameters(modelName)




    allParameters.Name={};
    allParameters.Source={};

    acceptableType={'double','Simulink.Parameter','Simulink.LookupTable','Simulink.Breakpoint'};
    vars_baseWkspc=Simulink.findVars(modelName,'SourceType','base workspace');
    for i=1:length(vars_baseWkspc)


        dt=Simulink.data.evalinGlobal(modelName,['class(',vars_baseWkspc(i).Name,')']);
        if(any(strcmp(acceptableType,dt)))
            allParameters.Name{end+1}=vars_baseWkspc(i).Name;
            allParameters.Source{end+1}='base workspace';
        end
    end

    vars_sldd=Simulink.findVars(modelName,'SourceType','data dictionary');
    for i=1:length(vars_sldd)


        sldd=vars_sldd(i).Source;
        ddObj=Simulink.data.dictionary.open(sldd);
        dDataSectObj=getSection(ddObj,'Design Data');
        dt=evalin(dDataSectObj,['class(',vars_sldd(i).Name,')']);
        if(any(strcmp(acceptableType,dt)))
            allParameters.Name{end+1}=vars_sldd(i).Name;
            allParameters.Source{end+1}=sldd;
        end
    end
end

