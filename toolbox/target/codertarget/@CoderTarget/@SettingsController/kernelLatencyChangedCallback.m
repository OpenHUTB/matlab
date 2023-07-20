function kernelLatencyChangedCallback(hObj,hDlg,tag,arg)




    widgetChangedCallback(hObj,hDlg,tag,arg);



    mdlWks=get_param(hObj.getModel,'ModelWorkspace');
    val=codertarget.data.getParameterValue(hObj.getConfigSet,'OS.KernelLatency');
    assignin(mdlWks,'mwTaskManagerKernelLatency',val);
end
