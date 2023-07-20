


function[varUsage,variableUsage]=getVarUsage(variableUsage,modelToRun,modelName)
    [variableUsage.TopModel]=deal('');
    variableUsage=slddSplit(variableUsage,modelToRun,modelName);
    source=string({variableUsage.Source});
    sourceType={variableUsage.SourceType};


    idx=sourceType=="mask workspace";
    source(idx)=source(idx).extractBefore('/');


    idx=sourceType~="model workspace"&sourceType~="data dictionary";
    source(idx)=modelToRun;



    idx=sourceType=="data dictionary";
    source(idx)=string({variableUsage(idx).TopModel});



    varUsage={variableUsage.Name}+"/"+source;
end

function ret=slddSplit(variableUsage,modelToRun,modelName)



    ret=variableUsage;
    for x=1:numel(variableUsage)
        usage=variableUsage(x);
        if usage.SourceType=="data dictionary"
            ret(x).TopModel=getTopModel(usage.Users{1});
            for y=2:numel(usage.Users)
                usage.TopModel=getTopModel(usage.Users{y});
                ret=[ret,usage];
            end

            if~any(contains(usage.Users,modelToRun))




                duplicate=usage;
                duplicate.TopModel=modelToRun;
                replace(usage.Users,modelToRun,modelName);
                ret=[ret,duplicate];
            end
        end
    end
end

function topModel=getTopModel(user)
    topModel=extractBefore(user,'/');
    if strlength(topModel)==0
        topModel=user;
    end
end
