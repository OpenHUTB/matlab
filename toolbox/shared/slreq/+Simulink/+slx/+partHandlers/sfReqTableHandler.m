function h=sfReqTableHandler(~)
    h=Simulink.slx.PartHandler(i_id(),'blockDiagram',@i_load,@i_save);
end

function id=i_id
    id='SfReqTable';
end

function i_load(modelHandle,loadOptions)


    partName=slreq.internal.generatePartName(loadOptions);
    matchingNames=loadOptions.readerHandle.getMatchingPartNames(partName);
    modelSids={};
    for i=1:length(matchingNames)
        partName=matchingNames{i};

        if endsWith(partName,'/data.xml')
            parts=strsplit(matchingNames{i},'/');
            if parts{end}=="data.xml"
                modelSids{end+1}=parts{end-1};%#ok<AGROW> 
            end
        end
    end

    if~isempty(modelSids)

        if sf('feature','SLReqIntegration')

            modelName=getfullname(modelHandle);
            if Simulink.harness.isHarnessBD(modelHandle)


                topModelName=get_param(modelHandle,'OwnerBDName');
            else

                topModelName=modelName;
            end
            reqData=slreq.data.ReqData.getInstance();

            assert(numel(modelSids)==1);
            partOptions.modelSid=modelSids{1};
            partOptions.loadOptions=loadOptions;
            reqSetName=[modelName,'_',modelSids{1}];
            reqSet=reqData.loadReqSet(reqSetName,partOptions);

            reqSet.parent=[topModelName,'.slx'];
            reqSet.setModelSid(modelSids{1});


            slreq.data.ReqData.getInstance.addToSfReqSetMap(modelHandle,reqSetName);

            lsm=slreq.linkmgr.LinkSetManager.getInstance();
            lsm.scanMATLABPathOnSlreqInit(lsm.METADATA_SCAN_INIT_MODE_API);
        end
    end
end

function i_save(modelHandle,saveOptions)




    if~SLM3I.SLCommonDomain.isStateflowLoaded()
        return
    end

    if~sf('feature','SLReqIntegration')
        return
    end




    if~slreq.data.ReqData.exists()
        return;
    end

    slReqService=slreq.data.SLService();
    reqSet=slReqService.reconcileEmbeddedReqsetName(modelHandle);
    if isempty(reqSet)
        return;
    end

    asVersion='';
    reqData=slreq.data.ReqData.getInstance();
    reqData.saveReqSet(reqSet,[],asVersion,saveOptions);
end

