function sldvadvRuntimeErrDetectionViewTestCase(method,dataFile,model,idx)




    elems=strsplit(model,'/');
    model=elems{1};

    if~(exist(dataFile,'file')==2&&exist(model,'file')==4)

        h=findobj('Tag','SLDV_MdlAdv_ViewTestCase_WarnDlg');
        if isempty(h)

            warndlgName=getString(message(...
            'Sldv:ModelAdvisor:Runtime_Error_Detection:WarningDlgName'));
            warndlgMsg=getString(message(...
            'Sldv:ModelAdvisor:Runtime_Error_Detection:WarningDlgMsg'));
            h=warndlg(warndlgMsg,warndlgName);
            h.HandleVisibility='on';
            h.Tag='SLDV_MdlAdv_ViewTestCase_WarnDlg';
        else

            figure(h);
        end
        return;
    end
    sldvprivate('urlcall',method,dataFile,model,idx);

end