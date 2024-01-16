function generateOrigModel(this)

    if this.isDutWholeModel
        return;
    end

    prefix=this.OutModelFilePrefix;
    gmName=getGeneratedModelName(prefix,this.InModelFile);
    gmStartNodeName=regexprep(this.RootNetworkName,['^',this.InModelFile],gmName);

    try
        junkModelName=getGeneratedModelName('tempHDLC_',gmName);
        new_system(junkModelName,'model');
        junkSS=add_block('built-in/SubSystem',[junkModelName,'/tempHDLC']);
        Simulink.BlockDiagram.copyContentsToSubSystem(this.InModelFile,junkSS);

        new_system(gmName,'model');
        Simulink.SubSystem.copyContentsToBlockDiagram(junkSS,gmName);
        slInternal('convertAllSSRefBlocksToSubsystemBlocks',...
        get_param(gmName,'handle'));
        blk=gmStartNodeName;
        while~isempty(blk)
            if strcmp(get_param(blk,'Type'),'block')&&...
                strcmp(get_param(blk,'StaticLinkStatus'),'resolved')
                set_param(blk,'LinkStatus','inactive');
            end
            blk=get_param(blk,'Parent');
        end
        close_system(junkModelName,0);
        slpir.PIR2SL.initOutputModel(this.InModelFile,gmName);
        if(strncmp(get_param(gmName,'SignalResolutionControl'),'TryResolve',10))
            set_param(gmName,'SignalResolutionControl','UseLocalSettings');
        end
        Parent=get_param(gmStartNodeName,'Parent');
        delete_block(gmStartNodeName);
        delete_line(find_system(Parent,'FindAll','on','LookUnderMasks','On','SearchDepth',1,'Type','line'));
    catch me
        close_system(junkModelName,0);
        close_system(gmName,0);
        error(message('hdlcoder:engine:createtargetmodel',gmName,me.message));
    end
end
