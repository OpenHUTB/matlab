classdef ToolgroupContainer<images.internal.app.segmenter.volume.display.Container



    properties(Access=private)

        CloseListener event.listener

    end

    methods




        function self=ToolgroupContainer(show3DDisplay)

            self@images.internal.app.segmenter.volume.display.Container(show3DDisplay);

        end




        function addTabs(self,tabs)

            addTabGroup(self.App,tabs);

        end




        function loc=getLocation(self)

            loc=imageslib.internal.apputil.ScreenUtilities.getToolCenter(self.App.Name);

        end




        function clear(self)
            self.ProgressBar.setVisible(false);
            clearTitleBarName(self);
            clearQuickAccessBar(self);
        end





        function wait(self)
            setWaiting(self.App,true);
        end




        function resume(self)
            setWaiting(self.App,false);
        end




        function setColumnLayout(self)

            if~self.VolumeSupported
                setTwoColumnLayout(self);
                return;
            end

            makeAllFiguresVisible(self);

            xmlReader=images.internal.app.segmenter.volume.display.XML(serializeLayout(self,getLayout(self)));

            tileInfo(1).Height=1;
            tileInfo(1).Width=1;
            tileInfo(1).X=0;
            tileInfo(1).Y=0;

            tileInfo(2).Height=1;
            tileInfo(2).Width=1;
            tileInfo(2).X=1;
            tileInfo(2).Y=0;

            tileInfo(3).Height=1;
            tileInfo(3).Width=1;
            tileInfo(3).X=2;
            tileInfo(3).Y=0;

            occupantInfo(1).InFront='yes';
            occupantInfo(1).Name='Labels';
            occupantInfo(1).Tile=0;

            occupantInfo(2).InFront='yes';
            occupantInfo(2).Name='Slice';
            occupantInfo(2).Tile=1;

            occupantInfo(3).InFront='yes';
            occupantInfo(3).Name='3-D Display';
            occupantInfo(3).Tile=2;

            occupantInfo(4).InFront='yes';
            occupantInfo(4).Name='Current Block';
            occupantInfo(4).Tile=2;

            if self.OverviewVisible
                occupantInfo(5).InFront='no';
                occupantInfo(5).Name='Overview';
                occupantInfo(5).Tile=2;
            end

            xmlString=createXML(xmlReader,[0.2,0.55,0.25],1,tileInfo,occupantInfo);
            setLayout(self,deserializeLayout(self,xmlString));

            drawnow;

        end




        function setStackedLayout(self)

            if~self.VolumeSupported
                setTwoColumnLayout(self);
                return;
            end

            makeAllFiguresVisible(self);

            xmlReader=images.internal.app.segmenter.volume.display.XML(serializeLayout(self,getLayout(self)));

            tileInfo(1).Height=1;
            tileInfo(1).Width=1;
            tileInfo(1).X=0;
            tileInfo(1).Y=0;

            tileInfo(2).Height=2;
            tileInfo(2).Width=1;
            tileInfo(2).X=1;
            tileInfo(2).Y=0;

            tileInfo(3).Height=1;
            tileInfo(3).Width=1;
            tileInfo(3).X=0;
            tileInfo(3).Y=1;

            occupantInfo(1).InFront='yes';
            occupantInfo(1).Name='Labels';
            occupantInfo(1).Tile=0;

            occupantInfo(2).InFront='yes';
            occupantInfo(2).Name='Slice';
            occupantInfo(2).Tile=1;

            occupantInfo(3).InFront='yes';
            occupantInfo(3).Name='3-D Display';
            occupantInfo(3).Tile=2;

            occupantInfo(4).InFront='yes';
            occupantInfo(4).Name='Current Block';
            occupantInfo(4).Tile=2;

            if self.OverviewVisible
                occupantInfo(5).InFront='no';
                occupantInfo(5).Name='Overview';
                occupantInfo(5).Tile=2;
            end

            xmlString=createXML(xmlReader,[0.3,0.7],[0.5,0.5],tileInfo,occupantInfo);
            setLayout(self,deserializeLayout(self,xmlString));

            drawnow;

        end




        function enableQuickAccessBar(self)

            javaMethodEDT('setEnabled',self.SaveButton,true);
            self.UndoListener.Enabled='on';
            self.RedoListener.Enabled='on';
            self.SaveListener.Enabled='on';
            self.CutListener.Enabled='on';
            self.CopyListener.Enabled='on';
            self.PasteListener.Enabled='on';

        end




        function disableQuickAccessBar(self)

            self.UndoListener.Enabled='off';
            self.RedoListener.Enabled='off';
            self.SaveListener.Enabled='off';
            self.CutListener.Enabled='off';
            self.CopyListener.Enabled='off';
            self.PasteListener.Enabled='off';

        end




        function clearQuickAccessBar(self)

            javaMethodEDT('setEnabled',self.SaveButton,false);
            enableUndo(self,false);
            enableRedo(self,false);
            enableCut(self,false);
            enableCopy(self,false);
            enableRedo(self,false);

        end




        function enableUndo(self,TF)
            javaMethodEDT('setEnabled',self.UndoButton,TF);
        end




        function enableRedo(self,TF)
            javaMethodEDT('setEnabled',self.RedoButton,TF);
        end




        function enableCut(self,TF)
            javaMethodEDT('setEnabled',self.CutButton,TF);
        end




        function enableCopy(self,TF)
            javaMethodEDT('setEnabled',self.CopyButton,TF);
        end




        function enablePaste(self,TF)
            javaMethodEDT('setEnabled',self.PasteButton,TF);
        end




        function approveClose(self)

            try %#ok<TRYNC>
                approveClose(self.App);
            end

            self.CloseListener.Enabled=false;

            delete(self);

        end




        function vetoClose(self)
            vetoClose(self.App);
        end




        function close(self)
            close(self.App);
        end

    end


    methods(Access=protected)


        function setTwoColumnLayout(self)

            makeAllFiguresVisible(self);

            xmlReader=images.internal.app.segmenter.volume.display.XML(serializeLayout(self,getLayout(self)));

            tileInfo(1).Height=1;
            tileInfo(1).Width=1;
            tileInfo(1).X=0;
            tileInfo(1).Y=0;

            tileInfo(2).Height=1;
            tileInfo(2).Width=1;
            tileInfo(2).X=1;
            tileInfo(2).Y=0;

            occupantInfo(1).InFront='yes';
            occupantInfo(1).Name='Labels';
            occupantInfo(1).Tile=0;

            occupantInfo(2).InFront='yes';
            occupantInfo(2).Name='Slice';
            occupantInfo(2).Tile=1;

            xmlString=createXML(xmlReader,[0.25,0.75],1,tileInfo,occupantInfo);
            setLayout(self,deserializeLayout(self,xmlString));

            drawnow;

        end


        function layout=getLayout(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            layout=getDocumentTiling(md,self.App.Name);

        end


        function setLayout(self,layout)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            setDocumentTiling(md,self.App.Name,layout);

            drawnow();

        end


        function setLayoutToFile(~,layout,fileName)

            com.mathworks.widgets.desk.TilingSerializer.serialize(layout,java.io.File(fileName));
        end


        function layout=getLayoutFromFile(~,fileName)
            layout=com.mathworks.widgets.desk.TilingSerializer.deserialize(java.io.File(fileName));
        end


        function xmlLayout=serializeLayout(~,layout)
            xmlLayout=com.mathworks.widgets.desk.TilingSerializer.serialize(layout);
        end


        function layout=deserializeLayout(~,xmlLayout)
            layout=com.mathworks.widgets.desk.TilingSerializer.deserialize(xmlLayout);
        end


        function openApp(self)

            [x,y,width,height]=imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            setPosition(self.App,x,y,width,height);

            addlistener(self.App,'GroupAction',@(src,evt)actionCallback(self,evt));

            open(self.App);

            createProgressBar(self);

            addFigures(self);

        end


        function actionCallback(self,evt)

            if~isvalid(self)
                return;
            end

            switch evt.EventData.EventType

            case 'ACTIVATED'


            case 'CLOSING'
                reactToAppClosing(self);

            end

        end


        function addFigures(self)

            self.LabelFigure=figure('NumberTitle','off',...
            'Units','pixels',...
            'Name','Labels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self),...
            'CloseRequestFcn',@(~,~)showLabels(self,false));

            addFigure(self.App,self.LabelFigure);

            self.SliceFigure=figure('NumberTitle','off',...
            'Units','pixels',...
            'Name','Slice',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));

            self.CloseListener=event.listener(self.SliceFigure,'ObjectBeingDestroyed',@(~,~)close(self));

            addFigure(self.App,self.SliceFigure);

            self.VolumeFigure=figure('NumberTitle','off',...
            'Units','pixels',...
            'Name','3-D Display',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self),...
            'CloseRequestFcn',@(~,~)showVolume(self,false));

            addFigure(self.App,self.VolumeFigure);

            self.OverviewFigure=figure('NumberTitle','off',...
            'Units','pixels',...
            'Name','Overview',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self),...
            'CloseRequestFcn',@(~,~)showOverview(self,false));

            addFigure(self.App,self.OverviewFigure);

            drawnow;


            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;

            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            md.getClient(self.SliceFigure.Name,self.App.Name).putClientProperty(prop,java.lang.Boolean.FALSE);

        end


        function createApp(self)


            self.App=matlab.ui.internal.desktop.ToolGroup(getString(message('images:segmenter:volumeSegmenter')));

            images.internal.app.utilities.addDDUXLogging(self.App,'Image Processing Toolbox','Volume Segmenter');

            disableDataBrowser(self.App);

            g=self.App.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR,false);

            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE,false);

            wireUpQuickAccessBar(self);

            dropListener=com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER,dropListener);

            setClosingApprovalNeeded(self.App,true);

            hideViewTab(self.App);

        end


        function wireUpQuickAccessBar(self)

            undoAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Undo',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',undoAction,false);
            self.UndoListener=addlistener(undoAction.getCallback,'delayed',@(~,~)notify(self,'UndoRequested'));

            redoAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Redo',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',redoAction,false);
            self.RedoListener=addlistener(redoAction.getCallback,'delayed',@(~,~)notify(self,'RedoRequested'));

            helpAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Help',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',helpAction,true);
            self.HelpListener=addlistener(helpAction.getCallback,'delayed',@(~,~)notify(self,'HelpRequested'));

            saveAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Save',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',saveAction,false);
            self.SaveListener=addlistener(saveAction.getCallback,'delayed',@(~,~)notify(self,'SaveRequested'));

            cutAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Cut',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',cutAction,false);
            self.CutListener=addlistener(cutAction.getCallback,'delayed',@(~,~)notify(self,'CutRequested'));

            copyAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Copy',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',copyAction,false);
            self.CopyListener=addlistener(copyAction.getCallback,'delayed',@(~,~)notify(self,'CopyRequested'));

            pasteAction=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Paste',javax.swing.ImageIcon);
            javaMethodEDT('setEnabled',pasteAction,false);
            self.PasteListener=addlistener(pasteAction.getCallback,'delayed',@(~,~)notify(self,'PasteRequested'));


            ctm=com.mathworks.toolstrip.factory.ContextTargetingManager;
            ctm.setToolName(undoAction,'undo');
            ctm.setToolName(redoAction,'redo');
            ctm.setToolName(helpAction,'help');
            ctm.setToolName(saveAction,'save');
            ctm.setToolName(cutAction,'cut');
            ctm.setToolName(copyAction,'copy');
            ctm.setToolName(pasteAction,'paste');


            ja=javaArray('javax.swing.Action',1);
            ja(1)=undoAction;
            ja(2)=redoAction;
            ja(3)=helpAction;
            ja(4)=saveAction;
            ja(5)=cutAction;
            ja(6)=copyAction;
            ja(7)=pasteAction;

            c=self.App.Peer.getWrappedComponent;
            c.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS,ja);

            self.UndoButton=undoAction;
            self.RedoButton=redoAction;
            self.HelpButton=helpAction;
            self.SaveButton=saveAction;
            self.CutButton=cutAction;
            self.CopyButton=copyAction;
            self.PasteButton=pasteAction;

        end


        function removeFromLayout(~,~)














        end


        function idx=getFigureOrder(self)







            if~isempty(self.LayoutFileName)&&exist(self.LayoutFileName,'file')

                try
                    layout=getLayoutFromFile(self,self.LayoutFileName);
                    xmlReader=images.internal.app.segmenter.volume.display.XML(serializeLayout(self,layout));

                    idx=getOccupantOrder(xmlReader);
                catch
                    idx={'Labels','Slice','3-D Display'};
                end

            else
                idx={'Labels','Slice','3-D Display'};
            end

        end


        function createProgressBar(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            frame=md.getFrameContainingGroup(self.App.Name);
            sb=javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
            javaMethodEDT('setSharedStatusBar',frame,sb)
            self.ProgressBar=javaObjectEDT('javax.swing.JLabel','');
            self.ProgressBar.setName('progressLabel');
            self.ProgressBar.setVisible(false);
            sb.add(self.ProgressBar);

        end


        function str=getTitleBar(self)
            str=self.App.Title;
        end


        function setTitleBar(self,str)
            self.App.Title=str;
        end

    end


end