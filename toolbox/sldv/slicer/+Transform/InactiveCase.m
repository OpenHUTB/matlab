



classdef InactiveCase<Transform.AbstractTransform
    properties
        pivotBlockType='SwitchCase'
    end
    methods

        function yesno=applicable(obj,bh,~)%#ok<INUSL>

            yesno=strcmp(get(bh,'BlockType'),'SwitchCase');
        end


        function[inactiveV,inactiveE,activeH]=analyze(obj,bh,mdl,...
            cvd,mdlStructureInfo)%#ok<INUSL>

            obj.mdlStructureInfo=mdlStructureInfo;

            [inactiveV,activeH,red]=getInactiveCase(bh,cvd,mdlStructureInfo);
            if isempty(obj.uncovered)
                obj.uncovered=inactiveV;
            else
                obj.uncovered=[obj.uncovered;inactiveV];
            end

            inactiveE=getControlPorts(obj.uncovered);

            for i=1:length(red)
                if isempty(obj.redundant)
                    obj.redundant=red(i);
                else
                    obj.redundant(end+1)=red(i);
                end
            end
        end


        function obj=InactiveCase()

            obj.uncovered=[];
        end

        function reset(obj)
            obj.uncovered=[];
            obj.redundant=[];
        end
        function keeps=filterDeadBlocks(obj,handles)
            if~isempty(obj.redundant)
                s=[obj.redundant.handle];
                filter=arrayfun(@(x)~allSystemsAreToRemove(x,handles),s);
                obj.redundant=obj.redundant(filter);
                keeps=[obj.redundant.handle];
                keeps=reshape(keeps,numel(keeps),1);
            else
                keeps=[];
            end
        end
        function transform(obj,sliceXfrmr,~)
            for i=1:length(obj.redundant)
                bh=obj.redundant(i).handle;
                removeCaseBlk(sliceXfrmr,bh,...
                obj.redundant(i).index,...
                obj.redundant(i).ActionBlk);
            end
        end
        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)
            import Transform.*;

            for i=1:length(obj.redundant)
                bh=obj.redundant(i).handle;
                bhCopy=getCopyHandles(bh,refMdlToMdlBlk,mdl,mdlCopy);
                actionBlkCopy=getCopyHandles(obj.redundant(i).ActionBlk,...
                refMdlToMdlBlk,mdl,mdlCopy);
                if~isempty(bhCopy)&&~isempty(actionBlkCopy)
                    removeCaseBlk(sliceXfrmr,bhCopy,...
                    obj.redundant(i).index,...
                    actionBlkCopy);
                end
            end
        end
    end

    properties

uncovered

redundant


mdlStructureInfo
    end

end

function yesno=allSystemsAreToRemove(caseH,toRemove)
    ph=get(caseH,'PortHandles');
    yesno=true;
    for i=1:length(ph.Outport)
        pO=get(ph.Outport(i),'Object');
        dst=pO.getActualDst;
        for j=1:size(dst,1)
            dstP=dst(j,1);
            sysB=get(dstP,'ParentHandle');
            if all(sysB~=toRemove)
                yesno=false;
                return;
            end
        end
    end
end

function[ids,activeH,redundant]=getInactiveCase(bh,cvd,mdlStructureInfo)
    ids=[];
    activeH=[];

    bO=get(bh,'Object');


    assert(~bO.isSynthesized)

    [~,detail]=cvd.getDecisionInfo(bh);


    assert(length(detail.decision)==1);


    D=false(length(detail.decision.outcome),1);
    defaultActive=false;
    for i=1:length(detail.decision.outcome)
        if~contains(detail.decision.outcome(i).text,'implicit-default')&&...
            ~contains(detail.decision.outcome(i).text,'default')

            D(i)=detail.decision.outcome(i).executionCount>0;
        else
            defaultActive=detail.decision.outcome(i).executionCount>0;
        end
    end

    cases=getCaseValues(bh);
    nCases=numel(cases);
    activeCases=false(numel(cases),1);


    caseCount=cellfun(@(c)length(c),cases);

    indices=[0,cumsum(caseCount)];
    indices=[indices,indices(end)+1];

    for i=1:numel(cases)
        caseIdx=indices(i)+1:indices(i+1);
        inactiveOut=D(caseIdx);
        activeCases(i)=any(inactiveOut);
        if activeCases(i)
            activeH=[activeH;getCaseOutcome(bh,i)];%#ok<AGROW>
        else
            ids=[ids;getCaseOutcome(bh,i)];%#ok<AGROW>
        end
    end


    if defaultActive
        activeH=[activeH;getCaseOutcome(bh,nCases+1)];
    else
        ids=[ids;getCaseOutcome(bh,nCases+1)];
    end
    activeCases(nCases+1)=defaultActive;

    if length(find(activeCases))==1

        idx=find(activeCases);
        if~isempty(mdlStructureInfo)&&~isempty(activeH)
            mdlStructureInfo.alwaysExecutesCondSystems(activeH)=uint8(1);
            actionBlk=getActionBlock(activeH);
            redundant=struct('handle',bh,'index',idx,'ActionBlk',actionBlk);
            activeH=[];
            ids=[ids;bh];
        else


            redundant=[];
        end
    else
        redundant=[];
    end
end

function val=getCaseValues(bh)
    val=slResolve(get_param(bh,'CaseConditions'),bh);
end

function[sysH]=getCaseOutcome(bh,portId)
    ph=get(bh,'PortHandles');
    if portId>length(ph.Outport)

        sysH=[];
    else
        outPort=get(ph.Outport(portId),'Object');
        controlPort=outPort.getActualDst;
        if~isempty(controlPort)
            sysH=get_param(get(controlPort(1),'Parent'),'Handle');
        else
            sysH=[];
        end
    end
end

function actionBlk=getActionBlock(sysH)
    sysO=get(sysH,'Object');
    actionBlkObj=sysO.find('BlockType','ActionPort');
    if~isempty(actionBlkObj)
        actionBlk=actionBlkObj.Handle;
    else
        actionBlk=[];
    end
end

function removeCaseBlk(sliceXfrmr,bh,idx,actionBlk)
    ph=get(bh,'PortHandles');


    l=get(ph.Outport(idx),'Line');
    if l>0
        sliceXfrmr.deleteLine(l);
    end

    for i=1:length(ph.Inport)
        ilh=get(ph.Inport(i),'Line');
        if ilh>0
            sliceXfrmr.deleteLine(ilh);
        end
    end

    if~isempty(actionBlk)
        sliceXfrmr.deleteBlock(actionBlk);
    end
    sliceXfrmr.deleteBlock(bh);
end

function portHs=getControlPorts(sysHs)
    portHs=[];
    for idx=1:length(sysHs)
        sysH=sysHs(idx);
        if~strcmpi(get_param(sysH,'BlockType'),'SwitchCase')
            portHs(end+1)=get_param(sysH,'PortHandles').Ifaction;
        end
    end
    portHs=portHs';
end
