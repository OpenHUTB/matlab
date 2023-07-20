



classdef InactiveTrigger<Transform.AbstractTransform
    properties
        pivotBlockType='SubSystem'
    end
    methods
        function yesno=applicable(~,bh,~)
            yesno=strcmp(get(bh,'BlockType'),'SubSystem');
            if yesno
                ph=get(bh,'PortHandles');
                yesno=~isempty(ph.Trigger)&&isempty(ph.Enable);
            end
        end



        function[inactiveV,inactiveE,activeC]=analyze(obj,bh,mdl,cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;
            obj.model=mdl;

            if isFcnCallMdlRef(bh)
                inactiveV=[];
                inactiveE=[];
                activeC=bh;
                return;
            end

            [uncov,inactiveE,red,deadLogic]=...
            obj.getInactiveSys(bh,cvd,mdlStructureInfo);
            inactiveV=uncov;

            if isempty(obj.uncovered)
                obj.uncovered=uncov;
            else
                obj.uncovered=[obj.uncovered;uncov];
            end

            if isempty(obj.redundant)
                obj.redundant=red;
            else
                obj.redundant=[obj.redundant,red];
            end

            if~deadLogic
                activeC=bh;
            else
                activeC=[];
            end
        end


        function transform(obj,sliceXfrmr,~)

            for i=1:length(obj.redundant)
                removeRedundantTriggerPort(sliceXfrmr,obj.redundant(i));
            end
        end

        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)

            import Transform.*;

            toRemove=getCopyHandles(obj.redundant,refMdlToMdlBlk,...
            mdl,mdlCopy);
            for i=1:length(toRemove)
                removeRedundantTriggerPort(sliceXfrmr,toRemove(i));
            end
        end

        function keeps=filterDeadBlocks(obj,handles)

            filt=true(length(obj.redundant),1);
            for i=1:length(filt)
                sysO=get_param(get(obj.redundant(i),'Parent'),'Object');
                sysH=sysO.Handle;
                filt(i)=all(sysH~=handles);
            end
            obj.redundant=obj.redundant(filt);
            keeps=[];
        end
        function reset(this)
            this.redundant=[];
            this.uncovered=[];
        end


        function[handles,E,redundant,deadLogic]=getInactiveSys(obj,bh,cvd,mdlStructureInfo)


            import Analysis.*;
            import slslicer.internal.*

            handles=[];
            E=[];
            redundant=[];
            deadLogic=false;




            if SLCompGraphUtil.Instance.blockIsChildOfStateflow(bh)
                return;
            end


            ph=get(bh,'PortHandles');
            if~isempty(ph.Trigger)
                [detail,isMdl,covOwner]=obj.getCovDetailForSys(cvd,bh);

                if~isempty(detail)
                    if SLCompGraphUtil.Instance.blockIsStateflow(bh)
                        decision=detail.decision(1);
                    else
                        decision=detail.decision;
                    end
                    [allFired,noneFired]=...
                    checkTriggerSysCoverage(decision);
                    if noneFired
                        handles(end+1,1)=bh;
                    end

                    if allFired&&~isempty(mdlStructureInfo)
                        mdlStructureInfo.alwaysExecutesCondSystems(bh)=uint8(1);
                    end



                    if allFired||noneFired
                        e=getInactiveTriggerData(bh,mdlStructureInfo);

                        E(end+1)=e;
                        if allFired
                            redundant(end+1)=obj.getTriggerBlock(bh,isMdl);


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
    end


    methods(Access=protected)
        function[detail,isMdl,covOwner]=getCovDetailForSys(obj,cvd,bh)
            if Analysis.isRootOfMdlref(obj.mdlStructureInfo.refMdlToMdlBlk,bh)
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


function out=isFcnCallMdlRef(bh)


    out=false;
    sysO=get(bh,'Object');
    if sysO.isSynthesized
        origB=sysO.getTrueOriginalBlock;
        if origB~=bh
            out=strcmp(get(sysO.getTrueOriginalBlock,...
            'BlockType'),'ModelReference');
        end
    end
end

function e=getInactiveTriggerData(bh,~)
    ph=get(bh,'PortHandles');
    e=ph.Trigger;
end

function removeRedundantTriggerPort(sliceXfrmr,bh)

    o=get(bh,'Object');


    sysO=o.getParent;
    pH=sysO.PortHandles.Trigger;
    l=get(pH,'Line');
    if l>0
        sliceXfrmr.deleteLine(l);
    end
    sliceXfrmr.deleteBlock(bh);
end


function[allFired,nonFired]=checkTriggerSysCoverage(decision)


    m=length(decision);


    D=false(m,2);

    for i=1:m
        outcome=decision(i).outcome;
        if length(outcome)==2



            D(i,1)=(outcome(1).executionCount==0);
            D(i,2)=(outcome(2).executionCount==0);
        elseif length(outcome)==1

            D(i,1)=false;
            D(i,2)=(outcome(1).executionCount==0);
        end
    end

    nonFired=all(D(:,2));
    allFired=all(D(:,1))&&~nonFired;

end
