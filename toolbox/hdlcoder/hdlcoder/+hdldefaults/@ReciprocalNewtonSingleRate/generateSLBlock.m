function generateSLBlock(this,hC,targetBlkPath)



    reporterrors(this,hC);

    try
        if~hC.Synthetic
            originalBlkPath=getfullname(hC.SimulinkHandle);
        else
            originalBlkPath=getfullname(hC.getSLBlockHandle);
        end
        validBlk=1;
    catch me
        validBlk=0;
    end


    latencyInfo=this.getLatencyInfo(hC);
    latencyNum=latencyInfo.outputDelay;

    if validBlk
        load_system('simulink');


        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);


        xpos=185;
        ypos=70;


        if latencyNum>0
            add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'NumDelays',num2str(1),...
            'samptime',num2str(-1));
            add_line(targetBlkPath,'In1/1','Delay1/1','autorouting','on');
        end


        blkpath=[targetBlkPath,'/',hC.Name];
        xpos=xpos+60;
        add_block(originalBlkPath,blkpath,...
        'Position',[xpos,ypos,xpos+30,ypos+40]);
        this.setBlockSampleTime(hC,blkpath);

        if latencyNum>0
            add_line(targetBlkPath,'Delay1/1',[hC.Name,'/1'],'autorouting','on');
        else
            add_line(targetBlkPath,'In1/1',[hC.Name,'/1'],'autorouting','on');
        end


        xpos=xpos+60;

        if latencyNum>0
            add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'NumDelays',num2str(latencyNum-1),...
            'samptime',num2str(-1));
            add_line(targetBlkPath,[hC.Name,'/1'],'Delay2/1','autorouting','on');
            add_line(targetBlkPath,'Delay2/1','Out1/1','autorouting','on');
        else
            add_line(targetBlkPath,[hC.Name,'/1'],'Out1/1','autorouting','on');
        end

    end
end
