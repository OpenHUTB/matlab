function hisf_0017

    rec=getNewCheckObject('mathworks.hism.hisf_0017',false,@hCheckAlgo,'None');

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)

    violations={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    systemObj=get_param(bdroot(system),'object');

    allSfObjs=systemObj.find('-isa','Stateflow.Data');
    allData=mdladvObj.filterResultWithExclusion(allSfObjs);


    for i=1:length(allData)
        scope=allData(i).Scope;
        if strcmp(scope,'Local')
            dataId=allData(i).Id;
            parentId=sf('ParentOf',dataId);
            if isa(idToHandle(sfroot,parentId),'Stateflow.Machine')
                violations{end+1}=allData(i);%#ok<AGROW>
            end
        end
    end

end
