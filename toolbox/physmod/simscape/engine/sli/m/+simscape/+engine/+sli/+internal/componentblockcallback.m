function componentblockcallback(hBlk,type)





    try
        switch type
        case 'PRECOPY'
            lDoPreCopy(hBlk);
        case 'COPY'
            lDoCopy(hBlk);
        case 'PREDELETE'
            lDoPreDelete(hBlk);
        end
    catch ME
        ME.throwAsCaller();
    end

end

function lDoPreCopy(hBlk)


    if~pmsl_checklicense('Simscape')
        pm_error('physmod:pm_sli:RTM:RunTimeModule:error:user:NoLicenseToAddBlock',...
        get_param(hBlk,'Name'),'Simscape');
    elseif strcmp(lGetEditingMode(hBlk),'Restricted')
        pm_error('physmod:pm_sli:RTM:RunTimeModule:error:user:CannotAddBlockInRestrictedMode');
    end

end

function lDoCopy(hBlk)






    linkStatus=get_param(hBlk,'LinkStatus');
    if strcmp(linkStatus,'implicit')
        pm_warning(...
        'physmod:simscape:engine:sli:block:InvalidImplicitLink',...
        getfullname(hBlk));
    elseif~strcmp(linkStatus,'none')
        set_param(hBlk,'LinkStatus','none');
    end

end

function lDoPreDelete(hBlk)


    if strcmp(lGetEditingMode(hBlk),'Restricted')
        pm_error('physmod:pm_sli:RTM:RunTimeModule:error:user:CannotRemoveBlockInRestrictedMode');
    end

end

function editingMode=lGetEditingMode(hBlk)

    editingMode=simscape.engine.sli.internal.getmaskeditingmode(...
    get_param(hBlk,'MaskObject'));
end
