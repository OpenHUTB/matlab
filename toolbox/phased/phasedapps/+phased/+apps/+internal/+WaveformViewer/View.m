classdef View<handle



    properties(Hidden)
Toolstrip
ParametersFig
Parameters
Layout
Library
Characteristics
Canvas
GraphType
RealAndImaginary
RealAndImaginaryFig
MagnitudeAndPhase
MagnitudeAndPhaseFig
Spectrum
SpectrumFig
PSpectrumFig
PSpectrum
Spectrogram
SpectrogramFig
AmbiguityFunctionContour
AmbiguityFunctionContourFig
AmbiguityFunctionSurface
AmbiguityFunctionSurfaceFig
AmbiguityFunctionDelayCut
AmbiguityFunctionDelayCutFig
AmbiguityFunctionDopplerCut
AmbiguityFunctionDopplerCutFig
AutoCorrelation
AutoCorrelationFig
MatchedFilterCoefficientsFig
MatchedFilterCoefficients
StretchProcessorFig
StretchProcessor
ListPanel
SampleRatePanel
SampleRateLabel
SampleRateEdit

FigureGroup
RealAndImaginaryDoc
ParametersDoc
SpectrumDoc
CharacteristicsDoc
MagnitudeAndPhaseDoc
SpectrogramDoc
PSpectrumDoc
MatchedFilterCoefficientsDoc
StretchProcessorDoc
AmbiguityFunctionSurfaceDoc
AmbiguityFunctionContourDoc
AmbiguityFunctionDelayCutDoc
AmbiguityFunctionDopplerCutDoc
AutoCorrelationDoc

AppHandle
    end

    methods
        function self=View(apphandle,isAppContainer)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            self.AppHandle=apphandle;

            self.Toolstrip=phased.apps.internal.WaveformViewer.Toolstrip(apphandle,isAppContainer);
            if~self.Toolstrip.IsAppContainer
                group=self.Toolstrip.ToolGroup.Peer.getWrappedComponent;

                group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE,false);

                group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE,false);

                self.Library=figure(...
                'Name',getString(message('phased:apps:waveformapp:Library')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'Tag','LibraryFig',...
                'HandleVisibility','off',...
                'Units','pixels',...
                'Visible','on',...
                'DeleteFcn',@(h,e)deleteFigure(self));

                self.Toolstrip.ToolGroup.addFigure(self.Library);

                self.RealAndImaginaryFig=figure(...
                'Name',getString(message('phased:apps:waveformapp:RealandImaginary')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','RealandImaginary',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none');

                self.Toolstrip.ToolGroup.addFigure(self.RealAndImaginaryFig);

                self.ParametersFig=figure(...
                'Name',getString(message('phased:apps:waveformapp:Parameters')),...
                'Tag','ParametersFig',...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Units','pixels',...
                'Visible','on',...
                'DeleteFcn',@(h,e)deleteFigure(self));
                self.Toolstrip.ToolGroup.addFigure(self.ParametersFig);

                self.Characteristics=figure(...
                'Name',getString(message('phased:apps:waveformapp:Characteristics')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','CharacteristicsFig',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none');

                self.Toolstrip.ToolGroup.addFigure(self.Characteristics);


                self.ListPanel=uipanel('Parent',self.Library,...
                'Title','',...
                'BorderType','none',...
                'HighlightColor',[.5,.5,.5],...
                'Visible','on');
                self.positionFigures();
                self.disableCloseGestureOnDockedFeatures();

                self.Canvas=phased.apps.internal.WaveformViewer.Canvas(self);

                if~self.Toolstrip.IsAppContainer
                    self.SampleRatePanel=uipanel('Parent',self.ParametersFig,...
                    'Title','',...
                    'BorderType','line',...
                    'HighlightColor',[.5,.5,.5],...
                    'Visible','on');
                else
                    self.SampleRatePanel=uipanel('Parent',self.ParametersFig,...
                    'Title','',...
                    'BorderType','line',...
                    'AutoResizeChildren','off',...
                    'Visible','on');
                end
                self.SampleRateLabel=uicontrol(...
                'Parent',self.SampleRatePanel,...
                'Style','text',...
                'FontSize',8,...
                'Position',[20,10,108,20],...
                'String',getString(message('phased:apps:waveformapp:SampleRateLabel','Sample Rate')),...
                'HorizontalAlignment','right');
                self.SampleRateEdit=uicontrol(...
                'Parent',self.SampleRatePanel,...
                'Style','edit',...
                'String','1000000',...
                'Position',[130,10,130,20],...
                'Tag','SampleRate',...
                'HorizontalAlignment','left');

                self.Parameters=phased.apps.internal.WaveformViewer.Parameters(self);

                hspacing=3;
                vspacing=4;

                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Library,...
                'VerticalGap',vspacing,...
                'HorizontalGap',hspacing,...
                'VerticalWeights',1,...
                'HorizontalWeights',1);

                add(self.Layout,self.ListPanel,1,1,...
                'Fill','Both')

                self.Canvas.AutoSelect=false;
                self.Canvas.WaveformList.Data={'Waveform',getString(message('phased:apps:waveformapp:Rectangular')),getString(message('phased:apps:waveformapp:MatchedFilter'))};
                self.Canvas.WaveformList.updateUI();
                self.Canvas.SelectIdx=1;
                self.Canvas.InsertIdx=2;
                self.Canvas.RectNum=1;
                self.Canvas.AutoSelect=true;

                self.RealAndImaginary=phased.apps.internal.WaveformViewer.RealAndImaginary(self);
                controllib.plot.internal.FloatingPalette(self.RealAndImaginaryFig,{'ZoomIn';'ZoomOut';'Pan'});
                figure(self.RealAndImaginaryFig);

                self.SpectrumFig=figure(...
                'Name',getString(message('phased:apps:waveformapp:Spectrum')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','Spectrum',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none');
                self.Toolstrip.ToolGroup.addFigure(self.SpectrumFig);
                self.Spectrum=phased.apps.internal.WaveformViewer.Spectrum(self);
                controllib.plot.internal.FloatingPalette(self.SpectrumFig,{'ZoomIn';'ZoomOut';'Pan'});
            else
                self.FigureGroup=matlab.ui.internal.FigureDocumentGroup('Tag','FiguresGroup');

                self.Toolstrip.AppContainer.add(self.FigureGroup);

                realandimagFigOptions.Title=getString(message('phased:apps:waveformapp:RealandImaginary'));
                realandimagFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                realandimagFigOptions.Tag='RealandImaginary';

                document=FigureDocument(realandimagFigOptions);
                document.Closable=false;
                self.RealAndImaginaryFig=document.Figure;
                self.RealAndImaginaryFig.Internal=false;
                self.RealAndImaginaryDoc=document;

                set(self.RealAndImaginaryFig,...
                'Name',getString(message('phased:apps:waveformapp:RealandImaginary')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','RealandImaginary',...
                'Units','pixels',...
                'Visible','on',...
                'AutoResizeChildren','off',...
                'Menubar','none');

                self.Toolstrip.AppContainer.add(self.RealAndImaginaryDoc);

                spectrumFigOptions.Title=getString(message('phased:apps:waveformapp:Spectrum'));
                spectrumFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                spectrumFigOptions.Tag='Spectrum';

                document=FigureDocument(spectrumFigOptions);

                self.SpectrumFig=document.Figure;
                self.SpectrumFig.Internal=false;
                self.SpectrumDoc=document;

                set(self.SpectrumFig,...
                'Name',getString(message('phased:apps:waveformapp:Spectrum')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','Spectrum',...
                'Units','pixels',...
                'Visible','on',...
                'AutoResizeChildren','off',...
                'Menubar','none');

                self.Toolstrip.AppContainer.add(self.SpectrumDoc);

                paramFigOptions.Title=getString(message('phased:apps:waveformapp:Parameters'));
                paramFigOptions.Tag='paramsfig';
                paramFigOptions.Region='right';

                self.ParametersDoc=FigurePanel(paramFigOptions);
                self.Toolstrip.AppContainer.add(self.ParametersDoc);
                self.ParametersFig=self.ParametersDoc.Figure;
                set(self.ParametersFig,...
                'Name',getString(message('phased:apps:waveformapp:Parameters')),...
                'Tag','ParametersFig',...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Units','pixels',...
                'Visible','on',...
                'AutoResizeChildren','off',...
                'DeleteFcn',@(h,e)deleteFigure(self));

                characteristicfigOptions.Title=getString(message('phased:apps:waveformapp:Characteristics'));
                characteristicfigOptions.Tag='characteristicsfig';
                characteristicfigOptions.Region='bottom';

                self.CharacteristicsDoc=FigurePanel(characteristicfigOptions);
                self.Toolstrip.AppContainer.add(self.CharacteristicsDoc);
                self.Characteristics=self.CharacteristicsDoc.Figure;
                set(self.Characteristics,...
                'Name',getString(message('phased:apps:waveformapp:Characteristics')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'AutoResizeChildren','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Tag','CharacteristicsFig',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none');

                self.Canvas=phased.apps.internal.WaveformViewer.Canvas(self);

                self.Layout=uigridlayout(self.ParametersFig);
                self.Layout.ColumnWidth={'1x'};
                self.Layout.RowHeight={50,'2x','1x','1x'};
                self.Layout.ColumnSpacing=0;
                self.Layout.RowSpacing=0;
                self.Layout.Padding=[0,0,0,0];
                self.Layout.Scrollable='on';


                if~isAppContainer
                    self.SampleRatePanel=uipanel('Parent',self.ParametersFig,...
                    'Title','',...
                    'BorderType','line',...
                    'HighlightColor',[.5,.5,.5],...
                    'AutoResizeChildren','off',...
                    'Visible','on');
                else
                    self.SampleRatePanel=uipanel('Parent',self.ParametersFig,...
                    'Title','',...
                    'BorderType','line',...
                    'AutoResizeChildren','off',...
                    'Visible','on');
                end
                self.SampleRateLabel=uicontrol(...
                'Parent',self.SampleRatePanel,...
                'Style','text',...
                'FontSize',8,...
                'Position',[20,10,108,20],...
                'String',getString(message('phased:apps:waveformapp:SampleRateLabel','Sample Rate')),...
                'HorizontalAlignment','right');
                self.SampleRateEdit=uicontrol(...
                'Parent',self.SampleRatePanel,...
                'Style','edit',...
                'String','1000000',...
                'Position',[130,10,130,20],...
                'Tag','SampleRate',...
                'HorizontalAlignment','left');

                self.Parameters=phased.apps.internal.WaveformViewer.Parameters(self);

                self.Canvas.AutoSelect=false;
                data={'Waveform',getString(message('phased:apps:waveformapp:Rectangular')),'MatchedFilter'};

                self.Canvas.WaveformList.Data=data;
                self.Canvas.SelectIdx=1;
                self.Canvas.WaveformList.updateUI();
                self.Canvas.InsertIdx=2;
                self.Canvas.RectNum=1;
                self.Canvas.AutoSelect=true;

                self.RealAndImaginary=phased.apps.internal.WaveformViewer.RealAndImaginary(self);

                self.Spectrum=phased.apps.internal.WaveformViewer.Spectrum(self);
            end
        end

        function duplicateAction(self)

            idx=self.Canvas.WaveformList.getSelectedRows();
            k=numel(idx);
            for i=1:k
                self.Canvas.SelectIdx=idx(i);
                waveformName=self.Canvas.WaveformList.Data{self.Canvas.SelectIdx};
                waveformName=strcat(waveformName,'Copy');
                index=self.Canvas.InsertIdx;
                selectIndex=self.Canvas.SelectIdx;
                if~strcmp(self.Parameters.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:FMCW')))&&self.Parameters.PRFPRIIndex(selectIndex)==2
                    self.Parameters.PRFPRIIndex(index)=2;
                end
                self.notify('DuplicateInsertionRequested',phased.apps.internal.WaveformViewer.AddOrDeleteRequestedEventData(index,selectIndex));
            end
            titleUpdate(self);
            setAppStatus(self,true);
            self.characteristicsAction();
            setAppStatus(self,false);
            self.addplotAction();
        end

        function positionFigures(self)
            if self.Toolstrip.IsAppContainer
                layoutJSON=jsondecode(fileread(fullfile(matlabroot,'toolbox','phased','phasedapps',...
                '+phased','+apps','+internal','+WaveformViewer','defaultLayout.json')));

                self.Toolstrip.AppContainer.Layout=layoutJSON;
            else

                grpname=self.Toolstrip.getGroupName();

                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setDocumentArrangement(grpname,md.TILED,java.awt.Dimension(3,2));

                loc=com.mathworks.widgets.desk.DTLocation.create(0);
                md.setClientLocation(self.Library.Name,grpname,loc);

                loc=com.mathworks.widgets.desk.DTLocation.create(2);
                md.setClientLocation(self.ParametersFig.Name,grpname,loc);

                loc=com.mathworks.widgets.desk.DTLocation.create(1);
                md.setClientLocation(self.RealAndImaginaryFig.Name,grpname,loc);

                if any(ismember(findall(0,'type','figure'),self.MagnitudeAndPhaseFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.MagnitudeAndPhaseFig.Name,grpname,loc);
                end

                if any(ismember(findall(0,'type','figure'),self.SpectrumFig))
                    figure(self.RealAndImaginaryFig)
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.SpectrumFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.PSpectrumFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.PSpectrumFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.SpectrogramFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.SpectrogramFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.AmbiguityFunctionContourFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.AmbiguityFunctionContourFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.AmbiguityFunctionSurfaceFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.AmbiguityFunctionSurfaceFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.AmbiguityFunctionDelayCutFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.AmbiguityFunctionDelayCutFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.AmbiguityFunctionDopplerCutFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.AmbiguityFunctionDopplerCutFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.AutoCorrelationFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.AutoCorrelationFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.MatchedFilterCoefficientsFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.MatchedFilterCoefficientsFig.Name,grpname,loc);
                end
                if any(ismember(findall(0,'type','figure'),self.StretchProcessorFig))
                    loc=com.mathworks.widgets.desk.DTLocation.create(1);
                    md.setClientLocation(self.StretchProcessorFig.Name,grpname,loc);
                end
                md.setDocumentRowSpan(grpname,0,2,3);
                md.setDocumentRowSpan(grpname,0,0,5);
                loc=com.mathworks.widgets.desk.DTLocation.create(4);
                md.setClientLocation(self.Characteristics.Name,grpname,loc);

                md.setDocumentColumnWidths(grpname,[0.24,0.50,0.26]);
                md.setDocumentRowHeights(grpname,[0.7,0.3]);
                drawnow;
            end
        end
        function disableCloseGestureOnDockedFeatures(self)

            grpname=self.Toolstrip.getGroupName();
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            stateFALSE=java.lang.Boolean.FALSE;
            md.getClient(self.ParametersFig.Name,grpname).putClientProperty(prop,stateFALSE);
            md.getClient(self.Library.Name,grpname).putClientProperty(prop,stateFALSE);
            md.getClient(self.RealAndImaginaryFig.Name,grpname).putClientProperty(prop,stateFALSE);
            md.getClient(self.Characteristics.Name,grpname).putClientProperty(prop,stateFALSE);
        end
        function deleteFigure(self)
            if~self.Toolstrip.IsAppContainer
                if~isempty(self.Toolstrip.ToolGroup)&&isvalid(self.Toolstrip.ToolGroup)
                    self.Toolstrip.ToolGroup.setClosingApprovalNeeded(false);
                    self.Toolstrip.ToolGroup.approveClose();
                    self.Toolstrip.ToolGroup.close();
                    delete(self.Toolstrip.ToolGroup)
                    delete(self.Canvas.WaveformList)
                end
            else
                if~isempty(self.Toolstrip.AppContainer)&&isvalid(self.Toolstrip.AppContainer)
                    delete(self.Canvas.WaveformList);
                end
            end
        end
    end

    methods(Hidden)
        function defaultLayoutAction(self)
            self.positionFigures();
        end

        function addAction(self)
            index=self.Canvas.InsertIdx;
            SampleRate=str2num(self.SampleRateEdit.String);%#ok<ST2NM>
            self.notify('InsertionRequested',phased.apps.internal.WaveformViewer.AddOrDeleteRequestedEventData(index,self.Canvas.SelectIdx,SampleRate));

            titleUpdate(self);
            setAppStatus(self,true);
            self.characteristicsAction();
            setAppStatus(self,false);

            self.addplotAction();
            self.Canvas.buttonsEnable();
            self.Parameters.MatchedFilterDialog=phased.apps.internal.WaveformViewer.MatchedFilterDialog(self.Parameters);
            idx=self.Parameters.MatchedFilterDialog.ProcessTypeEdit.Value;
            value=self.Parameters.MatchedFilterDialog.ProcessType;
            self.Parameters.notify('SystemCompressionView',phased.apps.internal.WaveformViewer.ProcessTypeEventData(idx,value))
        end

        function deleteAction(self)
            index=self.Canvas.WaveformList.getSelectedRows();
            k=numel(index);
            titleUpdate(self);
            for i=1:k
                self.Canvas.SelectIdx=index(i);
                index=index-1;
                insertIndex=self.Canvas.InsertIdx;
                self.notify('DeletionRequested',phased.apps.internal.WaveformViewer.AddOrDeleteRequestedEventData(insertIndex,self.Canvas.SelectIdx));
            end
        end
        function characteristicsAction(self)

            set(self.Parameters.WaveformCharacteristics.characteristicsTable,'Data',[]);
            ind=1:size(self.Canvas.WaveformList.Data,1);
            for i=1:numel(ind)
                index=ind(i);
                self.notify('CharacteristicsRequested',phased.apps.internal.WaveformViewer.CharacteristicsRequestedEventData(index));
            end
        end

        function addplotAction(self,graphtype)

            if nargin==1
                graphtype='';
            else
                self.GraphType=graphtype;
            end
            index=self.Canvas.SelectIdx;

            self.notify('PlotRequested',phased.apps.internal.WaveformViewer.PlotRequestedEventData(index,graphtype));
            self.GraphType='';
        end

        function thresholdCallback(self,graph)

            setAppStatus(self,true);
            self.characteristicsAction();
            setAppStatus(self,false);
            if strcmp(graph,'spectrogram')
                try
                    if~self.Toolstrip.IsAppContainer
                        value=evalin('base',self.Spectrogram.hThresholdedt.String);
                        self.Spectrogram.hThresholdedt.String=value;
                        if isempty(value)&&~isempty(self.Spectrogram.hThresholdedt.String)
                            value='';
                        end
                    else
                        value=evalin('base',self.Spectrogram.hThresholdedt.Value);
                        if isempty(value)&&~isempty(self.Spectrogram.hThresholdedt.Value)
                            value='';
                        end
                    end
                    validateattributes(value,{'numeric'},...
                    {'nonempty','scalar','real','finite'},'','Threshold')
                    if~self.Toolstrip.IsAppContainer
                        self.Spectrogram.thresholdpre=self.Spectrogram.hThresholdedt.String;
                    else
                        self.Spectrogram.thresholdpre=self.Spectrogram.hThresholdedt.Value;
                    end
                catch me
                    throwError(self,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                    if~self.Toolstrip.IsAppContainer
                        self.Spectrogram.hThresholdedt.String=self.Spectrogram.thresholdpre;
                    else
                        self.Spectrogram.hThresholdedt.Value=self.Spectrogram.thresholdpre;
                    end
                    return
                end
            end
            self.addplotAction(graph);
        end
    end

    methods(Hidden)
        function elementParameterInvalid(self,data)
            elementParameterInvalid(self.Parameters,data)
        end
        function compressParameterInvalid(self,data)
            compressParameterInvalid(self.Parameters,data)
        end
        function elementInserted(self,data)
            insertElement(self.Canvas,data.Elem,data.Process,data.Index)
        end

        function elementDeleted(self,data)
            deleteElement(self.Canvas,data.Elem,data.Process,data.Index)
        end

        function plotAdded(self,data)
            import matlab.ui.internal.*;

            switch data.graphtype
            case getString(message('phased:apps:waveformapp:realimag'))
                realImaginaryPlot(self.RealAndImaginary,data);
            case getString(message('phased:apps:waveformapp:spectrum'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.SpectrumFig)
                        figure(self.RealAndImaginaryFig);
                        self.SpectrumFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:Spectrum')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'Tag','Spectrum',...
                        'HandleVisibility','off',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.ToolGroup.addFigure(self.SpectrumFig);
                        self.Spectrum=phased.apps.internal.WaveformViewer.Spectrum(self);
                        controllib.plot.internal.FloatingPalette(self.SpectrumFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SpectrumFig));
                    end
                else
                    if isempty(self.SpectrumFig)||~isvalid(self.SpectrumFig)
                        spectrumFigOptions.Title=getString(message('phased:apps:waveformapp:Spectrum'));
                        spectrumFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        spectrumFigOptions.Tag='Spectrum';

                        document=FigureDocument(spectrumFigOptions);

                        self.SpectrumFig=document.Figure;
                        self.SpectrumFig.Internal=false;
                        self.SpectrumDoc=document;

                        set(self.SpectrumFig,...
                        'Name',getString(message('phased:apps:waveformapp:Spectrum')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','Spectrum',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.SpectrumDoc);

                        self.Spectrum=phased.apps.internal.WaveformViewer.Spectrum(self);
                    end
                end
                spectrumPlot(self.Spectrum,data);
            case getString(message('phased:apps:waveformapp:magphase'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.MagnitudeAndPhaseFig)
                        figure(self.RealAndImaginaryFig);
                        self.MagnitudeAndPhaseFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:MagnitudeandPhase')),...
                        'NumberTitle','off',...
                        'IntegerHandle','on',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','magandphase',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.MagnitudeAndPhaseFig);
                        self.MagnitudeAndPhase=phased.apps.internal.WaveformViewer.MagnitudeAndPhase(self);
                        controllib.plot.internal.FloatingPalette(self.MagnitudeAndPhaseFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.MagnitudeAndPhaseFig));
                    end
                else
                    if isempty(self.MagnitudeAndPhaseFig)||~isvalid(self.MagnitudeAndPhaseFig)
                        magphaseFigOptions.Title=getString(message('phased:apps:waveformapp:MagnitudeandPhase'));
                        magphaseFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        magphaseFigOptions.Tag='magandphase';

                        document=FigureDocument(magphaseFigOptions);

                        self.MagnitudeAndPhaseFig=document.Figure;
                        self.MagnitudeAndPhaseFig.Internal=false;
                        self.MagnitudeAndPhaseDoc=document;

                        set(self.MagnitudeAndPhaseFig,...
                        'Name',getString(message('phased:apps:waveformapp:MagnitudeandPhase')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','magandphase',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.MagnitudeAndPhaseDoc);

                        self.MagnitudeAndPhase=phased.apps.internal.WaveformViewer.MagnitudeAndPhase(self);
                    end
                end
                magnitudePhasePlot(self.MagnitudeAndPhase,data);
            case getString(message('phased:apps:waveformapp:pspectrum'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.PSpectrumFig)
                        figure(self.RealAndImaginaryFig);
                        self.PSpectrumFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:PersistenceSpectrumLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','pspectrum',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.PSpectrumFig);
                        self.PSpectrum=phased.apps.internal.WaveformViewer.PersistenceSpectrum(self);
                        controllib.plot.internal.FloatingPalette(self.PSpectrumFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.PSpectrumFig));
                    end
                else
                    if isempty(self.PSpectrumFig)||~isvalid(self.PSpectrumFig)
                        PSpectrumFigOptions.Title=getString(message('phased:apps:waveformapp:PersistenceSpectrumLabel'));
                        PSpectrumFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        PSpectrumFigOptions.Tag='pspectrum';
                        document=FigureDocument(PSpectrumFigOptions);

                        self.PSpectrumFig=document.Figure;
                        self.PSpectrumFig.Internal=false;

                        self.PSpectrumDoc=document;

                        set(self.PSpectrumFig,...
                        'Name',getString(message('phased:apps:waveformapp:PersistenceSpectrumLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','pspectrum',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.PSpectrumDoc);

                        self.PSpectrum=phased.apps.internal.WaveformViewer.PersistenceSpectrum(self);
                    end
                end
                pspectrumPlot(self.PSpectrum,data);
            case getString(message('phased:apps:waveformapp:spectrogram'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.SpectrogramFig)
                        figure(self.RealAndImaginaryFig);
                        self.SpectrogramFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:Spectrogram')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','spectrogram',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.SpectrogramFig);
                        self.Spectrogram=phased.apps.internal.WaveformViewer.VisualSpectrogram(self);
                        controllib.plot.internal.FloatingPalette(self.SpectrogramFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SpectrogramFig));
                    end
                else
                    if isempty(self.SpectrogramFig)||~isvalid(self.SpectrogramFig)
                        SpectrogramFigOptions.Title=getString(message('phased:apps:waveformapp:Spectrogram'));
                        SpectrogramFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        SpectrogramFigOptions.Tag='spectrogram';

                        document=FigureDocument(SpectrogramFigOptions);

                        self.SpectrogramFig=document.Figure;
                        self.SpectrogramFig.Internal=false;
                        self.SpectrogramDoc=document;

                        set(self.SpectrogramFig,...
                        'Name',getString(message('phased:apps:waveformapp:Spectrogram')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','spectrogram',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.SpectrogramDoc);

                        self.Spectrogram=phased.apps.internal.WaveformViewer.VisualSpectrogram(self);
                    end
                end
                spectrogramPlot(self.Spectrogram,data);
            case getString(message('phased:apps:waveformapp:ambfuncontour'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.AmbiguityFunctionContourFig)
                        figure(self.RealAndImaginaryFig);
                        self.AmbiguityFunctionContourFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionContour')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfuncontour',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.AmbiguityFunctionContourFig);
                        self.AmbiguityFunctionContour=phased.apps.internal.WaveformViewer.AmbiguityFunctionContour(self);
                        controllib.plot.internal.FloatingPalette(self.AmbiguityFunctionContourFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.AmbiguityFunctionContourFig));
                    end
                else
                    if isempty(self.AmbiguityFunctionContourFig)||~isvalid(self.AmbiguityFunctionContourFig)
                        ambiguityFigOptions.Title=getString(message('phased:apps:waveformapp:AmbiguityFunctionContour'));
                        ambiguityFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        ambiguityFigOptions.Tag='ambfuncontour';

                        document=FigureDocument(ambiguityFigOptions);

                        self.AmbiguityFunctionContourFig=document.Figure;
                        self.AmbiguityFunctionContourFig.Internal=false;
                        self.AmbiguityFunctionContourDoc=document;

                        set(self.AmbiguityFunctionContourFig,...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionContour')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfuncontour',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.AmbiguityFunctionContourDoc);
                        self.AmbiguityFunctionContour=phased.apps.internal.WaveformViewer.AmbiguityFunctionContour(self);
                    end
                end
                contourPlot(self.AmbiguityFunctionContour,data);
            case getString(message('phased:apps:waveformapp:ambfunsurf'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.AmbiguityFunctionSurfaceFig)
                        figure(self.RealAndImaginaryFig);
                        self.AmbiguityFunctionSurfaceFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionSurface')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfunsurf',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.AmbiguityFunctionSurfaceFig);
                        self.AmbiguityFunctionSurface=phased.apps.internal.WaveformViewer.AmbiguityFunctionSurface(self);
                        controllib.plot.internal.FloatingPalette(self.AmbiguityFunctionSurfaceFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.AmbiguityFunctionSurfaceFig));
                    end
                else
                    if isempty(self.AmbiguityFunctionSurfaceFig)||~isvalid(self.AmbiguityFunctionSurfaceFig)
                        ambiguityFigOptions.Title=getString(message('phased:apps:waveformapp:AmbiguityFunctionSurface'));
                        ambiguityFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        ambiguityFigOptions.Tag='ambfunsurf';

                        document=FigureDocument(ambiguityFigOptions);

                        self.AmbiguityFunctionSurfaceFig=document.Figure;
                        self.AmbiguityFunctionSurfaceFig.Internal=false;
                        self.AmbiguityFunctionSurfaceDoc=document;

                        set(self.AmbiguityFunctionSurfaceFig,...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionSurface')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfunsurf',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.AmbiguityFunctionSurfaceDoc);
                        self.AmbiguityFunctionSurface=phased.apps.internal.WaveformViewer.AmbiguityFunctionSurface(self);
                    end
                end
                surfacePlot(self.AmbiguityFunctionSurface,data);
            case getString(message('phased:apps:waveformapp:ambfundelaycut'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.AmbiguityFunctionDelayCutFig)
                        figure(self.RealAndImaginaryFig);
                        self.AmbiguityFunctionDelayCutFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionDelayCut')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'Tag','ambfundelaycut',...
                        'HandleVisibility','off',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.AmbiguityFunctionDelayCutFig);
                        self.AmbiguityFunctionDelayCut=phased.apps.internal.WaveformViewer.AmbiguityFunctionDelayCut(self);
                        controllib.plot.internal.FloatingPalette(self.AmbiguityFunctionDelayCutFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.AmbiguityFunctionDelayCutFig));
                    end
                else
                    if isempty(self.AmbiguityFunctionDelayCutFig)||~isvalid(self.AmbiguityFunctionDelayCutFig)
                        ambiguityFigOptions.Title=getString(message('phased:apps:waveformapp:AmbiguityFunctionDelayCut'));
                        ambiguityFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        ambiguityFigOptions.Tag='ambfundelaycut';

                        document=FigureDocument(ambiguityFigOptions);

                        self.AmbiguityFunctionDelayCutFig=document.Figure;
                        self.AmbiguityFunctionDelayCutFig.Internal=false;
                        self.AmbiguityFunctionDelayCutDoc=document;

                        set(self.AmbiguityFunctionDelayCutFig,...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionDelayCut')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfundelaycut',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.AmbiguityFunctionDelayCutDoc);
                        self.AmbiguityFunctionDelayCut=phased.apps.internal.WaveformViewer.AmbiguityFunctionDelayCut(self);
                    end
                end
                delayCutPlot(self.AmbiguityFunctionDelayCut,data);
            case getString(message('phased:apps:waveformapp:ambfundopplercut'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.AmbiguityFunctionDopplerCutFig)
                        figure(self.RealAndImaginaryFig);
                        self.AmbiguityFunctionDopplerCutFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionDopplerCut')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfundoppercut',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.AmbiguityFunctionDopplerCutFig);
                        self.AmbiguityFunctionDopplerCut=phased.apps.internal.WaveformViewer.AmbiguityFunctionDopplerCut(self);
                        controllib.plot.internal.FloatingPalette(self.AmbiguityFunctionDopplerCutFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.AmbiguityFunctionDopplerCutFig));
                    end
                else
                    if isempty(self.AmbiguityFunctionDopplerCutFig)||~isvalid(self.AmbiguityFunctionDopplerCutFig)
                        ambiguityFigOptions.Title=getString(message('phased:apps:waveformapp:AmbiguityFunctionDopplerCut'));
                        ambiguityFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        ambiguityFigOptions.Tag='ambfundoppercut';

                        document=FigureDocument(ambiguityFigOptions);

                        self.AmbiguityFunctionDopplerCutFig=document.Figure;
                        self.AmbiguityFunctionDopplerCutFig.Internal=false;
                        self.AmbiguityFunctionDopplerCutDoc=document;

                        set(self.AmbiguityFunctionDopplerCutFig,...
                        'Name',getString(message('phased:apps:waveformapp:AmbiguityFunctionDopplerCut')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','ambfundoppercut',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.AmbiguityFunctionDopplerCutDoc);
                        self.AmbiguityFunctionDopplerCut=phased.apps.internal.WaveformViewer.AmbiguityFunctionDopplerCut(self);
                    end
                end
                dopplerCutPlot(self.AmbiguityFunctionDopplerCut,data);
            case getString(message('phased:apps:waveformapp:autocorrelation'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.AutoCorrelationFig)
                        figure(self.RealAndImaginaryFig);
                        self.AutoCorrelationFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:AutocorrelationFunction')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','autocorrfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.AutoCorrelationFig);
                        self.AutoCorrelation=phased.apps.internal.WaveformViewer.AutoCorrelation(self);
                        controllib.plot.internal.FloatingPalette(self.AutoCorrelationFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.AutoCorrelationFig));
                    end
                else
                    if isempty(self.AutoCorrelationFig)||~isvalid(self.AutoCorrelationFig)
                        AutoCorrelationFigOptions.Title=getString(message('phased:apps:waveformapp:AutocorrelationFunction'));
                        AutoCorrelationFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        AutoCorrelationFigOptions.Tag='autocorrfig';

                        document=FigureDocument(AutoCorrelationFigOptions);

                        self.AutoCorrelationFig=document.Figure;
                        self.AutoCorrelationFig.Internal=false;
                        self.AutoCorrelationDoc=document;

                        set(self.AutoCorrelationFig,...
                        'Name',getString(message('phased:apps:waveformapp:AutocorrelationFunction')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','autocorrfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.AutoCorrelationDoc);
                        self.AutoCorrelation=phased.apps.internal.WaveformViewer.AutoCorrelation(self);
                    end
                end
                correlationPlot(self.AutoCorrelation,data);
            case getString(message('phased:apps:waveformapp:MatchedFilterLabel'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.MatchedFilterCoefficientsFig)
                        figure(self.RealAndImaginaryFig);
                        self.MatchedFilterCoefficientsFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:MatchedFilterLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','matchedfilterfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.MatchedFilterCoefficientsFig);
                        self.MatchedFilterCoefficients=phased.apps.internal.WaveformViewer.MatchedFilterPlot(self);
                        controllib.plot.internal.FloatingPalette(self.MatchedFilterCoefficientsFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.MatchedFilterCoefficientsFig));
                    end
                else
                    if isempty(self.MatchedFilterCoefficientsFig)||~isvalid(self.MatchedFilterCoefficientsFig)
                        MatchedFilterFigOptions.Title=getString(message('phased:apps:waveformapp:MatchedFilterLabel'));
                        MatchedFilterFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        MatchedFilterFigOptions.Tag='matchedfilterfig';

                        document=FigureDocument(MatchedFilterFigOptions);

                        self.MatchedFilterCoefficientsFig=document.Figure;
                        self.MatchedFilterCoefficientsFig.Internal=false;
                        self.MatchedFilterCoefficientsDoc=document;

                        set(self.MatchedFilterCoefficientsFig,...
                        'Name',getString(message('phased:apps:waveformapp:MatchedFilterLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','matchedfilterfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.MatchedFilterCoefficientsDoc);
                        self.MatchedFilterCoefficients=phased.apps.internal.WaveformViewer.MatchedFilterPlot(self);
                    end
                end
                matchedfilter(self.MatchedFilterCoefficients,data);
            case getString(message('phased:apps:waveformapp:StretchProcessorLabel'))
                if~self.Toolstrip.IsAppContainer
                    if~ismember(findall(0,'type','figure'),self.StretchProcessorFig)
                        figure(self.RealAndImaginaryFig);
                        self.StretchProcessorFig=figure(...
                        'Name',getString(message('phased:apps:waveformapp:StretchProcessorLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','stretchprocessorfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');
                        self.Toolstrip.ToolGroup.addFigure(self.StretchProcessorFig);
                        self.StretchProcessor=phased.apps.internal.WaveformViewer.StretchProcessorPlot(self);
                        controllib.plot.internal.FloatingPalette(self.StretchProcessorFig,{'ZoomIn';'ZoomOut';'Pan'});
                        self.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.StretchProcessorFig));
                    end
                else
                    if isempty(self.StretchProcessorFig)||~isvalid(self.StretchProcessorFig)
                        StretchProcessorFigOptions.Title=getString(message('phased:apps:waveformapp:StretchProcessorLabel'));
                        StretchProcessorFigOptions.DocumentGroupTag=self.FigureGroup.Tag;
                        StretchProcessorFigOptions.Tag='stretchprocessorfig';

                        document=FigureDocument(StretchProcessorFigOptions);

                        self.StretchProcessorFig=document.Figure;
                        self.StretchProcessorFig.Internal=false;
                        self.StretchProcessorDoc=document;

                        set(self.StretchProcessorFig,...
                        'Name',getString(message('phased:apps:waveformapp:StretchProcessorLabel')),...
                        'NumberTitle','off',...
                        'IntegerHandle','off',...
                        'WindowKeyPressFcn',@(varargin)[],...
                        'HandleVisibility','off',...
                        'Tag','stretchprocessorfig',...
                        'Units','pixels',...
                        'Visible','on',...
                        'Menubar','none');

                        self.Toolstrip.AppContainer.add(self.StretchProcessorDoc);
                        self.StretchProcessor=phased.apps.internal.WaveformViewer.StretchProcessorPlot(self);
                    end
                end
                stretchProcessor(self.StretchProcessor,data);
            otherwise
                fig=findall(0,'type','figure');
                if any(ismember(fig,self.RealAndImaginaryFig))
                    realImaginaryPlot(self.RealAndImaginary,data);
                end
                if any(ismember(fig,self.SpectrumFig))
                    spectrumPlot(self.Spectrum,data);
                end
                if any(ismember(fig,self.MagnitudeAndPhaseFig))
                    magnitudePhasePlot(self.MagnitudeAndPhase,data);
                end
                if any(ismember(fig,self.PSpectrumFig))
                    if numel(self.Canvas.WaveformList.getSelectedRows)==1
                        pspectrumPlot(self.PSpectrum,data);
                    end
                end
                if any(ismember(fig,self.SpectrogramFig))
                    if numel(self.Canvas.WaveformList.getSelectedRows)==1
                        spectrogramPlot(self.Spectrogram,data);
                    end
                end
                if any(ismember(fig,self.AmbiguityFunctionContourFig))
                    if numel(self.Canvas.WaveformList.getSelectedRows)==1
                        contourPlot(self.AmbiguityFunctionContour,data);
                    end
                end
                if any(ismember(fig,self.AmbiguityFunctionSurfaceFig))
                    if numel(self.Canvas.WaveformList.getSelectedRows)==1
                        surfacePlot(self.AmbiguityFunctionSurface,data);
                    end
                end
                if any(ismember(fig,self.AmbiguityFunctionDelayCutFig))
                    delayCutPlot(self.AmbiguityFunctionDelayCut,data);
                end
                if any(ismember(fig,self.AmbiguityFunctionDopplerCutFig))
                    dopplerCutPlot(self.AmbiguityFunctionDopplerCut,data);
                end
                if any(ismember(fig,self.AutoCorrelationFig))
                    correlationPlot(self.AutoCorrelation,data);
                end
                if any(ismember(fig,self.MatchedFilterCoefficientsFig))&&...
                    strcmp(phased.apps.internal.WaveformViewer.getWaveformString(class(data.compProperties)),'MatchedFilter')
                    matchedfilter(self.MatchedFilterCoefficients,data);
                elseif any(ismember(fig,self.MatchedFilterCoefficientsFig))&&...
                    strcmp(phased.apps.internal.WaveformViewer.getWaveformString(class(data.compProperties)),'StretchProcessor')
                    closeFigure(self,self.MatchedFilterCoefficientsFig);
                end
                if(any(ismember(fig,self.StretchProcessorFig))&&...
                    strcmp(phased.apps.internal.WaveformViewer.getWaveformString(class(data.compProperties)),'StretchProcessor'))
                    stretchProcessor(self.StretchProcessor,data);
                elseif(any(ismember(fig,self.StretchProcessorFig))&&...
                    strcmp(phased.apps.internal.WaveformViewer.getWaveformString(class(data.compProperties)),'MatchedFilter'))
                    closeFigure(self,self.StretchProcessorFig);
                end
            end
        end
        function characteristicsAdded(self,data)
            CalculateWaveformCharacteristics(self.Parameters.WaveformCharacteristics,data.Properties,data.Index)
        end

        function closeFigure(self,figure)
            if self.Toolstrip.IsAppContainer
                closeDocument(self.Toolstrip.AppContainer,self.FigureGroup.Tag,figure.Tag);
            else
                close(figure);
            end
        end

        function setAppStatus(self,value)
            if self.Toolstrip.IsAppContainer
                self.Toolstrip.AppContainer.Busy=value;
            else
                self.Toolstrip.ToolGroup.setWaiting(value);
            end
        end

        function throwError(self,messagestring,me)
            if nargin==3
                title=messagestring;
                if~self.Toolstrip.IsAppContainer
                    h=errordlg(me.message,title,'modal');
                    uiwait(h);
                else
                    uialert(self.Toolstrip.AppContainer,me.message,title);
                end
            else
                if~self.Toolstrip.IsAppContainer
                    h=errordlg(messagestring,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),'modal');
                    uiwait(h);
                else
                    uialert(self.Toolstrip.AppContainer,messagestring,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')));
                end
            end
        end

        function titleUpdate(self)
            if~self.Toolstrip.IsAppContainer
                title=self.Toolstrip.ToolGroup.Title;
                if~strcmp(title(end),'*')
                    self.Toolstrip.ToolGroup.Title=sprintf('%s*',title);
                else
                    self.Toolstrip.ToolGroup.Title=title;
                end
            else
                title=self.Toolstrip.AppContainer.Title;
                if~contains(title,'*')
                    self.Toolstrip.AppContainer.Title=sprintf('%s*',title);
                else
                    self.Toolstrip.AppContainer.Title=title;
                end
            end
        end
    end


    events(Hidden)
EmptyStoreDataElements
DuplicateInsertionRequested
InsertionRequested
DeletionRequested
PlotRequested
CharacteristicsRequested
NewName
Componentsadd
    end
end