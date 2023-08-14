function dialogCallback(hViewer,action)




    if~isa(hViewer,'TflDesigner.TflViewer')
        DAStudio.error('RTW:tfl:invalidObjError');
    end
    switch action
    case 'SaveAs'
        switch hViewer.Type
        case 'TflTable'
            hTflTable=hViewer.Content;
            [fileName,pathName]=uiputfile('*.mat','Save CRL Table as');
            if fileName~=0
                hTflTable.Name=fileName;
                save(fullfile(pathName,fileName),'hTflTable');
                loc_refreshME(hViewer);
            else
                return;
            end
        otherwise
            DAStudio.error('RTW:tfl:resaveNotAllowedError',hViewer.Type);
        end
    case 'Edit'
        inspect(hViewer.Content);
    case 'Help'
        helpview([docroot,'/toolbox/rtw/helptargets.map'],'rtw_targfunclib');
    case 'Close'
        try
            hViewer.MeObj.delete;
        catch
            hViewer.delete;
        end
    otherwise
        DAStudio.error('RTW:tfl:unrecognizedActionError');
    end

    function loc_refreshME(this)
        fptme_WF=this.MeObj;


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',fptme_WF.getRoot);
        ed.broadcastEvent('PropertyChangedEvent',fptme_WF.getRoot);


        if~isempty(fptme_WF)
            if~isempty(fptme_WF.getDialog)
                fptme_WF.getDialog.refresh;
            end
        end




