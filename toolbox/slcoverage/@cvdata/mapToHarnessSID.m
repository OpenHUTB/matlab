function ssid=mapToHarnessSID(this,ssid)




    if isempty(ssid)
        return;
    end

    modelcovId=cv('get',this.rootId,'.modelcov');
    [ownerBlock,harnessName]=cv('get',modelcovId,'.ownerBlock','.harnessModel');
    if isempty(ownerBlock)||isempty(cv('GetRootPath',this.rootId))

        return;
    end

    blocks_SSID_inOwner=ssid;
    ownerModelName=bdroot(ownerBlock);
    blockParents=bdroot(blocks_SSID_inOwner);
    needsMapped=strcmp(ownerModelName,blockParents);
    if~any(needsMapped)

        return;
    end


    blocks_SSID_inOwner=blocks_SSID_inOwner(needsMapped);

    harnessInfo=Simulink.harness.internal.getActiveHarness(ownerModelName);
    if isempty(harnessInfo)||~strcmp(harnessInfo.name,harnessName)

        return;
    end

    if~iscell(blocks_SSID_inOwner)
        blocks_SSID_inOwner={blocks_SSID_inOwner};
    end
    blocks_SSID_Mapped=cellfun(@(ssid)mapSSIDFromModelToHarness(ssid,harnessInfo),blocks_SSID_inOwner,'UniformOutput',false);

    if~iscell(ssid)
        ssid=blocks_SSID_Mapped{1};
    else
        ssid(needsMapped)=blocks_SSID_Mapped;
    end
end

function blockSSID_inHarness=mapSSIDFromModelToHarness(blockSSID_inOwner,harnessInfo)
    blockSSID_inHarness=blockSSID_inOwner;
    try
        blockObject_inOwner=cvi.TopModelCov.getObject(blockSSID_inOwner);
        if isempty(blockObject_inOwner)
            return;
        end

        if contains(class(blockObject_inOwner),'Stateflow.')
            chartObj=blockObject_inOwner.Chart;
            newChartSSID=mapSSIDFromModelToHarness(Simulink.ID.getSID(chartObj),harnessInfo);
            newChartModelObject=getObject(newChartSSID);
            chart=newChartModelObject.find('-isa','Stateflow.Chart');
            newModelObject=chart.find('SSIdNumber',blockObject_inOwner.SSIdNumber);
            blockSSID_inHarness=Simulink.ID.getSID(newModelObject);
        else
            subsysPath=harnessInfo.ownerFullPath;
            blockPath_inOwner=blockObject_inOwner.getFullName;
            if contains(blockPath_inOwner,subsysPath)

                harnessModel=harnessInfo.name;
                [~,subsysName]=fileparts(subsysPath);
                if strcmp(subsysPath,blockPath_inOwner)

                    blockPath_relative='';
                else
                    blockPath_relative=blockPath_inOwner(numel(subsysPath)+1:end);
                end
                blockPath_inHarness=[harnessModel,'/',subsysName,blockPath_relative];
                blockSSID_inHarness=Simulink.ID.getSID(blockPath_inHarness);
            end
        end
    catch SlCovExcpt %#ok<NASGU>
        blockSSID_inHarness=blockSSID_inOwner;
    end
end
