function generateSLBlock(this,hC,targetBlkPath)



    validBlk=1;
    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end

    if validBlk

        cordicInfo=this.getBlockInfo(hC.SimulinkHandle);
        latencyNum=cordicInfo.iterNum;
        outType=hC.PirOutputSignals.Type.BaseType;
        outTypeStr=sprintf('fixdt(%d, %d, %d)',outType.Signed,...
        outType.WordLength,-outType.FractionLength);

        load_system('simulink');


        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);


        outport=[targetBlkPath,'/Out1'];
        outpos=get_param(outport,'Position');
        set_param(outport,'Position',outpos+[180,25,180,25]);


        xpos=185;
        ypos=70;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
        'Position',[xpos,ypos,xpos+30,ypos+30],...
        'NumDelays',int2str(latencyNum+1),...
        'samptime','-1');
        add_line(targetBlkPath,'In1/1','Delay1/1','autorouting','on');


        ypos=110;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
        'Position',[xpos,ypos,xpos+30,ypos+30],...
        'NumDelays',int2str(1),...
        'samptime','-1');
        add_line(targetBlkPath,'In2/1','Delay2/1','autorouting','on');


        ypos=105;
        blkpath=[targetBlkPath,'/',hC.Name];
        xpos=xpos+60;
        add_block('simulink/Math Operations/Trigonometric Function',blkpath,...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'Operator','sincos','ApproximationMethod','CORDIC',...
        'NumberOfIterations',int2str(cordicInfo.iterNum));
        add_line(targetBlkPath,'Delay2/1',[hC.Name,'/1'],'autorouting','on');
        this.setBlockSampleTime(hC,blkpath);


        ypos=100;
        xpos=xpos+55;
        outDelay=int2str(latencyNum);
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay3'],...
        'Position',[xpos,ypos,xpos+30,ypos+30],...
        'NumDelays',outDelay,'samptime','-1');
        add_line(targetBlkPath,[hC.Name,'/1'],'Delay3/1','autorouting','on');

        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay4'],...
        'Position',[xpos,ypos+60,xpos+30,ypos+90],...
        'NumDelays',outDelay,'samptime','-1');
        add_line(targetBlkPath,[hC.Name,'/2'],'Delay4/1','autorouting','on');


        xpos=370;
        ypos=92;
        add_block('simulink/Math Operations/Product',[targetBlkPath,'/Mul1'],...
        'OutDataTypeStr',outTypeStr,...
        'Position',[xpos,ypos,xpos+30,ypos+30]);
        add_line(targetBlkPath,'Delay3/1','Mul1/2','autorouting','on');
        add_line(targetBlkPath,'Delay1/1','Mul1/1','autorouting','on');
        ypos=152;
        add_block('simulink/Math Operations/Product',[targetBlkPath,'/Mul2'],...
        'OutDataTypeStr',outTypeStr,...
        'Position',[xpos,ypos,xpos+30,ypos+30]);
        add_line(targetBlkPath,'Delay4/1','Mul2/2','autorouting','on');
        add_line(targetBlkPath,'Delay1/1','Mul2/1','autorouting','on');


        xpos=440;
        ypos=102;
        add_block('simulink/Math Operations/Real-Imag to Complex',...
        [targetBlkPath,'/RI2C'],'Position',[xpos,ypos,xpos+30,ypos+30]);
        add_line(targetBlkPath,'Mul1/1','RI2C/2','autorouting','on');
        add_line(targetBlkPath,'Mul2/1','RI2C/1','autorouting','on');


        add_line(targetBlkPath,'RI2C/1','Out1/1','autorouting','on');
    end
end

