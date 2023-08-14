



classdef InactiveIf<Transform.AbstractTransform
    properties
        pivotBlockType='If'
        redundant=[];
    end
    methods
        function yesno=applicable(~,bh,~)

            yesno=strcmp(get(bh,'BlockType'),'If');
        end

        function[inactiveV,inactiveE,activeH]=analyze(obj,bh,mdl,cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;
            obj.model=mdl;

            [inactiveV,activeH]=getInactiveIf(bh,cvd,mdlStructureInfo);
            if isempty(obj.uncovered)
                obj.uncovered=inactiveV;
            else
                obj.uncovered=[obj.uncovered;inactiveV];
            end

            inactiveE=[];


        end


        function obj=InactiveIf()

            obj.uncovered={};
        end

        function transform(~,~,~)

        end
        function transformCopy(~,~,~,~,~)

        end
    end

    properties

uncovered


model
mdlStructureInfo
    end

end

function[ids,activeH]=getInactiveIf(bh,cvd,mdlStructureInfo)
    ids=[];
    activeH=[];

    bO=get(bh,'Object');
    if(bO.isSynthesized)
        orig=bO.getTrueOriginalBlock;
        assert(strcmp(get(orig,'BlockType'),'SubSystem'))

        ids(end+1,1)=orig;
        return;
    end

    [~,detail]=cvd.getDecisionInfo(bh);


    for i=1:length(detail.decision)
        assert(strcmp(detail.decision(i).outcome(1).text,'false'));
    end

    if length(detail.decision)==1

        for j=1:length(detail.decision.outcome)
            handleIfOutcome(1,j);
        end
        indices=[2,1];
        outCome=arrayfun(@(x)detail.decision.outcome(x).executionCount>0,...
        indices);

    else

        n=length(detail.decision);
        indices=[(1:n)',repmat(2,n,1);n,1];
        for j=1:size(indices,1)
            dIdx=indices(j,1);
            oIdx=indices(j,2);
            handleIfOutcome(dIdx,oIdx);
        end
        numOutcomes=n+1;
        outCome=arrayfun(@(x)detail.decision(indices(x,1)).outcome(...
        indices(x,2)).executionCount>0,...
        1:numOutcomes);
    end
    if length(find(outCome))==1&&~isempty(activeH)&&~isempty(mdlStructureInfo)

        mdlStructureInfo.alwaysExecutesCondSystems(activeH)=uint8(1);
        activeH=[];
    end


    function handleIfOutcome(dIdx,oIdx)
        if detail.decision(dIdx).outcome(oIdx).executionCount<1
            sysH=getIfOutcome(bh,dIdx,oIdx);
            if~isempty(sysH)
                ids(end+1,1)=sysH;
            end
        else
            sysH=getIfOutcome(bh,dIdx,oIdx);
            if~isempty(sysH)

                activeH(end+1,1)=sysH;
            end
        end
    end

end


function[sysH]=getIfOutcome(bh,decisionIdx,outcomeIdx)


    showElse=strcmp(get(bh,'ShowElse'),'on');






    if outcomeIdx==2
        portId=decisionIdx;
    else
        portId=decisionIdx+1;
    end

    ph=get(bh,'PortHandles');
    if showElse
        outPort=get(ph.Outport(portId),'Object');
    else
        if portId<=length(ph.Outport)
            outPort=get(ph.Outport(portId),'Object');
        else

            sysH=[];
            return
        end

    end

    controlPort=outPort.getActualDst;
    if~isempty(controlPort)
        sysH=get_param(get(controlPort(1),'Parent'),'Handle');
    else
        sysH=[];
    end


end
