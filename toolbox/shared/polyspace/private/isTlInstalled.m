function ret=isTlInstalled()




    ret=pslink.util.Helper.isWindows()&&~isempty(which('dspacerc'))&&...
    (~isempty(which('dsdd_config'))||~isempty(which('tl_config')));


