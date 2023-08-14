function transformFCIPActivationData(gcb,threadNum,FCDataDim)





    if isempty(threadNum)
        return;
    end





    if isempty(FCDataDim)
        return;
    end
























    try


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


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);
        createBlocks(gcb,threadNum,FCDataDim);
    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,threadNum,FCDataDim)

    startX=0;
    startY=0;

    if(threadNum>=FCDataDim)

        if(threadNum/FCDataDim<=1)

            curX=startX;
            curY=startY;
            blockWidth=30;
            blockHeight=30;
            for i=1:3
                curBlockName=[gcb,sprintf('/Delay%d',i)];
                curY=curY-50;
                curX=curX+60;
                add_block('hdlsllib/Discrete/Delay',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
                set_param(curBlockName,'DelayLength','0');
            end
            add_line(gcb,'inAddr/1','Delay1/1','autorouting','on');
            add_line(gcb,'Delay1/1','outAddr/1','autorouting','on');

            add_line(gcb,'inWrValid/1','Delay2/1','autorouting','on');
            add_line(gcb,'Delay2/1','outWrValid/1','autorouting','on');

            add_line(gcb,'inData/1','Delay3/1','autorouting','on');
            add_line(gcb,'Delay3/1','outData/1','autorouting','on');
        else


            curX=startX;
            curY=startY;
            blockWidth=30;
            blockHeight=30;
            for i=2:threadNum/FCDataDim
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
            blockHeight=50*threadNum/FCDataDim;
            add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'NumInputs','threadNum/FCDataDim');



            curX=startX+120;
            curY=startY+120;
            blockWidth=80;
            blockHeight=30;
            curBlockName=[gcb,sprintf('/bitShift1')];
            add_block('hdlsllib/Logic and Bit Operations/Bit Shift',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'mode','Shift Right Logical','N','log2(threadNum/FCDataDim)');


            curBlockName=[gcb,sprintf('/HDLCounter1')];
            curY=curY+80;
            curX=curX+80;
            blockWidth=60;
            blockHeight=30;
            add_block('hdlsllib/Sources/HDL Counter',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'CountEnbPort','on');
            set_param(curBlockName,'CountMax','threadNum/FCDataDim-1');
            set_param(curBlockName,'CountWordLen','log2(threadNum/FCDataDim)');

            curBlockName=[gcb,sprintf('/CompareToConstant1')];
            curX=curX+80;
            blockWidth=100;
            blockHeight=30;
            add_block('simulink/Logic and Bit Operations/Compare To Constant',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'const','threadNum/FCDataDim-1');
            set_param(curBlockName,'relop','==');

            curBlockName=[gcb,sprintf('/And1')];
            curX=curX+150;
            curY=curY-5;
            blockWidth=30;
            blockHeight=30;
            add_block('simulink/Logic and Bit Operations/Logical Operator',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);


            add_line(gcb,'inWrValid/1','HDLCounter1/1','autorouting','on');
            add_line(gcb,'HDLCounter1/1','CompareToConstant1/1','autorouting','on');
            add_line(gcb,'inWrValid/1','And1/1','autorouting','on');
            add_line(gcb,'CompareToConstant1/1','And1/2','autorouting','on');
            add_line(gcb,'And1/1','outWrValid/1','autorouting','on');

            srcPortName=sprintf('inData/1');
            destPortName=sprintf('Delay2/1');
            add_line(gcb,srcPortName,destPortName,'autorouting','on');

            for i=2:threadNum/FCDataDim-1
                srcPortName=sprintf('Delay%d/1',i);
                destPortName=sprintf('Delay%d/1',i+1);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end

            srcPortName=sprintf('inData/1');
            destPortName=sprintf('Vector Concatenate1/%d/%d',threadNum/FCDataDim);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');

            for i=2:threadNum/FCDataDim
                srcPortName=sprintf('Delay%d/1',i);
                destPortName=sprintf('Vector Concatenate1/%d',threadNum/FCDataDim-i+1);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end


            add_line(gcb,'inAddr/1','bitShift1/1','autorouting','on');
            add_line(gcb,'bitShift1/1','outAddr/1','autorouting','on');


            for i=2:threadNum/FCDataDim
                srcPortName=sprintf('inWrValid/1');
                destPortName=sprintf('Delay%d/2',i);
                add_line(gcb,srcPortName,destPortName,'autorouting','on');
            end

            srcPortName=sprintf('Vector Concatenate1/1');
            destPortName=sprintf('outData/1');
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end



        curX=curX+110;
        curY=curY+50;
        curBlockName=[gcb,sprintf('/dready constant1')];
        add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[curX,curY,curX+30,curY+30]);
        set_param(curBlockName,'OutDataTypeStr','boolean');
        add_line(gcb,'dready constant1/1','dready_out/1','autorouting','on');

    else



        curX=startX;
        curY=startY;
        curBlockName=[gcb,'/DataFIFO'];
        add_block('dnnfpgaFCIPDataFIFO/DataFIFO',curBlockName,'Position',[curX,curY,curX+100,curY+200]);


        blockWidth=25;
        blockHeight=25;
        curX=curX+200;
        curY=curY+200;
        for i=1:FCDataDim/threadNum
            curBlockName=[gcb,sprintf('/Vector Selector%d',i)];
            curY=curY+50;
            add_block('hdlsllib/Signal Routing/Selector',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param(curBlockName,'InputPortWidth','FCDataDim');
            vecStr=sprintf('%d:1:%d',(i-1)*threadNum+1,i*threadNum);
            set_param(curBlockName,'IndexParamArray',{vecStr});
        end


        curX=curX+10;
        curY=curY+100;
        curBlockName=[gcb,'/Tapped Delay1'];
        add_block('hdlsllib/Discrete/Tapped Delay',curBlockName,'Position',[curX,curY,curX+30,curY+30]);
        set_param(curBlockName,'NumDelays','FCDataDim/threadNum-1','includeCurrent','on');


        curX=curX+80;
        curY=curY;
        curBlockName=[gcb,'/OR1'];
        add_block('simulink/Logic and Bit Operations/Logical Operator',curBlockName,'Position',[curX,curY,curX+30,curY+30]);
        set_param(curBlockName,'Operator','OR','Inputs','1');


        curX=curX+100;
        curY=curY-150;
        blockWidth=30;
        blockHeight=30;
        for i=2:FCDataDim/threadNum
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
        set_param(curBlockName,'CountMax','FCDataDim/threadNum-1');
        set_param(curBlockName,'CountWordLen','log2(FCDataDim/threadNum)');



        curX=curX+150;
        blockWidth=30;
        blockHeight=10*threadNum;
        curBlockName=[gcb,'/Multiport Switch1'];
        add_block('hdlsllib/Signal Routing/Multiport Switch',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'DataPortOrder','Zero-based contiguous','Inputs','FCDataDim/threadNum');



        curX=curX-200;
        curY=curY+300;
        blockWidth=80;
        blockHeight=30;
        curBlockName=[gcb,sprintf('/bitShift1')];
        add_block('hdlsllib/Logic and Bit Operations/Bit Shift',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'mode','Shift Left Logical','N','log2(FCDataDim/threadNum)');


        curX=curX+150;
        curBlockName=[gcb,'/addr add1'];
        add_block('hdlsllib/Math Operations/Add',curBlockName,'Position',[curX,curY,curX+40,curY+40]);
        set_param(curBlockName,'OutDataTypeStr','Inherit: Inherit via back propagation');




        add_line(gcb,'inAddr/1','DataFIFO/1','autorouting','on');
        add_line(gcb,'inData/1','DataFIFO/2','autorouting','on');
        add_line(gcb,'inWrValid/1','DataFIFO/3','autorouting','on');


        add_line(gcb,'DataFIFO/3','Tapped Delay1/1','autorouting','on');
        add_line(gcb,'Tapped Delay1/1','OR1/1','autorouting','on');

        for i=2:FCDataDim/threadNum
            srcPortName='OR1/1';
            destPortName=sprintf('Delay%d/2',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end


        for i=1:FCDataDim/threadNum
            srcPortName=sprintf('DataFIFO/2');
            destPortName=sprintf('Vector Selector%d/1',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end
        for i=2:FCDataDim/threadNum
            srcPortName=sprintf('Vector Selector%d/1',i);
            destPortName=sprintf('Delay%d/1',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end


        add_line(gcb,'OR1/1','HDLCounter1/1','autorouting','on');
        add_line(gcb,'HDLCounter1/1','Multiport Switch1/1','autorouting','on');
        add_line(gcb,'Vector Selector1/1','Multiport Switch1/2','autorouting','on');

        for i=2:FCDataDim/threadNum
            srcPortName=sprintf('Delay%d/1',i);
            destPortName=sprintf('Multiport Switch1/%d',i+1);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end
        srcPortName='Multiport Switch1/1';
        destPortName='outData/1';
        add_line(gcb,srcPortName,destPortName,'autorouting','on');


        add_line(gcb,'DataFIFO/1','bitShift1/1','autorouting','on');
        add_line(gcb,'bitShift1/1','addr add1/1','autorouting','on');
        add_line(gcb,'HDLCounter1/1','addr add1/2','autorouting','on');
        add_line(gcb,'addr add1/1','outAddr/1','autorouting','on');


        add_line(gcb,'OR1/1','outWrValid/1','autorouting','on');


        add_line(gcb,'DataFIFO/4','dready_out/1','autorouting','on');

    end





end
