









function genCustomActionFromModel(mdl)

    targetBlockTypes='RoadRunnerScenario';


    mdl=char(mdl);
    [~,isresoved]=sls_resolvename(mdl);
    if isresoved&&(~bdIsLoaded(mdl))
        load_system(mdl);
        objCleanupModel=onCleanup(@()close_system(mdl,0));
    end

    allBlks=find_system(mdl,'Type','Block');


    targetBlks={};
    for idx=1:length(allBlks)
        blkType=get_param(allBlks{idx},'BlockType');
        if any(strcmpi(targetBlockTypes,blkType))
            targetBlks{end+1}=allBlks(idx);%#ok
        end
    end


    actDic=containers.Map;
    for idx=1:length(targetBlks)
        actstr=get_param(targetBlks{idx},'UserDefinedActions');
        actlist=eval(actstr{:});
        [nrows,~]=size(actlist);
        for idy=1:nrows
            if strcmp(actlist{idy,2},'Bus object')
                actDic(actlist{idy,1})=actlist{idy,3};
            end
        end
    end


    actkeys=actDic.keys;
    for idx=1:length(actkeys)
        actName=actkeys{idx};
        actBus=actDic(actName);
        builder=ssm.sl_agent_metadata.internal.CustomActionBuilder(...
        actBus,'outputFileName',[actName,'.seaction']);
        builder.ActionName=actName;
        builder.buildData;
        builder.writeToFile;
    end
end


