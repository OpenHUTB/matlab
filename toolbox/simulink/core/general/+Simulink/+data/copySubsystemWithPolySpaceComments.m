function new_blk_hdl=copySubsystemWithPolySpaceComments(origSubsys,newSubsys,varargin)









    block_hdl=get_param(origSubsys,'handle');
    srcRoot=bdroot(block_hdl);
    new_mdl_name=strtok(newSubsys,'/');
    new_mdl_hdl=get_param(new_mdl_name,'handle');





    set_param(new_mdl_hdl,'SIDAllowCopied','on');
    set_param(new_mdl_hdl,'SIDNewHighWatermark',...
    get_param(srcRoot,'SIDHighWatermark'));
    new_blk_hdl=add_block(origSubsys,newSubsys,varargin{:});

    set_param(new_mdl_hdl,'SIDAllowCopied','off');


    blkList=get_param(srcRoot,'GetPolySpaceStartCommentBlocks');
    for index=1:length(blkList)
        if(coder.internal.isBlockInSS(block_hdl,blkList(index)))
            origSID=Simulink.ID.getSID(blkList(index));
            newSID=Simulink.ID.getSubsystemBuildSID(origSID,new_blk_hdl);
            origPSComment=get_param(blkList(index),'PolySpaceStartComment');
            set_param(newSID,'PolySpaceStartComment',origPSComment);
        end
    end

    blkList=get_param(bdroot(block_hdl),'GetPolySpaceEndCommentBlocks');
    for index=1:length(blkList)
        if(coder.internal.isBlockInSS(block_hdl,blkList(index)))
            origSID=Simulink.ID.getSID(blkList(index));
            newSID=Simulink.ID.getSubsystemBuildSID(origSID,new_blk_hdl);
            origPSComment=get_param(blkList(index),'PolySpaceEndComment');
            set_param(newSID,'PolySpaceEndComment',origPSComment);
        end
    end
end

