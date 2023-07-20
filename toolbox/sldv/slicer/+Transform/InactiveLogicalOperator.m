classdef InactiveLogicalOperator<Transform.AbstractTransform



    properties
        pivotBlockType='Logic';
        redundant=[];
    end
    methods
        function yesno=applicable(~,bh,~)
            yesno=strcmp(get(bh,'BlockType'),'Logic');
        end

        function[inactiveV,inactiveE,contextH]=analyze(obj,bh,mdl,cvd,mdlStructureInfo)

            obj.mdlStructureInfo=mdlStructureInfo;
            obj.model=mdl;

            inactiveV=[];
            [unc,inactiveE]=analyzeInactiveLogicalInputs(bh,cvd);

            if isempty(obj.redundant)
                obj.redundant=unc;
            else
                obj.redundant=[obj.redundant,unc];
            end

            contextH=[];
        end


        function obj=InactiveLogicalOperator()

            obj.redundant=struct('handle',[],'portInfo',[]);
        end

        function transform(~,~,~)

        end
        function transformCopy(obj,sliceXfrmr,refMdlToMdlBlk,mdl,mdlCopy)
            import Transform.*;
            if~isempty(obj.redundant)
                for k=1:length(obj.redundant)
                    LogicOp=get_param(obj.redundant(k).handle,'LogicOp');
                    origBlkH=obj.redundant(k).handle;
                    toRemove=getCopyHandles(origBlkH,refMdlToMdlBlk,mdl,mdlCopy);
                    if~isempty(toRemove)
                        disableUnusedInports(sliceXfrmr,toRemove,LogicOp,obj.redundant(k).portInfo,origBlkH);
                    end
                end
            end
        end
        function reset(this)
            this.redundant=[];
        end
    end

    properties


model
mdlStructureInfo
    end

end

function[redundant,deadInportH]=analyzeInactiveLogicalInputs(bh,cvd)

    import Analysis.*;

    deadInportH=[];
    LogicOp=get_param(bh,'LogicOp');
    obj=get(bh,'Object');
    if obj.isSynthesized
        origBlock=obj.getTrueOriginalBlock;
    else
        origBlock=bh;
    end

    [~,detail]=cvd.getConditionInfo(origBlock);
    ph=get_param(origBlock,'PortHandles');

    portInfo=[];

    if isempty(detail)
        redundant=struct('handle',[],'portInfo',[]);
        return;
    end
    if prod(get(ph.Outport(1),'CompiledPortDimensions'))>1

        return;
    end
    for i=1:length(detail)
        neverTrue=detail(i).trueCnts==0;
        neverFalse=detail(i).falseCnts==0;
        if neverTrue&&neverFalse

            neverTrue=false;
            neverFalse=false;
        end
        lh=get(ph.Inport(i),'Line');
        linePoints=[];
        srcBlockPos=[];
        origSrcBlockHandle='';
        if lh>0
            linePoints=get(lh,'Points');
            srcBlockHandle=get(lh,'SrcBlockHandle');
            if srcBlockHandle>0
                srcBlockPos=get(srcBlockHandle,'Position');
                origSrcBlockHandle=srcBlockHandle;
            end
        end
        pInfo=struct('index',i,'neverTrue',neverTrue,'neverFalse',neverFalse,...
        'linePoints',linePoints,'srcBlockPos',srcBlockPos,'origSrcBlockHandle',origSrcBlockHandle);
        if isempty(portInfo)
            portInfo=pInfo;
        else
            portInfo(end+1)=pInfo;%#ok<AGROW>
        end
        if neverTrue||neverFalse
            deadInportH=[deadInportH;ph.Inport(i)];%#ok<AGROW>
        end
    end
    [alwaysTrueOut,alwaysFalseOut]=analyzeOutportState(portInfo,LogicOp);

    if alwaysTrueOut||alwaysFalseOut
        deadInportH=ph.Inport';
    end
    redundant=struct('handle',bh,'portInfo',portInfo);

end


function[alwaysTrueOut,alwaysFalseOut]=analyzeOutportState(portInfo,LogicOp)


    alwaysTrueOut=false;
    alwaysFalseOut=false;
    switch lower(LogicOp)
    case 'and'
        alwaysTrueOut=true;
        for i=1:length(portInfo)
            alwaysTrueOut=alwaysTrueOut&&portInfo(i).neverFalse;
            alwaysFalseOut=alwaysFalseOut||portInfo(i).neverTrue;
        end
    case 'or'
        alwaysFalseOut=true;
        for i=1:length(portInfo)
            alwaysTrueOut=alwaysTrueOut||portInfo(i).neverFalse;
            alwaysFalseOut=alwaysFalseOut&&portInfo(i).neverTrue;
        end
    case 'nor'
        alwaysTrueOut=true;
        for i=1:length(portInfo)
            alwaysTrueOut=alwaysTrueOut&&portInfo(i).neverTrue;
            alwaysFalseOut=alwaysFalseOut||portInfo(i).neverFalse;
        end
    case 'nand'
        alwaysFalseOut=true;
        for i=1:length(portInfo)
            alwaysTrueOut=alwaysTrueOut||portInfo(i).neverTrue;
            alwaysFalseOut=alwaysFalseOut&&portInfo(i).neverFalse;
        end
    case 'xor'
        if numel(portInfo)==2
            if portInfo(1).neverTrue&&portInfo(2).neverFalse
                alwaysTrueOut=true;
            elseif portInfo(1).neverFalse&&portInfo(2).neverTrue
                alwaysTrueOut=true;
            elseif portInfo(1).neverTrue&&portInfo(2).neverTrue
                alwaysFalseOut=true;
            elseif portInfo(1).neverFalse&&portInfo(2).neverFalse
                alwaysFalseOut=true;
            end
        end
    case 'nxor'
        if numel(portInfo)==2
            if portInfo(1).neverTrue&&portInfo(2).neverFalse
                alwaysFalseOut=true;
            elseif portInfo(1).neverFalse&&portInfo(2).neverTrue
                alwaysFalseOut=true;
            elseif portInfo(1).neverTrue&&portInfo(2).neverTrue
                alwaysTrueOut=true;
            elseif portInfo(1).neverFalse&&portInfo(2).neverFalse
                alwaysTrueOut=true;
            end
        end
    case 'not'
        assert(numel(portInfo)==1)
        alwaysTrueOut=portInfo(1).neverTrue;
        alwaysFalseOut=portInfo(1).neverFalse;
    otherwise
    end
end
function disableUnusedInports(sliceXfrmr,bh,LogicOp,portInfo,origBlkH)

    [alwaysTrueOut,alwaysFalseOut]=analyzeOutportState(portInfo,LogicOp);

    if alwaysTrueOut
        removeRedundantLogicalBlock(sliceXfrmr,bh,'true',origBlkH);
    elseif alwaysFalseOut
        removeRedundantLogicalBlock(sliceXfrmr,bh,'false',origBlkH);
    else
        replaceInputsByConstant(sliceXfrmr,bh,portInfo);
    end

end

function replaceInputsByConstant(sliceXfrmr,bh,portInfo)


    ph=get(bh,'PortHandles');
    blockPath=getfullname(bh);

    for i=1:length(portInfo)
        if portInfo(i).neverFalse||portInfo(i).neverTrue
            if portInfo(i).neverFalse
                Value='true';
            else
                Value='false';
            end
            if~isempty(portInfo(i).linePoints)&&~isempty(portInfo(i).srcBlockPos)




                lineH=get(ph.Inport(i),'Line');
                if lineH>0
                    srcBlockH=get(lineH,'SrcBlockHandle');
                    origPos=get(srcBlockH,'Position');
                    set_param(srcBlockH,'Position',origPos-[10,0,10,0]);
                    sliceXfrmr.deleteLine(lineH);
                end
                newBlockPath=[getfullname(get_param(bh,'Parent')),'/',get_param(portInfo(i).origSrcBlockHandle,'Name')];
                newBlkH=sliceXfrmr.replaceByConstant(newBlockPath,portInfo(i).srcBlockPos,Value);
                newPH=get(newBlkH,'PortHandles');
                thisLH=add_line(get(bh,'Parent'),newPH.Outport(1),ph.Inport(i),'autorouting','on');






                linePoints=get(thisLH,'Points');
                origLinePoints=portInfo(i).linePoints;
                if size(linePoints,1)>2
                    for j=2:size(linePoints,1)-1
                        if size(origLinePoints,1)>=j
                            linePoints(j,:)=origLinePoints(j,:);
                        end
                    end
                end
                showName=get_param(portInfo(i).origSrcBlockHandle,'ShowName');
                set_param(newBlkH,'ShowName',showName);

                sliceXfrmr.sliceMapper.origTransform(portInfo(i).origSrcBlockHandle,newBlkH,true);
            end
        end
    end
end
function removeRedundantLogicalBlock(sliceXfrmr,bh,Value,origBlkH)
    ph=get(bh,'PortHandles');
    showName=get_param(bh,'ShowName');
    for i=1:length(ph.Inport)
        unusedLine=get(ph.Inport(i),'Line');
        if unusedLine>0
            sliceXfrmr.deleteLine(unusedLine);
        end
    end

    portPos=get(ph.Outport(1),'Position');
    blockPos=[portPos(1)-30,...
    portPos(2)-7,...
    portPos(1),...
    portPos(2)+7];
    blockPath=getfullname(bh);

    ph=get(origBlkH,'PortHandle');
    origMdlPort=ph.Outport(1);


    sliceXfrmr.deleteBlock(bh);
    newBlkH=sliceXfrmr.replaceByConstant(blockPath,blockPos,Value,origMdlPort);

    sliceXfrmr.sliceMapper.origTransform(origBlkH,newBlkH,true);

    set_param(newBlkH,'ShowName',showName);
end
