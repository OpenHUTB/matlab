function value=get_rtw_info_hook_file_name(model)










    try
        stf=deblank(get_param(model,'SystemTargetFile'));
    catch
        DAStudio.error('RTW:buildProcess:modelUnavailable',model);
    end

    [emptyIfNoHook,value.HookFileName]=coder.make.internal.rtw_hook_name(stf,'rtw_info');

    value.FileExists=~isempty(emptyIfNoHook);
