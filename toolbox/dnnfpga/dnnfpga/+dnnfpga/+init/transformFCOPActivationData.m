function transformFCOPActivationData(gcb,threadNum,FCDataDim)





    if isempty(threadNum)
        return;
    end





    if isempty(FCDataDim)
        return;
    end

    try


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);


        blocks=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
        for i=1:length(blocks)
            if(strcmp(get_param(blocks{i},'BlockType'),'SubSystem')&&...
                strcmp(get_param(blocks{i},'Name'),get_param(gcb,'Name')))||...
                strcmp(get_param(blocks{i},'BlockType'),'Inport')||...
                strcmp(get_param(blocks{i},'BlockType'),'Outport')
                continue;
            end
            delete_block(blocks{i});
        end

        createBlocksVectorOutConversion(gcb,threadNum,FCDataDim);
    catch me
        disp(me.message);
    end

end

function createBlocksVectorOutConversion(gcb,threadNum,FCDataDim)



    startX=0;
    startY=0;






    if(threadNum>=FCDataDim)

        blockWidth=25;
        blockHeight=25;
        curX=startX;
        curY=startY;
        for i=1:threadNum/FCDataDim
            curBlockName=[gcb,sprintf('/Vector Selector%d',i)];
            curY=curY+50;
            add_block('hdlsllib/Signal Routing/Selector',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'InputPortWidth','threadNum');
            vecStr=sprintf('%d:1:%d',(i-1)*FCDataDim+1,i*FCDataDim);
            set_param(curBlockName,'IndexParamArray',{vecStr});
        end

        if(threadNum/FCDataDim<=1)
            curX=curX;
            curY=curY-200;
            srcPortName='dataIn/1';
            destPortName='Vector Selector1/1';
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
            srcPortName='Vector Selector1/1';
            destPortName='dataOut/1';
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        else


            curX=curX+100;
            curY=curY-150;
            blockWidth=30;
            blockHeight=30;
            for i=2:threadNum/FCDataDim
                curBlockName=[gcb,sprintf('/Delay%d',i)];
                curY=curY+50;
                add_block('hdlsllib/Discrete/Delay',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
                DelayLength=sprintf('%d',i-1);
                set_param(curBlockName,'DelayLength',DelayLength,'ShowEnablePort','on');
            end


            curBlockName=[gcb,sprintf('/HDLCounter1')];
            curY=curY-180;
            curX=curX+120;
            blockWidth=60;
            blockHeight=30;
            add_block('hdlsllib/Sources/HDL Counter',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'CountEnbPort','on');
            set_param(curBlockName,'CountMax','threadNum/FCDataDim-1');
            set_param(curBlockName,'CountWordLen','log2(threadNum/FCDataDim)');



            curX=curX+150;
            blockWidth=30;
            blockHeight=10*threadNum;
            curBlockName=[gcb,'/Multiport Switch1'];
            add_block('hdlsllib/Signal Routing/Multiport Switch',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'DataPortOrder','Zero-based contiguous','Inputs','threadNum/FCDataDim');




            for i=2:threadNum/FCDataDim
                srcPortName='validIn/1';
                destPortName=sprintf('Delay%d/2',i);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end


            for i=1:threadNum/FCDataDim
                srcPortName=sprintf('dataIn/1');
                destPortName=sprintf('Vector Selector%d/1',i);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end
            for i=2:threadNum/FCDataDim
                srcPortName=sprintf('Vector Selector%d/1',i);
                destPortName=sprintf('Delay%d/1',i);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end


            add_line(gcb,'validIn/1','HDLCounter1/1','autorouting','on');
            add_line(gcb,'HDLCounter1/1','Multiport Switch1/1','autorouting','on');
            add_line(gcb,'Vector Selector1/1','Multiport Switch1/2','autorouting','on');

            for i=2:threadNum/FCDataDim
                srcPortName=sprintf('Delay%d/1',i);
                destPortName=sprintf('Multiport Switch1/%d',i+1);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end
            srcPortName='Multiport Switch1/1';
            destPortName='dataOut/1';
            add_line(gcb,srcPortName,destPortName,'autorouting','on');

        end

        add_line(gcb,'addrIn/1','addrOut/1','autorouting','on');
        add_line(gcb,'lenIn/1','lenOut/1','autorouting','on');
        add_line(gcb,'validIn/1','validOut/1','autorouting','on');

    else

        ratio=FCDataDim/threadNum;

        curX=startX;
        curY=startY;
        blockWidth=30;
        blockHeight=30;
        for i=2:ratio
            curBlockName=[gcb,sprintf('/Delay%d',i)];
            curY=curY-50;
            curX=curX+60;
            add_block('hdlsllib/Discrete/Delay',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'DelayLength','1','ShowEnablePort','on');
        end


        curBlockName=[gcb,sprintf('/Vector Concatenate1')];
        curX=curX+110;
        curY=curY-5;
        blockWidth=20;
        blockHeight=50*ratio;
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'NumInputs','FCDataDim/threadNum');



        curX=startX+120;
        curY=startY+120;
        blockWidth=80;
        blockHeight=30;
        curBlockName=[gcb,sprintf('/bitShift1')];
        add_block('hdlsllib/Logic and Bit Operations/Bit Shift',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'mode','Shift Right Logical','N','log2(FCDataDim/threadNum)');


        curBlockName=[gcb,sprintf('/HDLCounter1')];
        curY=curY+80;
        curX=curX+80;
        blockWidth=60;
        blockHeight=30;
        add_block('hdlsllib/Sources/HDL Counter',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'CountEnbPort','on');
        set_param(curBlockName,'CountMax','FCDataDim/threadNum-1');
        set_param(curBlockName,'CountWordLen','log2(FCDataDim/threadNum)');

        curBlockName=[gcb,sprintf('/CompareToConstant1')];
        curX=curX+80;
        blockWidth=100;
        blockHeight=30;
        add_block('simulink/Logic and Bit Operations/Compare To Constant',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'const','FCDataDim/threadNum-1');
        set_param(curBlockName,'relop','==');

        curBlockName=[gcb,sprintf('/And1')];
        curX=curX+150;
        curY=curY-5;
        blockWidth=30;
        blockHeight=30;
        add_block('simulink/Logic and Bit Operations/Logical Operator',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);



        curX=curX-200;
        curY=curY+120;
        blockWidth=80;
        blockHeight=30;
        curBlockName=[gcb,sprintf('/bitShift2')];
        add_block('hdlsllib/Logic and Bit Operations/Bit Shift',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'mode','Shift Right Logical','N','log2(FCDataDim/threadNum)');




        add_line(gcb,'validIn/1','HDLCounter1/1','autorouting','on');
        add_line(gcb,'HDLCounter1/1','CompareToConstant1/1','autorouting','on');
        add_line(gcb,'validIn/1','And1/1','autorouting','on');
        add_line(gcb,'CompareToConstant1/1','And1/2','autorouting','on');
        add_line(gcb,'And1/1','validOut/1','autorouting','on');

        srcPortName=sprintf('dataIn/1');
        destPortName=sprintf('Delay2/1');
        add_line(gcb,srcPortName,destPortName,'autorouting','on');

        for i=2:ratio-1
            srcPortName=sprintf('Delay%d/1',i);
            destPortName=sprintf('Delay%d/1',i+1);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end

        srcPortName=sprintf('dataIn/1');
        destPortName=sprintf('Vector Concatenate1/%d/%d',FCDataDim/threadNum);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');

        for i=2:ratio
            srcPortName=sprintf('Delay%d/1',i);
            destPortName=sprintf('Vector Concatenate1/%d',FCDataDim/threadNum-i+1);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end


        add_line(gcb,'addrIn/1','bitShift1/1','autorouting','on');
        add_line(gcb,'bitShift1/1','addrOut/1','autorouting','on');


        add_line(gcb,'lenIn/1','bitShift2/1','autorouting','on');
        add_line(gcb,'bitShift2/1','lenOut/1','autorouting','on');



        for i=2:ratio
            srcPortName=sprintf('validIn/1');
            destPortName=sprintf('Delay%d/2',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end

        srcPortName=sprintf('Vector Concatenate1/1');
        destPortName=sprintf('dataOut/1');
        add_line(gcb,srcPortName,destPortName,'autorouting','on');

    end

end
