function closeCB(hObj,hDlg,action)




    classObj=hObj.fcnclass;
    classObj.closeCB(hDlg,action);

    if hObj.fcnclass.RightClickBuild
        coder.internal.configFcnProtoSSBuild(hObj.fcnclass.SubsysBlockHdl,[],'Close');
    end

    if~isempty(hObj.closeListener)&&ishandle(hObj.closeListener)
        hObj.closeListener=[];
    end

    hObj.removeBlockDiagramCallback('PreClose');
