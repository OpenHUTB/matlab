function generateSLBlock(this,hC,targetBlkPath)






    reporterrors(this,hC);

    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch me %#ok<NASGU>
        validBlk=0;
    end

    hF=this.getHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    oldPVs=s.pcache;
    hF.setimplementation;
    implementation=hF.Implementation;

    if validBlk
        switch implementation
        case 'parallel'
            latencyInfo=this.getLatencyInfo(hC);
            outputlat=latencyInfo.outputDelay;
            inputlat=latencyInfo.inputDelay;
            if outputlat>0||inputlat>0
                targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);


                if outputlat>0
                    preg=hF.getHDLParameter('filter_pipelined');
                    if preg
                        blockPVs=getModifiedBlockParamValues(this,hC);
                    else
                        blockPVs={};
                    end
                    [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath,blockPVs);
                    this.addSLBlockLatency(hC,targetBlkPath,latencyInfo,outputBlk,outputBlkPosition);
                else
                    if inputlat>0
                        blockPVs=getModifiedBlockParamValues(this,hC);
                        [outputBlk,outputBlkPosition]=addFilterBlkInputLatency(this,hC,targetBlkPath,latencyInfo);
                        addFilterBlock(this,hC,originalBlkPath,targetBlkPath,outputBlk,outputBlkPosition,blockPVs);


                    end
                end
            else
                targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
            end

        case{'serial','serialcascade','distributedarithmetic'}

            latencyInfo=this.getLatencyInfo(hC);
            outputlat=latencyInfo.outputDelay;
            if outputlat>0
                targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);

                blockPVs=getModifiedBlockParamValues(this,hC);
                [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath,blockPVs);
                this.addSLBlockLatency(hC,targetBlkPath,latencyInfo,outputBlk,outputBlkPosition);
            else

                blockPVs=getModifiedBlockParamValues(this,hC);
                add_block(originalBlkPath,targetBlkPath,blockPVs{:});
                [turnhilitingon,color]=this.getHiliteInfo(hC);
                set_param(targetBlkPath,'BackgroundColor',color);

                if turnhilitingon
                    this.hiliteBlkAncestors(targetBlkPath,color);
                end




            end

        otherwise
            targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
        end
    end

    this.unApplyParams(oldPVs);


    function[outputBlk,outputBlkPosition]=addFilterBlkInputLatency(this,hC,targetBlkPath,latencyInfo)


        blkpath=[targetBlkPath,'/',hC.Name,'_GenInputDelay'];

        load_system('simulink');

        add_intDelay(this,hC,blkpath,latencyInfo);


        set_param(blkpath,'Position',[185,75,215,115]);

        add_line(targetBlkPath,'In1/1',[hC.Name,'_GenInputDelay','/1'],'autorouting','on');

        outputBlk=[hC.Name,'_GenInputDelay'];
        outputBlkPosition=[215,75];

        [~,color]=this.getHiliteInfo(hC);
        set_param(blkpath,'BackgroundColor',color);



        function[]=add_intDelay(this,hC,blkPath,latencyInfo)

            current_system=get_param(0,'currentSystem');
            simulink_present=find_system('type','block_diagram','name','simulink');
            if isempty(simulink_present)
                load_system('simulink');
            end
            set_param(0,'currentSystem',current_system);
            add_block('simulink/Discrete/Integer Delay',blkPath);
            if isempty(simulink_present)
                bdclose('simulink');
            end

            set_param(blkPath,'NumDelays',num2str(latencyInfo.inputDelay));


            [~,color]=this.getHiliteInfo(hC);
            set_param(blkPath,'BackgroundColor',color);


            function addFilterBlock(this,hC,srcBlkPath,targetBlkPath,outputBlk,lastBlkPosition,srcBlkParam)

                origpos=get_param(srcBlkPath,'position');
                blkSize=[origpos(3)-origpos(1),origpos(4)-origpos(2)];

                blkPosition=[lastBlkPosition(1)+50,lastBlkPosition(2)];

                if nargin==4
                    srcBlkParam={};
                end

                position=[blkPosition,blkPosition+blkSize];
                blkpath=[targetBlkPath,'/',hC.Name];

                load_system('simulink');
                add_block(srcBlkPath,blkpath,srcBlkParam{:});
                set_param(blkpath,'Position',position);
                add_line(targetBlkPath,[outputBlk,'/1'],[hC.Name,'/1'],'autorouting','on');
                add_line(targetBlkPath,[hC.Name,'/1'],'Out1/1','autorouting','on');

                if~isempty(srcBlkParam)
                    [~,color]=this.getHiliteInfo(hC);
                    set_param(blkpath,'BackgroundColor',color);
                end





