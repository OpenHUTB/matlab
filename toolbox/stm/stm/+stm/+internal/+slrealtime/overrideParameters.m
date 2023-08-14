function parameterPreviousValues=overrideParameters(inParameterSet,variableParam,scenarioParameter,targetName,applicationName)


    parameterPreviousValues=struct('blockPath',{},'value',{},'name',{});

    try
        tg=slrealtime;
        stm.internal.slrealtime.checkTargetAndApplication(targetName,applicationName);
        parameterToRestoreCount=1;
        parameterSet=[preprocessParameters(inParameterSet),preprocessParameters(variableParam),scenarioParameter];
        for i=1:length(parameterSet)
            p=parameterSet(i);
            prependMdlName=isempty(regexp(p.Source,['^',applicationName,'\/'],'once'));
            if~isempty(p.Source)&&prependMdlName
                p.Source=[applicationName,'/',p.Source];
            end
            try
                if~isempty(p.Source)
                    tg.getparam(p.Source,p.Name);
                else

                    tg.getparam('',p.Name);
                end
            catch


                error(message('stm:realtime:InvalidParameter',[p.Source,'/',p.Name]));
            end
            if~isempty(p.Value)

                parameterPreviousValues(parameterToRestoreCount).blockPath=p.Source;
                if~isempty(p.Source)
                    parameterPreviousValues(parameterToRestoreCount).value=tg.getparam(p.Source,p.Name);
                else

                    parameterPreviousValues(parameterToRestoreCount).value=tg.getparam('',p.Name);
                end
                parameterPreviousValues(parameterToRestoreCount).name=p.Name;
                parameterToRestoreCount=parameterToRestoreCount+1;
                v=p.Value;
                if~isempty(p.Source)
                    tg.setparam(p.Source,p.Name,v);
                else

                    tg.setparam('',p.Name,v);
                end
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
        if ischar(pSet(i).Value)
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
