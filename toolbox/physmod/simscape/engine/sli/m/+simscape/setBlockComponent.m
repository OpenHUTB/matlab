function setBlockComponent(hBlock,componentPath)






    s=warning('off','backtrace');
    C=onCleanup(@()warning(s));


    if~simscape.engine.sli.internal.iscomponentblock(hBlock)
        msgID='physmod:simscape:engine:sli:block:CannotSetNonSimscapeComponentBlock';
        pm_error(msgID,getfullname(hBlock));
    end


    clear(which(componentPath));

    set_param(hBlock,'SourceFile',componentPath);

end
