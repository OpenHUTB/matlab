function handleSelectCameraFileDialog(oldNode,currentNode)

    persistent listeners;%#ok<PUSE>

    browser=iatbrowser.Browser;
    javaTreePanel=java(browser.treePanel.javaPeer);

    frame=iatbrowser.getDesktopFrame();

    fileChooser=javaObjectEDT('com.mathworks.toolbox.imaq.devicechooser.DeviceFileChooserDialog',...
    frame,javaTreePanel,true,'com.mathworks.toolbox.imaq.browser.resources.RES_CAMERA_FILE_CHOOSER');

    fileChooser.setName('CameraFileDialog');

    okCallback=handle(fileChooser.getOkCallback());
    listeners=handle.listener(okCallback,'delayed',@handleOK);

    cancelCallback=handle(fileChooser.getCancelCallback());
    listeners(2)=handle.listener(cancelCallback,'delayed',@handleCancel);

    fileChooser.displayDialogAndGetButtonPressed();

    function handleCancel(obj,event)%#ok<INUSD,INUSD>



        browser=iatbrowser.Browser;
        browser.treePanel.selectNode(oldNode,false);
        clear listeners
    end

    function handleOK(obj,event)%#ok<INUSD,INUSD>
        try
            format=char(fileChooser.getFileName());

            if isa(currentNode,'iatbrowser.SelectCameraFileNode')
                deviceNode=currentNode.Parent;
            else
                deviceNode=currentNode;
            end

            existingNode=deviceNode.getNode(format);

            if~isempty(existingNode)
                browser=iatbrowser.Browser;
                browser.treePanel.selectNode(existingNode,true);
                return;
            end
            newFormatNode=iatbrowser.FormatNode(deviceNode,format,false);
            newFormatNode.createDevice();
            newFormatNode.setToolTipText(iatbrowser.getResourceString('RES_DESKTOP','CameraFile.Tooltip'));


            deviceNode.addChild(newFormatNode);
        catch err
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessage(...
            iatbrowser.getDesktopFrame(),...
            'CAMERA_FILE_LOAD_FAILED',...
            err.getReport('basic','hyperlinks','off'),...
            [],...
            @(obj,event)iatbrowser.handleSelectCameraFileDialog(oldNode,currentNode));
        end
        clear listeners
    end

end
