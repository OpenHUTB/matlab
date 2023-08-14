function fcnCallSplitJunction(obj)










    if isR2009bOrEarlier(obj.ver)
        fcncallSplitBlks=slexportprevious.utils.findBlockType(obj.modelName,'FunctionCallSplit');
        if isempty(fcncallSplitBlks)
            return;
        end

        for bIdx=1:length(fcncallSplitBlks)
            blk=fcncallSplitBlks{bIdx};

            blkHdl=get_param(blk,'Handle');



            Simulink.BlockDiagram.createSubSystem(blkHdl);


            ssBlk=get_param(blkHdl,'Parent');


            ph=get_param(blkHdl,'PortHandles');
            for inportIndex=1:length(ph.Inport)
                inport=ph.Inport(inportIndex);
                line=get_param(inport,'Line');
                inportBlock=get_param(line,'SrcBlockHandle');
                set_param(inportBlock,'Port',num2str(get_param(inport,'PortNumber')));
            end

            for outportIndex=1:length(ph.Outport)
                outport=ph.Outport(outportIndex);
                line=get_param(outport,'Line');
                outportBlocks=get_param(line,'DstBlockHandle');
                for outportBlockIndex=1:length(outportBlocks)
                    outportBlock=outportBlocks(outportBlockIndex);
                    set_param(outportBlock,'Port',num2str(get_param(outport,'PortNumber')));
                end
            end

            obj.replaceWithEmptySubsystem(ssBlk,'Function-Call Split');

        end

    elseif isR2015bOrEarlier(obj.ver)
        fcncallSplitBlks=slexportprevious.utils.findBlockType(obj.modelName,'FunctionCallSplit');

        for bIdx=1:length(fcncallSplitBlks)
            blk=fcncallSplitBlks{bIdx};
            numOutputPorts=str2num(get_param(blk,'NumOutputPorts'));%#ok


            if(numOutputPorts<=2)
                continue;
            end


            blkHdl=get_param(blk,'Handle');
            blkName=get_param(blk,'Name');



            Simulink.BlockDiagram.createSubSystem(blkHdl);


            ssBlk=get_param(blkHdl,'Parent');


            for outputPortNum=1:(numOutputPorts-1)
                blockPath=[ssBlk,'/SplitBlock',num2str(outputPortNum)];
                add_block('simulink/Ports & Subsystems/Function-Call Split',...
                blockPath,'MakeNameUnique','on');
                set_param([ssBlk,'/SplitBlock',num2str(outputPortNum)],'IconShape','round');
                position=get_param(blockPath,'Position');
                splitBlockWidth=abs(position(3)-position(1));
                splitBlockHeight=abs(position(4)-position(2));
                offset=[splitBlockWidth*2*outputPortNum,0,splitBlockWidth*2*outputPortNum,0];
                new_position=position+offset;
                set_param(blockPath,'Position',new_position);
            end


            for outputPortNum=2:numOutputPorts-1
                srcBlock=['SplitBlock',num2str(outputPortNum-1)];
                dstBlock=['SplitBlock',num2str(outputPortNum)];
                add_line(ssBlk,[srcBlock,'/2'],[dstBlock,'/1']);
            end



            ph=get_param(blkHdl,'PortHandles');
            assert(length(ph.Inport)==1);
            inport=ph.Inport(1);
            line=get_param(inport,'Line');
            inportBlock=get_param(line,'SrcBlockHandle');
            inportName=get_param(inportBlock,'Name');
            delete_line(ssBlk,[inportName,'/1'],[blkName,'/1']);
            add_line(ssBlk,[inportName,'/1'],'SplitBlock1/1');
            set_param(inportBlock,'Port',num2str(get_param(inport,'PortNumber')));
            inportPosition=get_param(inportBlock,'Position');
            splitBlockPosition=get_param([ssBlk,'/SplitBlock1'],'Position');
            set_param(inportBlock,'Position',[inportPosition(1),splitBlockPosition(2)...
            ,inportPosition(3),splitBlockPosition(4)]);

            lastSplitBlockPosition=get_param([ssBlk,'/SplitBlock',num2str(numOutputPorts-1)],'Position');
            outportBlockHorzPosition=[(lastSplitBlockPosition(1)+4*splitBlockWidth),0...
            ,(lastSplitBlockPosition(3)+4*splitBlockWidth),0];



            for outportIndex=1:length(ph.Outport)
                outport=ph.Outport(outportIndex);
                line=get_param(outport,'Line');
                outportBlocks=get_param(line,'DstBlockHandle');
                for outportBlockIndex=1:length(outportBlocks)
                    outportBlock=outportBlocks(outportBlockIndex);
                    outportName=get_param(outportBlock,'Name');
                    set_param(outportBlock,'Port',num2str(get_param(outport,'PortNumber')));
                    delete_line(ssBlk,[blkName,'/',num2str(outportIndex)],[outportName,'/1']);
                    if(outportIndex==length(ph.Outport))
                        add_line(ssBlk,['SplitBlock',(num2str(outportIndex)-1),'/2'],...
                        [outportName,'/1']);
                    else
                        add_line(ssBlk,['SplitBlock',num2str(outportIndex),'/1'],...
                        [outportName,'/1']);
                    end
                    outportVertPositionOffset=(length(ph.Outport)-outportIndex)*2*splitBlockHeight;
                    outportBlockVertPosition=[0,(lastSplitBlockPosition(2)+outportVertPositionOffset)...
                    ,0,(lastSplitBlockPosition(4)+outportVertPositionOffset)];
                    set_param(outportBlock,'Position',outportBlockHorzPosition+outportBlockVertPosition);
                end
            end


            delete_block([ssBlk,'/',blkName]);
        end
    end



