function preinitcomponentmask(hBlk)











    if strcmp(get_param(hBlk,'LinkStatus'),'implicit')
        pm_error('physmod:simscape:engine:sli:block:InvalidImplicitLink',...
        getfullname(hBlk));
    elseif~strcmp(get_param(hBlk,'LinkStatus'),'none')||~isempty(get_param(hBlk,'ReferenceBlock'))
        pm_warning(...
        'physmod:simscape:engine:sli:block:LinkedSimscapeComponent',...
        getfullname(hBlk));
        set_param(hBlk,'LinkStatus','none');
    end
end
