



function slimDocDDG_cb(dlg,h,tag,value)

    needNotifyPI=false;
    blk=h.getBlock;
    blkName=blk.getFullName;

    switch tag
    case 'docTypeCmb'
        propVal=getCurrentFormat(value);
        props={'DocumentType',propVal};
        needNotifyPI=true;
    case 'ecoderFlagEdit'
        props={'ECoderFlag',value};
        needNotifyPI=true;
    case 'contentEditor'
        props={'content',value};
        needNotifyPI=true;
    case{'htmlBtn','rtfBtn'}
        docblock('edit_document',blkName);
    end

    if needNotifyPI
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,props);



        if(~dlg.isWidgetWithError(tag))
            dlg.clearWidgetDirtyFlag(tag);
        end
    end

    if strcmp(tag,'contentEditor')
        fileName=docblock('getBlockFileName',blk.getFullName);
        try
            [wfid,errMsg]=fopen(fileName,'w','n','utf-8');
        catch ME
            wfid=-1;
            errMsg=ME.message;
        end

        if wfid<0
            warning(message('SimulinkBlocks:docblock:CannotCreateTempFile',errMsg));
            return;
        end

        try
            fwrite(wfid,value,'char*1');
        catch ME
            warning(message('SimulinkBlocks:docblock:WriteBlockToTempFile',ME.message));
        end

        fclose(wfid);
    end
end

function format=getCurrentFormat(index)
    formats={'Text','RTF','HTML'};
    format=formats{index+1};
end


