



classdef InactiveEnableTrigger<Transform.AbstractTransform
    properties
        pivotBlockType='SubSystem'
    end
    methods
        function yesno=applicable(~,bh,~)
            yesno=strcmp(get(bh,'BlockType'),'SubSystem');
            if yesno
                ph=get(bh,'PortHandles');
                yesno=~isempty(ph.Trigger)&&~isempty(ph.Enable);
            end
        end



        function[inactiveV,inactiveIn,activeC]=analyze(obj,bh,mdl,...
            cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;
            obj.model=mdl;

            [uncov,inactiveIn,red,deadLogic]=...
            obj.getInactiveSys(bh,cvd,mdlStructureInfo);
            inactiveV=uncov;


            if isempty(obj.uncovered)
                obj.uncovered=uncov;
            else
                obj.uncovered=[obj.uncovered;uncov];
            end

            for i=1:length(red)
                if isempty(obj.redundant)
                    obj.redundant=struct('handle',red(i));
                else
                    obj.redundant(end+1)=struct('handle',red(i));
                end
            end

            if~deadLogic
                activeC=bh;
            else
                activeC=[];
            end
        end


        function[handles,inactiveInputs,redundant,deadLogic]=...
            getInactiveSys(obj,bh,cvd,mdlStructureInfo)



            handles=[];
            inactiveInputs=[];
            redundant=[];
            deadLogic=false;

            ph=get(bh,'PortHandles');
            if~isempty(ph.Trigger)
                [detail,isMdl,covOwner]=obj.getCovDetailForSys(cvd,bh);

                if~isempty(detail)
                    assert(length(detail.decision)==1);


                    allFired=(detail.decision.outcome(1).executionCount==0);
                    noneFired=(detail.decision.outcome(2).executionCount==0);

                    if allFired&&~isempty(mdlStructureInfo)
                        mdlStructureInfo.alwaysExecutesCondSystems(bh)=uint8(1);
                    end

                    if noneFired

                        handles(end+1,1)=bh;
                    end



                    if allFired||noneFired

                        inactiveInputs(end+1,1)=getTriggerPort(bh);
                        inactiveInputs(end+1,1)=getEnablePort(bh);
                        if allFired
                            redundant(end+1,1)=obj.getTriggerBlock(bh,isMdl);
                            redundant(end+1,1)=obj.getEnableBlock(bh,isMdl);


                        end
                        if noneFired&&isMdl
                            h=obj.getDisabledMdlBlkSynth(covOwner,mdlStructureInfo);
                            if~isempty(h)
                                handles(end+1,1)=h;
                            end
                        end
                    end

                    if allFired||noneFired
                        deadLogic=true;
                    else
                        deadLogic=false;
                    end
                end
            end

        end


        function reset(this)
            this.uncovered=[];
            this.redundant=[];
        end

        function transform(obj,sliceXfrmr,~)

            for i=1:length(obj.redundant)
                removeRedundantPort(sliceXfrmr,obj.redundant(i).handle);
            end
        end

        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)

            import Transform.*;
            if~isempty(obj.redundant)
                toRemove=getCopyHandles([obj.redundant.handle],refMdlToMdlBlk,mdl,mdlCopy);
                for i=1:length(toRemove)
                    removeRedundantPort(sliceXfrmr,toRemove(i));
                end
            end
        end

        function keeps=filterDeadBlocks(obj,handles)

            filt=true(length(obj.redundant),1);
            for i=1:length(filt)
                sysO=get_param(get(obj.redundant(i).handle,'Parent'),'Object');
                sysH=sysO.Handle;
                filt(i)=all(sysH~=handles);
            end
            obj.redundant=obj.redundant(filt);
            keeps=[];
        end

    end

    methods(Access=protected)
        function[detail,isMdl,covOwner]=getCovDetailForSys(~,cvd,bh)
            if isRootSysForModelref(bh)
                sysO=get(bh,'Object');
                bd=sysO.getCompiledParent;
                [~,detail]=cvd.getDecisionInfo(bd);
                isMdl=true;
                covOwner=bd;
            else
                [~,detail]=cvd.getDecisionInfo(bh);
                isMdl=false;
                covOwner=bh;
            end
        end


        function actionBlk=getTriggerBlock(~,sysH,isMdlref)
            if~isMdlref
                sysO=get(sysH,'Object');
                b=sysO.getChildren;
            else
                sysO=get(sysH,'Object');
                bdO=get(sysO.getCompiledParent,'Object');
                b=bdO.getChildren;
            end
            actionBlk=[];
            for i=1:length(b)

                if isa(b(i),'Simulink.Block')&&...
                    strcmpi(b(i).BlockType,'TriggerPort')
                    actionBlk=b(i).Handle;
                end
            end
        end

        function actionBlk=getEnableBlock(~,sysH,isMdlref)
            if~isMdlref
                sysO=get(sysH,'Object');
                b=sysO.getChildren;
            else
                sysO=get(sysH,'Object');
                bdO=get(sysO.getCompiledParent,'Object');
                b=bdO.getChildren;
            end
            actionBlk=[];
            for i=1:length(b)

                if isa(b(i),'Simulink.Block')&&...
                    strcmpi(b(i).BlockType,'EnablePort')
                    actionBlk=b(i).Handle;
                end
            end
        end

        function h=getDisabledMdlBlkSynth(~,covOwner,mdlStructureInfo)
            h=[];
            if~isempty(mdlStructureInfo)...
                &&mdlStructureInfo.refMdlToMdlBlk.isKey(covOwner)
                h=mdlStructureInfo.refMdlToMdlBlk(covOwner);
            end
        end
    end
    properties
uncovered
redundant

model
mdlStructureInfo
    end
end

function yesno=isRootSysForModelref(bh)
    sysO=get(bh,'Object');
    if sysO.isSynthesized&&strcmp(...
        get(sysO.getCompiledParent,'Type'),'block_diagram')
        yesno=true;
    else
        yesno=false;
    end
end

function e=getTriggerPort(bh)
    ph=get(bh,'PortHandles');
    e=ph.Trigger;
end

function e=getEnablePort(bh)
    ph=get(bh,'PortHandles');
    e=ph.Enable;
end


function removeRedundantPort(sliceXfrmr,bh)
    sliceXfrmr.deleteBlock(bh);
end
