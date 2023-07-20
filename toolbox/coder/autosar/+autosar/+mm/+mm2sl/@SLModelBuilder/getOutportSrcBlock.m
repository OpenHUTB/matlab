





function srcBlock=getOutportSrcBlock(currOutBlk,srcBlkType)
    srcBlock=[];
    try
        inportNum=1;

        cBlkType=get_param(currOutBlk,'BlockType');
        if~strcmpi(cBlkType,'Outport')&&...
            ~strcmpi(cBlkType,'Goto')&&...
            ~strcmpi(cBlkType,'Merge')

            return
        end

        cLine=get_param(currOutBlk,'LineHandles');
        if iscell(cLine)
            cLine=cLine{1};
        end

        if cLine.Inport(inportNum)>0
            sPort=get_param(cLine.Inport(inportNum),'SrcPortHandle');
            if~isempty(sPort)&&sPort>0
                pBlock=get_param(sPort,'Parent');
                pBlockType=get_param(pBlock,'BlockType');

                if strcmpi(pBlockType,srcBlkType)

                    srcBlock=pBlock;
                elseif strcmpi(pBlockType,'SubSystem')
                    outPortIdx=num2str(get_param(sPort,'PortNumber'));
                    outPort=find_system(pBlock,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,...
                    'FollowLinks','on','LookUnderMasks','all','Type','Block',...
                    'BlockType','Outport','Port',outPortIdx);
                    if iscell(outPort)
                        outPort=outPort{1};
                    end
                    srcBlock=autosar.mm.mm2sl.ModelBuilder.getOutportSrcBlock(...
                    outPort,srcBlkType);
                    return
                else

                    return
                end
            end
        end
    catch Me %#ok<NASGU>

        return
    end
end
