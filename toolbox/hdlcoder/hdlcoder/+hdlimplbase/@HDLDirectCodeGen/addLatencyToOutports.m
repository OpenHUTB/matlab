function[]=addLatencyToOutports(~,hC,targetBlkPath,outputBlk,lastBlkPosition,color,outDelay)




    blkSize=[20,40];
    move_down=[0,50];
    blkPosition=[lastBlkPosition(1)+50,lastBlkPosition(2)-move_down(2)];

    BaseRate=-1;

    for ii=1:length(hC.PirOutputPorts)
        blkPosition=blkPosition+move_down;
        position=[blkPosition,blkPosition+blkSize];
        sampleTime=BaseRate;
        if outDelay>0
            gendelayblkpath=[targetBlkPath,'/',hC.Name,'_GenDelay',num2str(ii)];
            add_intDelay(gendelayblkpath);
            set_param(gendelayblkpath,'NumDelays',num2str(outDelay));
            set_param(gendelayblkpath,'samptime',num2str(sampleTime));
            set_param(gendelayblkpath,'Position',position);
            set_param(gendelayblkpath,'BackgroundColor',color);
            delayout=[hC.Name,'_GenDelay',num2str(ii),'/1'];
            add_line(targetBlkPath,[outputBlk,'/',num2str(ii)],delayout,'autorouting','on');
            add_line(targetBlkPath,[hC.Name,'_GenDelay',num2str(ii),'/1'],['Out',num2str(ii),'/1'],'autorouting','on');
        else
            add_line(targetBlkPath,[outputBlk,'/',num2str(ii)],['Out',num2str(ii),'/1'],'autorouting','on');
        end
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
