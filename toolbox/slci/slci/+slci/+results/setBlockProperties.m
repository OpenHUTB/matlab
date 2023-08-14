

function setBlockProperties(keyToHandle,Config,blockReader)
    assert(nargin==2||nargin==3);


    isResultsMF=(nargin==3);
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    blks=keys(keyToHandle);

    mdl=Config.getModelName();
    mdlHdl=get_param(mdl,'Handle');
    graphicalBlks=slci.results.find_blocks_all(mdlHdl);

    if~isResultsMF
        datamgr=Config.getDataManager();
        blockReader=datamgr.getBlockReader();
        datamgr.beginTransaction();
    end
    try
        numBlks=numel(blks);
        for k=1:numBlks
            blkKey=blks{k};
            blkHdl=keyToHandle(blkKey);


            if~isVisible(blkHdl,graphicalBlks)

                blkObj=blockReader.getObject(blkKey);

                visibleTarget=getVisibleBlock(blkObj,mdlHdl,...
                graphicalBlks,blockReader);

                if~isempty(visibleTarget)
                    if isResultsMF
                        blkObj.isVisible=false;

                        blkObj.visibleTarget=visibleTarget;


                    else
                        blkObj.setIsVisible(false);
                        blkObj.setVisibleTarget({visibleTarget});
                        blockReader.replaceObject(blkKey,blkObj);
                    end
                end
            end


            if isGroundWithinStateflow(blkHdl)
                blkObj=blockReader.getObject(blkKey);
                blkObj.addPrimVerSubstatus('OPTIMIZED');
                blkObj.addPrimTraceSubstatus('OPTIMIZED');
                if~isResultsMF
                    blockReader.replaceObject(blkKey,blkObj);
                end


            else
                [flag,chartObj]=isSFunctionWithinChart(blkHdl,blockReader);
                if flag
                    if isResultsMF
                        isEmptyChart=chartObj.isEmpty;
                    else
                        isEmptyChart=chartObj.getIsEmpty();
                    end
                    if isEmptyChart
                        blkObj=blockReader.getObject(blkKey);
                        blkObj.addPrimVerSubstatus('VIRTUAL');
                        blkObj.addPrimTraceSubstatus('VIRTUAL');
                        if~isResultsMF
                            blockReader.replaceObject(blkKey,blkObj);
                        end


                    elseif chartObj.getIsInline()
                        blkObj=blockReader.getObject(blkKey);
                        blkObj.addPrimVerSubstatus('INLINED');
                        blkObj.addPrimTraceSubstatus('INLINED');
                        if~isResultsMF
                            blockReader.replaceObject(blkKey,blkObj);
                        end


                    end
                end
            end
        end
    catch ex
        if~isResultsMF
            datamgr.rollbackTransaction();
        end
        throw(ex);
    end
    if~isResultsMF
        datamgr.commitTransaction();
    end
end




function visibleFlag=isVisible(blkHdl,graphicalBlks)
    visibleFlag=true;
    if isempty(find(graphicalBlks==blkHdl,1))
        visibleFlag=false;
    elseif isParentHiddenMask(blkHdl)
        visibleFlag=false;
    end
end


function flag=isParentHiddenMask(blkHdl)
    flag=false;
    parent=get_param(blkHdl,'Parent');
    if strcmpi(get_param(parent,'Type'),'block')
        if strcmpi(get_param(parent,'Mask'),'on')&&...
            strcmpi(get_param(parent,'MaskHideContents'),'on')
            flag=true;
        else

            flag=isParentHiddenMask(parent);
        end
    end
end


function visibleBlk=getVisibleBlock(blkObj,mdlHdl,graphicalBlks,blockReader)

    visibleBlk=[];
    isResultsMF=isa(blockReader,'slci_results_mf.ReaderObject_MF');


    if isResultsMF

        if isa(blkObj,'slci_results_mf.HiddenBlockObject')
            visibleBlk=getOrigBlock(blkObj,blockReader);
        end


        if isempty(visibleBlk)
            blkHdl=blkObj.blockHandle;
            visibleBlk=getVisibleParent(blkHdl,mdlHdl,graphicalBlks);
        end
    else

        if isa(blkObj,'slci.results.HiddenBlockObject')
            visibleBlk=getOrigBlock(blkObj,blockReader);
        end


        if isempty(visibleBlk)
            blkHdl=blkObj.getBlockHandle();
            visibleBlk=getVisibleParent(blkHdl,mdlHdl,graphicalBlks);
        end
    end
end


function origBlock=getOrigBlock(hiddenBlkObj,blockReader)
    isResultsMF=isa(blockReader,'slci_results_mf.ReaderObject_MF');

    if isResultsMF
        origBlock=hiddenBlkObj.origBlock;
        if~isempty(origBlock)
            origBlockObj=blockReader.getObject(origBlock);
            if isa(origBlockObj,'slci_results_mf.HiddenBlockObject')
                origBlock=getOrigBlock(origBlockObj,blockReader);
            end
        end
    else
        origBlock=hiddenBlkObj.getOrigBlock();

        if~isempty(origBlock)
            origBlockObj=blockReader.getObject(origBlock);
            if isa(origBlockObj,'slci.results.HiddenBlockObject')
                origBlock=getOrigBlock(origBlockObj,blockReader);
            end
        end
    end
end


function visibleBlk=getVisibleParent(blkHdl,mdlHdl,graphicalBlks)
    parentHdl=get_param(get_param(blkHdl,'Parent'),'Handle');
    if(parentHdl==mdlHdl)

        visibleBlk=[];
    elseif isVisible(parentHdl,graphicalBlks)

        visibleBlk=slci.results.getKeyFromBlockHandle(parentHdl);
    else

        visibleBlk=getVisibleParent(parentHdl,mdlHdl,graphicalBlks);
    end
end




function flag=isGroundWithinStateflow(blkHdl)
    if strcmpi(get_param(blkHdl,'BlockType'),'Ground')
        parentHdl=get_param(blkHdl,'Parent');
        parentObj=get_param(parentHdl,'Object');

        if strcmpi(get_param(parentHdl,'Type'),'Block')...
            &&strcmpi(get_param(parentHdl,'BlockType'),'Subsystem')...
            &&strcmpi(slci.internal.getSubsystemType(parentObj),'Stateflow')
            portH=get_param(parentHdl,'PortHandles');

            if isempty(portH.Inport)

                groundPh=get_param(blkHdl,'PortHandles');
                assert(numel(groundPh.Outport)==1,...
                'Ground block must have only one outport');
                dst=slci.internal.getActualDst(blkHdl,0);
                if(size(dst,1)==1)&&...
                    strcmpi(get_param(dst(1,1),'BlockType'),'S-Function')
                    flag=true;
                    return;
                end
            end
        end
    end
    flag=false;
end



function[flag,parentObj]=isSFunctionWithinChart(blkHdl,reader)
    if strcmpi(get_param(blkHdl,'BlockType'),'S-Function')
        parentHdl=get_param(blkHdl,'Parent');
        parentObj=get_param(parentHdl,'Object');

        if strcmpi(get_param(parentHdl,'Type'),'Block')...
            &&strcmpi(get_param(parentHdl,'BlockType'),'Subsystem')...
            &&strcmpi(slci.internal.getSubsystemType(parentObj),'Stateflow')
            if~slci.internal.isUnsupportedStateflowBlock(parentHdl)
                parentObj=reader.getObject(slci.results.getKeyFromBlockHandle(parentHdl));
                flag=true;
                return;
            end
        end
    end
    parentObj=[];
    flag=false;
end
