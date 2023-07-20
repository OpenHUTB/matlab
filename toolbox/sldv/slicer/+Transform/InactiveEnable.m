



classdef InactiveEnable<Transform.AbstractTransform
    properties
        pivotBlockType='SubSystem'
    end
    methods
        function yesno=applicable(~,bh,~)


            yesno=strcmp(get(bh,'BlockType'),'SubSystem');
            if yesno

                ph=get(bh,'PortHandles');
                yesno=~isempty(ph.Enable)&&isempty(ph.Trigger);
            end
        end

        function[inactiveH,inactiveInH,conditionalH]=...
            analyze(obj,bh,mdl,cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;
            obj.model=mdl;

            [uncov,inactiveInH,red,deadLogic]=...
            obj.getInactiveSys(bh,cvd,mdlStructureInfo);
            inactiveH=uncov;

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

                conditionalH=bh;
            else
                conditionalH=[];
            end
        end

        function transform(obj,sliceXfrmr,mdl)%#ok<INUSD>

            for i=1:length(obj.redundant)
                removeRedundantEnablePort(sliceXfrmr,obj.redundant(i).handle);
            end
        end

        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)
            import Transform.*;
            if~isempty(obj.redundant)
                [sliceEnablePortH,origEnablePortH]=getCopyHandles([obj.redundant.handle],refMdlToMdlBlk,mdl,mdlCopy);
                for i=1:length(sliceEnablePortH)
                    origSysH=get_param(get(origEnablePortH(i),'Parent'),'Handle');
                    inheritInitialOutputsToParentConditionalSS(origSysH,refMdlToMdlBlk,mdl,mdlCopy,sliceXfrmr);
                    removeRedundantEnablePort(sliceXfrmr,sliceEnablePortH(i));
                end
            end
        end

        function reset(this)
            this.redundant=[];
            this.uncovered=[];
        end

        function[handles,E,redundant,deadLogic]=getInactiveSys(obj,bh,cvd,mdlStructureInfo)



            handles=[];
            E=[];
            redundant=[];
            ph=get(bh,'PortHandles');
            if~isempty(ph.Enable)





                [detail,isMdl,covOwner]=obj.getCovDetailForSys(cvd,bh);
                assert(length(detail.decision)==1);


                if prod(get(ph.Enable,'CompiledPortDimensions'))==1
                    [allEnabled,allDisabled]=...
                    checkEnableSysCoverage(detail.decision.outcome);
                else
                    [allEnabled,allDisabled]=...
                    checkVectorEnableSysCoverage(covOwner,cvd,detail);
                end
                if allDisabled
                    handles(end+1,1)=bh;
                end

                if allEnabled&&~isempty(mdlStructureInfo)
                    mdlStructureInfo.alwaysExecutesCondSystems(bh)=uint8(1);
                end



                if allEnabled||allDisabled
                    e=getInactiveEnableData(bh);
                    if allEnabled
                        redundant=obj.getEnableBlock(bh,isMdl);
                    end
                    if allDisabled&&isMdl


                        h=obj.getDisabledMdlBlkSynth(covOwner,mdlStructureInfo);
                        if~isempty(h)
                            handles(end+1,1)=h;
                        end
                    end
                    E=[E;e];
                end
                deadLogic=allEnabled||allDisabled;
            end
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

function e=getInactiveEnableData(bh)

    ph=get(bh,'PortHandles');
    inport=get(ph.Enable,'Object');

    e=inport.Handle;
end

function removeRedundantEnablePort(sliceXfrmr,bh)

    o=get(bh,'Object');


    sysO=o.getParent;
    pH=sysO.PortHandles.Enable;

    enableNeedReplaced=false;
    enablePH=get_param(bh,'PortHandles');
    if~isempty(enablePH.Outport)
        enableLH=get_param(bh,'LineHandles');
        if enableLH.Outport>0


            enableNeedReplaced=true;
            portPos=get(enablePH.Outport(1),'Position');
            enablePos=[portPos(1)-30,...
            portPos(2)-7,...
            portPos(1),...
            portPos(2)+7];
            enablePath=getfullname(bh);
        end
    end

    l=get(pH,'Line');
    if l>0

        sliceXfrmr.deleteLine(l);
    end
    sliceXfrmr.deleteBlock(bh);

    if enableNeedReplaced

        sliceXfrmr.replaceByConstant(enablePath,enablePos,'true');
    end
end

function[allEnabled,allDisabled]=checkEnableSysCoverage(outcome)

    allEnabled=(outcome(1).executionCount==0);
    allDisabled=(outcome(2).executionCount==0);
end
function[allEnabled,allDisabled]=checkVectorEnableSysCoverage(bh,cvd,detail)



    allDisabled=false;
    if detail.decision.outcome(2).executionCount==0


        allDisabled=true;
        allEnabled=false;
    else

        [~,cdetail]=cvd.getConditionInfo(bh);
        if isempty(cdetail)

            allEnabled=false;
            allDisabled=false;
        else
            allEnabled=true;
            for n=1:length(cdetail)
                if cdetail(n).falseCnts~=0
                    allEnabled=false;
                    break
                end
            end
        end
    end
end

