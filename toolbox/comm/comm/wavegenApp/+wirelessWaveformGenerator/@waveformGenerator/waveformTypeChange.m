function waveformTypeChange(obj,newValue)





    if obj.useAppContainer
        freezeApp(obj);
    else
        obj.ToolGroup.setWaiting(true);
    end


    obj.pWaveform=[];
    newValueNoNewLine=replace(newValue,newline,' ');
    for item=obj.pWaveformGalleryItems
        item=item{:};
        if strcmpi(item.Tag,newValueNoNewLine)
            item.Value=true;
        else
            item.Value=false;
        end
    end

    obj.pCurrentWaveformType=replace(newValue,newline,' ');

    waveformRegistration=obj.pRegistrations.findChild('Name',newValue);
    className=waveformRegistration.Class;
    dependency=waveformRegistration(1).Depends;
    if~isempty(dependency)
        propSet=waveformRegistration(1).PropertySet;
        productBaseCode=dependency;

        licSuccess=obj.checkProduct(productBaseCode,propSet);
    else


        licSuccess=true;
    end

    if~licSuccess

        if strcmp(obj.pCurrentWaveformType,obj.pFirstWaveformType)

            obj.pFirstWaveformType='OFDM';
        end


        for idx=1:length(obj.pWaveformGalleryItems)
            thisItem=obj.pWaveformGalleryItems{idx};
            if strcmp(thisItem.Tag,obj.pFirstWaveformType)
                thisItem.Value=true;
            else
                thisItem.Value=false;
            end
        end

        obj.waveformTypeChange(obj.pFirstWaveformType);


        if obj.useAppContainer
            unfreezeApp(obj);
        else
            obj.ToolGroup.setWaiting(false);
        end
        return;
    end

    if obj.useAppContainer

        needLeftSidePanel=eval([className,'.hasLeftFigurePanel']);
        leftPanel=obj.AppContainer.getPanel('ConfigPanel');
        if needLeftSidePanel

            if isempty(leftPanel)

                leftPanel=matlab.ui.internal.FigurePanel(...
                'Title',getString(message('comm:waveformGenerator:WaveformFig')),...
                'Tag','ConfigPanel');
                addPanel(obj.AppContainer,leftPanel);
            end

            fig=leftPanel.Figure;
        else





            mainDocumentTag=eval([className,'.paramFigureTag']);
            mainDocument=obj.AppContainer.getDocument("figureDocumentGroup",mainDocumentTag);
            if isempty(mainDocument)

                mainDocument=matlab.ui.internal.FigureDocument(...
                'Tag',mainDocumentTag,...
                'DocumentGroupTag','figureDocumentGroup',...
                'Closable',false);
                mainDocument.Figure.Tag=mainDocumentTag;
                addDocument(obj.AppContainer,mainDocument);
            else

                mainDocument.Visible=true;
            end

            fig=mainDocument.Figure;
            fig.AutoResizeChildren='off';
        end



        obj.pParametersFig=fig;
        obj.pParametersFig.UserData=obj;
        if isempty(obj.pParameters)

            obj.pParameters=wirelessWaveformGenerator.Parameters(obj);
        end

        if isempty(obj.pParameters.CurrentDialog)

            oldNumColumns=nan;
        else
            oldNumColumns=getNumColumns(obj.pParameters.CurrentDialog);
            leftPanelWasLaunched=obj.pParameters.CurrentDialog.hasLeftFigurePanel;
        end
    end


    obj.setParametersDialog(className);

    export2MATLAB=find(obj.pExportBtn.Popup,'generateMLCode');
    export2Simulink=find(obj.pExportBtn.Popup,'exportToSimulink');
    export2MATLAB.Enabled=exportsMLCode(obj.pParameters.CurrentDialog);
    export2Simulink.Enabled=exportsMLCode(obj.pParameters.CurrentDialog);

    clearScopes(obj);



    if obj.useAppContainer
        if~isempty(leftPanel)&&xor(leftPanel.Opened,needLeftSidePanel)

            txPanel=obj.AppContainer.getPanel('RadioFig');
            if isempty(txPanel)||~txPanel.Opened



                leftPanel.Opened=needLeftSidePanel;



                waitfor(obj.AppContainer,'PanelLayout')
            end
        end


        newNumColumns=getNumColumns(obj.pParameters.CurrentDialog);
        if needLeftSidePanel&&(isnan(oldNumColumns)||~leftPanelWasLaunched||oldNumColumns~=newNumColumns)
            if newNumColumns>1
                obj.AppContainer.PanelLayout.referenceWidth=1600;
                obj.AppContainer.PanelLayout.left.portion=0.441;
            else
                obj.AppContainer.PanelLayout.referenceWidth=1280;
                obj.AppContainer.PanelLayout.left.portion=0.25;
            end
        end
    end


    if obj.useAppContainer
        unfreezeApp(obj);
    else
        obj.ToolGroup.setWaiting(false);
    end
end

