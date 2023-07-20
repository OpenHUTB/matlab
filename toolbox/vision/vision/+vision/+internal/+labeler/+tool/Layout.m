


classdef Layout<vision.internal.uitools.NewToolStripApp2




    properties(Access=protected)



ROILabelSetDisplay



FrameLabelSetDisplay



InstructionsSetDisplay



LegendDisplay



AttributesSublabelsDisplay



GraphicsDisplay

SignalNavigationDisplay


OverviewDisplay



MetadataDisplay


VisualSummaryDisplay


GroupName


APP
    end


    properties(Access=protected)

        ShowAttributeTab=false;
        ShowInstructionTab=false;
        ShowNavControlTab=false;
        ShowOverviewTab=false;
        ShowMetadataTab=false;

    end

    properties
        NameROILabelSetDisplay='ROI Display';
        NameFrameLabelSetDisplay='Frame Display';
        NameInstructionsSetDisplay='Instruction Display';
        NameAttributesSublabelsDisplay='Attribute Sublabel Display';
        NameSignalNavigationDisplay='Signal Navigation Display';
        NameOverviewDisplay='Overview Display';
        NameMetadataDisplay='Metadata Display';
        NameVisualSummaryDisplay='Visual Summary Display';
    end





    properties(Access=private)

        PropXClose=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
        PropName=com.mathworks.widgets.desk.DTClientProperty.NAME;
        StateFalse=java.lang.Boolean.FALSE;
        StateTrue=java.lang.Boolean.TRUE;
    end

    properties(Abstract,Access=protected)
        NameNoneDisplay;
        DefaultLayoutFileName;
        DefaultLayoutWAttribFileName;
    end


    events

ClientActivated
    end




    methods(Abstract,Access=protected)

        configureDisplays(this)
        saveLayoutToSessionInLabelMode(this)
    end




    methods


        function doTileLayoutAtLoad(this)



            this.ShowInstructionTab=false;
            this.ShowAttributeTab=false;
            this.ShowNavControlTab=false;
            this.ShowOverviewTab=false;
            this.ShowMetadataTab=false;

            setVisibilityOfTabFigureXClose(this);
            makeDefaultFiguresVisible(this.Container,this.ShowNavControlTab);
            makeUnusedFiguresInvisible(this.Container,this.ShowInstructionTab,...
            this.ShowAttributeTab,this.ShowAttributeTab,this.ShowMetadataTab);


            setAppLayoutFromFileName(this.Container,this.DefaultLayoutFileName);
        end


        function grpName=get.GroupName(this)


            grpName=this.getGroupName();
        end


        function out=getTilingLayout(this)
            out=getTilingLayout(this.Container);
        end


        function restoreDefaultLayout(this,showInstructionTab)


            wait(this.Container);
            createXMLandGenerateLayout(this,1,1);


            this.ShowInstructionTab=showInstructionTab;
            this.ShowAttributeTab=~isempty(this.AttributesSublabelsDisplay)&&...
            isPanelVisible(this.AttributesSublabelsDisplay);
            this.ShowNavControlTab=~isempty(this.SignalNavigationDisplay)&&...
            isPanelVisible(this.SignalNavigationDisplay);


            saveLayoutToSessionInLabelMode(this);
            doTileLayoutToRestoreDefault(this);


            resume(this.Container);
        end


        function xmlString=createXMLandGenerateLayout(this,displayGridNumRows,displayGridNumCols)
            hasVisualSummary=~isempty(this.VisualSummaryDisplay);
            xmlString=createXMLandGenerateLayout(this.Container,displayGridNumRows,displayGridNumCols,hasVisualSummary);
        end


        function[numRows,numCols]=getGridLayout(this)
            [numRows,numCols]=getGridLayout(this.Container);
        end



        function setAppLayout(this,opaqueLayout)
            setAppLayout(this.Container,opaqueLayout);






        end
    end




    methods(Access=protected,Sealed)


        function createDefaultLayoutAtLoad(this)






            configureDisplays(this);

            addDisplayNames(this);

            this.ShowInstructionTab=false;
            this.ShowAttributeTab=false;
            this.ShowNavControlTab=false;
            this.ShowOverviewTab=false;
            this.ShowMetadataTab=false;
            doTileLayoutAtLoad(this);

        end


        function createDefaultLayoutForNewSession(this)




            this.ShowInstructionTab=false;
            this.ShowAttributeTab=false;
            this.ShowNavControlTab=false;
            this.ShowOverviewTab=false;
            this.ShowMetadataTab=false;
            if~useAppContainer()
                resetDisplayGridDims(this.Container);
            else
                resetDocGridDims(this);
            end
            doTileLayoutAtLoad(this);
        end
    end


    methods(Access=protected)


        function tf=isTabSelected(this,name)
            tf=this.APP.isClientSelected(name,this.GroupName);
        end


        function updateTileLayout4AttribInstruct(this,showInstructionTab,showAttributeTab,varargin)




            this.ShowInstructionTab=showInstructionTab;
            this.ShowAttributeTab=showAttributeTab;

            if useAppContainer()
                if this.ShowInstructionTab
                    makeInstructionVisible(this.Container);
                else
                    makeInstructionInvisible(this.Container);
                end

                if this.ShowAttributeTab
                    makeAttribSublabelVisible(this.Container);
                else
                    makeAttribSublabelInvisible(this.Container);
                end

                restoreDocFigureLayout(this.Container,varargin{:});
            else
                opaqueLayout=getTilingLayout(this);
                xmlLayout=serializeLayout(this,opaqueLayout);
                xmlHandlerObj=vision.internal.labeler.tool.XMLHandler(xmlLayout);

                placeAttribInstrucPanels(this,xmlHandlerObj,varargin{:});
            end

        end


        function setTabName(this,displayClass,name)
            setTabName(this.Container,displayClass.Name,name);
        end


        function setDisplayTileLocation(this,displayClass,targetTileNumber)

            currentTileNumber=getTileNumber(this,displayClass);






            for i=1:2


                if currentTileNumber~=targetTileNumber
                    this.APP.setClientLocation(displayClass.Name,this.GroupName,...
                    com.mathworks.widgets.desk.DTLocation.create(targetTileNumber));
                    drawnow()
                    currentTileNumber=getTileNumber(this,displayClass);
                end

                if currentTileNumber==targetTileNumber
                    break;
                end
            end
        end


        function removeSignalNav(this)
            makeSignalNavInvisible(this.Container);
            drawnow();
        end

        function resetDisplaysInNewSession(this)
            for i=this.DisplayManager.NumDisplays:-1:2
                thisDisplay=this.DisplayManager.getDisplayFromIdNoCheck(i);
                dispFig=thisDisplay.Fig;
                figName=dispFig.Name;
                removeDisplay(this,dispFig.Name);
                removeDocumentTab(this.Container,dispFig,figName);
            end
            showDefaultSignalDisplay(this);
        end


        function removeDisplayPlus(this,varargin)
            fig=varargin{1};
            isAppClosing=varargin{2};
            if~isAppClosing&&isOnlyOneDisplayTabVisible(this)
                showDefaultSignalDisplay(this);
            end
            figName=fig.Name;
            removeDisplay(this,figName);
            removeClientTabGroup(this.Container,fig,figName);

        end

        function DummyCallback(~,varargin)
        end

        function setTabXCloseButtonCallback(this,displayClass)

            this.APP.getClient(displayClass.Name,this.GroupName).putClientProperty(com.mathworks.widgets.desk.DTClientProperty.VETO_CLOSE,@this.DummyCallback);
        end


        function addNewDisplayAsTabInLayout(this,newDisplay,noCloseButton)
            configureNewDisplay(this,newDisplay);
            addDisplayName(this,newDisplay);

            if noCloseButton
                hideTabXCloseButton(this,newDisplay);
            end

            makeSignalVisible(this.Container,newDisplay);
            drawnow();

        end



        function xmlLayout=serializeLayout(this,opaqueLayout)
            xmlLayout=serializeLayout(this.Container,opaqueLayout);
        end


        function serializeLayoutToFile(this,opaqueLayout,fullFileName)
            serializeLayoutToFile(this.Container,opaqueLayout,fullFileName);
        end



        function opaqueLayout=deserializeLayout(this,xmlLayout)
            opaqueLayout=deserializeLayout(this.Container,xmlLayout);
        end


        function opaqueLayout=deserializeLayoutFromFile(this,fullFileName)
            opaqueLayout=deserializeLayoutFromFile(this.Container,fullFileName);
        end


        function tf=hasLayoutAttributePanel(this,inLayout)
            tf=hasLayoutAttributePanel(this.Container,inLayout);
        end


        function tf=hasLayoutSignalNavPanel(this,inLayout)
            tf=hasLayoutSignalNavPanel(this.Container,inLayout);
        end


        function tf=isLayoutCompatible(this,inLayout)
            tf=hasLayoutSignalNavPanel(this,inLayout);
        end


        function outLayout=convertOldLayoutToNew(this,inLayout)






            outLayout=inLayout;
        end

        function resetDocGridDims(this)
            this.Tool.DocumentGridDimensions=[1,1];
        end

    end

    methods(Access=private)

        function n=getCurrentDisplayGridNumRows(this)
            n=this.Container.CurrentDisplayGridNumRows;
        end

        function n=getCurrentDisplayGridNumCols(this)
            n=this.Container.CurrentDisplayGridNumCols;
        end


        function tf=isDefaultFactoryLayout(this,displays)








            tf=false;

            if((this.NumberOfRowTiles==2)&&(this.NumberOfColumnTiles==3))
                [tFlag,displayTileId]=areDisplaysOnSameTile(this,displays);
                tf=(tFlag&&(displayTileId==1));
            end

        end


        function removeDisplay(this,name)
            removeDisplay(this.DisplayManager,name);
        end


        function tf=isOnlyOneDisplayTabVisible(this)
            if useAppContainer()

                tf=hasOneSignalDoc(this.Container);
            else
                tf=isOnlyOneDisplayTabVisible(this.DisplayManager);
            end
        end


        function showDefaultSignalDisplay(this)

            showNoneSignalDisplay(this.Container);
        end


        function numSignalRows=getNumberOfSignalRows(this)

            numSignalRows=0;
            if this.ShowNavControlTab
                numSignalRows=1;
            end
        end


        function tileNumber=getTileNumber(this,setDisplay)
            tileNumber=getTileNumber(this.Container,setDisplay.Fig);
        end


        function tileNumber=getFirstVisibleDisplayTileNumber(this,displays)

            tileNumber=-1;
            for i=1:numel(displays)
                tileNumber=getTileNumber(this,displays{i});
                if tileNumber>-1
                    return;
                end
            end
        end



        function[tf,displayTileId]=areDisplaysOnSameTile(this,displays)


            numDisplays=numel(displays);
            tileNumber=zeros(numDisplays,1);
            for i=1:numel(displays)
                tileNumber(i)=getTileNumber(this,displays{i});
            end



            idx=tileNumber>0;
            validTileNumbers=tileNumber(idx);

            tf=all(validTileNumbers==validTileNumbers(1));

            if tf
                displayTileId=validTileNumbers(1);
            else
                displayTileId=-1;
            end
        end


        function tileNumber=getTileNumberFromName(this,displayName)

            tileNumber=-1;

            client=this.APP.getClient(displayName,this.GroupName);
            clientLocObj=this.APP.getClientLocation(client);

            if~isempty(clientLocObj)
                tileNumber=clientLocObj.getTile();
            end
        end


        function attrInstrTileNumber=columnIndexOfAttribInstrucPanel(this)
            attrInstrTileNumber=getTileNumber(this.InstructionsSetDisplay);
            if(attrInstrTileNumber==-1)&&~isempty(this.AttributesSublabelsDisplay)
                attrInstrTileNumber=getTileNumber(this.AttributesSublabelsDisplay);
            end
        end


        function showLastColAndSetColWidth(this)



            oldColumnWidths=this.ColumnWidths;
            assert(oldColumnWidths(end)<=0);
            newAttrbInstrcColW=0.2;
            oldColumnWidthsAdjusted=adjustProportionately(oldColumnWidths(1:end-1),1-newAttrbInstrcColW);
            newColumnWidths=[oldColumnWidthsAdjusted(:);newAttrbInstrcColW];
            setColumnWidths(this,newColumnWidths);
        end


        function hideLastColAndSetColWidth(this)
            oldColumnWidths=this.ColumnWidths;
            newAttrbInstrcColW=0;
            oldColumnWidthsAdjusted=adjustProportionately(oldColumnWidths(1:end-1),1.0);
            newColumnWidths=[oldColumnWidthsAdjusted(:);newAttrbInstrcColW];
            setColumnWidths(this,newColumnWidths);
        end


        function tf=isValidVisualSummaryDocked(this)
            tf=~isempty(this.VisualSummaryDisplay)&&...
            isvalid(this.VisualSummaryDisplay)&&...
            isDocked(this.VisualSummaryDisplay);
        end

        function tf=anyDisplayOccupiesSameTile(this,targetTileID)

            tf=false;
            displays=this.DisplayManager.Displays;
            for i=1:this.DisplayManager.NumDisplays
                thisDisplay=displays{i};
                tf=isPanelVisible(thisDisplay)&&...
                (getTileNumber(this,thisDisplay)==targetTileID);
                if tf
                    return;
                end
            end
        end


        function tf=occupiesSameTile(this,setDisplay,targetTileID)
            tf=isPanelVisible(setDisplay)&&...
            (getTileNumber(this,setDisplay)==targetTileID);
        end


        function tf=occupiesSameTileVS(this,targetTileID)
            tf=false;
            if isValidVisualSummaryDocked(this)
                tf=isPanelVisible(this.VisualSummaryDisplay)&&...
                (getTileNumber(this,this.VisualSummaryDisplay)==targetTileID);
            end
        end


        function lastTileID=getLastTileID(this)









            if this.NumberOfRowTiles==1
                lastTileID=this.NumberOfColumnTiles-1;
            else
                lastTileID=this.NumberOfColumnTiles-1;
...
...
...
...
...
...
...
...
...
...
...
            end
        end


        function placeAttribInstrucPanels(this,xmlHandlerObj,varargin)


            [recreateLayout,setInstrcTileLocation,setAttribTileLocation]...
            =needToRecreateLayoutForAttribSublabel(this,xmlHandlerObj);

            displayGridNumRows=getCurrentDisplayGridNumRows(this);
            displayGridNumCols=getCurrentDisplayGridNumCols(this);
            inAutomationMode=false;

            if nargin>2
                displayGridNumRows=varargin{1}(1);
                displayGridNumCols=varargin{1}(2);

                inAutomationMode=varargin{2};
            end

            grabFocus(this.DisplayManager);
            modifyAttribInstructionPanelVisibility(this);

            if recreateLayout||inAutomationMode
                createXMLandGenerateLayout(this,displayGridNumRows,displayGridNumCols);
            end

            if~recreateLayout
                setAttribOrInstructionPanelTileLocation(this,setInstrcTileLocation,setAttribTileLocation);
            end
        end


        function setTileGridDimension(this,numColTiles,numRowTiles)

            targetTileGridDim=java.awt.Dimension(numColTiles,numRowTiles);
            currentTileGridDim=this.APP.getDocumentTiledDimension(this.GroupName);

            for i=1:2



                if currentTileGridDim~=targetTileGridDim
                    this.APP.setDocumentArrangement(this.GroupName,...
                    this.APP.TILED,java.awt.Dimension(numColTiles,numRowTiles));
                    pause(0.1);
                    drawnow()
                    currentTileGridDim=this.APP.getDocumentTiledDimension(this.GroupName);
                end
                if currentTileGridDim==targetTileGridDim
                    break;
                end
            end
        end


        function colWidths=getDefaultColumnWidths(this)
            showRightPanel=this.ShowInstructionTab||this.ShowAttributeTab;
            if showRightPanel
                colWidths=[this.LABEL_DEF_COL_W,0.6,0.2];
            else
                colWidths=[this.LABEL_DEF_COL_W,0.8];
            end
        end


        function rowHeights=getDefaultRowHeights(this)
            if this.ShowNavControlTab
                rowHeights=[0.82,0.18];
            else
                rowHeights=1.0;
            end
        end


        function setColumnWidths(this,colWidths)


            if this.NumberOfColumnTiles==numel(colWidths)

                this.APP.setDocumentColumnWidths(this.getGroupName,colWidths);
                pause(0.1);
                drawnow();

            end
        end


        function setRowHeights(this,rowHeights)


            if this.NumberOfRowTiles==numel(rowHeights)

                this.APP.setDocumentRowHeights(this.getGroupName,rowHeights);
                pause(0.1);
                drawnow();

            end
        end


        function createAndOrnaizeTileGrids(this)




            numColTiles=3;
            numRowTiles=2;
            setTileGridDimension(this,numColTiles,numRowTiles);




            if numRowTiles>1
                this.APP.setDocumentRowSpan(this.GroupName,0,0,2);
                this.APP.setDocumentRowSpan(this.GroupName,0,2,2);
            end
            drawnow();
            colWidths=getDefaultColumnWidths(this);
            rowHeights=getDefaultRowHeights(this);

            setColumnWidths(this,colWidths);
            setRowHeights(this,rowHeights);

            drawnow()
        end


        function addNewDisplayToApp(this,newDisplay)


            addFigureToApp(newDisplay,this);
            addDisplayName(this,newDisplay);
        end


        function addDisplaysToApp(this)


            addFigureToApp(getDisplay(this.DisplayManager,this.NameNoneDisplay),this);

            addFigureToApp(this.FrameLabelSetDisplay,this);
            addFigureToApp(this.ROILabelSetDisplay,this);
            addFigureToApp(this.InstructionsSetDisplay,this);
            if~isempty(this.AttributesSublabelsDisplay)
                addFigureToApp(this.AttributesSublabelsDisplay,this);
            end

            if~isempty(this.SignalNavigationDisplay)
                addFigureToApp(this.SignalNavigationDisplay,this);
            end

            if~isempty(this.OverviewDisplay)
                addFigureToApp(this.OverviewDisplay,this)
            end

            if~isempty(this.MetadataDisplay)
                addFigureToApp(this.MetadataDisplay,this)
            end



        end


        function addDisplayName(this,newDisplay)
            drawnow;
            setTabName(this,newDisplay,newDisplay.Name);
        end


        function addDisplayNames(this)






            drawnow;

            setTabName(this,this.ROILabelSetDisplay,this.NameROILabelSetDisplay);
            setTabName(this,this.FrameLabelSetDisplay,this.NameFrameLabelSetDisplay);
            setTabName(this,getDisplay(this.DisplayManager,this.NameNoneDisplay),this.NameNoneDisplay);

            setTabName(this,this.InstructionsSetDisplay,this.NameInstructionsSetDisplay);
            if~isempty(this.AttributesSublabelsDisplay)
                setTabName(this,this.AttributesSublabelsDisplay,this.NameAttributesSublabelsDisplay);
            end
            if~isempty(this.SignalNavigationDisplay)
                setTabName(this,this.SignalNavigationDisplay,this.NameSignalNavigationDisplay);
            end
            if~isempty(this.OverviewDisplay)
                setTabName(this,this.OverviewDisplay,this.NameOverviewDisplay);
            end
            if~isempty(this.MetadataDisplay)
                setTabName(this,this.MetadataDisplay,this.NameMetadataDisplay);
            end

        end

        function setLayoutfromXML(this,filename)
            xmlFile=fullfile(toolboxdir('vision'),'vision',...
            '+vision','+internal','+labeler','+tool',filename);
            xDoc=xmlread(xmlFile);
            xmlString=xmlwrite(xDoc);
            opaqueLayout=deserializeLayout(this,xmlString);
            setAppLayout(this,opaqueLayout);
        end


        function doTileLayoutToRestoreDefault(this)

            if~this.ShowInstructionTab&&...
                ~this.ShowAttributeTab&&...
                ~this.ShowNavControlTab

                doTileLayoutAtLoad(this);
            else
                if this.ShowNavControlTab


                    grabFocus(this.DisplayManager);
                    currentDisplayGridNumRows=getCurrentDisplayGridNumRows(this);
                    currentDisplayGridNumCols=getCurrentDisplayGridNumCols(this);
                    createXMLandGenerateLayout(this,currentDisplayGridNumRows,currentDisplayGridNumCols);
                else


                    assert(~this.ShowInstructionTab);
                    assert(this.ShowAttributeTab);

                    setAppLayoutFromFileName(this.Container,this.DefaultLayoutWAttribFileName);
                end
            end

        end


        function setVisibilityOfTabFigureXClose(this)

            drawnow;

            hideTabXCloseButton(this,this.ROILabelSetDisplay);
            hideTabXCloseButton(this,this.FrameLabelSetDisplay);

            hideTabXCloseButton(this,getDisplay(this.DisplayManager,this.NameNoneDisplay));
            if~isempty(this.AttributesSublabelsDisplay)
                hideTabXCloseButton(this,this.AttributesSublabelsDisplay);
            end
            hideTabXCloseButton(this,this.InstructionsSetDisplay);
            if~isempty(this.SignalNavigationDisplay)
                hideTabXCloseButton(this,this.SignalNavigationDisplay);
            end
            if~isempty(this.OverviewDisplay)
                hideTabXCloseButton(this,this.OverviewDisplay);
            end
            if~isempty(this.MetadataDisplay)
                hideTabXCloseButton(this,this.MetadataDisplay);
            end
        end


        function setDisplayTileLocations(this)
            setDisplayTileLocation(this,this.ROILabelSetDisplay,0);
            setDisplayTileLocation(this,this.FrameLabelSetDisplay,0);

            setDisplayTileLocation(this,getDisplay(this.DisplayManager,this.NameNoneDisplay),1);

            if~isempty(this.AttributesSublabelsDisplay)
                setDisplayTileLocation(this,this.AttributesSublabelsDisplay,2);
            end
            setDisplayTileLocation(this,this.InstructionsSetDisplay,2);
            if~isempty(this.SignalNavigationDisplay)
                setDisplayTileLocation(this,this.SignalNavigationDisplay,3);
            end
            if~isempty(this.OverviewDisplay)
                setDisplayTileLocation(this,this.OverviewDisplay,1);
            end
            if~isempty(this.MetadataDisplay)

                setDisplayTileLocation(this,this.MetadataDisplay,2);
            end

            grabFocus(this.ROILabelSetDisplay);
            drawnow()
        end


        function hideTabXCloseButton(this,displayClass)

            hideTabXCloseButton(this.Container,displayClass.Name);
        end

        function[recreateLayout,setInstrcTileLocation,setAttribTileLocation]=needToRecreateLayoutForAttribSublabel(this,xmlHandlerObj)

            hasAttrib=~isempty(this.AttributesSublabelsDisplay);
            isAttribPanelVisible=hasAttrib&&isPanelVisible(this.AttributesSublabelsDisplay);
            isInstrucPanelVisible=isPanelVisible(this.InstructionsSetDisplay);
            isAttribInstrucColVisible=isAttribPanelVisible||isInstrucPanelVisible;
            needAttribInstructColumn=this.ShowInstructionTab||this.ShowAttributeTab;

            needToShowColumn=~isAttribInstrucColVisible&&needAttribInstructColumn;
            needToHideColumn=isAttribInstrucColVisible&&~needAttribInstructColumn;

            recreateLayout=false;
            setInstrcTileLocation=false;
            setAttribTileLocation=false;

            if needToShowColumn
                if this.ShowInstructionTab||this.ShowAttributeTab

                    recreateLayout=true;
                end
            elseif needToHideColumn
                if attribInstrcPanelsInLastFullColAlone(this.Container,xmlHandlerObj)
                    recreateLayout=true;
                end
            else
                if isAttribPanelVisible&&isInstrucPanelVisible
                else
                    if isAttribPanelVisible
                        if this.ShowInstructionTab
                            setInstrcTileLocation=true;
                        end
                    else
                        if this.ShowAttributeTab
                            setAttribTileLocation=true;
                        end
                    end
                end
            end
        end

        function modifyAttribInstructionPanelVisibility(this)

            if this.ShowAttributeTab
                makeFigureVisible(this.AttributesSublabelsDisplay);
            else
                makeFigureInvisible(this.AttributesSublabelsDisplay);
            end
            drawnow();

            if this.ShowInstructionTab
                makeFigureVisible(this.InstructionsSetDisplay);
            else
                makeFigureInvisible(this.InstructionsSetDisplay);
            end
            drawnow();
        end

        function setAttribOrInstructionPanelTileLocation(this,setInstrcTileLocation,setAttribTileLocation)

            if setInstrcTileLocation
                attrTileNumber=getTileNumber(this,this.AttributesSublabelsDisplay);
                setDisplayTileLocation(this,this.InstructionsSetDisplay,attrTileNumber);
            elseif setAttribTileLocation
                instrucTileNumber=getTileNumber(this,this.InstructionsSetDisplay);
                setDisplayTileLocation(this,this.AttributesSublabelsDisplay,instrucTileNumber);
            end
        end

    end



    methods

        function createProjectedViewLayout(this)
            if~this.ShowAttributeTab
                fullFileName=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool','projected_view_xml.mat');
                projected_params=load(fullFileName);
                opaqueLayout=getTilingLayout(this);
                xmlLayout=serializeLayout(this,opaqueLayout);
                xmlHandlerObj=vision.internal.labeler.tool.XMLHandler(xmlLayout);
                displays=this.DisplayManager.Displays;
                signalid=3;

                if numel(displays)>2
                    defaultDisp4=projected_params.projected_layout.occupantInfo(4);
                    defaultDisp5=projected_params.projected_layout.occupantInfo(5);
                    for i=2:numel(displays)
                        projected_params.projected_layout.occupantInfo(signalid).Name=displays{i}.Name;
                        projected_params.projected_layout.occupantInfo(signalid).InFront='yes';
                        projected_params.projected_layout.occupantInfo(signalid).TargetTileID_1D=1;
                        signalid=signalid+1;
                    end
                    projected_params.projected_layout.occupantInfo(signalid)=defaultDisp4;
                    projected_params.projected_layout.occupantInfo(signalid+1)=defaultDisp5;
                else
                    projected_params.projected_layout.occupantInfo(3).Name=this.DisplayManager.getSelectedDisplay.Name;
                end
                xmlString=xmlHandlerObj.createXML(projected_params.projected_layout.rows,projected_params.projected_layout.Cols,projected_params.projected_layout.Tiles,projected_params.projected_layout.occupantInfo);
                opaqueLayout=deserializeLayout(this,xmlString);
                setAppLayout(this,opaqueLayout);
            else
                fullFileName=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool','projectedViewAttr.mat');
                projected_params=load(fullFileName);
                opaqueLayout=getTilingLayout(this);
                xmlLayout=serializeLayout(this,opaqueLayout);
                xmlHandlerObj=vision.internal.labeler.tool.XMLHandler(xmlLayout);
                displays=this.DisplayManager.Displays;
                signalid=3;

                if numel(displays)>2
                    defaultDisp4=projected_params.projectedViewAttributes.occupants(4);
                    defaultDisp5=projected_params.projectedViewAttributes.occupants(5);
                    defaultDisp6=projected_params.projectedViewAttributes.occupants(6);
                    for i=2:numel(displays)
                        projected_params.projectedViewAttributes.occupants(signalid).Name=displays{i}.Name;
                        projected_params.projectedViewAttributes.occupants(signalid).InFront='yes';
                        projected_params.projectedViewAttributes.occupants(signalid).TargetTileID_1D=1;
                        signalid=signalid+1;
                    end
                    projected_params.projectedViewAttributes.occupants(signalid)=defaultDisp4;
                    projected_params.projectedViewAttributes.occupants(signalid+1)=defaultDisp5;
                    projected_params.projectedViewAttributes.occupants(signalid+2)=defaultDisp6;
                else
                    projected_params.projectedViewAttributes.occupants(3).Name=this.DisplayManager.getSelectedDisplay.Name;
                end
                xmlString=xmlHandlerObj.createXML(projected_params.projectedViewAttributes.rows,projected_params.projectedViewAttributes.cols,projected_params.projectedViewAttributes.tiles,projected_params.projectedViewAttributes.occupants);
                opaqueLayout=deserializeLayout(this,xmlString);
                setAppLayout(this,opaqueLayout)
                setDisplayTileLocation(this,this.ProjectedViewDisplay,2);
                setTabName(this,this.ProjectedViewDisplay,'Projected view');
            end
        end

        function createProjectedViewLayoutInAlgoMode(this)
            fullFileName=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool','projectedViewAttr.mat');
            projected_params=load(fullFileName);
            opaqueLayout=getTilingLayout(this);
            xmlLayout=serializeLayout(this,opaqueLayout);
            xmlHandlerObj=vision.internal.labeler.tool.XMLHandler(xmlLayout);
            displays=this.DisplaysForAutomation;
            signalid=3;
            if numel(this.DisplaysForAutomation)>1



                defDisplay5=projected_params.projectedViewAttributes.occupants(5);
                defDisplay6=projected_params.projectedViewAttributes.occupants(6);
                for i=1:numel(displays)
                    projected_params.projectedViewAttributes.occupants(signalid).Name=displays{i}.Name;
                    projected_params.projectedViewAttributes.occupants(signalid).InFront='yes';
                    projected_params.projectedViewAttributes.occupants(signalid).TargetTileID_1D=1;
                    signalid=signalid+1;
                end
                projected_params.projectedViewAttributes.occupants(signalid).Name=this.NameInstructionsSetDisplay;
                projected_params.projectedViewAttributes.occupants(signalid).InFront='yes';
                projected_params.projectedViewAttributes.occupants(signalid).TargetTileID_1D=3;
                projected_params.projectedViewAttributes.occupants(signalid+1)=defDisplay5;
                projected_params.projectedViewAttributes.occupants(signalid+2)=defDisplay6;
            else
                projected_params.projectedViewAttributes.occupants(3).Name=this.SignalNamesForAutomation;
                projected_params.projectedViewAttributes.occupants(4).Name=this.NameInstructionsSetDisplay;
            end
            xmlString=xmlHandlerObj.createXML(projected_params.projectedViewAttributes.rows,projected_params.projectedViewAttributes.cols,projected_params.projectedViewAttributes.tiles,projected_params.projectedViewAttributes.occupants);
            opaqueLayout=deserializeLayout(this,xmlString);
            setAppLayout(this,opaqueLayout)
            setDisplayTileLocation(this,this.ProjectedViewDisplay,2);
            setTabName(this,this.ProjectedViewDisplay,'Projected view');
            drawnow();
            if this.ShowAttributeTab
                setDisplayTileLocation(this,this.AttributesSublabelsDisplay,3);
            end
        end
    end
end


function newColW=adjustProportionately(colW,newSum)

    newColW=(colW./sum(colW(:)))*newSum;


    if(sum(newColW(:))>newSum)&&(numel(newColW)>1)
        newColW(end)=newSum-sum(newColW(1:(end-1)));
    end
end


function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end
