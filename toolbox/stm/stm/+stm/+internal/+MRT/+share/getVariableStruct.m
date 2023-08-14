
function paraList=getVariableStruct(vars,originalModel,harnessName)
    topModel=getTopModel(originalModel,harnessName);
    paraList=struct(...
    'Name',{vars.Name},...
    'TopModel',topModel,...
    'ModelName',topModel,...
    'SourceType',{vars.SourceType},...
    'ModelElement',{vars.Users},...
    'Value','',...
    'HarnessName',harnessName,...
    'ValueType','',...
    'Source','',...
    'SIDFullString','',...
    'IsMask',false);


    slddMap=containers.Map;
    slddList=[];
    for x=numel(vars):-1:1
        var=vars(x);
        runtimeValue=[];
        addRuntimeValue=true;
        if strcmp(var.SourceType,'base workspace')
            runtimeValue=evalin('base',var.Name);
        elseif strcmp(var.SourceType,'model workspace')
            paraList(x).ModelName=var.Source;
            hModelWorkspace=get_param(var.Source,'modelworkspace');
            runtimeValue=hModelWorkspace.getVariable(var.Name);
        elseif endsWith(lower(var.Source),'.sldd')
            if slddMap.isKey(var.Source)
                idx=slddMap(var.Source);
                dataDictionary=slddList(idx);
            else
                nTotal=slddMap.Count;
                assert(nTotal==length(slddList));
                try
                    dataDictionary=Simulink.data.dictionary.open(var.Source);
                    slddList=[slddList,dataDictionary];
                    slddMap(var.Source)=nTotal+1;
                catch err
                    throw(err);
                end
            end
            dds=dataDictionary.getSection('Design Data');
            name=var.Name;
            if dds.exist(name)
                entry=dds.getEntry(name);
            else
                paraList(x)=[];
                continue;
            end
            runtimeValue=entry.getValue();
            paraList(x).SourceType=entry.DataSource;
            paraList(x).Source=which(var.Source);
        elseif strcmp(var.SourceType,'mask workspace')
            source=var.Source;
            name=var.Name;
            maskParam=stm.internal.MRT.share.getMaskParameter(source,name);
            if isempty(maskParam)


                paraList(x)=[];
                continue;
            else
                paraList(x).IsMask=true;
                paraList(x).Source=source;
                paraList(x).SIDFullString=get_param(source,'SIDFullString');
                paraList(x).ModelElement={source};
                paraList(x).Value=maskParam.Value;
                paraList(x).ValueType=0;
                addRuntimeValue=false;
            end
        end

        if~isValidType(runtimeValue)
            paraList(x)=[];
            continue;
        end

        if addRuntimeValue
            paraList(x).RuntimeValue=runtimeValue;
            [canShow,paraList(x).Value]=stm.internal.util.getDisplayValue(runtimeValue);
            if isa(runtimeValue,'Simulink.Parameter')
                canShow=false;
            end
            paraList(x).ValueType=double(~canShow);
        end
    end

    closeSlddList(slddList);
end

function closeSlddList(slddList)
    arrayfun(@(sldd)sldd.close,slddList);
end

function valid=isValidType(runtimeValue)
    valid=~isa(runtimeValue,'Simulink.ConfigSet');
end

function topModel=getTopModel(model,harness)
    ind=strfind(harness,'%%%');
    if isempty(ind)
        topModel=model;
    else
        topModel=harness(1:ind-1);
    end
end
