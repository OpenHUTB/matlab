function generateSubsystemWithLatency(this,hC,targetBlkPath,latencyInfo)



























    hdldrv=hdlcurrentdriver;
    rates=hdldrv.PirInstance.getModelSampleTimes;
    if~isempty(rates>=0)
        BaseRate=1;
    else
        BaseRate=min(rates(rates>0));
    end

    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end

    if validBlk

        add_block('built-in/Subsystem',targetBlkPath);

        [turnhilitingon,color]=getHiliteInfo(hC);

        if turnhilitingon
            hiliteBlkAncestors(targetBlkPath,color);
        end

        for ii=1:length(hC.PirInputPorts)
            inportPath{ii}=[targetBlkPath,'/In',num2str(ii)];
            add_block('built-in/Inport',inportPath{ii});
            set_param(inportPath{ii},'Position',[85,78+((ii-1)*20),115,92+((ii-1)*20)]);
        end

        for ii=1:length(hC.PirOutputPorts)
            outportPath{ii}=[targetBlkPath,'/Out',num2str(ii)];
            add_block('built-in/Outport',outportPath{ii});
            set_param(outportPath{ii},'Position',[395,88+((ii-1)*20),425,102+((ii-1)*20)]);
        end

        blkpath=[targetBlkPath,'/',hC.Name];
        add_block(originalBlkPath,blkpath);
        set_param(blkpath,'Position',[185,75,215,115]);




        outputDelay=latencyInfo.outputDelay;
        for ii=1:length(hC.PirOutputPorts)
            sampleTime=BaseRate;
            if outputDelay>0
                gendelayblkpath=[targetBlkPath,'/',hC.Name,'_GenDelay',num2str(ii)];
                add_block('simulink/Discrete/Integer Delay',gendelayblkpath);
                set_param(gendelayblkpath,'NumDelays',num2str(outputDelay));
                set_param(gendelayblkpath,'samptime',num2str(sampleTime));
                set_param(gendelayblkpath,'Position',[185+80,75,215+80,115]);
                set_param(gendelayblkpath,'BackgroundColor',color);
                makeSyntheticBlkPassThrough(hC,gendelayblkpath);


                makeSyntheticBlkPassThrough(hC,gendelayblkpath);
                add_line(targetBlkPath,[hC.Name,'/',num2str(ii)],[hC.Name,'_GenDelay',num2str(ii),'/1'],'autorouting','on');
                add_line(targetBlkPath,[hC.Name,'_GenDelay',num2str(ii),'/1'],['Out',num2str(ii),'/1'],'autorouting','on');
            else
                add_line(targetBlkPath,[hC.Name,'/',num2str(ii)],['Out',num2str(ii),'/1'],'autorouting','on');
            end

        end

        for ii=1:length(hC.PirInputPorts)
            add_line(targetBlkPath,['In',num2str(ii),'/','1'],[hC.Name,'/',num2str(ii)],'autorouting','on');
        end






    else

    end


    function hiliteBlkAncestors(blkPath,color)


        currentTargetModel=bdroot;
        while~isempty(blkPath)&&~strcmp(blkPath,currentTargetModel)
            set_param(blkPath,'BackgroundColor',color);
            blkPath=get_param(blkPath,'Parent');
        end


        function[turnhilitingon,color]=getHiliteInfo(hC)


            srcMdlName=strtok(getfullname(hC.SimulinkHandle),'/');


            srcMdlCoderObj=hdlmodeldriver(srcMdlName);



            color=srcMdlCoderObj.getParameter('hilitecolor');
            turnhilitingon=srcMdlCoderObj.getParameter('hiliteancestors');



            function makeSyntheticBlkPassThrough(hC,syntheticBlkPath)

                hdltargetcc=hdltargetmodelcc(hC.SimulinkHandle);

                if~isempty(hdltargetcc)
                    hdltargetcc.forEach(...
                    syntheticBlkPath,...
                    'simulink/Discrete/Integer Delay',{},...
                    'hdldefaults.PassThroughHDLEmission');
                else

                end




