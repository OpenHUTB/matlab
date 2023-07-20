




function modelReloadBusesOnOpen(model)
    mws=get_param(model,'ModelWorkspace');
    requiredMWSElements=["TxTree","RxTree"];
    if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))

        preserveDirtyFlag=feval('Simulink.PreserveDirtyFlag',bdroot(model),'blockDiagram');%#ok<NASGU,FVAL>

        modelHandle=get_param(model,'handle');
        TxTree=mws.getVariable('TxTree');
        RxTree=mws.getVariable('RxTree');


        TxTree.modelHandle=modelHandle;
        RxTree.modelHandle=modelHandle;

        TxTree.createStructsAndParameters();
        TxTree.clearUndoStack
        RxTree.createStructsAndParameters();
        RxTree.clearUndoStack
    end


    if mws.hasVariable('SerdesIBIS')
        SerdesIBIS=mws.getVariable('SerdesIBIS');
        ibisModels=SerdesIBIS.Models;
        for indx=1:length(ibisModels)
            calculateModelData(ibisModels(indx))
        end
    end

    TxBlockFound=false;
    RxBlockFound=false;
    currentTopLevelBlocks=find_system(model,'SearchDepth',1,'BlockType','SubSystem');
    for idxBlocks=1:size(currentTopLevelBlocks,1)

        blockOrigLibraryAndName=get_param(currentTopLevelBlocks{idxBlocks},'ReferenceBlock');
        if strcmp(blockOrigLibraryAndName,'serdesUtilities/Analog Channel')

            serdes.internal.callbacks.analogChannelUpdate(currentTopLevelBlocks{idxBlocks},"Initialization");
        end



        blockName=get_param(currentTopLevelBlocks{idxBlocks},'Name');
        if strcmp(blockName,'Tx')
            priorPriority=get_param(currentTopLevelBlocks{idxBlocks},'Priority');
            if isempty(priorPriority)

                set_param(currentTopLevelBlocks{idxBlocks},'Priority','1');
            elseif~strcmp(priorPriority,'1')

                warning(message('serdes:callbacks:PriorityPropertyValueNotRecognized',...
                'Tx',num2str(priorPriority),'1'));
            end
            TxBlockFound=true;
        elseif strcmp(blockName,'Rx')
            priorPriority=get_param(currentTopLevelBlocks{idxBlocks},'Priority');
            if isempty(priorPriority)

                set_param(currentTopLevelBlocks{idxBlocks},'Priority','2');
            elseif~strcmp(priorPriority,'2')

                warning(message('serdes:callbacks:PriorityPropertyValueNotRecognized',...
                'Rx',num2str(priorPriority),'2'));
            end
            RxBlockFound=true;
        end
    end
    if~TxBlockFound||~RxBlockFound


        warning(message('serdes:callbacks:TxorRxNotFound'))
    end
end