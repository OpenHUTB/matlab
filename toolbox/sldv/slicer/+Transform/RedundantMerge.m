




classdef RedundantMerge<Transform.AbstractTransform
    properties
        pivotBlockType='Merge';
        redundant=[];
        mdlStructureInfo;
    end
    methods(Access=public)
        function out=applicable(~,bh,~)
            out=strcmp(get(bh,'BlockType'),'Merge');
        end


        function markRedundant(obj,blkH,index)
            if isempty(obj.redundant)
                obj.redundant=struct('handle',blkH,'index',index);
            else
                obj.redundant(end+1)=struct('handle',blkH,'index',index);
            end
        end

        function[i,j,c]=analyze(~,~,~,~,~)


            i=[];
            j=[];
            c=[];

        end

        function postAnalyze(obj,bh,irInactiveH)

            if obj.mdlStructureInfo.subordinateMergeBlks.isKey(bh)
                return;
            elseif destIsAnotherMerge(bh)&&~isempty(obj.mdlStructureInfo)
                obj.mdlStructureInfo.subordinateMergeBlks(bh)=uint8(1);
                return;
            end



            obj.analyzeMergeTree(bh,irInactiveH,[]);
        end

        function[inactiveMrgH,leafAct,leafAlwaysExecs]=analyzeMergeTree(this,bh,...
            irInactiveH,parH)
            inactiveMrgH=[];
            mdlStructureInfo=this.mdlStructureInfo;%#ok<*PROPLC>
            if~strcmp(get_param(bh,'BlockType'),'Merge')

                leafAct=isActive(bh);
                if leafAct
                    leafAlwaysExecs=activeBlockAlwaysExecutes(parH,bh,mdlStructureInfo);
                else
                    leafAlwaysExecs=false;
                end
            else
                leafAct=[];
                leafAlwaysExecs=[];


                mergeInputs=get(bh,'PortHandles').Inport;
                leafIdx2PortIdx=[];

                for i=1:numel(mergeInputs)
                    prtLfAct=[];
                    prtLfAlwys=[];
                    ipObj=get(mergeInputs(i),'Object');
                    srcInfo=ipObj.getActualSrc;

                    for j=1:size(srcInfo,1)
                        childH=get(srcInfo(j,1),'ParentHandle');
                        [subInct,subLfAct,subLfAlways]=this.analyzeMergeTree(...
                        childH,irInactiveH,bh);
                        inactiveMrgH=[inactiveMrgH,subInct];%#ok<AGROW>
                        prtLfAct=[prtLfAct,subLfAct];%#ok<AGROW>
                        prtLfAlwys=[prtLfAlwys,subLfAlways];%#ok<AGROW>
                    end
                    leafAct=[leafAct,prtLfAct];%#ok<AGROW>
                    leafAlwaysExecs=[leafAlwaysExecs,prtLfAlwys];%#ok<AGROW>
                    leafCnt=numel(prtLfAct);
                    leafIdx2PortIdx=[leafIdx2PortIdx,i*ones(1,leafCnt)];%#ok<AGROW>
                end

                if all(~leafAct)

                    inactiveMrgH=[inactiveMrgH,bh];
                else
                    if isequal(leafAct,leafAlwaysExecs)
                        portIndex=leafIdx2PortIdx(find(leafAct));
                        portIndex=unique(portIndex);

                        if numel(portIndex)==1



                            this.markRedundant(bh,portIndex);



                            for idx=1:numel(inactiveMrgH)
                                inActBlkH=inactiveMrgH(idx);
                                this.markRedundant(inActBlkH,[]);
                            end
                            inactiveMrgH=[];
                        end
                    end
                end
            end
            function yesno=isActive(bh)
                yesno=~ismember(bh,irInactiveH);
                if yesno
                    bObj=get(bh,'Object');
                    if bObj.isSynthesized
                        bh=bObj.getTrueOriginalBlock;
                        yesno=~ismember(bh,irInactiveH);
                    end
                end
                if yesno&&slfeature('NewSlicerBackend')


                    ancestors=...
                    slslicer.internal.SLGraphUtil.getBlockAncestors(bh,...
                    mdlStructureInfo.refMdlToMdlBlk);
                    yesno=isempty(intersect(ancestors,irInactiveH));
                end
            end
        end

        function transform(obj,sliceXfrmr,~)
            for i=1:length(obj.redundant)
                removeRedundantMergeBlock(sliceXfrmr,obj.redundant(i).handle,...
                obj.redundant(i).index);
            end
        end

        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)
            import Transform.*;

            if~isempty(obj.redundant)
                bh=[obj.redundant.handle];
                [toRemove,vbh]=getCopyHandles(bh,refMdlToMdlBlk,mdl,mdlCopy);

                for i=1:length(toRemove)
                    removeRedundantMergeBlock(sliceXfrmr,toRemove(i),...
                    obj.redundant(bh==vbh(i)).index);
                end
            end
        end
        function keeps=filterDeadBlocks(obj,handles)
            if~isempty(obj.redundant)
                s=[obj.redundant.handle];
                filter=arrayfun(@(x)~any(handles==x),s);
                obj.redundant=obj.redundant(filter);
            end
            keeps=[];
        end
    end
end


function out=destIsAnotherMerge(bh)
    out=false;
    ph=get_param(bh,'PortHandles');
    portH=ph.Outport;
    pO=get(portH,'Object');


    if pO.Line~=-1
        try
            actDsts=pO.getActualDst;
            if(size(actDsts,1)==1)
                blkH=get(actDsts(1,1),'ParentHandle');
                out=strcmp(get(blkH,'BlockType'),'Merge');
            end
        catch Mx
        end
    end
end


function out=activeBlockAlwaysExecutes(mrgH,inBlk,mdlStructureInfo)
    mergeParentH=get_param(get_param(mrgH,'Parent'),'Handle');
    parH=get_param(get_param(inBlk,'Parent'),'Handle');
    out=doesCondAncestorAlwaysExecutes(parH,mergeParentH,mdlStructureInfo);
end

function out=doesCondAncestorAlwaysExecutes(parH,mergeParentH,mdlStructureInfo)
    out=true;

    while(true)
        if((parH==mergeParentH)||...
            strcmp(get_param(parH,'Type'),'block_diagram'))
            return;
        end
        if slprivate('is_stateflow_based_block',parH)


            out=false;
            return;
        end
        if isConditional(parH)
            out=mdlStructureInfo.alwaysExecutesCondSystems.isKey(parH);
            return;
        else
            parH=get_param(get_param(parH,'Parent'),'Handle');
        end
    end
end


function out=isConditional(blkH)
    ph=get_param(blkH,'PortHandles');
    out=~isempty(ph.Enable)||~isempty(ph.Trigger)||...
    ~isempty(ph.Ifaction)||~isempty(ph.Reset);
end

function removeRedundantMergeBlock(sliceXfrmr,bh,idx)


    parent=get(bh,'Parent');
    ph=get(bh,'PortHandles');

    if~isempty(idx)
        inLine=get(ph.Inport(idx),'Line');
        inPoints=get(inLine,'Points');

        outLine=get(ph.Outport,'Line');
        outPoints=get(outLine,'Points');
    end

    for i=1:length(ph.Inport)
        if isempty(idx)||i~=idx
            unusedLine=get(ph.Inport(i),'Line');
            if unusedLine>0




                sliceXfrmr.deleteLine(unusedLine);
            end
        end
    end


    sliceXfrmr.deleteBlock(bh);


    if~isempty(idx)
        sliceXfrmr.addLine(parent,[inPoints(end,:);outPoints(1,:)]);
    end
end
