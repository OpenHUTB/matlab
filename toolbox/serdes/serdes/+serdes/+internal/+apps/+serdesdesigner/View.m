classdef View<handle




    properties
PlotsDoc_Blank
PlotsDoc_PulseRes
PlotsDoc_StatEye
PlotsDoc_PrbsWaveform
PlotsDoc_Contours
PlotsDoc_Bathtub
PlotsDoc_COM
PlotsDoc_Report
PlotsDoc_BER
PlotsDoc_ImpulseRes
PlotsDoc_CTLE

PlotsFig_Blank
PlotsFig_PulseRes
PlotsFig_StatEye
PlotsFig_PrbsWaveform
PlotsFig_Contours
PlotsFig_Bathtub
PlotsFig_COM
PlotsFig_Report
PlotsFig_BER
PlotsFig_ImpulseRes
PlotsFig_CTLE
PlotsFigLayout_CTLE

PlotsDoc_All_NonBlank
PlotsFig_All_NonBlank
PlotsGroup

Plot_PulseRes
Plot_StatEye
Plot_PrbsWaveform
Plot_Contours
Plot_Bathtub
Plot_COM
Plot_Report
        Plot_Report_RowCount=0;
        Plot_Report_ColumnCount=0;
Plot_BER
Plot_BERContour
Plot_ImpulseRes

PlotAxes_PulseRes
PlotAxes_StatEye
PlotAxes_PrbsWaveform
PlotAxes_Contours
PlotAxes_Bathtub
PlotAxes_COM
PlotAxes_Report
PlotAxes_BER
PlotAxes_BERContour
PlotAxes_ImpulseRes

Toolstrip
CanvasDoc
CanvasFig
CanvasFigLayout
ParametersDoc
ParametersFig

        ChannelFlag=3;
ParametersFigLayout
    end

    properties(Hidden)
Parameters
Canvas
Listeners

AllFigures
PlotsDoc_All
PlotsFig_All
NonPlotFigures

SerdesDesignerTool
ClientActionListener

        ClosingAppContainer=false;
        BusyClickingBlock=false;
        BusyClickingCanvas=false;
        BusyClickingKeyBoard=false;
    end

    properties(Constant,Hidden)
        PPSS=get(0,'ScreenSize');
        DPSS=ismac*serdes.internal.apps.serdesdesigner.View.PPSS+...
        ~ismac*matlab.ui.internal.PositionUtils.getDevicePixelScreenSize;
        PixelRatio=...
        serdes.internal.apps.serdesdesigner.View.DPSS(4)/serdes.internal.apps.serdesdesigner.View.PPSS(4);
        AppSize=[1100,1000]*serdes.internal.apps.serdesdesigner.View.PixelRatio;
    end

    methods

        function obj=View(name,serdesDesign)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            obj.Toolstrip=serdes.internal.apps.serdesdesigner.Toolstrip();


            group=FigureDocumentGroup();
            group.Title="Canvas";
            group.Tag="canvas";
            obj.Toolstrip.appContainer.add(group);

            documentOptions.Title=getString(message('serdes:serdesdesigner:SerdesSystemText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="CanvasFig";
            obj.CanvasDoc=FigureDocument(documentOptions);
            obj.CanvasDoc.Closable=false;
            obj.Toolstrip.appContainer.add(obj.CanvasDoc);
            obj.CanvasFig=obj.CanvasDoc.Figure;
            obj.CanvasFig.AutoResizeChildren='off';



            obj.CanvasFigLayout=uigridlayout(obj.CanvasFig,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'Scrollable','off');


            group=FigureDocumentGroup();
            group.Title="Parameters";
            group.Tag="parameters";
            obj.Toolstrip.appContainer.add(group);

            documentOptions.Title=getString(message('serdes:serdesdesigner:BlockParametersText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="ParametersFig";
            obj.ParametersDoc=FigureDocument(documentOptions);
            obj.ParametersDoc.Closable=false;
            obj.Toolstrip.appContainer.add(obj.ParametersDoc);
            obj.ParametersFig=obj.ParametersDoc.Figure;
            obj.ParametersFig.AutoResizeChildren='off';
            obj.ParametersFigLayout=uigridlayout(obj.ParametersFig,'RowHeight',{'1x'},'ColumnWidth',{'1x'},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');


            group=FigureDocumentGroup();
            group.Title="Plots";
            group.Tag="plots";
            obj.Toolstrip.appContainer.add(group);
            obj.PlotsGroup=group;

            documentOptions.Title=getString(message('serdes:serdesdesigner:PlotsText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_Blank";
            obj.PlotsDoc_Blank=FigureDocument(documentOptions);
            obj.PlotsDoc_Blank.Closable=false;
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_Blank);
            obj.PlotsFig_Blank=obj.PlotsDoc_Blank.Figure;

            documentOptions.Title=getString(message('serdes:serdesdesigner:PulseResponseText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_PulseRes";
            obj.PlotsDoc_PulseRes=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_PulseRes);
            obj.PlotsDoc_PulseRes.Phantom=true;
            obj.PlotsFig_PulseRes=obj.PlotsDoc_PulseRes.Figure;
            obj.PlotsFig_PulseRes.AutoResizeChildren='on';
            set(obj.PlotsDoc_PulseRes,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_PulseRes));

            documentOptions.Title=getString(message('serdes:serdesdesigner:StatEyeText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_StatEye";
            obj.PlotsDoc_StatEye=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_StatEye);
            obj.PlotsDoc_StatEye.Phantom=true;
            obj.PlotsFig_StatEye=obj.PlotsDoc_StatEye.Figure;
            obj.PlotsFig_StatEye.AutoResizeChildren='on';
            set(obj.PlotsDoc_StatEye,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_StatEye));

            documentOptions.Title=getString(message('serdes:serdesdesigner:PrbsWaveformText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_PrbsWaveform";
            obj.PlotsDoc_PrbsWaveform=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_PrbsWaveform);
            obj.PlotsDoc_PrbsWaveform.Phantom=true;
            obj.PlotsFig_PrbsWaveform=obj.PlotsDoc_PrbsWaveform.Figure;
            obj.PlotsFig_PrbsWaveform.AutoResizeChildren='on';
            set(obj.PlotsDoc_PrbsWaveform,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_PrbsWaveform));

            documentOptions.Title=getString(message('serdes:serdesdesigner:ContoursText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_Contours";
            obj.PlotsDoc_Contours=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_Contours);
            obj.PlotsDoc_Contours.Phantom=true;
            obj.PlotsFig_Contours=obj.PlotsDoc_Contours.Figure;
            obj.PlotsFig_Contours.AutoResizeChildren='on';
            set(obj.PlotsDoc_Contours,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_Contours));

            documentOptions.Title=getString(message('serdes:serdesdesigner:BathtubText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_Bathtub";
            obj.PlotsDoc_Bathtub=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_Bathtub);
            obj.PlotsDoc_Bathtub.Phantom=true;
            obj.PlotsFig_Bathtub=obj.PlotsDoc_Bathtub.Figure;
            obj.PlotsFig_Bathtub.AutoResizeChildren='on';
            set(obj.PlotsDoc_Bathtub,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_Bathtub));

            documentOptions.Title=getString(message('serdes:serdesdesigner:ComText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_COM";
            obj.PlotsDoc_COM=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_COM);
            obj.PlotsDoc_COM.Phantom=true;
            obj.PlotsFig_COM=obj.PlotsDoc_COM.Figure;
            obj.PlotsFig_COM.AutoResizeChildren='on';
            set(obj.PlotsDoc_COM,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_COM));

            documentOptions.Title=getString(message('serdes:serdesdesigner:ReportText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_Report";
            obj.PlotsDoc_Report=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_Report);
            obj.PlotsDoc_Report.Phantom=true;
            obj.PlotsFig_Report=obj.PlotsDoc_Report.Figure;

            set(obj.PlotsDoc_Report,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_Report));

            documentOptions.Title=getString(message('serdes:serdesdesigner:BerText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_BER";
            obj.PlotsDoc_BER=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_BER);
            obj.PlotsDoc_BER.Phantom=true;
            obj.PlotsFig_BER=obj.PlotsDoc_BER.Figure;
            obj.PlotsFig_BER.AutoResizeChildren='on';
            set(obj.PlotsDoc_BER,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_BER));

            documentOptions.Title=getString(message('serdes:serdesdesigner:ImpulseResponseText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_ImpulseRes";
            obj.PlotsDoc_ImpulseRes=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_ImpulseRes);
            obj.PlotsDoc_ImpulseRes.Phantom=true;
            obj.PlotsFig_ImpulseRes=obj.PlotsDoc_ImpulseRes.Figure;
            obj.PlotsFig_ImpulseRes.AutoResizeChildren='on';
            set(obj.PlotsDoc_ImpulseRes,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_ImpulseRes));

            documentOptions.Title=getString(message('serdes:serdesdesigner:CTLEText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="PlotsFig_CTLE_Transfer_Function";
            obj.PlotsDoc_CTLE=FigureDocument(documentOptions);
            obj.Toolstrip.appContainer.add(obj.PlotsDoc_CTLE);
            obj.PlotsDoc_CTLE.Phantom=true;
            obj.PlotsFig_CTLE=obj.PlotsDoc_CTLE.Figure;
            obj.PlotsFig_CTLE.AutoResizeChildren='off';
            set(obj.PlotsDoc_CTLE,'CanCloseFcn',@(h,e)plotCloseRequestFcn(obj,obj.PlotsFig_CTLE));


            obj.PlotsDoc_All=[...
            obj.PlotsDoc_Blank,...
            obj.PlotsDoc_PulseRes,...
            obj.PlotsDoc_StatEye,...
            obj.PlotsDoc_PrbsWaveform,...
            obj.PlotsDoc_Contours,...
            obj.PlotsDoc_Bathtub,...
            obj.PlotsDoc_COM,...
            obj.PlotsDoc_Report,...
            obj.PlotsDoc_BER,...
            obj.PlotsDoc_ImpulseRes,...
            obj.PlotsDoc_CTLE];


            obj.PlotsDoc_All_NonBlank=[...
            obj.PlotsDoc_PulseRes,...
            obj.PlotsDoc_StatEye,...
            obj.PlotsDoc_PrbsWaveform,...
            obj.PlotsDoc_Contours,...
            obj.PlotsDoc_Bathtub,...
            obj.PlotsDoc_COM,...
            obj.PlotsDoc_Report,...
            obj.PlotsDoc_BER,...
            obj.PlotsDoc_ImpulseRes,...
            obj.PlotsDoc_CTLE];


            obj.PlotsFig_All=[...
            obj.PlotsFig_Blank,...
            obj.PlotsFig_PulseRes,...
            obj.PlotsFig_StatEye,...
            obj.PlotsFig_PrbsWaveform,...
            obj.PlotsFig_Contours,...
            obj.PlotsFig_Bathtub,...
            obj.PlotsFig_COM,...
            obj.PlotsFig_Report,...
            obj.PlotsFig_BER,...
            obj.PlotsFig_ImpulseRes,...
            obj.PlotsFig_CTLE];


            obj.PlotsFig_All_NonBlank=[...
            obj.PlotsFig_PulseRes,...
            obj.PlotsFig_StatEye,...
            obj.PlotsFig_PrbsWaveform,...
            obj.PlotsFig_Contours,...
            obj.PlotsFig_Bathtub,...
            obj.PlotsFig_COM,...
            obj.PlotsFig_Report,...
            obj.PlotsFig_BER,...
            obj.PlotsFig_ImpulseRes,...
            obj.PlotsFig_CTLE];


            obj.NonPlotFigures=[...
            obj.CanvasFig,...
            obj.ParametersFig,...
            obj.PlotsFig_Blank];


            obj.AllFigures=[...
            obj.CanvasFig,...
            obj.ParametersFig,...
            obj.PlotsFig_Blank,...
            obj.PlotsFig_PulseRes,...
            obj.PlotsFig_StatEye,...
            obj.PlotsFig_PrbsWaveform,...
            obj.PlotsFig_Contours,...
            obj.PlotsFig_Bathtub,...
            obj.PlotsFig_COM,...
            obj.PlotsFig_Report,...
            obj.PlotsFig_BER,...
            obj.PlotsFig_ImpulseRes,...
            obj.PlotsFig_CTLE];





            obj.Parameters=serdes.internal.apps.serdesdesigner.Parameters(obj);
            obj.Canvas=serdes.internal.apps.serdesdesigner.Canvas(obj);












            s=settings;
            screensize=get(0,'MonitorPositions');
            if~isempty(s)&&~isempty(screensize)&&...
                isprop(s,'serdes')&&...
                isprop(s.serdes,'SerDesDesigner')&&...
                isprop(s.serdes.SerDesDesigner,'X')&&...
                isprop(s.serdes.SerDesDesigner,'Y')&&...
                isprop(s.serdes.SerDesDesigner,'Width')&&...
                isprop(s.serdes.SerDesDesigner,'Height')


                X=s.serdes.SerDesDesigner.X.ActiveValue;
                Y=s.serdes.SerDesDesigner.Y.ActiveValue;
                Width=s.serdes.SerDesDesigner.Width.ActiveValue;
                Height=s.serdes.SerDesDesigner.Height.ActiveValue;


                Xmin=screensize(1,1);
                Ymin=screensize(1,2);
                Xmax=screensize(1,3);
                Ymax=screensize(1,4);
                if numel(screensize)>4

                    for i=2:numel(screensize)/4
                        Xmax=Xmax+screensize(i,3);
                        if X<Xmax
                            Ymax=screensize(i,4);
                            break;
                        end
                    end
                end


                if X<Xmin||X>=Xmax
                    X=s.serdes.SerDesDesigner.X.FactoryValue;
                end
                if Y<Ymin||Y>=Ymax
                    Y=s.serdes.SerDesDesigner.Y.FactoryValue;
                end


                if Width<400||Width>Xmax-Xmin
                    Width=s.serdes.SerDesDesigner.Width.FactoryValue;
                end
                if Height<400||Height>Ymax-Ymin
                    Height=s.serdes.SerDesDesigner.Height.FactoryValue;
                end


                if X+Width>Xmax
                    X=Xmax-Width;
                end
                if Y+Height>Ymax
                    Y=Ymax-Height;
                end


                if~isempty(obj.Toolstrip)&&...
                    ~isempty(obj.Toolstrip.appContainer)&&...
                    isprop(obj.Toolstrip.appContainer,'WindowBounds')
                    obj.Toolstrip.appContainer.WindowBounds=[X,Y,Width,Height];
                end
            end

            if nargin<2
                name='';
                serdesDesign=serdesquicksimulation;
            end
            obj.newView(name,serdesDesign,false)


            for i=1:numel(obj.AllFigures)
                if obj.AllFigures(i)==obj.CanvasFig

                    set(obj.AllFigures(i),'WindowKeyPressFcn',@(src,event)KeyBoardShortCuts(obj,event));
                else

                    set(obj.AllFigures(i),'KeyPressFcn',@(src,event)KeyBoardShortCuts2(obj,event));
                end
            end
        end


        function KeyBoardShortCuts(obj,event)
            if isempty(obj.Canvas.SelectIdx)||obj.isBusyClickingKeyBoard()
                return;
            end
            obj.setBusyClickingKeyBoard(true);
            switch(event.Key)
            case 'delete'
                if obj.Toolstrip.DeleteBtn.Enabled
                    obj.deleteAction();
                end
            case 'leftarrow'
                if obj.Canvas.SelectIdx>1
                    obj.Canvas.selectElement(obj.Canvas.SelectIdx-1);
                end
            case 'rightarrow'
                if obj.Canvas.SelectIdx<numel(obj.Canvas.Cascade.Elements)
                    obj.Canvas.selectElement(obj.Canvas.SelectIdx+1);
                end
            case 'tab'
                if obj.Canvas.SelectIdx<numel(obj.Canvas.Cascade.Elements)
                    obj.Canvas.selectElement(obj.Canvas.SelectIdx+1);
                else
                    obj.Canvas.selectElement(1);
                end
            otherwise
                obj.KeyBoardShortCuts2(event);
            end
            obj.setBusyClickingKeyBoard(false);
        end
        function KeyBoardShortCuts2(obj,event)

            if isempty(obj.Canvas.SelectIdx)
                return;
            end
            switch(event.Key)
            case 's'
                if~isempty(event.Modifier)&&strcmpi(event.Modifier,'control')
                    obj.SerdesDesignerTool.Model.saveAction();
                end
            case 'o'
                if~isempty(event.Modifier)&&strcmpi(event.Modifier,'control')
                    obj.SerdesDesignerTool.Model.openAction();
                end
            end

        end


        function busy=isBusyClickingBlock(obj)
            busy=obj.BusyClickingBlock;
        end
        function busy=isBusyClickingCanvas(obj)
            busy=obj.BusyClickingCanvas;
        end
        function busy=isBusyClickingKeyBoard(obj)
            busy=obj.BusyClickingKeyBoard;
        end
        function setBusyClickingBlock(obj,isBusy)

            obj.setWatchCursor(isBusy);
            obj.BusyClickingBlock=isBusy;
        end
        function setBusyClickingCanvas(obj,isBusy)

            obj.setWatchCursor(isBusy);
            obj.BusyClickingCanvas=isBusy;
        end
        function setBusyClickingKeyBoard(obj,isBusy)

            obj.setWatchCursor(isBusy);
            obj.BusyClickingKeyBoard=isBusy;
        end
        function setWatchCursor(obj,isWatchCursor)

            if isWatchCursor
                pointerType='watch';
            else
                pointerType='arrow';
            end
            for i=1:length(obj.AllFigures)
                set(obj.AllFigures(i),'pointer',pointerType);
            end
            drawnow;
        end


        function result=plotCloseRequestFcn(obj,selectedFigure)


            result=obj.ClosingAppContainer;
            if result
                return;
            end
            if~isempty(selectedFigure)
                visiblePlotDocs=obj.getVisiblePlotDocs();
                if~isempty(visiblePlotDocs)&&...
                    length(visiblePlotDocs)==1&&...
                    visiblePlotDocs{1}.Figure==selectedFigure
                    obj.PlotsDoc_Blank.Phantom=false;
                end
                serdesDesign=obj.SerdesDesignerTool.Model.SerdesDesign;
                switch selectedFigure
                case obj.PlotsFig_PulseRes
                    obj.PlotsDoc_PulseRes.Phantom=true;
                    serdesDesign.PlotVisible_PulseRes=false;
                case obj.PlotsFig_ImpulseRes
                    obj.PlotsDoc_ImpulseRes.Phantom=true;
                    serdesDesign.PlotVisible_ImpulseRes=false;
                case obj.PlotsFig_StatEye
                    obj.PlotsDoc_StatEye.Phantom=true;
                    serdesDesign.PlotVisible_StatEye=false;
                case obj.PlotsFig_PrbsWaveform
                    obj.PlotsDoc_PrbsWaveform.Phantom=true;
                    serdesDesign.PlotVisible_PrbsWaveform=false;
                case obj.PlotsFig_Contours
                    obj.PlotsDoc_Contours.Phantom=true;
                    serdesDesign.PlotVisible_Contours=false;
                case obj.PlotsFig_Bathtub
                    obj.PlotsDoc_Bathtub.Phantom=true;
                    serdesDesign.PlotVisible_Bathtub=false;
                case obj.PlotsFig_COM
                    obj.PlotsDoc_COM.Phantom=true;
                    serdesDesign.PlotVisible_COM=false;
                case obj.PlotsFig_Report
                    obj.PlotsDoc_Report.Phantom=true;
                    serdesDesign.PlotVisible_Report=false;
                case obj.PlotsFig_BER
                    obj.PlotsDoc_BER.Phantom=true;
                    serdesDesign.PlotVisible_BER=false;
                case obj.PlotsFig_CTLE
                    obj.PlotsDoc_CTLE.Phantom=true;
                    serdesDesign.PlotVisible_CTLE=false;
                end
            end
            obj.enableDisableAutoUpdateButtonAndCheckbox();
            result=true;
        end
        function enableDisableAutoUpdateButtonAndCheckbox(obj)


            drawnow;
            if~obj.PlotsDoc_Blank.Phantom
                obj.Toolstrip.AutoUpdateBtn.Enabled=false;
                obj.Toolstrip.AutoUpdateCheckbox.Enabled=false;
                obj.Toolstrip.AutoUpdateRadioBtn.Enabled=false;
                obj.Toolstrip.ManualUpdateRadioBtn.Enabled=false;
            else
                obj.Toolstrip.AutoUpdateBtn.Enabled=~obj.Toolstrip.isAutoUpdate();
                obj.Toolstrip.AutoUpdateCheckbox.Enabled=true;
                obj.Toolstrip.AutoUpdateRadioBtn.Enabled=true;
                obj.Toolstrip.ManualUpdateRadioBtn.Enabled=true;
            end
        end
        function isAnyPlotsFigVisible=isAnyPlotVisible(obj)

            isAnyPlotsFigVisible=false;
            try
                for i=1:numel(obj.PlotsFig_All_NonBlank)
                    if~obj.PlotsDoc_All_NonBlank(i).Phantom
                        isAnyPlotsFigVisible=true;
                        return;
                    end
                end
            catch

                return;
            end
        end
        function visiblePlotDocs=getVisiblePlotDocs(obj)

            visiblePlotDocs={};
            try
                count=0;
                for i=1:numel(obj.PlotsDoc_All_NonBlank)
                    if~obj.PlotsDoc_All_NonBlank(i).Phantom
                        count=count+1;
                        visiblePlotDocs{count}=obj.PlotsDoc_All_NonBlank(i);%#ok<AGROW>
                    end
                end
            catch

            end
        end
        function selectedPlotDoc=getSelectedPlotDoc(obj)

            try
                lastSelectedPlot=obj.PlotsGroup.LastSelected;
                if~isempty(lastSelectedPlot)
                    tag=lastSelectedPlot.tag;
                end
                for i=1:numel(obj.PlotsDoc_All_NonBlank)
                    if strcmp(obj.PlotsDoc_All_NonBlank(i).Tag,tag)
                        selectedPlotDoc=obj.PlotsDoc_All_NonBlank(i);
                        return;
                    end
                end
            catch

            end
            selectedPlotDoc=[];
        end
        function togglePlotsDocSelection(obj)

            selectedPlotDoc=obj.getSelectedPlotDoc();
            for i=1:length(obj.PlotsDoc_All_NonBlank)
                obj.PlotsDoc_All_NonBlank(i).Selected=true;
                drawnow;
                obj.PlotsDoc_All_NonBlank(i).Selected=false;
                drawnow;
            end
            selectedPlotDoc.Selected=true;
            drawnow;
        end
        function isPlotsFig=isPlot(obj,fig)

            isPlotsFig=false;
            for i=1:numel(obj.PlotsFig_All_NonBlank)
                if fig==obj.PlotsFig_All_NonBlank(i)
                    isPlotsFig=true;
                    return;
                end
            end
        end

        function enableInsertionActions(obj,enabled)
            obj.Toolstrip.AgcBtn.Enabled=enabled;
            obj.Toolstrip.FfeBtn.Enabled=enabled;
            obj.Toolstrip.VgaBtn.Enabled=enabled;
            obj.Toolstrip.SatAmpBtn.Enabled=enabled;
            obj.Toolstrip.DfeCdrBtn.Enabled=enabled;
            obj.Toolstrip.CdrBtn.Enabled=enabled;
            obj.Toolstrip.CtleBtn.Enabled=enabled;
            obj.Toolstrip.TransparentBtn.Enabled=enabled;
        end
    end

    methods(Hidden)
        function newName(obj,name)


            obj.CanvasFig.Name=getString(message('serdes:serdesdesigner:SerdesSystemText'));
        end

        function newSerdesDesign(obj,serdesDesign)

            obj.Toolstrip.BERtargetEdit.Value=getEngineeringNotationString(serdesDesign.BERtarget);
            obj.Toolstrip.SymbolTimeEdit.Value=getEngineeringNotationString(serdesDesign.SymbolTime*1e12);
            obj.Toolstrip.SamplesPerSymbolDropdown.Value=num2str(serdesDesign.SamplesPerSymbol);
            obj.Toolstrip.ModulationDropdown.Value=serdesDesign.Modulation;
            obj.Toolstrip.SignalingDropdown.Value=serdesDesign.Signaling;


            deleteAllElements(obj.Canvas)
            insertAllElements(obj.Canvas,serdesDesign)
        end

        function updateCascadeText(obj,serdesDesign)
            len=numel(serdesDesign.Elements);

            for i=1:len
                ev=obj.Canvas.Cascade.Elements(i);
                ev.StageText.ID.String=sprintf('%d',i);
                ev.Picture.Name.Text=serdesDesign.Elements{i}.Name;

            end
        end

        function newView(obj,name,serdesDesign,enable)
            obj.newName(name);
            obj.enableActions(false);

            obj.newSerdesDesign(serdesDesign);
            obj.updateCascadeText(serdesDesign);

            obj.enableActions(true,(numel(serdesDesign.Elements)>0));
        end
    end

    methods(Hidden)
        function defaultLayoutAction(obj,~)
            try

                obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyDefaultLayout')));


                lastSelectedPlotDoc=obj.getSelectedPlotDoc();


                obj.Toolstrip.setInitialLayout();


                obj.PlotsDoc_Blank.Phantom=isAnyPlotVisible(obj);


                obj.togglePlotsDocSelection();


                drawnow;
                currentSelectedPlotDoc=obj.getSelectedPlotDoc();
                if~isempty(currentSelectedPlotDoc)
                    currentSelectedPlotDoc.Selected=false;
                end
                if~isempty(lastSelectedPlotDoc)
                    lastSelectedPlotDoc.Selected=true;
                else
                    obj.PlotsDoc_Blank.Selected=true;
                end

                obj.enableDisableAutoUpdateButtonAndCheckbox();
            catch ex

                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end

            obj.SerdesDesignerTool.setStatus('');
        end

        function addAction(obj,type)
            figure(obj.CanvasFig);
            drawnow;
            index=obj.Canvas.InsertIdx;
            obj.notify('InsertionRequested',...
            serdes.internal.apps.serdesdesigner.AddOrDeleteRequestedEventData(index,type))
            figure(obj.CanvasFig);
        end

        function deleteAction(obj)
            index=obj.Canvas.SelectIdx;
            obj.notify('DeletionRequested',...
            serdes.internal.apps.serdesdesigner.AddOrDeleteRequestedEventData(index))
            figure(obj.CanvasFig);
        end

        function enableActions(obj,val,nonemptyVal)

            if nargin<3
                nonemptyVal=val;
            end

            debug_hack=true;
            if debug_hack
                val=true;
                nonemptyVal=true;
            end

            obj.Listeners.WindowMousePress.Enabled=val;
            obj.Listeners.WindowMouseMotion.Enabled=val;
            obj.Listeners.WindowMouseRelease.Enabled=val;
            obj.Listeners.SizeChanged.Enabled=val;

            obj.Toolstrip.NewBtn.Enabled=val;
            obj.Toolstrip.OpenBtn.Enabled=val;
            obj.Toolstrip.SaveBtn.Enabled=nonemptyVal;


            obj.Toolstrip.BERtargetEdit.Enabled=nonemptyVal;
            obj.Toolstrip.BERtargetLabel.Enabled=nonemptyVal;
            obj.Toolstrip.SymbolTimeEdit.Enabled=nonemptyVal;
            obj.Toolstrip.SymbolTimeLabel.Enabled=nonemptyVal;
            obj.Toolstrip.SamplesPerSymbolDropdown.Enabled=nonemptyVal;
            obj.Toolstrip.SamplesPerSymbolLabel.Enabled=nonemptyVal;
            obj.Toolstrip.ModulationDropdown.Enabled=nonemptyVal;
            obj.Toolstrip.ModulationLabel.Enabled=nonemptyVal;
            obj.Toolstrip.SignalingDropdown.Enabled=nonemptyVal;
            obj.Toolstrip.SignalingLabel.Enabled=nonemptyVal;















            obj.Toolstrip.JitterBtn.Enabled=nonemptyVal;


            obj.Toolstrip.DefaultLayoutBtn.Enabled=nonemptyVal;
            obj.Toolstrip.PlotBtn.Enabled=nonemptyVal;
            obj.Toolstrip.AutoUpdateBtn.Enabled=~obj.Toolstrip.isAutoUpdate();
            obj.Toolstrip.AutoUpdateCheckbox.Enabled=nonemptyVal;
            obj.Toolstrip.AutoUpdateRadioBtn.Enabled=nonemptyVal;
            obj.Toolstrip.ManualUpdateRadioBtn.Enabled=nonemptyVal;
            obj.Toolstrip.ExportBtn.Enabled=nonemptyVal;
            enableInsertionActions(obj,nonemptyVal);
        end
    end

    methods(Hidden)








        function elementParameterInvalid(obj,data)
            elementParameterInvalid(obj.Parameters,data);
        end

        function parameterChanged(obj,data)
            obj.updateCascadeText(data.SerdesDesign);
        end

        function elementInserted(obj,data)
            obj.enableActions(false);
            insertElement(obj.Canvas,data.SerdesDesign,data.Index);
            obj.updateCascadeText(data.SerdesDesign);
            obj.enableActions(true);
        end

        function elementDeleted(obj,data)
            obj.enableActions(false);
            deleteElement(obj.Canvas,data.SerdesDesign,data.Index);
            obj.updateCascadeText(data.SerdesDesign);
            obj.enableActions(true,(numel(data.SerdesDesign.Elements)>0));
        end

        function selectedElement(obj,data)
            ev=obj.Canvas.Cascade.Elements(data.Index);
            selectElement(ev,data.Element);
        end
    end

    events(Hidden)
InsertionRequested
DeletionRequested
    end
end



function shrinkNameAsNeeded(u,targetWidth)







    fullname=u.String;
    Nchars=numel(fullname);
    if Nchars<2||u.Extent(3)<targetWidth
        return
    end






    str=[fullname(1:end-2),'...'];
    u.String=str;
    if u.Extent(3)<targetWidth
        u.String=fullname;
        return
    end



    Nchars=Nchars-1;



    while 1
        Nchars=Nchars-1;
        str(Nchars)='';
        u.String=str;

        if Nchars==2||u.Extent(3)<targetWidth


            break
        end
    end
end


function strNum=getEngineeringNotationString(number)
    strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(number);
end
