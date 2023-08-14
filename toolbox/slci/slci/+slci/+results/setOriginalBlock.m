function setOriginalBlock(keyToHandle,Config)





    isResultsMF=isa(Config,'slci_results_mf.ReaderObject_MF');

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    if isResultsMF
        blockReader=Config;
    else
        datamgr=Config.getDataManager();
        blockReader=datamgr.getBlockReader();
    end
    if slcifeature('BEPSupport')==1
        syntRootToOrigRootIOBlockMap=slci.internal.getSyntRootToOrigRootIOBlockMap(cell2mat(values(keyToHandle)));
    end

    blkKeys=keys(keyToHandle);
    processedBlks=[];
    for k=1:numel(blkKeys)
        blkKey=blkKeys{k};
        blkHdl=keyToHandle(blkKey);
        blkObj=get_param(blkHdl,'Object');
        if blkObj.isSynthesized()&&...
            isempty(find(processedBlks==blkHdl,1))
            origBlkHdl=blkObj.getTrueOriginalBlock();
            blkType=get_param(blkHdl,'BlockType');
            if slcifeature('VirtualBusSupport')==1&&...
                (strcmp(blkType,'Inport')||strcmp(blkType,'Outport'))



                if slcifeature('BEPSupport')==1
                    if syntRootToOrigRootIOBlockMap.isKey(blkHdl)
                        origBlkHdl=syntRootToOrigRootIOBlockMap(blkHdl);
                    end
                else
                    try
                        origBlkHdl=slInternal('busDiagnostics','getOriginalBlockHandleForRootIOBlock',blkHdl);
                    catch


                    end
                end
            end



            if~isempty(origBlkHdl)&&(origBlkHdl~=blkHdl)
                origKey=slci.results.getKeyFromBlockHandle(origBlkHdl);


                if blockReader.hasObject(origKey)
                    origBlk=blockReader.getObject(origKey);

                    processedBlks(end+1)=blkHdl;%#ok<AGROW>
                    processedBlks=slci.results.updateOrigBlock(...
                    blkHdl,origBlk,...
                    processedBlks,blockReader);
                end
            end
        end
    end
end
