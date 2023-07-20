


function callbacks=getCallbacks(mdlAndItsBlks)

    mdlCallbacks=struct('ModelName','','Callbacks',{});
    blkCallbacks=struct('BlkPaths',{},'Callbacks',{});
    portCallbacks=struct('BlkPaths',{},'Callbacks',{});
    maskCallbacks=struct('BlkPaths',{});


    mdlCallBackTypes={'PreLoadFcn','PostLoadFcn','CloseFcn',...
    'PreSaveFcn','PostSaveFcn',...
    'InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn'};

    for modelIdx=1:length(mdlAndItsBlks)
        modelName=mdlAndItsBlks(modelIdx).ModelName;
        Simulink.variant.reducer.utils.assert(bdIsLoaded(modelName));

        for callbackId=1:numel(mdlCallBackTypes)
            populateMdlCallbacks;
        end

        allBlks=mdlAndItsBlks(modelIdx).Blocks;

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



        callbkStr=strtrim(get_param(modelName,mdlCallBackTypes{callbackId}));
        if isempty(callbkStr)
            return;
        end
        idx=strcmp({mdlCallbacks.ModelName},modelName);
        if any(idx)
            mdlCallbacks(idx).Callbacks{end+1}=mdlCallBackTypes{callbackId};
        else
            mdlCallbacks(end+1).ModelName=modelName;
            mdlCallbacks(end).Callbacks{1}=mdlCallBackTypes{callbackId};
        end
    end


    function populateBlkCallbacks

        if Simulink.variant.reducer.utils.isBlockFromShippingLibrary(allBlks(blkId))
            return;
        end

        if isStateflowBlock(allBlks{blkId})
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
            portCallbackType='ConnectionCallback';
            if isempty(get_param(inportOutportH(portIdx),portCallbackType))
                return;
            end


            idx=strcmp({portCallbacks.BlkPaths},allBlks{blkId});
            if any(idx)
                return;
            end
            portCallbacks(end+1).BlkPaths=allBlks{blkId};
            portCallbacks(end).Callbacks{1}=portCallbackType;
        end
    end
end

function status=isStateflowBlock(x)
    status=false;
    p=get_param(x,'Parent');
    if isempty(p)
        return;
    end
    status=slprivate('is_stateflow_based_block',get_param(p,'Handle'));
end
