function modSys=removeNVBlocks(sliceXfrmr,mdl,handles,hasSimState,varargin)





    import Transform.*;
    if nargin<9
        opts=SlicerConfiguration.getDefaultOptions;
    else
        opts=varargin{5};
    end
    if nargin<8
        deadBlockInOrig=[];
    else
        deadBlockInOrig=varargin{4};
    end

    if nargin<7
        refMdlToMdlBlk=[];
    else
        refMdlToMdlBlk=varargin{3};
    end

    if nargin<6
        redundantMerges=[];
    else
        redundantMerges=varargin{2};
    end

    if nargin<5
        systemNeedsOutput=[];
    else
        systemNeedsOutput=varargin{1};
    end

    if~isempty(sliceXfrmr)
        slMap=sliceXfrmr.sliceMapper;
    else
        slMap=[];
    end


    warnInConnect=warning('off','Simulink:Engine:InputNotConnected');
    warnOutConnect=warning('off','Simulink:Engine:OutputNotConnected');

    blkCnt=numel(handles);
    modSys=zeros(1,blkCnt);

    for i=1:blkCnt

        bh=handles(i);

        if ishandle(bh)&&strcmp(get_param(bh,'Type'),'block')








            parentBlk=get_param(bh,'Parent');
            if strcmp(get_param(parentBlk,'Type'),'block')&&...
                strcmp(get_param(parentBlk,'Commented'),'through')
                continue;
            end

            if strcmpi(get_param(bh,'Virtual'),'off')
                modSys(i)=get_param(parentBlk,'Handle');
            end

            bt=get(bh,'BlockType');
            switch bt
            case 'SubSystem'
                if~strcmp(get(handles(i),'MaskType'),'Sigbuilder block')
                    if~hasNonRedundatMergedOutput(bh,redundantMerges,slMap,refMdlToMdlBlk,deadBlockInOrig)
                        removeDisabledSys(sliceXfrmr,bh);
                    end
                else
                    disconnectBlock(sliceXfrmr,bh);
                    sliceXfrmr.deleteBlockSafe(bh);
                end
            case 'ModelReference'
                removeDisabledSys(sliceXfrmr,bh);
            case 'If'
                disconnectBlock(sliceXfrmr,bh);
                sliceXfrmr.deleteBlockSafe(bh);

            case 'SwitchCase'
                disconnectBlock(sliceXfrmr,bh);
                sliceXfrmr.deleteBlockSafe(bh);
            case 'Inport'
                inportB=get(handles(i),'Object');
                parent=inportB.getParent;
                if isa(parent,'Simulink.SubSystem')

                    portNumber=str2double(inportB.Port);
                    ph=parent.PortHandle.Inport(portNumber);
                    sliceXfrmr.deletePortLine(ph);
                    disconnectBlock(sliceXfrmr,bh);
                    sliceXfrmr.deleteBlockSafe(bh);
                else
                    disconnectBlock(sliceXfrmr,bh);
                    if~opts.SliceOptions.RootLevelInterfaces
                        sliceXfrmr.deleteBlockSafe(bh);
                    end
                end
            case 'Outport'


                outportB=get(handles(i),'Object');
                parent=outportB.getParent;
                if isa(parent,'Simulink.SubSystem')

                    portNumber=str2double(outportB.Port);
                    ph=parent.PortHandle.Outport(portNumber);
                    sliceXfrmr.deletePortLine(ph);
                else


                end
                disconnectBlock(sliceXfrmr,bh);
                if~isRootLevelBlock(bh)
                    sliceXfrmr.deleteBlockSafe(bh);
                end
            case 'DataStoreMemory'

                sliceXfrmr.deleteBlockSafe(bh);



            case 'TriggerPort'

            case 'EnablePort'

            case 'ForEach'

            case 'ForIterator'

            otherwise

                disconnectBlock(sliceXfrmr,bh);
                sliceXfrmr.deleteBlockSafe(bh);
            end
        end
    end


    warning([warnInConnect,warnOutConnect]);

    modSys=unique(modSys);
    modSys=modSys(modSys~=0);
end

function out=hasNonRedundatMergedOutput(blkH,redundantMerges,slMap,refMdlToMdlBlk,deadBlockInOrig)
    out=false;
    if~isempty(slMap)
        [origBlk,inlined]=slMap.findInOrig(blkH);

        if(~isempty(origBlk)&&inlined&&strcmp(get_param(origBlk,'Type'),'block_diagram'))
            if isempty(refMdlToMdlBlk)
                return;
            end

            origBlk=refMdlToMdlBlk(origBlk);
        end

        if~isempty(origBlk)
            thisPH=get_param(origBlk,'PortHandles');
            for pIdx=1:length(thisPH.Outport)
                if isNonRedundantOutputMerged(thisPH.Outport(pIdx),redundantMerges,deadBlockInOrig)
                    out=true;
                    return;
                end
            end
        end
    end
end

function out=isNonRedundantOutputMerged(portH,redundantMerges,deadBlockInOrig)
    out=false;
    pO=get(portH,'Object');


    if pO.Line~=-1
        try
            actDsts=pO.getActualDst;
            if(size(actDsts,1)==1)
                bh=get(actDsts(1,1),'ParentHandle');
                out=~ismember(bh,deadBlockInOrig)&&...
                ~ismember(bh,redundantMerges)&&...
                strcmp(get(bh,'BlockType'),'Merge');
            end
        catch Mx
        end
    end
end


function yesno=isRootLevelBlock(bh)
    bO=get(bh,'Object');
    yesno=isa(bO.getParent,'Simulink.BlockDiagram');
end
