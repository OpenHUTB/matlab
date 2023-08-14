function generateSLBlock(this,hC,targetBlkPath)


    [~,~,inputSigns,~,~,blockOptions]=this.getBlockInfo(hC);
    out1=hC.PirOutputSignals(1);
    targetMode=targetmapping.mode(out1);
    mulKind=blockOptions.mulKind;

    if(targetMode&&strcmp(inputSigns,'/'))

        in1signal=hC.PirInputSignals(1);
        in1Type=in1signal.Type;
        in1Dim=in1Type.getDimensions;
        isMatrix1x1=in1Dim(1)==1;
        matrixMode=strcmpi(mulKind,'Matrix(*)');

        if(matrixMode&&~isMatrix1x1)
            isMatrix2x2=(in1Dim(1)==2&&in1Dim(2)==2);

            if isMatrix2x2


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


                    add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
                    'Position',[xpos,ypos,xpos+30,ypos+40],...
                    'NumDelays',num2str(0),...
                    'samptime',num2str(-1));
                    add_line(targetBlkPath,'In1/1','Delay1/1','autorouting','on');


                    blkpath=[targetBlkPath,'/',hC.Name];
                    xpos=xpos+60;
                    add_block(originalBlkPath,blkpath,...
                    'Position',[xpos,ypos,xpos+30,ypos+40]);
                    add_line(targetBlkPath,'Delay1/1',[hC.Name,'/1'],'autorouting','on');
                    this.setBlockSampleTime(hC,blkpath);


                    xpos=xpos+60;
                    add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
                    'Position',[xpos,ypos,xpos+30,ypos+40],...
                    'NumDelays',num2str(latencyNum-1),...
                    'samptime',num2str(-1));
                    add_line(targetBlkPath,[hC.Name,'/1'],'Delay2/1','autorouting','on');
                    add_line(targetBlkPath,'Delay2/1','Out1/1','autorouting','on');

                end
            end
        end

    else



        validBlk=1;

        try
            originalBlkPath=getfullname(hC.SimulinkHandle);
        catch
            validBlk=0;
        end

        if validBlk
            lat=hC.getImplementationLatency;
            if~isempty(lat)&&lat>0
                generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,lat);
            elseif hC.getIsProtectedModel
                generateSLProtectedModel(this,hC,originalBlkPath,targetBlkPath);
            else
                targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
            end
        else

        end

    end