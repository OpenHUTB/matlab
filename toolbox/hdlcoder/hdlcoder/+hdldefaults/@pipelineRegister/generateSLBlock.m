function generateSLBlock(this,hC,targetBlkPath)


    userData=this.getHDLUserData(hC);

    blkPath=targetBlkPath;

    current_system=get_param(0,'currentSystem');
    simulink_present=find_system('type','block_diagram','name','simulink');
    if isempty(simulink_present)
        load_system('simulink');
    end
    set_param(0,'currentSystem',current_system);
    blkPath=addSLBlock(this,hC,'simulink/Discrete/Integer Delay',blkPath);

    set_param(blkPath,'samptime','-1',...
    'Position',userData.Position,...
    'Orientation',userData.Orientation,...
    'ShowName','off',...
    'NumDelays',sprintf('%d',userData.Latency));

    if hdlgetparameter('hiliteancestors')
        set_param(blkPath,'BackgroundColor',hdlgetparameter('hilitecolor'));
    end

    if isempty(simulink_present)
        bdclose('simulink');
    end

