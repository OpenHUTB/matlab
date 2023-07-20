function flag=checkInvalidDUT(this)






    flag=true;


    blockList=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,'SearchDepth',1,'Type','block');
    blockTypes=get_param(blockList,'BlockType');
    enablePort=find(strcmp(blockTypes,'EnablePort'));
    triggerPort=find(strcmp(blockTypes,'TriggerPort'));
    resetPort=find(strcmp(blockTypes,'ResetPort'));
    forEachBlock=find(strcmp(blockTypes,'ForEach'));


    variantDUT=false;
    objParams=get_param(this.m_DUT,'ObjectParameters');
    if isfield(objParams,'Variant')
        variantDUT=strcmpi(get_param(this.m_DUT,'Variant'),'on');
    end


    BlackBoxDUT=false;
    if~strcmpi(this.m_DUT,this.m_sys)
        hd=slprops.hdlblkdlg(this.m_DUT);
        if~isempty(hd.getCurrentArchImplParams)
            BlackBoxDUT=strcmpi(hd.archSelection,'BlackBox');
        end
    end

    candidatePortsOrBlocks=[enablePort;triggerPort;resetPort;forEachBlock];

    if(numel(candidatePortsOrBlocks)||variantDUT||BlackBoxDUT)
        flag=false;

        this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_Subsystem_setting_unsupported'),this.m_DUT,0);
    end
end
