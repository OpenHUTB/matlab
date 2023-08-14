function parameterPreviousValues=overrideParameters(executionContext,inParameterSet,variableParam,scenarioParameter)


    parameterPreviousValues=struct('blockPath',{},'value',{},'name',{});

    try
        tg=slrealtime;
        targetName=executionContext.targetName;
        applicationName=executionContext.applicationToRun;
        if(executionContext.realtimeWorkflow<=2)
            stm.internal.genericrealtime.checkTargetAndApplication(targetName,applicationName);
        end
        parameterToRestoreCount=1;
        parameterSet=[preprocessParameters(inParameterSet),preprocessParameters(variableParam),scenarioParameter];
        for i=1:length(parameterSet)
            p=parameterSet(i);
            if(executionContext.realtimeWorkflow<=2)
                prependMdlName=isempty(regexp(p.Source,['^',applicationName,'\/'],'once'));
                if~isempty(p.Source)&&prependMdlName
                    p.Source=[applicationName,'/',p.Source];
                end
            end

            try
                loc_readParameter(tg,p.Source,p.Name);
            catch ME


                error(message('stm:realtime:InvalidParameter',[p.Source,'/',p.Name]));
            end
            if~isempty(p.Value)

                parameterPreviousValues(parameterToRestoreCount).blockPath=p.Source;
                parameterPreviousValues(parameterToRestoreCount).value=...
                loc_readParameter(tg,p.Source,p.Name);
                parameterPreviousValues(parameterToRestoreCount).name=p.Name;
                parameterToRestoreCount=parameterToRestoreCount+1;
                v=p.Value;
                loc_writeParameter(tg,v,p.Source,p.Name);
            end
        end
    catch ME
        rethrow(ME);
    end

end

function paramSet=preprocessParameters(pSet)
    paramSet=struct('Name',{},'Source',{},'Value',{});
    for i=1:length(pSet)
        paramSet(i).Name=pSet(i).Name;
        paramSet(i).Source=pSet(i).Source;
        if isfield(pSet(i),'RuntimeValue')&&~isempty(pSet(i).RuntimeValue)
            if ischar(pSet(i).RuntimeValue)||isstring(pSet(i).RuntimeValue)
                paramSet(i).Value=evalin('base',pSet(i).RuntimeValue);
            else
                paramSet(i).Value=pSet(i).RuntimeValue;
            end
        else
            if ischar(pSet(i).Value)||isstring(pSet(i).Value)
                if~isempty(pSet(i).Value)
                    paramSet(i).Value=evalin('base',pSet(i).Value);
                else
                    paramSet(i).Value=[];
                end
            else
                paramSet(i).Value=pSet(i).Value;
            end
        end
    end
end

function val=loc_readParameter(tg,source,name)
    if~isempty(source)
        val=tg.getparam(source,name);
    else
        val=tg.getparam('',name);
    end
end

function loc_writeParameter(tg,val,source,name)
    if~isempty(source)
        tg.setparam(source,name,val);
    else
        tg.setparam('',name,val);
    end
end
