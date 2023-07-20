



classdef RedundantIf<Transform.AbstractTransform
    properties

        pivotBlockType='If';

        redundant=[];
    end
    methods

        function yesno=applicable(obj,bh,cvd)
            yesno=strcmp(get(bh,'BlockType'),'If');
        end

        function[inactiveV,inactiveIn,c]=analyze(obj,bh,~,cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;

            ifB=getRedundantIfBlks(bh,cvd);
            if isempty(obj.redundant)
                obj.redundant=ifB;
            else
                obj.redundant=[obj.redundant;ifB];
            end
            if~isempty(ifB)
                inactiveV=ifB.handle;
            else
                inactiveV=[];
            end


            inactiveIn=[];
            c=[];
        end


        function obj=RedundantIf()

            obj.redundant=[];
        end

        function reset(this)
            this.redundant=[];
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

        function transform(obj,sliceXfrmr,mdl)

            for i=1:length(obj.redundant)
                bh=obj.redundant(i).handle;
                removeIfBlk(sliceXfrmr,bh,...
                obj.redundant(i).index,...
                obj.redundant(i).ActionBlk);
            end
        end

        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)

            import Transform.*;

            for i=1:length(obj.redundant)
                bh=obj.redundant(i).handle;
                bhCopy=getCopyHandles(bh,refMdlToMdlBlk,mdl,mdlCopy);
                if ishandle(bhCopy)
                    actionBlkCopy=getCopyHandles(obj.redundant(i).ActionBlk,...
                    refMdlToMdlBlk,mdl,mdlCopy);
                    removeIfBlk(sliceXfrmr,bhCopy,...
                    obj.redundant(i).index,...
                    actionBlkCopy);
                end
            end
        end

    end

    properties


mdlStructureInfo
    end

end

function yesno=allSystemsAreToRemove(ifH,toRemove)
    ph=get(ifH,'PortHandles');
    yesno=true;
    for i=1:length(ph.Outport);
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

function redundant=getRedundantIfBlks(bh,cvd)
    redundant=struct('handle',{},'index',{},'ActionBlk',{});

    bO=get(bh,'Object');
    if(bO.isSynthesized)
        orig=bO.getTrueOriginalBlock;
        assert(strcmp(get(orig,'BlockType'),'SubSystem'))

        return;
    end

    [~,detail]=cvd.getDecisionInfo(bh);
    if length(detail.decision)==1

        assert(length(detail.decision.outcome)==2);
        indices=[2,1];
        outCome=arrayfun(@(x)detail.decision.outcome(x).executionCount>0,...
        indices);
    else

        n=length(detail.decision);
        indices=[(1:n)',repmat(2,n,1);n,1];
        numOutcomes=n+1;
        outCome=arrayfun(@(x)detail.decision(indices(x,1)).outcome(...
        indices(x,2)).executionCount>0,...
        1:numOutcomes);
    end

    if length(find(outCome))==1

        portId=find(outCome);

        ph=get(bh,'PortHandles');
        if length(ph.Outport)>=portId




            outPort=get(ph.Outport(portId),'Object');
            controlPort=outPort.getActualDst;
        else
            controlPort=[];
        end
        if~isempty(controlPort)
            sysH=get_param(get(controlPort(1),'Parent'),'Handle');

            sysO=get(sysH,'Object');
            b=sysO.getChildren;
            actionBlk=[];
            for i=1:length(b)

                if strcmpi(b(i).type,'block')&&...
                    strcmpi(b(i).BlockType,'ActionPort')
                    actionBlk=b(i).Handle;
                end
            end

            s=struct('handle',bh,'index',portId,'ActionBlk',actionBlk);
            redundant=s;
        else
            redundant=struct('handle',bh,'index',portId,'ActionBlk',[]);
        end

    else
        redundant=struct('handle',{},'index',{},'ActionBlk',{});
    end


end

function removeIfBlk(sliceXfrmr,bh,idx,actionBlk)

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
