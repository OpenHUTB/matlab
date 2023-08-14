function generateSLBlock(this,hC,targetBlkPath)





    impl=getFunctionImpl(this,hC);

    if isempty(impl)

        reporterrors(this,hC);
        originalBlkPath=getfullname(hC.SimulinkHandle);


        latencyInfo=this.getLatencyInfo(hC);
        latencyNum=latencyInfo.outputDelay;
        xpos=220;
        ypos=65;

        load_system('simulink');

        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);

        blkpath=[targetBlkPath,'/',hC.Name];
        add_block(originalBlkPath,blkpath,'Position',[xpos,ypos,xpos+30,ypos+40]);
        add_line(targetBlkPath,'In1/1',[hC.Name,'/1'],'autorouting','on');
        add_line(targetBlkPath,'In2/1',[hC.Name,'/2'],'autorouting','on');
        this.setBlockSampleTime(hC,blkpath);
        xpos=xpos+60;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(latencyNum),...
        'samptime',num2str(-1));
        add_line(targetBlkPath,[hC.Name,'/1'],'Delay2/1','autorouting','on');
        add_line(targetBlkPath,'Delay2/1','Out1/1','autorouting','on');
    else
        impl.generateSLBlock(hC,targetBlkPath);
    end

end






