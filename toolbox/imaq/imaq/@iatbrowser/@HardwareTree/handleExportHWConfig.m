function handleExportHWConfig(this,obj,theEvent,default)%#ok<INUSL,INUSD,INUSD,INUSD>







    browser=iatbrowser.Browser;
    vids=browser.getAllVideoinputObjects;
    frame=iatbrowser.getDesktopFrame();
    diaTitle=imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.resources.RES_EXPORTER',...
    'dialog.export.title');
    switch default
    case 'CODEFILE'
        dia=com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.MFileExporter(vids,pwd);
        diaTitle=imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.resources.RES_EXPORTER',...
        'dialog.mfile.title');
    case 'SELECTED'
        dia=com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.MultiDestinationExporter(...
        vids,pwd,com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.ObjectDestinations.WORKSPACE);
        currentNode=this.currentNode;
        dia.selectFormat(currentNode.Parent.DisplayName,currentNode.Format);
    otherwise
        dia=com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.MultiDestinationExporter(...
        vids,pwd,com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.ObjectDestinations.WORKSPACE);
    end

    okCallback=handle(dia.getOKCallback());
    this.saveButtonsListener=handle.listener(okCallback,'delayed',@handleOkCallback);

    helpCallback=handle(dia.getHelpCallback());
    this.saveButtonsListener(2)=handle.listener(helpCallback,'delayed',@handleHelp);

    dia.showAsDialog(frame,diaTitle);
    drawnow;

    function handleOkCallback(obj,theEvent)%#ok<INUSL>

        callbackData=theEvent.JavaEvent;
        if isempty(callbackData)||callbackData.videoInputObjects.isEmpty()

            return;
        end

        action=char(callbackData.destination);


        varNames={};
        vidObjs=[];
        for i=1:callbackData.videoInputObjects.size()
            if i==1
                varNames{i}=char(callbackData.varNames.elementAt(i-1));%#ok<AGROW>
                vidObjs=handle(callbackData.videoInputObjects.elementAt(i-1).getUDDObj());
            else
                varNames{end+1}=char(callbackData.varNames.elementAt(i-1));%#ok<AGROW>
                vidObjs(end+1)=handle(callbackData.videoInputObjects.elementAt(i-1).getUDDObj());%#ok<AGROW>
            end
        end
        vidObjs=imaqgate('privateUDDToMATLAB',vidObjs);

        switch lower(action)
        case 'matlab workspace'
            iatbrowser.exportToWorkspace(varNames,vidObjs);
        case 'mat-file'
            iatbrowser.exportToMOrMAT(char(callbackData.filename),vidObjs,varNames,false);
        case 'matlab code file'
            iatbrowser.exportToMOrMAT(char(callbackData.filename),vidObjs,varNames,true)
        otherwise
            assert(false,'Invalid export destination specified.');
        end
    end

    function handleHelp(obj,theEvent)%#ok<INUSD,INUSD>
        helpview(fullfile(docroot,'toolbox','imaq','imaq.map'),'export_hardware_config');
    end
end
