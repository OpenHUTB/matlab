function[]=addSLBlockLatency(this,hC,targetBlkPath,latencyInfo,outputBlk,lastBlkPosition)






    blkSize=[20,40];
    blkPosition=[lastBlkPosition(1)+50,lastBlkPosition(2)];
    move_down=[0,50];

    BaseRate=-1;
    [turnhilitingon,color]=this.getHiliteInfo(hC);

    outputDelay=latencyInfo.outputDelay;

    for ii=1:length(hC.PirOutputPorts)
        blkPosition=blkPosition+(ii-1)*move_down;
        position=[blkPosition,blkPosition+blkSize];
        sampleTime=BaseRate;
        if outputDelay>0
            gendelayblkpath=[targetBlkPath,'/',hC.Name,'_GenDelay',num2str(ii)];
            add_intDelay(gendelayblkpath);
            set_param(gendelayblkpath,'NumDelays',num2str(outputDelay));
            set_param(gendelayblkpath,'samptime',num2str(sampleTime));
            set_param(gendelayblkpath,'Position',position);
            set_param(gendelayblkpath,'BackgroundColor',color);
            makeSyntheticBlkPassThrough(hC,gendelayblkpath);


            makeSyntheticBlkPassThrough(hC,gendelayblkpath);
            add_line(targetBlkPath,[outputBlk,'/',num2str(ii)],[hC.Name,'_GenDelay',num2str(ii),'/1'],'autorouting','on');
            add_line(targetBlkPath,[hC.Name,'_GenDelay',num2str(ii),'/1'],['Out',num2str(ii),'/1'],'autorouting','on');
        else
            add_line(targetBlkPath,[outputBlk,'/',num2str(ii)],['Out',num2str(ii),'/1'],'autorouting','on');
        end
    end




    function makeSyntheticBlkPassThrough(hC,syntheticBlkPath)

        hdltargetcc=hdltargetmodelcc(hC.SimulinkHandle);

        if~isempty(hdltargetcc)
            hdltargetcc.forEach(...
            syntheticBlkPath,...
            'built-in/Delay',{},...
            'hdldefaults.PassThroughHDLEmission');
        else

        end

        function[]=add_intDelay(blkPath)
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



