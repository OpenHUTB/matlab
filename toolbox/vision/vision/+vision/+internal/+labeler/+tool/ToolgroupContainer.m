classdef ToolgroupContainer<vision.internal.labeler.tool.Container




    properties(Access=private)

        PropXClose=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
        PropName=com.mathworks.widgets.desk.DTClientProperty.NAME;
        StateFalse=java.lang.Boolean.FALSE;
        StateTrue=java.lang.Boolean.TRUE;

GroupName
    end

    methods

        function colW=getColumnWidths(this)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            colW=double(md.getDocumentColumnWidths(this.GroupName));
        end


        function colH=getRowHeights(this)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            colH=double(md.getDocumentRowHeights(this.GroupName));
        end


        function numRows=getNumberOfRowTiles(this)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            numRows=md.getDocumentTiledDimension(this.GroupName).height;
        end


        function numCols=getNumberOfColumnTiles(this)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            numCols=md.getDocumentTiledDimension(this.GroupName).width;
        end


        function tf=attribInstrcPanelsInLastFullColAlone(this,xmlHandlerObj)






            instrctTileId=-1;

            numRows=this.NumberOfRowTiles;
            numCols=this.NumberOfColumnTiles;

            attribTileId=getTileNumber(this,this.AttribSublabelFigure);
            tf=(attribTileId>0)&&isTile_Hfull_W1_XendGE2Y0(xmlHandlerObj,attribTileId,numRows,numCols);

            if~tf
                instrctTileId=getTileNumber(this,this.InstructionFigure);

                if attribTileId>0
                    tf=(attribTileId==instrctTileId);
                else
                    tf=(instrctTileId>0)&&isTile_Hfull_W1_XendGE2Y0(xmlHandlerObj,instrctTileId,numRows,numCols);
                end
            end

            if tf
                if(attribTileId>0)||(instrctTileId>0)
                    tileId=max(attribTileId,instrctTileId);
                    tf=isTileOccupiedByNoneOther(xmlHandlerObj,tileId,...
                    this.NameAttributesSublabelsDisplay,this.NameInstructionsSetDisplay);
                end
            end
        end
    end

    methods




        function this=ToolgroupContainer(title,name)

            this@vision.internal.labeler.tool.Container(title,name);
            this.GroupName=this.App.Name;
            this.SignalsMap=containers.Map;
        end

        function tmpWaitFor(~)

        end

        function fig=getSignalFigureByName(this,figName)
            assert(isKey(this.SignalsMap,figName))
            val=this.SignalsMap(figName);
            fig=val{2};
        end

        function removeClientTabGroup(this,hFig,figName)
            removeDocumentTab(this,hFig,figName);
        end

        function removeDocumentTab(this,hFig,figName)
            removeClientTabGroup(this.App,hFig);

            if isKey(this.SignalsMap,figName)
                val=this.SignalsMap(figName);
                fig=val{2};
                if~isempty(fig)



                    remove(this.SignalsMap,figName);
                end


            end
        end


        function addContainerListeners(this)
            toolGroup=this.App;

            addlistener(toolGroup,'GroupAction',@this.onGroupAction);
            addlistener(toolGroup,'ClientAction',@this.onClientAction);


        end




        function addTabs(this,tabs)


            addTabGroup(this.App,tabs);

        end

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
...
...
...



        function loc=getLocation(this)

            loc=imageslib.internal.apputil.ScreenUtilities.getToolCenter(this.App.Name);

        end




        function clear(this)
            this.ProgressBar.setVisible(false);
            clearTitleBarName(this);
            clearQuickAccessBar(this);
        end





        function wait(this)
            setWaiting(this.App,true);
        end




        function resume(this)
            setWaiting(this.App,false);
        end



        function enableQABUndo(this,TF)


            javaMethodEDT('setEnabled',this.UndoButton,any(TF));
        end


        function enableQABRedo(this,TF)


            javaMethodEDT('setEnabled',this.RedoButton,any(TF));
        end










        function enableQuickAccessBar(this)

            javaMethodEDT('setEnabled',this.SaveButton,true);
            this.UndoListener.Enabled='on';
            this.RedoListener.Enabled='on';
            this.SaveListener.Enabled='on';
            this.CutListener.Enabled='on';
            this.CopyListener.Enabled='on';
            this.PasteListener.Enabled='on';

        end




        function disableQuickAccessBar(this)

            this.UndoListener.Enabled='off';
            this.RedoListener.Enabled='off';
            this.SaveListener.Enabled='off';
            this.CutListener.Enabled='off';
            this.CopyListener.Enabled='off';
            this.PasteListener.Enabled='off';

        end




        function clearQuickAccessBar(this)

            javaMethodEDT('setEnabled',this.SaveButton,false);
            enableUndo(this,false);
            enableRedo(this,false);
            enableCut(this,false);
            enableCopy(this,false);
            enableRedo(this,false);

        end




        function enableUndo(this,TF)
            javaMethodEDT('setEnabled',this.UndoButton,TF);
        end




        function enableRedo(this,TF)
            javaMethodEDT('setEnabled',this.RedoButton,TF);
        end




        function enableCut(this,TF)
            javaMethodEDT('setEnabled',this.CutButton,TF);
        end




        function enableCopy(this,TF)
            javaMethodEDT('setEnabled',this.CopyButton,TF);
        end




        function enablePaste(this,TF)
            javaMethodEDT('setEnabled',this.PasteButton,TF);
        end




        function approveClose(this)
            try %#ok<TRYNC>
                approveClose(this.App);
            end
        end




        function vetoClose(this)
            vetoClose(this.App);
        end




        function close(this)
            close(this.App);
        end

        function name=getGroupName(this)
            name=this.GroupName;
        end

        function makeVisibleAtPos(this)
            [x,y,w,h]=imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition;
            setPosition(this.App,x,y,w,h);

            open(this.App);
        end


        function setDocPanelNames(this)
            drawnow;

            setTabName(this,this.ROILabelFigure.Name,this.NameROILabelSetDisplay);
            setTabName(this,this.FrameLabelFigure.Name,this.NameFrameLabelSetDisplay);
            setTabName(this,this.NoneSignalFigure.Name,this.NameNoneDisplay);
            setTabName(this,this.InstructionFigure.Name,this.NameInstructionsSetDisplay);
            setTabName(this,this.AttribSublabelFigure.Name,this.NameAttributesSublabelsDisplay);
            setTabName(this,this.SignalNavFigure.Name,this.NameSignalNavigationDisplay);
        end

        function makeSignalVisible(~,display)
            makeFigureVisible(display);
        end

        function makeSignalInvisible(~,display)
            makeFigureInvisible(display);
        end

        function addNewSignalFigure(this,title)
            assert(isempty(this.SignalsMap)||(~isKey(this.SignalsMap,title)));

            fig=createFig(this);
            id=length(this.SignalsMap)+1;
            this.SignalsMap(title)={id,fig};

            addFigure(this.App,fig);
        end

        function addFigure(this,fig)
            addFigure(this.App,fig);
        end


        function addFigures(this,addOverviewFigure,addMetadataFigure)
            this.NoneSignalFigure=createFig(this);
            addFigure(this.App,this.NoneSignalFigure);

            this.ROILabelFigure=createFig(this);
            addFigure(this.App,this.ROILabelFigure);

            this.SignalNavFigure=createFig(this);
            addFigure(this.App,this.SignalNavFigure);

            this.FrameLabelFigure=createFig(this);
            addFigure(this.App,this.FrameLabelFigure);

            this.InstructionFigure=createFig(this);
            addFigure(this.App,this.InstructionFigure);

            this.AttribSublabelFigure=createFig(this);
            addFigure(this.App,this.AttribSublabelFigure);

            if addOverviewFigure
                this.OverviewFigure=createFig(this);
                addFigure(this.App,this.OverviewFigure);
            end

            if addMetadataFigure
                this.MetadataFigure=createFig(this);
                addFigure(this.App,this.MetadataFigure);
            end

            drawnow;
        end

        function setTabName(this,displayClassName,name)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.getClient(displayClassName,this.GroupName).putClientProperty(this.PropName,name);

        end

        function hideTabXCloseButton(this,displayClassName)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.getClient(displayClassName,this.GroupName).putClientProperty(this.PropXClose,this.StateFalse);
        end

        function showTearOffDialog(this,tearOffPopUp,toolstripBtn,isFloat)
            if isempty(isFloat)
                showTearOffDialog(this.App,tearOffPopUp,toolstripBtn);
            else
                showTearOffDialog(this.App,tearOffPopUp,toolstripBtn,logical(isFloat));
            end
        end


        function makeDefaultFiguresVisible(this,showNavControlTab)
            set(this.ROILabelFigure,'Visible','on');
            set(this.FrameLabelFigure,'Visible','on');

            if~showNavControlTab
                set(this.NoneSignalFigure,'Visible','on');
            end

            drawnow()
        end

        function showNoneSignalDisplay(this)
            set(this.NoneSignalFigure,'Visible','on');
        end


        function makeUnusedFiguresInvisible(this,showInstructionTab,showAttributeTab,showNavControlTab,showMetadataTab)



            if~showInstructionTab
                set(this.InstructionFigure,'Visible','off');
            end

            if~showAttributeTab
                set(this.AttribSublabelFigure,'Visible','off');
            end

            if~showNavControlTab
                set(this.SignalNavFigure,'Visible','off');
            end

            if~showMetadataTab
                if isvalid(this.MetadataFigure)
                    set(this.MetadataFigure,'Visible','off');
                end
            end

            drawnow()
        end

        function makeNonDisplayInvisible(this)
            set(this.NoneSignalFigure,'Visible','off');
        end

        function makeSignalNavVisible(this)
            set(this.SignalNavFigure,'Visible','on');
        end

        function makeSignalNavInvisible(this)
            set(this.SignalNavFigure,'Visible','off');
        end



        function delete(this)

            deleteIfFigHandle(this.NoneSignalFigure);
            deleteIfFigHandle(this.ROILabelFigure);
            deleteIfFigHandle(this.SignalNavFigure);
            deleteIfFigHandle(this.FrameLabelFigure);
            deleteIfFigHandle(this.InstructionFigure);
            deleteIfFigHandle(this.AttribSublabelFigure);
            figsCell=values(this.SignalsMap);
            for i=1:numel(figsCell)
                deleteIfFigHandle(figsCell{i});
            end
            deleteIfFigHandle(this.OverviewFigure);
            deleteIfFigHandle(this.MetadataFigure);
        end

    end




    methods


        function[numRows,numCols]=getGridLayout(this)
            numRows=this.NumberOfRowTiles-this.ShowOverviewTab-1;
            numCols=this.NumberOfColumnTiles-this.ShowAttributeTab-1;
        end


        function tileNumber=getTileNumber(this,fig)

            tileNumber=-1;
            if isVisible(fig)
                pause(0.2);
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                client=md.getClient(fig.Name,this.GroupName);
                clientLocObj=md.getClientLocation(client);
                if~isempty(clientLocObj)
                    tileNumber=clientLocObj.getTile();
                end
            end
        end


        function hideSignalNavTabBarIfAny(this)
            tileNumber=getTileNumber(this,this.SignalNavFigure);
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setDocumentBarPosition(this.GroupName,tileNumber,...
            com.mathworks.widgets.desk.Desktop.HIDE_DOCUMENT_BAR);
        end


        function setAppLayout(this,opaqueLayout)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setDocumentTiling(this.GroupName,opaqueLayout);




            drawnow();
            hideSignalNavTabBarIfAny(this);
        end

        function setAppLayoutFromFileName(this,xmlFileName)
            xmlFile=fullfile(toolboxdir('vision'),'vision',...
            '+vision','+internal','+labeler','+tool',xmlFileName);
            xDoc=xmlread(xmlFile);
            xmlString=xmlwrite(xDoc);
            opaqueLayout=deserializeLayout(this,xmlString);
            setAppLayout(this,opaqueLayout);
        end


        function out=getTilingLayout(this)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            out=md.getDocumentTiling(this.GroupName);
        end

        function resetAppFigDocLayout(this,numRows,numCols)
        end


        function xmlString=createXMLandGenerateLayout(this,...
            displayGridNumRows,displayGridNumCols,hasVisualSummary)
            assert(displayGridNumRows>=1&&displayGridNumRows<=3);
            assert(displayGridNumCols>=1&&displayGridNumCols<=3);

            this.CurrentDisplayGridNumRows=displayGridNumRows;
            this.CurrentDisplayGridNumCols=displayGridNumCols;

            opaqueLayout=getTilingLayout(this);
            xmlLayout=serializeLayout(this,opaqueLayout);
            xmlHandlerObj=vision.internal.labeler.tool.XMLHandler(xmlLayout);
            newColWidths=computeNewColumnWidthsForDisplay(this,displayGridNumCols,xmlHandlerObj);
            newRowHeights=computeNewRowHeightsForDisplay(this,displayGridNumRows,xmlHandlerObj);

            isVisualSummaryDocked=hasVisualSummary&&...
            contains(string(xmlLayout),this.NameVisualSummaryDisplay);






            needAttribInstructColumn=this.ShowInstructionTab||this.ShowAttributeTab;
            numTilesAfterMerge=1...
            +(displayGridNumRows*displayGridNumCols)...
            +needAttribInstructColumn...
            +this.ShowNavControlTab...
            +this.ShowOverviewTab;
            numRows=displayGridNumRows+this.ShowNavControlTab+this.ShowOverviewTab;
            numCols=1+displayGridNumCols+needAttribInstructColumn;















            if this.ShowNavControlTab
                numDisplays=this.NumSignalFigures;
                docAreaFigureNames=['Signal',keysOrderedByCreation(this)];
            else
                numDisplays=1;
                docAreaFigureNames={'Signal'};
            end


            numVisibleOccupants=2+numDisplays+...
            this.ShowNavControlTab+...
            this.ShowInstructionTab+...
            this.ShowAttributeTab+...
            this.ShowOverviewTab+...
            this.ShowMetadataTab+...
            isVisualSummaryDocked;

            isROIDefinitionPanelInFront=isInFront(this,this.NameROILabelSetDisplay,xmlHandlerObj);
            if this.ShowInstructionTab&&this.ShowAttributeTab
                isInstructionPanelFront=isInFront(this,this.NameInstructionsSetDisplay,xmlHandlerObj);
                isAttribSublabelPanelFront=~isInstructionPanelFront;
            else

                isInstructionPanelFront=true;
                isAttribSublabelPanelFront=true;
            end

            mergedTileInfo=repmat(struct('TopLeftXY',[0,0],'HinNumRows',1,'WinNumCols',1),[numTilesAfterMerge,1]);



            i=1;
            mergedTileInfo(i).TopLeftXY=[0,0];
            mergedTileInfo(i).HinNumRows=numRows;
            mergedTileInfo(i).WinNumCols=1;
            if this.ShowOverviewTab
                mergedTileInfo(i).HinNumRows=numRows-2;
            end



            i=2;
            for r=1:displayGridNumRows
                r_0b=r-1;
                for c=1:displayGridNumCols
                    c_0b=c;


                    mergedTileInfo(i).TopLeftXY=[c_0b,r_0b];
                    mergedTileInfo(i).HinNumRows=1;
                    mergedTileInfo(i).WinNumCols=1;
                    if this.ShowOverviewTab
                        mergedTileInfo(i).HinNumRows=2;
                    end
                    i=i+1;
                end
            end


            if needAttribInstructColumn
                assert(c==numCols-2);

                mergedTileInfo(i).TopLeftXY=[numCols-1,0];
                mergedTileInfo(i).HinNumRows=numRows;
                mergedTileInfo(i).WinNumCols=1;

                if this.ShowMetadataTab
                    mergedTileInfo(i).HinNumRows=numRows-1;
                end

                i=i+1;
            end


            if this.ShowOverviewTab
                if this.ShowNavControlTab
                    assert(r==numRows-2);
                else
                    assert(r==numRows-1);
                end
                mergedTileInfo(i).TopLeftXY=[0,numRows-2];
                mergedTileInfo(i).HinNumRows=2;
                mergedTileInfo(i).WinNumCols=1;

                i=i+1;
                r=r+1;
            end



            if this.ShowNavControlTab
                assert(r==numRows-1);
                mergedTileInfo(i).TopLeftXY=[1,numRows-1];
                mergedTileInfo(i).HinNumRows=1;
                mergedTileInfo(i).WinNumCols=numCols-1-needAttribInstructColumn;
                i=i+1;
            end


            if this.ShowMetadataTab
                mergedTileInfo(i).TopLeftXY=[numCols-1,numRows-1];
                mergedTileInfo(i).HinNumRows=1;
                mergedTileInfo(i).WinNumCols=1;

            end


            occupantInfo=repmat(struct('Name','defaultName','InFront','yes','TargetTileID_1D',1),[numVisibleOccupants,1]);

            i=1;
            occupantInfo(i).Name=this.NameROILabelSetDisplay;
            occupantInfo(i).InFront=bool2YesNo(this,isROIDefinitionPanelInFront);
            occupantInfo(i).TargetTileID_1D=0;

            i=2;
            occupantInfo(i).Name=this.NameFrameLabelSetDisplay;
            occupantInfo(i).InFront=bool2YesNo(this,~isROIDefinitionPanelInFront);
            occupantInfo(i).TargetTileID_1D=0;







            if this.ShowNavControlTab
                displayIdx=1;
                numActiveDisplays=this.NumSignalFigures;
            else
                displayIdx=0;
                numActiveDisplays=1;
            end

            dispCount=0;



            targetTileID_1D=1;
            if isVisualSummaryDocked

                i=i+1;
                occupantInfo(i).Name=this.NameVisualSummaryDisplay;
                occupantInfo(i).InFront='no';
                occupantInfo(i).TargetTileID_1D=targetTileID_1D;
            end




            targetTileID_1D=0;
            for r=1:displayGridNumRows
                for c=1:displayGridNumCols
                    dispCount=dispCount+1;
                    if dispCount<=numActiveDisplays

                        displayIdx=displayIdx+1;
                        targetTileID_1D=targetTileID_1D+1;

                        i=i+1;
                        occupantInfo(i).Name=docAreaFigureNames{displayIdx};
                        occupantInfo(i).InFront='yes';
                        occupantInfo(i).TargetTileID_1D=targetTileID_1D;
                    else
                        targetTileID_1D=targetTileID_1D+1;
                    end
                end
            end





            for loopidx=1:(numActiveDisplays-(displayGridNumRows*displayGridNumCols))

                displayIdx=displayIdx+1;
                i=i+1;
                occupantInfo(i).Name=docAreaFigureNames{displayIdx};
                occupantInfo(i).InFront='no';
                occupantInfo(i).TargetTileID_1D=targetTileID_1D;
            end

            if this.ShowInstructionTab||this.ShowAttributeTab



                targetTileID_1D=targetTileID_1D+1;

                if this.ShowInstructionTab
                    i=i+1;
                    occupantInfo(i).Name=this.NameInstructionsSetDisplay;
                    occupantInfo(i).InFront=bool2YesNo(this,isInstructionPanelFront);
                    occupantInfo(i).TargetTileID_1D=targetTileID_1D;
                end

                if this.ShowAttributeTab
                    i=i+1;
                    occupantInfo(i).Name=this.NameAttributesSublabelsDisplay;
                    occupantInfo(i).InFront=bool2YesNo(this,isAttribSublabelPanelFront);
                    occupantInfo(i).TargetTileID_1D=targetTileID_1D;
                end
            end

            if this.ShowOverviewTab


                targetTileID_1D=targetTileID_1D+1;

                i=i+1;
                occupantInfo(i).Name=this.NameOverviewDisplay;
                occupantInfo(i).InFront='yes';
                occupantInfo(i).TargetTileID_1D=targetTileID_1D;
            end


            if this.ShowNavControlTab



                targetTileID_1D=targetTileID_1D+1;

                i=i+1;
                occupantInfo(i).Name=this.NameSignalNavigationDisplay;
                occupantInfo(i).InFront='yes';
                occupantInfo(i).TargetTileID_1D=targetTileID_1D;
            end

            if this.ShowMetadataTab

                targetTileID_1D=targetTileID_1D+1;

                i=i+1;
                occupantInfo(i).Name=this.NameMetadataDisplay;
                occupantInfo(i).InFront='yes';
                occupantInfo(i).TargetTileID_1D=targetTileID_1D;
            end

            drawnow;
            xmlString=xmlHandlerObj.createXML(newRowHeights,newColWidths,mergedTileInfo,occupantInfo);
            opaqueLayout=deserializeLayout(this,xmlString);
            setAppLayout(this,opaqueLayout);




            hideSignalNavTabBarIfAny(this);

        end


        function serializeLayoutToFile(~,opaqueLayout,fullFileName)
            com.mathworks.widgets.desk.TilingSerializer.serialize(opaqueLayout,java.io.File(fullFileName));
        end


        function opaqueLayout=deserializeLayoutFromFile(~,fullFileName)
            opaqueLayout=com.mathworks.widgets.desk.TilingSerializer.deserialize(java.io.File(fullFileName));
        end

        function tf=isNoneSignalDocVisible(this)
            tf=isVisible(this.NoneSignalFigure);
        end

        function makeAttribSublabelVisible(this)
            set(this.AttribSublabelFigure,'Visible','on');
        end

        function makeAttribSublabelInvisible(this)
            set(this.AttribSublabelFigure,'Visible','off');
        end

        function makeInstructionVisible(this)
            set(this.InstructionFigure,'Visible','on');
        end

        function makeInstructionInvisible(this)
            set(this.InstructionFigure,'Visible','off');
        end

        function makeOverviewVisible(this)


            if isvalid(this.OverviewFigure)
                set(this.OverviewFigure,'Visible','on');
            end
        end

        function makeOverviewInvisible(this)


            if isvalid(this.OverviewFigure)
                set(this.OverviewFigure,'Visible','off');
            end
        end

        function makeMetadataVisible(this)
            set(this.MetadataFigure,'Visible','on');
        end

        function makeMetadataInvisible(this)
            set(this.MetadataFigure,'Visible','off');
        end

    end


    methods(Access=public)


        function layout=getLayout(this)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            layout=getDocumentTiling(md,this.App.Name);

        end


        function setLayout(this,layout)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            setDocumentTiling(md,this.App.Name,layout);

            drawnow();

        end


        function setLayoutToFile(~,layout,fileName)

            com.mathworks.widgets.desk.TilingSerializer.serialize(layout,java.io.File(fileName));
        end


        function layout=getLayoutFromFile(~,fileName)
            layout=com.mathworks.widgets.desk.TilingSerializer.deserialize(java.io.File(fileName));
        end


        function tf=hasLayoutAttributePanel(this,inLayout)
            layoutXML=serializeLayout(this,inLayout);
            tf=contains(string(layoutXML),this.NameAttributesSublabelsDisplay);
        end


        function tf=hasLayoutSignalNavPanel(this,inLayout)
            layoutXML=serializeLayout(this,inLayout);
            tf=contains(string(layoutXML),this.NameSignalNavigationDisplay);
        end


        function xmlLayout=serializeLayout(~,layout)
            xmlLayout=com.mathworks.widgets.desk.TilingSerializer.serialize(layout);
        end


        function layout=deserializeLayout(~,xmlLayout)
            layout=com.mathworks.widgets.desk.TilingSerializer.deserialize(xmlLayout);
        end

        function setClosingApprovalNeeded(this,flag)
            setClosingApprovalNeeded(this.App,flag);
        end


        function setTitleBar(this,str)
            this.App.Title=str;
        end


        function str=getTitleBar(this)
            str=this.App.Title;
        end

    end
    methods(Access=protected)



        function openApp(this)

            addContainerListeners(this);
        end


        function onClientAction(this,~,evt)


            data=evt.EventData;
            hFig=data.Client;

            if isempty(hFig)||~isvalid(hFig)
                return;
            end

            type=data.EventType;
            if strcmp(type,'DEACTIVATED')

            elseif strcmp(type,'ACTIVATED')


                if~isempty(hFig)&&ishghandle(hFig)

                    evtData=vision.internal.labeler.tool.display.ClientEventData(hFig.Name);
                    reactToAppClientActivation(this,evtData);
                end


            end

        end


        function onGroupAction(this,~,evt)

            if~isvalid(this)
                return;
            end

            switch evt.EventData.EventType

            case 'ACTIVATED'
                reactToAppInFocus(this);

            case 'DEACTIVATED'
                reactToAppFocusLost(this);

            case 'CLOSING'
                if isClosingApprovalNeeded(this.App)
                    reactToAppClosing(this);
                end
            end

        end


        function createApp(this,title,name)


            this.App=matlab.ui.internal.desktop.ToolGroup(title,name);


            switch title
            case vision.getMessage('vision:labeler:ToolTitleGTL')
                vision.internal.addDDUXLogging(this.App,'Automated Driving Toolbox','Ground Truth Labeler');

            case vision.getMessage('vision:labeler:ToolTitleVL')
                vision.internal.addDDUXLogging(this.App,'Computer Vision Toolbox','Video Labeler');

            case vision.getMessage('vision:labeler:ToolTitleIL')
                vision.internal.addDDUXLogging(this.App,'Computer Vision Toolbox','Image Labeler');
            end

            disableDataBrowser(this.App);
            removeDocumentTabs(this);

            wireUpQuickAccessBar(this);

            if~isdeployed()
                this.App.setContextualHelpCallback(@(es,ed)doc(title));
            end

            setClosingApprovalNeeded(this,true);

            hideViewTab(this.App);
        end

        function disableDragDrop(~)
            dropListener=com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER,dropListener);
        end

        function removeDocumentTabs(this)

            group=this.App.Peer.getWrappedComponent;



            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR,false);

            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE,false);
        end


        function wireUpQuickAccessBar(this)

            undoAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Undo',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',undoAction,false);
            this.UndoListener=addlistener(undoAction.getCallback,'delayed',@(~,~)notify(this,'UndoRequested'));

            redoAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Redo',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',redoAction,false);
            this.RedoListener=addlistener(redoAction.getCallback,'delayed',@(~,~)notify(this,'RedoRequested'));

            helpAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Help',javax.swing.ImageIcon);
            helpEnable=~isdeployed();
            javaMethodEDT('setEnabled',helpAction,helpEnable);
            this.HelpListener=addlistener(helpAction.getCallback,'delayed',@(~,~)notify(this,'HelpRequested'));


            ctm=com.mathworks.toolstrip.factory.ContextTargetingManager;
            ctm.setToolName(undoAction,'undo');
            ctm.setToolName(redoAction,'redo');
            ctm.setToolName(helpAction,'help');


            ja=javaArray('javax.swing.Action',1);
            ja(1)=undoAction;
            ja(2)=redoAction;
            ja(3)=helpAction;

            c=this.App.Peer.getWrappedComponent;
            c.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS,ja);

            this.UndoButton=undoAction;
            this.RedoButton=redoAction;
            this.HelpButton=helpAction;

        end


        function removeFromLayout(this,str)


            xmlReader=vision.internal.labeler.tool.XML(serializeLayout(this,getLayout(this)));

            xmlString=removeFromLayout(xmlReader,str);

            if~isempty(xmlString)


                setLayout(this,deserializeLayout(this,xmlString));
                drawnow;

            end

        end


        function createProgressBar(this)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            frame=md.getFrameContainingGroup(this.App.Name);
            sb=javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
            javaMethodEDT('setSharedStatusBar',frame,sb)
            this.ProgressBar=javaObjectEDT('javax.swing.JLabel','');
            this.ProgressBar.setName('progressLabel');
            this.ProgressBar.setVisible(false);
            sb.add(this.ProgressBar);

        end
    end

    methods(Access=private)
        function hFig=createFig(this)

            warning('off','MATLAB:figure:SetResize');
            c=onCleanup(@()warning('on','MATLAB:figure:SetResize'));


            hFig=figure('Resize','off','Visible','off',...
            'NumberTitle','off','Name','','HandleVisibility',...
            'callback','Color','white','IntegerHandle','off');
        end

        function newColWidths=computeNewColumnWidthsForDisplay(this,displayGridNumCols,xmlHandlerObj)











            if roiSceneLabelPanelsShareFirstCol(this)
                firstColW=this.ColumnWidths(1);
            else
                firstColW=this.LABEL_DEF_COL_W;
            end











            if attribInstrcPanelsInLastFullColAlone(this,xmlHandlerObj)
                attribInstrcColW=this.ColumnWidths(end);
            else
                attribInstrcColW=this.ATTRIB_INSTRCT_COL_W;
            end









            needAttribInstructColumn=needToKeepAttribInstrcPanels(this);
            newColWidths=zeros(1+displayGridNumCols+double(needAttribInstructColumn),1);
            newColWidths(1)=firstColW;
            if needAttribInstructColumn
                newColWidths(end)=attribInstrcColW;
                eachDispColW=(1.0-firstColW-attribInstrcColW)/displayGridNumCols;
                newColWidths(2:end-1)=eachDispColW;
            else
                eachDispColW=(1.0-firstColW)/displayGridNumCols;
                newColWidths(2:end)=eachDispColW;
            end


            if sum(newColWidths)~=1
                newColWidths(end)=1-sum(newColWidths(1:end-1));
            end
        end
        function newRowHeights=computeNewRowHeightsForDisplay(this,displayGridNumRows,xmlHandlerObj)



            needRangeSlider=(this.NumSignalFigures>0);
            needOverviewDisplay=this.ShowOverviewTab;

            if~needRangeSlider&&~needOverviewDisplay


                newRowHeights=1.0;
                return;
            end

            newRowHeights=zeros(displayGridNumRows+needRangeSlider+needOverviewDisplay,1);

            if(numel(this.RowHeights)>1)&&...
                doesSignalNavOccupyTile(this)&&...
                doesSignalNavOccupyLastTile(this,xmlHandlerObj)&&...
                ~isLastTile_H1_W1_X1(this,xmlHandlerObj)

                newRowHeights(end)=this.RowHeights(end);
                heightUsed=newRowHeights(end);
            else

                newRowHeights(end)=this.NAV_CONTROL_ROW_H;
                heightUsed=newRowHeights(end);
            end

            if needOverviewDisplay
                newRowHeights(end-1)=this.OVERVIEW_ROW_H-this.NAV_CONTROL_ROW_H;
                heightUsed=[heightUsed,newRowHeights(end-1)];
            end

            eachDispRowH=(1.0-sum(heightUsed))/displayGridNumRows;
            newRowHeights(1:end-numel(heightUsed))=eachDispRowH;


            if sum(newRowHeights)~=1
                newRowHeights(end)=1-sum(newRowHeights(1:end-numel(heightUsed)));
            end
        end


        function tf=roiSceneLabelPanelsShareFirstCol(this)



            roiLabelTileNumber=getTileNumber(this,this.ROILabelFigure);
            sceneLabelTileNumber=getTileNumber(this,this.FrameLabelFigure);
            tf=(roiLabelTileNumber==0)&&...
            (roiLabelTileNumber==sceneLabelTileNumber);
        end



        function tf=needToKeepAttribInstrcPanels(this)
            tf=this.ShowAttributeTab||this.ShowInstructionTab;
        end


        function tf=doesSignalNavOccupyTile(this)


            tf=(getTileNumber(this,this.SignalNavFigure)>0);
        end

        function tf=doesSignalNavOccupyLastTile(this,xmlHandlerObj)
            tf=xmlHandlerObj.isLastOccupant(this.NameSignalNavigationDisplay);
        end

        function tf=isLastTile_H1_W1_X1(this,xmlHandlerObj)
            tf=xmlHandlerObj.isLastTile_H1_W1_X1();
        end



        function tf=isInFront(~,name,xmlLayout)


            tf=xmlLayout.isInFront(name);
        end

        function yesNo=bool2YesNo(~,flag)
            if flag
                yesNo='yes';
            else
                yesNo='no';
            end
        end


        function sortedKeys=keysOrderedByCreation(this)

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
...

            tmpKeys=keys(this.SignalsMap);
            vals=values(this.SignalsMap);
            ids=cellfun(@(v)v{1},vals);
            [sortedIds,sortIdx]=sort(ids);
            sortedKeys=tmpKeys(sortIdx);
        end
    end


end

function tf=isVisible(fig)
    tf=strcmp(fig.Visible,'on');
end

function deleteIfFigHandle(fig)
    if ishandle(fig)
        delete(fig)
    end
end

