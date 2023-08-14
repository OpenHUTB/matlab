





function callbacks=i_getCallbacks(optArgs)
    modelInfoStructsVec=optArgs.ModelRefModelInfoStructsVec;
    numModels=length(modelInfoStructsVec);

    mdlCallbacks.ModelName={};
    mdlCallbacks.Callbacks={};
    mdlCallbacks(end)=[];

    blkCallbacks.BlkPaths={};
    blkCallbacks.Callbacks={};
    blkCallbacks(end)=[];

    portCallbacks.BlkPaths={};
    portCallbacks.Callbacks={};
    portCallbacks(end)=[];

    maskCallbacks.BlkPaths={};
    maskCallbacks(end)=[];


    allMdlCallbacks={'PreLoadFcn','PostLoadFcn','CloseFcn',...
    'PreSaveFcn','PostSaveFcn',...
    'InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn'};

    portCallbks={'ConnectionCallback'};

    for modelIdx=numModels:-1:1
        modelInfoStruct=modelInfoStructsVec(modelIdx);
        modelName=modelInfoStruct.Name;

        Simulink.variant.reducer.utils.assert(bdIsLoaded(modelName));

        for callbackId=1:numel(allMdlCallbacks)
            populateMdlCallbacks;
        end

        allBlks=modelInfoStruct.BlksSVCEMap.keys;
        allBlks=allBlks(logical(Simulink.variant.utils.i_cell2mat(modelInfoStruct.BlksSVCEMap.values)));

        for blkId=1:numel(allBlks)

            populateBlkCallbacks;
        end
    end

    callbacks=Simulink.variant.reducer.types.VRedCallback;

    callbacks.mdlCallbacks=mdlCallbacks;
    callbacks.blkCallbacks=blkCallbacks;
    callbacks.portCallbacks=portCallbacks;
    callbacks.maskCallbacks=maskCallbacks;


    function populateMdlCallbacks



        callbkStr=strtrim(get_param(modelName,allMdlCallbacks{callbackId}));
        if isempty(callbkStr)
            return;
        end
        idx=strcmp({mdlCallbacks.ModelName},modelName);
        if any(idx)
            mdlCallbacks(idx).Callbacks{end+1}=allMdlCallbacks{callbackId};
        else
            mdlCallbacks(end+1).ModelName=modelName;
            mdlCallbacks(end).Callbacks{1}=allMdlCallbacks{callbackId};
        end
    end


    function populateBlkCallbacks

        if Simulink.variant.reducer.utils.isBlockFromShippingLibrary(allBlks(blkId))
            return;
        end


        paramStructData=Simulink.internal.getBlkParametersAndCallbacks(allBlks{blkId},true);
        callbackData=paramStructData.cbk;

        nonEmptyCallbacks=cellfun(@(x)~isempty(x),callbackData.cbData);
        if any(nonEmptyCallbacks)
            blkCallbacks(end+1).BlkPaths=allBlks{blkId};
            callbackFcnNames=callbackData.fcns(nonEmptyCallbacks);

            callbackFcnNames=strrep(callbackFcnNames,'*','');

            if~isrow(callbackFcnNames)
                callbackFcnNames=callbackFcnNames';
            end
            blkCallbacks(end).Callbacks=callbackFcnNames;
        end


        phs=get_param(allBlks{blkId},'PortHandles');
        inportOutportH=[phs.Inport,phs.Outport];

        for portIdx=1:numel(inportOutportH)
            populatePortCallbacks;
        end



        if~strcmp(get_param(allBlks{blkId},'Mask'),'on')
            return;
        end

        maskcallbacks=get_param(allBlks{blkId},'MaskCallbacks');
        if any(cellfun(@(x)~isempty(x),maskcallbacks))
            maskCallbacks(end+1).BlkPaths=allBlks{blkId};
        end

        maskinit=get_param(allBlks{blkId},'MaskInitialization');
        if isempty(maskinit)
            return;
        end

        idx=strcmp({maskCallbacks.BlkPaths},allBlks{blkId});

        if any(idx)
            return;
        end

        maskCallbacks(end+1).BlkPaths=allBlks{blkId};


        function populatePortCallbacks
            if isempty(get_param(inportOutportH(portIdx),portCallbks{1}))
                return;
            end

            idx=strcmp({portCallbacks.BlkPaths},allBlks{blkId});

            if any(idx)
                return;
            end
            portCallbacks(end+1).BlkPaths=allBlks{blkId};
            portCallbacks(end).Callbacks{1}=portCallbks{1};
        end
    end

end


