classdef RPMTrackerView<handle


    properties(Hidden,Transient=true)
TrackerAppContainer
Controller
    end

    properties(Access={?matlab.unittest.TestCase},Hidden)
AppID

TrackerTab
MethodDropDown
FrequencyResolutionEditField
FrequencyResolutionSlider
AddRidgePointButton
DeleteAllRidgePointButton
OrderEditField
StartTimeEditField
StartTimeUnitLabel
EndTimeEditField
EndTimeUnitLabel
PowerPenaltyEditField
FrequencyPenaltyEditField
EstimateButton
ExportButton

Frame
StatusbarWestLabel
StatusbarWestIcon
StatusbarEastLabel


FigureHandle
MapAxesHandle
MapImageHandle
RidgeLineHandle
TopOfMapAxesHandle
LinkMapAndTopOfMaxAxesHandle
CrosshairXLineHandle
CrosshairYLineHandle
StartTimePatchHandle
EndTimePatchHandle
RidgePointLineHandle

RPMAxesHandle
RPMLineHandle
HelpTextHandle

        mouseDownOnCrossHair=0;
        mouseDownOnRidgePoint=0;
        cursorIsOver=[];

MotionListener
CurrentModeListener
ModeManager
MouseDownListener
MouseUpListener

Opts
MapPower
MapFrequencyVector
MapTimeVector

EstimatedRPM
OutputTimeVector

RPMAxesXLim
IsRPMAxesCleared

CrosshairCoordinate

SelectedRidgePointIndex
SelectedRidgePointIndexForContextMenu

StartEndTimeUnitMultiplier

StatusText

        IsDirty=false
    end

    properties(Constant,Hidden)
        FrequencyResolutionSliderNumTick=11

        MapAxesSize=[0.07,0.5,0.83,0.45]
        RPMAxesSize=[0.07,0.08,0.83,0.3]

        StartEndTimePatchColor=[0.7,0.7,0.7]
        StartEndTimePatchTransparency=0.4



        RPMAxesYLimDefault=[-1,1]

        HelpTextFontSize=16
        HelpTextColor=[1/sqrt(3),1/sqrt(3),1/sqrt(3)]
        HelpTextEdgeColor=[1/sqrt(3),1/sqrt(3),1/sqrt(3)]
    end

    events(NotifyAccess=private)
AppClosed
    end

    methods
        function this=RPMTrackerView(Fx,Tx,Px,rpm,tout,opts)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.container.internal.AppContainer_Debug;
            import matlab.ui.internal.*;


            this.AppID=matlab.lang.internal.uuid;


            this.MapPower=Px;
            this.MapFrequencyVector=Fx;
            this.MapTimeVector=Tx+opts.TimeVector(1);
            if opts.IsTimeTable&&~isempty(rpm)
                rpm=rpm{:,:};
                tout=seconds(tout);
            end
            this.EstimatedRPM=rpm;
            this.OutputTimeVector=tout;
            this.Opts=opts;

            this.RPMAxesXLim=[opts.TimeVector(1),opts.TimeVector(end)];



            appOptions.Tag="rpmtrackerappcontainer"+this.AppID;
            appOptions.Title=getString(message('signal:rpmtrack:toolGroupName'));
            appOptions.UserDocumentTilingEnabled=false;
            screenSize=get(0,'ScreenSize');
            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
            appOptions.WindowBounds=[0.25*screenWidth,0.25*screenHeight,0.5*screenWidth,0.55*screenHeight];
            this.TrackerAppContainer=AppContainer(appOptions);
            set(this.TrackerAppContainer,'CanCloseFcn',@(h,e)closeCallback(this));


            this.createTrackerTab();


            this.createTFMSection();


            this.createRidgePointSection();


            this.createRidgeExtractionParamSection();


            this.createEstimateSection();


            this.createExportSection();


            this.renderGUI();
        end


    end


    methods(Hidden)
        function renderGUI(this)

            this.createStatusbar();


            this.createFigure();


            this.FigureHandle.Visible='on';
            this.TrackerAppContainer.Visible=true;

            drawnow limitrate nocallbacks

        end
    end


    methods(Hidden)



        function createTrackerTab(this)

            import matlab.ui.internal.toolstrip.TabGroup
            import matlab.ui.internal.toolstrip.Tab

            tabGroup=TabGroup();
            tabGroup.Tag='rpmtrackerTabGroupTag';


            this.TrackerTab=Tab(getString(message('signal:rpmtrack:trackerTabName')));
            this.TrackerTab.Tag='rpmtrackerTrackerTabTag';


            tabGroup.add(this.TrackerTab);


            this.TrackerAppContainer.addTabGroup(tabGroup);
        end

        function createTFMSection(this)
            import matlab.ui.internal.toolstrip.Column
            import matlab.ui.internal.toolstrip.DropDown
            import matlab.ui.internal.toolstrip.Slider
            import matlab.ui.internal.toolstrip.Label
            import matlab.ui.internal.toolstrip.EditField

            section=this.TrackerTab.addSection(getString(message('signal:rpmtrack:tfmSec')));
            col1=Column('HorizontalAlignment','right','Width',120);
            section.add(col1);
            col2=Column('Width',220);
            section.add(col2);
            col3=Column('Width',60);
            section.add(col3);
            col4=Column();
            section.add(col4);


            col1.add(Label([getString(message('signal:rpmtrack:methodLbl')),' ']));
            this.MethodDropDown=DropDown({getString(message('signal:rpmtrack:methodSTFT'));...
            getString(message('signal:rpmtrack:methodFSST'))});
            this.MethodDropDown.Tag='rpmtrackerMethodDropDownTag';
            this.MethodDropDown.Description=getString(message('signal:rpmtrack:methodTT'));
            if strcmpi(this.Opts.Method,'stft')
                this.MethodDropDown.SelectedIndex=1;
            else
                this.MethodDropDown.SelectedIndex=2;
            end
            this.MethodDropDown.ValueChangedFcn=...
            @(~,ed)onMethodValChanged(this,ed);
            col2.add(this.MethodDropDown);
            col3.addEmptyControl();
            col4.addEmptyControl();

            col1.addEmptyControl();
            col2.addEmptyControl();
            col3.addEmptyControl();
            col4.addEmptyControl();


            col1.add(Label(getString(message('signal:rpmtrack:freqResLbl'))));
            freqRes=this.Opts.FrequencyResolution;
            freqResMin=this.Opts.MinFrequencyResolution;
            freqResMax=this.Opts.MaxFrequencyResolution;
            freqResStep=(freqResMax/freqResMin-1)/...
            this.FrequencyResolutionSliderNumTick;

            freqResStep=max(1,floor(freqResStep));
            this.FrequencyResolutionSlider=...
            Slider([1,floor(freqResMax/freqResMin)],round(freqRes/freqResMin));
            this.FrequencyResolutionSlider.Tag=...
            'rpmtrackerFrequencyResolutionSliderTag';
            this.FrequencyResolutionSlider.Description=...
            getString(message('signal:rpmtrack:freqResTT'));
            this.FrequencyResolutionSlider.Ticks=...
            this.FrequencyResolutionSliderNumTick;
            this.FrequencyResolutionSlider.Steps=freqResStep;
            this.FrequencyResolutionSlider.UseSmallFont=true;
            this.FrequencyResolutionSlider.ValueChangedFcn=...
            @(~,ed)onFreqResSliderValChanged(this,ed);
            col2.add(this.FrequencyResolutionSlider);
            this.FrequencyResolutionSlider.Compact=true;


            this.FrequencyResolutionEditField=EditField(num2str(freqRes));
            this.FrequencyResolutionEditField.Tag=...
            'rpmtrackerFrequencyResolutionEditFieldTag';
            this.FrequencyResolutionEditField.Description=...
            getString(message('signal:rpmtrack:freqResTT'));
            this.FrequencyResolutionEditField.ValueChangedFcn=...
            @(~,ed)onFreqResEditFieldValChanged(this,ed);
            col3.add(this.FrequencyResolutionEditField);
            col4.add(Label('Hz'));
        end

        function createRidgePointSection(this)
            import matlab.ui.internal.toolstrip.Button
            import matlab.ui.internal.toolstrip.Column
            import matlab.ui.internal.toolstrip.Icon

            section=this.TrackerTab.addSection(...
            getString(message('signal:rpmtrack:ridgePointSec')));
            col=Column();
            section.add(col);


            this.AddRidgePointButton=Button(getString(message('signal:rpmtrack:addLbl')),...
            Icon.ADD_16);
            this.AddRidgePointButton.Tag=...
            'rpmtrackerAddRidgePointButtonTag';
            this.AddRidgePointButton.Description=getString(message('signal:rpmtrack:addTT'));
            this.AddRidgePointButton.Enabled=true;
            this.AddRidgePointButton.ButtonPushedFcn=...
            @(~,~)onAddPushed(this);
            col.add(this.AddRidgePointButton);


            this.DeleteAllRidgePointButton=Button(...
            getString(message('signal:rpmtrack:deleteAllLbl')),Icon.DELETE_16);
            this.DeleteAllRidgePointButton.Tag=...
            'rpmtrackerDeleteAllRidgePointButtonTag';
            this.DeleteAllRidgePointButton.Description=...
            getString(message('signal:rpmtrack:deleteAllTT'));
            this.DeleteAllRidgePointButton.Enabled=...
            ~isempty(this.Opts.Points);
            this.DeleteAllRidgePointButton.ButtonPushedFcn=...
            @(~,~)onDeleteAllPushed(this);
            col.add(this.DeleteAllRidgePointButton);
        end

        function createRidgeExtractionParamSection(this)
            import matlab.ui.internal.toolstrip.Column
            import matlab.ui.internal.toolstrip.Panel
            import matlab.ui.internal.toolstrip.EditField
            import matlab.ui.internal.toolstrip.Label

            section=this.TrackerTab.addSection(...
            getString(message('signal:rpmtrack:ridgeExtParamSec')));
            col1=Column();
            section.add(col1);
            emptyCol=Column('Width',10);
            section.add(emptyCol);
            col2=Column();
            section.add(col2);


            panel1=Panel();
            col1.add(panel1);
            c11=panel1.addColumn('HorizontalAlignment','right','Width',60);
            c12=panel1.addColumn('Width',60);
            c13=panel1.addColumn('HorizontalALignment','left');


            c11.add(Label([getString(message('signal:rpmtrack:orderLbl')),' ']));
            this.OrderEditField=EditField(num2str(this.Opts.Order));
            this.OrderEditField.Tag='rpmtrackerOrderEditFieldTag';
            this.OrderEditField.Description=getString(message('signal:rpmtrack:orderTT'));
            this.OrderEditField.ValueChangedFcn=...
            @(~,ed)onOrderValChanged(this,ed);
            c12.add(this.OrderEditField);
            c13.addEmptyControl();


            c11.add(Label([getString(message('signal:rpmtrack:startTimeLbl')),' ']));
            this.StartTimeEditField=EditField(num2str(this.Opts.StartTime));
            this.StartTimeEditField.Tag=...
            'rpmtrackerStartTimeEditFieldEditFieldTag';
            this.StartTimeEditField.Description=...
            getString(message('signal:rpmtrack:startTimeTT'));
            this.StartTimeEditField.ValueChangedFcn=...
            @(~,ed)onStartTimeValChanged(this,ed);
            c12.add(this.StartTimeEditField);

            this.StartTimeUnitLabel=Label();
            c13.add(this.StartTimeUnitLabel);


            c11.add(Label([getString(message('signal:rpmtrack:endTimeLbl')),' ']));
            this.EndTimeEditField=EditField(num2str(this.Opts.EndTime));
            this.EndTimeEditField.Tag=...
            'rpmtrackerEndTimeEditFieldEditFieldTag';
            this.EndTimeEditField.Description=getString(message('signal:rpmtrack:endTimeTT'));
            this.EndTimeEditField.ValueChangedFcn=...
            @(~,ed)onEndTimeValChanged(this,ed);
            c12.add(this.EndTimeEditField);

            this.EndTimeUnitLabel=Label();
            c13.add(this.EndTimeUnitLabel);


            panel2=Panel();
            col2.add(panel2);
            c21=panel2.addColumn('HorizontalAlignment','right');
            c22=panel2.addColumn('Width',60);
            c23=panel2.addColumn();


            c21.add(Label([getString(message('signal:rpmtrack:powPenLbl')),' ']));
            this.PowerPenaltyEditField=...
            EditField(num2str(this.Opts.PowerPenalty));
            this.PowerPenaltyEditField.Tag=...
            'rpmtrackerPowerPenaltyEditFieldTag';
            this.PowerPenaltyEditField.Description=...
            getString(message('signal:rpmtrack:powPenTT'));
            this.PowerPenaltyEditField.ValueChangedFcn=...
            @(~,ed)onPowerPenaltyValChanged(this,ed);
            c22.add(this.PowerPenaltyEditField);
            c23.add(Label('dB'));


            c21.add(Label([getString(message('signal:rpmtrack:freqPenLbl')),' ']));
            this.FrequencyPenaltyEditField=...
            EditField(num2str(this.Opts.FrequencyPenalty));
            this.FrequencyPenaltyEditField.Tag=...
            'rpmtrackerFrequencyPenaltyEditFieldTag';
            this.FrequencyPenaltyEditField.Description=...
            getString(message('signal:rpmtrack:freqPenTT'));
            this.FrequencyPenaltyEditField.ValueChangedFcn=...
            @(~,ed)onFrequencyPenaltyValChanged(this,ed);
            c22.add(this.FrequencyPenaltyEditField);


            c21.addEmptyControl();
            c22.addEmptyControl();
            c23.addEmptyControl();
            c23.addEmptyControl();
        end

        function createEstimateSection(this)
            import matlab.ui.internal.toolstrip.Button
            import matlab.ui.internal.toolstrip.Column
            import matlab.ui.internal.toolstrip.Icon

            section=this.TrackerTab.addSection(getString(message('signal:rpmtrack:rpmSec')));
            section.CollapsePriority=10;
            col=Column('HorizontalAlignment','center');
            section.add(col);


            this.EstimateButton=Button(getString(message('signal:rpmtrack:estimateLbl')),...
            Icon.RUN_24);
            this.EstimateButton.Tag='rpmtrackerRPMEstimateButtonTag';
            this.EstimateButton.Description=getString(message('signal:rpmtrack:estimateTT'));
            this.EstimateButton.Enabled=false;
            this.EstimateButton.ButtonPushedFcn=...
            @(~,~)computeRPMAndUpdatePlot(this.Controller);
            col.add(this.EstimateButton);
        end

        function createExportSection(this)
            import matlab.ui.internal.toolstrip.SplitButton
            import matlab.ui.internal.toolstrip.PopupList
            import matlab.ui.internal.toolstrip.ListItem
            import matlab.ui.internal.toolstrip.Column
            import matlab.ui.internal.toolstrip.Icon

            section=this.TrackerTab.addSection(getString(message('signal:rpmtrack:exportSec')));
            section.CollapsePriority=5;
            col=Column;
            section.add(col);


            splitButton=SplitButton(getString(message('signal:rpmtrack:exportLbl')),...
            Icon.CONFIRM_24);
            splitButton.Tag='rpmtrackerExportSplitButtonTag';


            this.ExportButton=splitButton;
            this.ExportButton.Description=getString(message('signal:rpmtrack:exportTT'));
            this.ExportButton.Enabled=false;
            this.ExportButton.ButtonPushedFcn=@(~,~)onExportPushed(this.Controller);
            col.add(this.ExportButton);


            popupList=PopupList();
            popupList.Tag='rpmtrackerExportButtonPopupListTag';
            splitButton.Popup=popupList;


            item1=ListItem(getString(message('signal:rpmtrack:exportEstRPMItemLbl')),...
            Icon.EXPORT_16);
            item1.Tag='rpmtrackerExportEstRPMItemTag';
            item1.ShowDescription=false;
            item1.ItemPushedFcn=@(~,~)onExportPushed(this.Controller);
            popupList.add(item1);


            item2=ListItem(getString(message('signal:rpmtrack:exportGenMLScriptItemLbl')),...
            Icon.MATLAB_16);
            item2.Tag='rpmtrackerGenMLScriptItemTag';
            item2.ShowDescription=false;
            item2.ItemPushedFcn=@(~,~)onGenerateMLScriptPushed(this.Controller);
            popupList.add(item2);
        end




        function createStatusbar(this)

            statusBar=matlab.ui.internal.statusbar.StatusBar();
            statusBar.Tag="statusBar";

            sLabel=matlab.ui.internal.statusbar.StatusLabel();
            sLabel.Tag="messageLabel";
            sLabel.Text='';
            sLabel.Region="left";
            statusBar.add(sLabel);
            this.StatusbarWestLabel=sLabel;

            sLabel=matlab.ui.internal.statusbar.StatusLabel();
            sLabel.Tag="corsshairLabel";
            sLabel.Text='';
            sLabel.Region="right";
            statusBar.add(sLabel);
            this.StatusbarEastLabel=sLabel;

            this.TrackerAppContainer.add(statusBar);
        end

        function setStatusTextAndIcon(this,textStr,iconType,location)







            if ischar(iconType)
                switch lower(iconType(1:4))
                case 'info'
                    icon=fullfile(matlabroot,'toolbox','signal','signal','+signal','+internal','+rpmtrack','Info.png');
                case 'warn'
                    icon=fullfile(matlabroot,'toolbox','signal','signal','+signal','+internal','+rpmtrack','Warning.png');
                end
            else
                icon=iconType;
            end

            if strcmpi(location,'east')
                lbl=this.StatusbarEastLabel;
            else
                lbl=this.StatusbarWestLabel;
            end
            if isempty(textStr)
                textStr='';
            end
            lbl.Text=textStr;
            lbl.Icon=icon;
        end




        function onMethodValChanged(this,~)

            this.Controller.computeMapAndUpdatePlot();
        end

        function onFreqResSliderValChanged(this,data)


            this.FrequencyResolutionEditField.Value=...
            num2str(data.EventData.Value*...
            this.Opts.MinFrequencyResolution);



            this.Controller.computeMapAndUpdatePlot();
        end

        function onFreqResEditFieldValChanged(this,data)

            newVal=str2double(data.EventData.NewValue);
            validFcn=@(x)(isreal(x)&&isfinite(x)&&(x>0)&&...
            ~isnan(x)&&~issparse(x)&&~isempty(x)&&isscalar(x)&&...
            (x>=this.Opts.MinFrequencyResolution)&&...
            (x<=this.Opts.MaxFrequencyResolution));
            isValid=validFcn(newVal);
            if~isValid

                this.FrequencyResolutionEditField.Value=...
                data.EventData.OldValue;



                this.clearRPMAxesAndRidgeLine();
                return
            else

                freqResMin=this.Opts.MinFrequencyResolution;
                this.FrequencyResolutionSlider.Value=...
                str2double(data.EventData.NewValue)/freqResMin;
            end



            this.Controller.computeMapAndUpdatePlot();
        end

        function onAddPushed(this,~)

            this.addRidgePoint([],[],'fromAddButton');
        end

        function onDeleteAllPushed(this,~)

            this.deleteAllRidgePoint();
        end

        function onOrderValChanged(this,data)

            newVal=str2double(data.EventData.NewValue);
            validFcn=@(x)(isreal(x)&&isfinite(x)&&(x>0)&&...
            ~isnan(x)&&~issparse(x)&&~isempty(x)&&isscalar(x));
            isValid=validFcn(newVal);
            if~isValid

                this.OrderEditField.Value=data.EventData.OldValue;
            else


                this.setEstimateButtonEnable();
            end


            this.createHelpTextOrderPointUnspecified();


            this.clearRPMAxesAndRidgeLine()
        end

        function onStartTimeValChanged(this,data)


            newVal=str2double(data.EventData.NewValue);

            newVal=this.convertStartEndTimeValueToSec(newVal);

            endTime=str2double(this.EndTimeEditField.Value);

            endTime=this.convertStartEndTimeValueToSec(endTime);
            validFcn=@(x)(isreal(x)&&isfinite(x)&&(x>=0)&&...
            ~isnan(x)&&isscalar(x)&&...
            (x>=this.Opts.TimeVector(1))&&(x<endTime));
            isValid=validFcn(newVal);
            if~isValid

                this.StartTimeEditField.Value=data.EventData.OldValue;
            else

                this.updateStartTimePatch();
            end



            this.setEstimateButtonEnable();


            this.createHelpTextOrderPointUnspecified();


            this.clearRPMAxesAndRidgeLine();
        end

        function onEndTimeValChanged(this,data)


            newVal=str2double(data.EventData.NewValue);

            newVal=this.convertStartEndTimeValueToSec(newVal);

            startTime=str2double(this.StartTimeEditField.Value);

            startTime=this.convertStartEndTimeValueToSec(startTime);
            validFcn=@(x)(isreal(x)&&isfinite(x)&&(x>0)&&...
            ~isnan(x)&&isscalar(x)&&...
            (x<=this.Opts.TimeVector(end))&&(x>startTime));
            isValid=validFcn(newVal);
            if~isValid

                this.EndTimeEditField.Value=data.EventData.OldValue;
            else

                this.updateEndTimePatch();
            end



            this.setEstimateButtonEnable();


            this.createHelpTextOrderPointUnspecified();


            this.clearRPMAxesAndRidgeLine();
        end

        function onPowerPenaltyValChanged(this,data)

            newVal=str2double(data.EventData.NewValue);
            validFcn=@(x)(isreal(x)&&(x>0)&&~isnan(x)&&...
            ~issparse(x)&&~isempty(x)&&isscalar(x));
            isValid=validFcn(newVal);
            if~isValid

                this.PowerPenaltyEditField.Value=data.EventData.OldValue;
            end


            this.clearRPMAxesAndRidgeLine();
        end

        function onFrequencyPenaltyValChanged(this,data)

            newVal=str2double(data.EventData.NewValue);
            validFcn=@(x)(isreal(x)&&(x>=0)&&~isnan(x)&&...
            ~issparse(x)&&~isempty(x)&&isscalar(x)&&isfinite(x));
            isValid=validFcn(newVal);
            if~isValid

                this.FrequencyPenaltyEditField.Value=data.EventData.OldValue;
            end


            this.clearRPMAxesAndRidgeLine();
        end

        function flag=closeCallback(this)
            flag=true;
            notify(this,'AppClosed')
        end




        function setEstimateButtonEnable(this)




            idx=this.getIndexRidgePointInActiveRegion();
            if this.EstimateButton.Enabled
                if(isempty(this.OrderEditField.Value)||isempty(idx))
                    this.EstimateButton.Enabled=false;
                end
            else
                if(~isempty(this.OrderEditField.Value)&&~isempty(idx))
                    this.EstimateButton.Enabled=true;
                end
            end
        end

    end


    methods(Hidden)
        function createFigure(this)

            this.createAxes();


            this.updateMapAndColorbarAxes();


            this.updateMapAxesUnits();


            this.updateCrosshairCoordinate();


            this.getStartEndTimeUnitLabelAndMultiplier();


            this.updateStartTimePatch();


            this.updateEndTimePatch();


            this.addRidgePoint([],[],'fromFunctionCall')



            this.updateRPMAxesAndRidgeLine();


            this.updateRPMAxesUnits();


            this.fullView(0,0);


            this.createHelpTextOrderPointUnspecified();


            this.setupListeners();
        end




        function createAxes(this)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.container.internal.AppContainer_Debug;
            import matlab.ui.internal.*;


            group=FigureDocumentGroup();
            group.Title="Figures";
            this.TrackerAppContainer.add(group);


            figOptions.Title=this.Opts.SignalArgName;
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            document=FigureDocument(figOptions);
            this.TrackerAppContainer.add(document);

            hFigure=document.Figure;
            hFigure.Visible='off';
            hFigure.NumberTitle='off';
            hFigure.AutoResizeChildren='off';
            hFigure.ResizeFcn=@(es,ed)resizeFigure(this,es,ed);
            hFigure.Tag='rpmtrackerFigureTag';


            hMapAxes=axes(...
            'Parent',hFigure,...
            'Position',this.MapAxesSize,...
            'Box','on',...
            'XTickLabel','',...
            'XGrid','on',...
            'YGrid','on',...
            'Tag','rpmtrackerMapAxesTag');
            hMapAxes.Title.String=...
            getString(message('signal:rpmtrack:mapPltTitle'));


            this.MapImageHandle=imagesc('Parent',hMapAxes,...
            'Tag','rpmtrackerMapImageTag');
            hColorbar=colorbar(...
            'peer',hMapAxes,'Location','EastOutside');

            delete(hColorbar.UIContextMenu)
            hColorbar.UIContextMenu=[];


            this.RidgeLineHandle=line('Parent',hMapAxes,...
            'XData',[],...
            'YData',[],...
            'Color','k',...
            'LineStyle','-',...
            'Tag','rpmtrackerRidgeLineTag');




            hTopOfMapAxes=axes(...
            'Parent',hFigure,...
            'Position',this.MapAxesSize,...
            'Visible','off',...
            'Tag','rpmtrackerTopOfMapAxesTag');




            this.LinkMapAndTopOfMaxAxesHandle=linkprop(...
            [hMapAxes,hTopOfMapAxes],...
            {'Position','XLim','YLim','ZLim','XScale','YScale','View'});



            this.CrosshairXLineHandle=line('Parent',hTopOfMapAxes,...
            'Tag','rpmtrackerCrosshairXLineTag');

            this.CrosshairYLineHandle=line('Parent',hTopOfMapAxes,...
            'Tag','rpmtrackerCrosshairYLineTag');


            this.StartTimePatchHandle=patch(...
            'XData',[0,0,1,1],...
            'YData',[0,1,1,0],...
            'EdgeColor',this.StartEndTimePatchColor,...
            'EdgeAlpha',this.StartEndTimePatchTransparency,...
            'FaceColor',this.StartEndTimePatchColor,...
            'FaceAlpha',this.StartEndTimePatchTransparency,...
            'Tag','rpmtrackerStartTimePatchTag',...
            'Parent',hTopOfMapAxes);

            this.EndTimePatchHandle=patch(...
            'XData',[0,0,1,1],...
            'YData',[0,1,1,0],...
            'EdgeColor',this.StartEndTimePatchColor,...
            'EdgeAlpha',this.StartEndTimePatchTransparency,...
            'FaceColor',this.StartEndTimePatchColor,...
            'FaceAlpha',this.StartEndTimePatchTransparency,...
            'Tag','rpmtrackerEndTimePatchTag',...
            'Parent',hTopOfMapAxes);


            hRPMAxes=axes(...
            'Parent',hFigure,...
            'Position',this.RPMAxesSize,...
            'Box','on',...
            'XGrid','on',...
            'YAxisLocation','left',...
            'YGrid','on',...
            'Tag','rpmtrackerRPMAxesTag');

            this.RPMLineHandle=line('Parent',hRPMAxes,...
            'Color','b',...
            'LineStyle','-',...
            'Tag','rpmtrackerRPMLineTag');

            hRPMAxes.YLabel.String=...
            getString(message('signal:rpmtrack:rpmPltYLbl'));
            axis(hRPMAxes,'tight')


            this.HelpTextHandle=text(hRPMAxes,0.1,0.1,'',...
            'Color',this.HelpTextColor,...
            'EdgeColor',this.HelpTextEdgeColor,...
            'Visible','off',...
            'Tag','rpmtrackerRPMHelpText');


            set([hFigure,hMapAxes,hRPMAxes],...
            'HandleVisibility','Callback');


            this.FigureHandle=hFigure;
            this.MapAxesHandle=hMapAxes;
            this.RidgePointLineHandle=gobjects(0);
            this.TopOfMapAxesHandle=hTopOfMapAxes;
            this.RPMAxesHandle=hRPMAxes;



            enableLegacyExplorationModes(hFigure);



            [~,bttns]=axtoolbar(this.TopOfMapAxesHandle,{'zoomin','zoomout','restoreview'},...
            'SelectionChangedFcn',@(es,ed)cbCurrentMode(this,es,ed));


            bttns(1).ButtonPushedFcn=@(es,ed)fullView(this,es,ed);

            axtoolbar(this.RPMAxesHandle,{'zoomin','zoomout','restoreview'});
        end
    end

    methods(Access={?signal.internal.rpmtrack.RPMTrackerController},Hidden)

        function[em,fres,varargout]=getPropertiesFromView(this,sel)







            if strcmpi(this.MethodDropDown.Value,...
                getString(message('signal:rpmtrack:methodSTFT')))
                em='stft';
            else
                em='fsst';
            end

            fres=str2double(this.FrequencyResolutionEditField.Value);

            if strcmpi(sel,'computeRPM')


                varargout{1}=str2double(this.OrderEditField.Value);

                pointX=[this.RidgePointLineHandle(:).XData];
                pointY=[this.RidgePointLineHandle(:).YData];

                ridgeIdx=this.getIndexRidgePointInActiveRegion();
                pointX=pointX(ridgeIdx);
                pointY=pointY(ridgeIdx);

                [pointX,Idx]=unique(pointX);
                pointY=pointY(Idx);
                varargout{2}=[pointX(:),pointY(:)];


                varargout{3}=...
                str2double(this.PowerPenaltyEditField.Value);

                varargout{4}=...
                str2double(this.FrequencyPenaltyEditField.Value);

                st=str2double(this.StartTimeEditField.Value);
                varargout{5}=this.convertStartEndTimeValueToSec(st);

                et=str2double(this.EndTimeEditField.Value);
                varargout{6}=this.convertStartEndTimeValueToSec(et);
            end
        end



        function setRpm(this,rpm,tOut)
            this.EstimatedRPM=rpm;
            this.OutputTimeVector=tOut;
        end

        function setMap(this,Tx,Fx,Px)
            this.MapTimeVector=Tx;
            this.MapFrequencyVector=Fx;
            this.MapPower=Px;
        end



        function updateMapAndColorbarAxes(this)



            Tx=this.MapTimeVector;
            Fx=this.MapFrequencyVector;
            Px=this.MapPower;


            infIdx=find(isinf(Px(:)));
            if~isempty(infIdx)
                Px(infIdx)=Inf;
                minVal=min(Px(:));
                Px(infIdx)=minVal;
            end


            set(this.MapImageHandle,'XData',Tx,'YData',Fx,'CData',Px);


            this.MapAxesHandle.View=[0,90];


            mapAxesXLim=[min(Tx),max(Tx)];
            mapAxesYLim=[0,max(Fx)];
            set(this.MapAxesHandle,'XLim',mapAxesXLim,...
            'YLim',mapAxesYLim);



            this.updateCrosshairXLine();

            this.setDirty(false);
        end

        function updateMapAxesUnits(this)

            xt=get(this.MapAxesHandle,'XTick');
            [cs,eu]=convert2engstrs(xt,'time');
            set(this.MapAxesHandle,'XTickLabel',cs);
            if strcmpi(eu,'secs')
                eu='s';
            end
            set(get(this.MapAxesHandle,'XLabel'),...
            'String',[getString(message('signal:rpmtrack:timeLbl')),' (',eu,')']);


            yt=get(this.MapAxesHandle,'YTick');
            [cs,eu]=convert2engstrs(yt);
            set(this.MapAxesHandle,'YTickLabel',cs);
            set(get(this.MapAxesHandle,'YLabel'),...
            'String',[getString(message('signal:rpmtrack:freqLbl')),' (',eu,'Hz)']);
        end




        function updateRPMAxesAndRidgeLine(this)
            rpmEst=this.EstimatedRPM;
            if~isempty(rpmEst)


                rpmAxesYLim=[0.9*min(rpmEst),1.1*max(rpmEst)];


                order=str2double(this.OrderEditField.Value);
                set(this.RidgeLineHandle,'XData',this.OutputTimeVector,...
                'YData',this.EstimatedRPM*order/60);


                this.ExportButton.Enabled=true;
                this.EstimateButton.Enabled=false;


                this.IsRPMAxesCleared=false;
            else

                rpmAxesYLim=this.RPMAxesYLimDefault;
                this.ExportButton.Enabled=false;
                this.IsRPMAxesCleared=true;
            end


            set(this.RPMLineHandle,'XData',this.OutputTimeVector,...
            'YData',rpmEst);
            set(this.RPMAxesHandle,'XLim',this.RPMAxesXLim,...
            'YLim',rpmAxesYLim);


            this.updateRPMAxesUnits();

            this.setDirty(false);
        end

        function clearRPMAxesAndRidgeLine(this)
            if~this.IsRPMAxesCleared

                this.EstimatedRPM=[];
                this.OutputTimeVector=[];
                set(this.RidgeLineHandle,'XData',[],'YData',[]);


                set(this.RPMLineHandle,'XData',[],'YData',[]);
                set(this.RPMAxesHandle,'XLim',this.RPMAxesXLim,...
                'YLim',this.RPMAxesYLimDefault);
                yt=get(this.RPMAxesHandle,'YTick');
                cs=convert2engstrs(yt);
                set(this.RPMAxesHandle,'YTickLabel',cs);
                set(get(this.RPMAxesHandle,'YLabel'),'String',...
                getString(message('signal:rpmtrack:rpmPltYLbl')));


                this.updateRPMAxesUnits();


                this.setEstimateButtonEnable();




                this.ExportButton.Enabled=false;

                this.IsRPMAxesCleared=true;
            end
        end

        function setToolgroupWaiting(this,isWaiting)

            this.TrackerAppContainer.Busy=isWaiting;
        end

        function updateCrosshairReadout(this)

            t=this.CrosshairCoordinate.X;
            [tVal,~,tUnit]=engunits(t,'latex','time');
            if strcmp(tUnit,'secs')
                tUnit='s';
            elseif strcmpi(tUnit,'\mus')
                tUnit=sprintf([char(956),'s']);
            end
            timeReadoutText=[getString(message('signal:rpmtrack:timeLbl')),' = ',...
            sprintf('%.3f',tVal),' ',tUnit];


            f=this.CrosshairCoordinate.Y;
            [fVal,~,fUnit]=engunits(f,'latex');
            if strcmpi(fUnit,'\mu')
                fUnit=char(956);
            end
            frequencyReadoutText=['    ',getString(message('signal:rpmtrack:freqLbl')),' = ',...
            sprintf('%.3f',fVal),' ',fUnit,'Hz'];


            pVal=this.getPowerValue();
            powerReadoutText=['    ',getString(message('signal:rpmtrack:powerLbl')),' = ',...
            sprintf('%.3f',pVal),' dB'];

            readoutText=[getString(message('signal:rpmtrack:crosshairCoordinateLbl')),': ',...
            timeReadoutText,...
            frequencyReadoutText,...
            powerReadoutText];
            this.setStatusTextAndIcon(readoutText,[],'east')
        end

        function bringVerticalCrosshairIntoActiveRegion(this)






            st=str2double(this.StartTimeEditField.Value);
            st=this.convertStartEndTimeValueToSec(st);
            et=str2double(this.EndTimeEditField.Value);
            et=this.convertStartEndTimeValueToSec(et);
            mapAxesXLim=get(this.MapAxesHandle,'XLim');
            xLim=[max(mapAxesXLim(1),st),min(mapAxesXLim(2),et)];

            xPos=[];
            if((this.CrosshairCoordinate.X<xLim(1))||...
                (this.CrosshairCoordinate.X>xLim(2)))
                xPos=mean(xLim);
            end


            this.setCrosshair(xPos);
        end


        function setDirty(this,dirtyflag)
            if this.IsDirty==dirtyflag
                return;
            elseif dirtyflag
                this.IsDirty=true;
            elseif~dirtyflag
                this.IsDirty=false;
            end
        end

        function setEstimateButtonEnabled(this,isEnabled)
            this.EstimateButton.Enabled=isEnabled;
        end

        function setExportButtonEnabled(this,isEnabled)
            this.ExportButton.Enabled=isEnabled;
        end
    end

    methods(Hidden)
        function updateRPMAxesUnits(this)

            xt=get(this.RPMAxesHandle,'XTick');
            [cs,eu]=convert2engstrs(xt,'time');
            set(this.RPMAxesHandle,'XTickLabel',cs);
            if strcmpi(eu,'secs')
                eu='s';
            end
            set(get(this.RPMAxesHandle,'XLabel'),...
            'String',[getString(message('signal:rpmtrack:timeLbl')),' (',eu,')']);


            yt=get(this.RPMAxesHandle,'YTick');
            [cs,eu]=convert2engstrs(yt);
            set(this.RPMAxesHandle,'YTickLabel',cs);
            m=getMultiplier(eu);
            if~isempty(m)
                set(get(this.RPMAxesHandle,'YLabel'),'String',...
                [getString(message('signal:rpmtrack:rpmPltYLbl')),' (',m,')']);
            end
        end


        function createHelpTextOrderPointUnspecified(this)





            drawnow limitrate nocallbacks;


            order=this.OrderEditField.Value;
            ridgePntIdx=this.getIndexRidgePointInActiveRegion();


            if isempty(order)&&isempty(ridgePntIdx)
                helpTextStr=getString(message('signal:rpmtrack:hlpTxtNoOrderNoPoint'));
            elseif isempty(order)&&~isempty(ridgePntIdx)
                helpTextStr=getString(message('signal:rpmtrack:hlpTxtNoOrder'));
            elseif~isempty(order)&&isempty(ridgePntIdx)
                helpTextStr=getString(message('signal:rpmtrack:hlpTxtNoPoint'));
            else
                this.HelpTextHandle.Visible='off';
                return
            end

            this.HelpTextHandle.Visible='off';


            tmp=text(this.RPMAxesHandle,0.1,0.1,helpTextStr,...
            'FontSize',this.HelpTextFontSize,...
            'Visible','off');
            wText=tmp.Extent(3);
            hText=tmp.Extent(4);
            delete(tmp);


            xAxisCenter=this.RPMAxesXLim(1)+diff(this.RPMAxesXLim)/2;
            yAxisCenter=this.RPMAxesYLimDefault(1)+...
            diff(this.RPMAxesYLimDefault)/2;


            textPosition=get(this.HelpTextHandle,'Position');
            textExtent=get(this.HelpTextHandle,'Extent');
            xText=xAxisCenter-wText/2;
            yText=yAxisCenter-hText/2+textPosition(2)-textExtent(2);


            set(this.HelpTextHandle,'String',helpTextStr,...
            'FontSize',16,...
            'Position',[xText,yText],...
            'Visible','on');
        end






        function plotRidgePoint(this,xValueToPlot,yValueToPlot)

            for np=1:length(xValueToPlot)

                this.RidgePointLineHandle(end+1)=...
                line(...
                'Parent',this.MapAxesHandle,...
                'XData',xValueToPlot(np),...
                'YData',yValueToPlot(np),...
                'LineStyle','none',...
                'Marker','o',...
                'MarkerFaceColor',[0,0,0],...
                'MarkerEdgeColor',[0,0,0],...
                'Tag','rpmtrackerRidgePointLineTag');


                this.installRidgePointContextMenu(...
                this.RidgePointLineHandle(end));
            end
        end

        function addRidgePoint(this,~,~,fromWhere)




            xValueToPlot=[];
            yValueToPlot=[];

            switch fromWhere
            case 'fromFunctionCall'

                if size(this.Opts.Points,1)
                    xValueToPlot=this.Opts.Points(:,1);
                    yValueToPlot=this.Opts.Points(:,2);
                end

            case{'fromDoubleClick','fromAddButton'}

                crosshairX=this.CrosshairCoordinate.X;
                crosshairY=this.CrosshairCoordinate.Y;

                pointX=[];

                if~isempty(this.RidgePointLineHandle)

                    pointX=[this.RidgePointLineHandle(:).XData];
                end



                if(length(pointX)+1>this.Opts.DataLength)

                    this.StatusText=...
                    getString(message('signal:rpmtrack:TooManyUniquePoints'));
                    this.setStatusTextAndIcon(this.StatusText,...
                    'warn','west')
                elseif any(pointX==crosshairX)


                    this.StatusText=...
                    getString(message('signal:rpmtrack:NotUniqueTimeValueRidgePoint'));
                    this.setStatusTextAndIcon(this.StatusText,...
                    'warn','west');
                else
                    xValueToPlot=crosshairX;
                    yValueToPlot=crosshairY;
                end
            end

            if~isempty(xValueToPlot)

                this.plotRidgePoint(xValueToPlot,yValueToPlot);


                this.setEstimateButtonEnable();


                if~this.DeleteAllRidgePointButton.Enabled
                    this.DeleteAllRidgePointButton.Enabled=true;
                end



                this.clearRPMAxesAndRidgeLine();



                this.createHelpTextOrderPointUnspecified();
            end
        end

        function OnRidgePointContextMenuOpen(this,~,~)




            this.SelectedRidgePointIndexForContextMenu=this.SelectedRidgePointIndex;
        end

        function deleteARidgePoint(this,src,~)




            if isa(src,'matlab.ui.container.Menu')&&strcmp(src.Tag,'deleteCurrentTag')
                selRidgePntIdx=this.SelectedRidgePointIndexForContextMenu;
            else
                selRidgePntIdx=this.SelectedRidgePointIndex;
            end
            if isempty(selRidgePntIdx)
                return;
            end


            this.RidgePointLineHandle(selRidgePntIdx).XData=[];
            this.RidgePointLineHandle(selRidgePntIdx).YData=[];


            delete(this.RidgePointLineHandle(selRidgePntIdx).UIContextMenu)
            delete(this.RidgePointLineHandle(selRidgePntIdx));
            this.RidgePointLineHandle(selRidgePntIdx)=[];


            this.SelectedRidgePointIndex=[];

            drawnow limitrate nocallbacks


            this.isCursorOverAny();
            this.wbmotionGeneral();


            if isempty(this.RidgePointLineHandle)
                this.DeleteAllRidgePointButton.Enabled=false;
            end


            this.setEstimateButtonEnable();


            this.clearRPMAxesAndRidgeLine();


            this.createHelpTextOrderPointUnspecified();
        end

        function deleteAllRidgePoint(this,~,~)



            set(this.RidgePointLineHandle,'XData',[],'YData',[]);
            for np=1:numel(this.RidgePointLineHandle)
                delete(this.RidgePointLineHandle(np).UIContextMenu);
                delete(this.RidgePointLineHandle(np));
            end

            this.RidgePointLineHandle=gobjects(0);
            this.SelectedRidgePointIndex=[];


            this.DeleteAllRidgePointButton.Enabled=false;
            this.EstimateButton.Enabled=false;


            this.clearRPMAxesAndRidgeLine();


            this.createHelpTextOrderPointUnspecified();
        end

        function ridgeIdx=getIndexRidgePointInActiveRegion(this)
            ridgeIdx=[];
            if~isempty(this.RidgePointLineHandle)

                st=str2double(this.StartTimeEditField.Value);
                st=this.convertStartEndTimeValueToSec(st);
                et=str2double(this.EndTimeEditField.Value);
                et=this.convertStartEndTimeValueToSec(et);


                pointX=[this.RidgePointLineHandle(:).XData];


                ridgeIdx=find(((pointX>=st)&(pointX<=et)));
            end
        end




        function updateCrosshairCoordinate(this)
            mapAxesXLim=this.MapAxesHandle.XLim;
            mapAxesYLim=this.MapAxesHandle.YLim;
            x=mean(mapAxesXLim);
            y=mean(mapAxesYLim);


            set(this.CrosshairXLineHandle,'XData',mapAxesXLim,...
            'YData',[y,y]);
            set(this.CrosshairYLineHandle,'XData',[x,x],...
            'YData',mapAxesYLim);
            this.CrosshairCoordinate.X=x;
            this.CrosshairCoordinate.Y=y;
        end

        function updateCrosshairXLine(this)





            mapAxesXLim=this.MapAxesHandle.XLim;
            vCrosshairXData=this.CrosshairXLineHandle.XData;
            if any(mapAxesXLim~=vCrosshairXData)
                this.CrosshairXLineHandle.XData=mapAxesXLim;
            end
        end

        function setCrosshair(this,x,y)



            if isempty(x)
                x=this.CrosshairCoordinate.X;
            else
                this.CrosshairCoordinate.X=x;
            end

            if(nargin==3)
                if isempty(y)
                    y=this.CrosshairCoordinate.Y;
                else
                    this.CrosshairCoordinate.Y=y;
                end
            else
                y=this.CrosshairCoordinate.Y;
            end


            set(this.CrosshairXLineHandle,'YData',[y,y]);
            set(this.CrosshairYLineHandle,'XData',[x,x]);


            this.updateCrosshairReadout();
        end

        function isCursorOverAny(this)






            this.cursorIsOver=struct('HVCrosshair',[0,0],...
            'RidgePoint',0,...
            'StartEndTimePatch',0,...
            'MapAxes',0);


            hAxes=this.whichAxesIsCursorOver();
            if isempty(hAxes)

                return;
            end


            cp=get(hAxes,'CurrentPoint');

            cp=cp(1,1:2);


            this.cursorIsOver.MapAxes=(hAxes==this.MapAxesHandle);

            if this.cursorIsOver.MapAxes

                this.cursorIsOver.StartEndTimePatch=...
                this.isCursorOverStartEndPatch(cp);

                if~this.cursorIsOver.StartEndTimePatch

                    this.cursorIsOver.HVCrosshair=...
                    this.isCursorOverCrosshair(cp);

                    if~isempty(this.RidgePointLineHandle)&&...
                        ~any(this.cursorIsOver.HVCrosshair)&&...
                        ~this.mouseDownOnRidgePoint

                        this.cursorIsOver.RidgePoint=...
                        this.isCursorOverRidgePoint(cp);
                    else
                        this.changeColorRidgePointMarker('edge','k');
                    end
                end
            end

        end

        function ret=isCursorOverStartEndPatch(this,cp)


            st=str2double(this.StartTimeEditField.Value);
            st=this.convertStartEndTimeValueToSec(st);
            et=str2double(this.EndTimeEditField.Value);
            et=this.convertStartEndTimeValueToSec(et);
            ret=(cp(1)<st)||(cp(1)>et);
        end

        function ret=isCursorOverCrosshair(this,cp)


            crosshairXY=[this.CrosshairCoordinate.X,...
            this.CrosshairCoordinate.Y];




            distInXY=abs(crosshairXY-cp);
            xAxisRange=diff(get(this.MapAxesHandle,'XLim'));
            yAxisRange=diff(get(this.MapAxesHandle,'YLim'));
            axesRange=[xAxisRange,yAxisRange];






            ret=fliplr(distInXY*67<axesRange);
        end

        function ret=isCursorOverRidgePoint(this,cp)


            ridgePointX=[this.RidgePointLineHandle(:).XData];
            ridgePointY=[this.RidgePointLineHandle(:).YData];
            ridgePoint=[ridgePointX(:),ridgePointY(:)];

            xAxisRange=diff(get(this.MapAxesHandle,'XLim'));
            yAxisRange=diff(get(this.MapAxesHandle,'YLim'));
            axesRange=[xAxisRange,yAxisRange];





            distInXY=abs(ridgePoint-cp);


            isNear=find(all(distInXY*100<axesRange,2));

            ret=~isempty(isNear);
            this.SelectedRidgePointIndex=[];
            if ret




                dist=Inf(size(ridgePoint,1),1);
                dist(isNear)=sum(distInXY(isNear,:).^2,2);
                [~,this.SelectedRidgePointIndex]=min(dist);

            end

            this.changeColorRidgePointMarker('edge','r');
        end

        function hAxes=whichAxesIsCursorOver(this)

            mapTags={'rpmtrackerMapAxesTag',...
            'rpmtrackerMapImageTag',...
            'rpmtrackerRidgeLineTag',...
            'rpmtrackerTopOfMapAxesTag',...
            'rpmtrackerCrosshairXLineTag',...
            'rpmtrackerCrosshairYLineTag',...
            'rpmtrackerRidgePointLineTag',...
            'rpmtrackerStartTimePatchTag',...
            'rpmtrackerEndTimePatchTag'};

            obj=hittest(this.FigureHandle);
            if ishandle(obj)&&any(strcmpi(obj.Tag,mapTags))
                hAxes=this.MapAxesHandle;
            else
                hAxes=[];
            end
        end

        function changePointer(this,newPointer)

            setptr(this.FigureHandle,newPointer);
        end


        function powVal=getPowerValue(this)


            x=this.CrosshairCoordinate.X;
            y=this.CrosshairCoordinate.Y;

            powMapSize=size(this.MapPower);





            mapTimeVec=this.MapTimeVector;
            if(powMapSize(2)>1)
                dx=mapTimeVec(2)-mapTimeVec(1);
            else
                dx=0;
            end
            mapFreqVec=this.MapFrequencyVector;
            if(powMapSize(1)>1)
                dy=mapFreqVec(2)-mapFreqVec(1);
            else
                dy=0;
            end


            x=x-dx/2;
            y=y-dy/2;


            [~,i]=min(abs(x-mapTimeVec));
            if isempty(i)
                i=1;
            elseif(i>powMapSize(2))
                i=powMapSize(2);
            end
            [~,j]=min(abs(y-mapFreqVec));
            if isempty(j)
                j=1;
            elseif(j>powMapSize(1))
                j=powMapSize(1);
            end


            powVal=double(this.MapPower(j,i));
        end





        function getStartEndTimeUnitLabelAndMultiplier(this)
            xt=get(this.MapAxesHandle,'XTick');
            [~,e,u]=engunits(xt,'latex','time');
            if strcmpi(u,'secs')
                u='s';
            elseif strcmpi(u,'\mus')
                u=sprintf([char(956),'s']);
            end

            this.StartEndTimeUnitMultiplier=e;
            this.StartTimeUnitLabel.Text=u;
            this.EndTimeUnitLabel.Text=u;


            stVal=str2double(this.StartTimeEditField.Value);
            this.StartTimeEditField.Value=num2str(stVal*e);
            etVal=str2double(this.EndTimeEditField.Value);
            this.EndTimeEditField.Value=num2str(etVal*e);
        end

        function updateStartTimePatch(this)

            y0=0;
            y1=max(this.MapFrequencyVector);


            x0=min(this.Opts.TimeVector(1));
            x1=str2double(this.StartTimeEditField.Value);
            x1=this.convertStartEndTimeValueToSec(x1);


            set(this.StartTimePatchHandle,'XData',[x0,x0,x1,x1],...
            'YData',[y0,y1,y1,y0]);


            this.bringVerticalCrosshairIntoActiveRegion();
        end

        function updateEndTimePatch(this)

            y0=0;
            y1=max(this.MapFrequencyVector);


            x0=str2double(this.EndTimeEditField.Value);
            x0=this.convertStartEndTimeValueToSec(x0);
            x1=max(this.Opts.TimeVector(end));


            set(this.EndTimePatchHandle,'XData',[x0,x0,x1,x1],...
            'YData',[y0,y1,y1,y0]);


            this.bringVerticalCrosshairIntoActiveRegion();
        end


        function cval=convertStartEndTimeValueToSec(this,val)
            mult=this.StartEndTimeUnitMultiplier;
            cval=val/mult;
        end





        function installRidgePointContextMenu(this,hRidgePointLine)


            hCM=uicontextmenu('Parent',this.FigureHandle,...
            'tag','ridgePointContext');

            hCM.ContextMenuOpeningFcn=@this.OnRidgePointContextMenuOpen;


            opts={hCM,...
            [getString(message('signal:rpmtrack:cmDelCurrLbl')),' (Shift+Left Click)'],...
            'deleteCurrentTag',...
            @this.deleteARidgePoint};
            createContext(opts);

            opts={hCM,...
            getString(message('signal:rpmtrack:cmDelAllLbl')),...
            'deleteAllTag',...
            @this.deleteAllRidgePoint};
            createContext(opts);

            set(hRidgePointLine,'UIContextMenu',hCM);
            function hMenu=createContext(opts)

                args={'Parent',opts{1},...
                'Tag',opts{3},...
                'Label',opts{2},...
                'Callback',opts{4:end}};
                hMenu=uimenu(args{:});
            end
        end





        function cbMotionListener(this,es,ed)
            this.isCursorOverAny();

            if any(this.mouseDownOnCrossHair)

                crossHairArg='v';
                if all(this.mouseDownOnCrossHair)
                    crossHairArg='hv';
                elseif this.mouseDownOnCrossHair(1)
                    crossHairArg='h';
                end

                this.wbmotionCrosshair(es,ed,crossHairArg);
            elseif this.mouseDownOnRidgePoint
                this.wbdownRidgePoint()
            else
                this.wbmotionGeneral(es,ed);
            end
        end

        function cbListenerMouseDown(this,es,ed)

            this.isCursorOverAny();

            if this.isDoubleClick&&all(this.cursorIsOver.HVCrosshair)

                this.addRidgePoint(es,ed,'fromDoubleClick')
            elseif this.isShiftLeftClick()&&this.cursorIsOver.RidgePoint

                this.deleteARidgePoint([],[]);
            else

                this.mouseDownOnCrossHair=...
                this.cursorIsOver.HVCrosshair;
                this.mouseDownOnRidgePoint=...
                this.cursorIsOver.RidgePoint;
            end
        end

        function cbListenerMouseUp(this,es,ed)%#ok<INUSD>

            this.mouseDownOnCrossHair=[0,0];
            this.mouseDownOnRidgePoint=0;
            this.changeColorRidgePointMarker('face','black');

        end

        function isSuppress=panZoomFilter(this,varargin)


            isSuppress=any(this.cursorIsOver.HVCrosshair)||...
            this.cursorIsOver.RidgePoint;
        end


        function wbMotionDummy(this,varargin)%#ok<INUSD>


        end

        function wbmotionGeneral(this,es,ed)%#ok<INUSD>

            zm=zoom(this.FigureHandle,'getmode');

            this.StatusText=[];
            this.StatusbarWestIcon=[];

            if any(this.cursorIsOver.HVCrosshair)

                if all(this.cursorIsOver.HVCrosshair)

                    this.changePointer('fleur')
                    this.StatusText=getString(message(...
                    'signal:rpmtrack:overHVCrosshairStatus'));
                    this.StatusbarWestIcon='info';

                elseif this.cursorIsOver.HVCrosshair(1)

                    this.changePointer('uddrag')
                else

                    this.changePointer('lrdrag')
                end
            elseif this.cursorIsOver.RidgePoint

                this.changePointer('datacursor')
            elseif this.cursorIsOver.MapAxes&&strcmpi(zm,'off')

                this.changePointer('arrow');
            end

            this.setStatusTextAndIcon(...
            this.StatusText,...
            this.StatusbarWestIcon,'west');
        end

        function wbmotionCrosshair(this,~,~,sel)





            cp=get(this.MapAxesHandle,'CurrentPoint');

            if(cp(1,2)<0)

                return;
            end

            x=cp(1,1);
            y=cp(1,2);

            switch sel
            case 'h'
                x=this.CrosshairCoordinate.X;
            case 'v'
                y=this.CrosshairCoordinate.Y;
            end


            if any(sel=='v')
                x=this.constrainToMapAxisLim(x,'x');
            end
            if any(sel=='h')
                y=this.constrainToMapAxisLim(y,'y');
            end

            this.setCrosshair(x,y);
        end

        function wbmotionRidgePoint(this,~,~)




            selRidgePntIdx=this.SelectedRidgePointIndex;
            if isempty(selRidgePntIdx)
                return;
            end


            cp=get(this.MapAxesHandle,'CurrentPoint');

            if cp(1,2)<0

                return;
            end


            x=cp(1,1);
            y=cp(1,2);



            x=this.constrainToMapAxisLim(x,'x');
            y=this.constrainToMapAxisLim(y,'y');


            this.setCrosshair(x,y);








            oldX=this.RidgePointLineHandle(selRidgePntIdx).XData;
            oldY=this.RidgePointLineHandle(selRidgePntIdx).YData;


            this.RidgePointLineHandle(selRidgePntIdx).XData=x;
            this.RidgePointLineHandle(selRidgePntIdx).YData=y;



            distInX=abs(x-oldX);
            distInY=abs(y-oldY);



            if(((distInX)||(distInY)))
                this.EstimateButton.Enabled=true;
                this.clearRPMAxesAndRidgeLine();
            end



            drawnow limitrate nocallbacks
        end

        function wbdownRidgePoint(this,~,~)


            if this.isShiftLeftClick()

                this.deleteARidgePoint([],[]);

            elseif this.isLeftClick()


                this.changeColorRidgePointMarker('face','red');

                this.wbmotionRidgePoint();
            end
        end


        function b=isLeftClick(this)






            b=strcmpi(this.FigureHandle.SelectionType,'normal');
        end

        function b=isDoubleClick(this)
            b=strcmpi(this.FigureHandle.SelectionType,'open');
        end

        function b=isRightClick(this)
            b=strcmpi(this.FigureHandle.SelectionType,'alt');
        end

        function b=isShiftLeftClick(this)
            b=strcmpi(this.FigureHandle.SelectionType,'extend');
        end

        function aOut=constrainToMapAxisLim(this,aIn,axis)





            switch axis
            case 'x'
                st=str2double(this.StartTimeEditField.Value);
                st=this.convertStartEndTimeValueToSec(st);
                et=str2double(this.EndTimeEditField.Value);
                et=this.convertStartEndTimeValueToSec(et);
                mapAxisXLim=get(this.MapAxesHandle,'XLim');
                xLim=[max(mapAxisXLim(1),st),min(mapAxisXLim(2),et)];
                if(aIn<xLim(1))
                    aOut=xLim(1);
                elseif(aIn>xLim(2))
                    aOut=xLim(2);
                else
                    aOut=aIn;
                end
            case 'y'
                yLim=get(this.MapAxesHandle,'YLim');
                if(aIn<yLim(1))
                    aOut=yLim(1);
                elseif(aIn>yLim(2))
                    aOut=yLim(2);
                else
                    aOut=aIn;
                end
            end
        end

        function changeColorRidgePointMarker(this,sel,col)




            if isempty(this.RidgePointLineHandle)

                return;
            end

            selRidgePntIdx=this.SelectedRidgePointIndex;
            if isempty(selRidgePntIdx)


                set(this.RidgePointLineHandle,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','k');
            else
                switch sel
                case 'edge'
                    set(this.RidgePointLineHandle(selRidgePntIdx),...
                    'MarkerEdgeColor',col);
                case 'face'
                    set(this.RidgePointLineHandle(selRidgePntIdx),...
                    'MarkerFaceColor',col);
                case 'both'
                    set(this.RidgePointLineHandle(selRidgePntIdx),...
                    'MarkerEdgeColor',col,...
                    'MarkerFaceColor',col);
                end
            end
        end

        function bringHorizontalCrosshairIntoPanRegion(this)



            mapAxesYLim=get(this.MapAxesHandle,'YLim');

            y=[];
            if((this.CrosshairCoordinate.Y<mapAxesYLim(1))||...
                (this.CrosshairCoordinate.Y>mapAxesYLim(2)))
                y=mean(mapAxesYLim);
            end


            this.setCrosshair([],y);
        end




        function fullView(this,~,~)

            mapXdata=get(this.MapImageHandle,'XData');
            newXlim=[min(mapXdata),max(mapXdata)];
            set(this.MapAxesHandle,'XLim',newXlim);

            mapYdata=get(this.MapImageHandle,'YData');
            newYlim=[min(mapYdata),max(mapYdata)];
            set(this.MapAxesHandle,'YLim',newYlim);

            this.updateMapAxesUnits();
        end




        function resizeFigure(this,~,~)


            this.createHelpTextOrderPointUnspecified();





            this.updateMapAxesUnits();
            this.updateRPMAxesUnits();
        end

        function setupListeners(this)


            this.MotionListener=addlistener(...
            this.FigureHandle,...
            'WindowMouseMotion',...
            @(es,ed)this.cbMotionListener(es,ed));

            this.MouseDownListener=addlistener(...
            this.FigureHandle,...
            'WindowMousePress',...
            @(es,ed)this.cbListenerMouseDown(es,ed));

            this.MouseUpListener=addlistener(...
            this.FigureHandle,...
            'WindowMouseRelease',...
            @(es,ed)this.cbListenerMouseUp(es,ed));


            this.FigureHandle.WindowButtonMotionFcn=@this.wbMotionDummy;
        end

        function varargout=cbCurrentMode(this,~,evtData)
            sel=evtData.Selection;


            if~isempty(sel)
                if strcmp(sel.Value,'on')



                    hz=zoom(this.FigureHandle);
                    hz.ActionPostCallback=@(es,ed)resizeFigure(this,es,ed);
                    hz.ButtonDownFilter=@this.panZoomFilter;
                    varargout{1}=hz;
                    if strcmp(sel.Tag,'zoomin')

                        this.StatusText=getString(message(...
                        'signal:rpmtrack:zoomDragStatus'));
                    else

                        this.StatusText=getString(message(...
                        'signal:rpmtrack:zoomOutStatus'));
                    end
                    this.StatusbarWestIcon='info';
                else

                end
            else

            end
        end
    end
end




function multStr=getMultiplier(units)
    if isempty(units)
        multStr='';
        return;
    end
    switch units
    case 'y'
        multStr='\times 1e-24';
    case 'z'
        multStr='\times 1e-21';
    case 'a'
        multStr='\times 1e-18';
    case 'f'
        multStr='\times 1e-15';
    case 'p'
        multStr='\times 1e-12';
    case 'n'
        multStr='\times 1e-9';
    case '\mu'
        multStr='\times 1e-6';
    case 'm'
        multStr='\times 1e-3';
    case 'k'
        multStr='\times 1e3';
    case 'M'
        multStr='\times 1e6';
    case 'G'
        multStr='\times 1e9';
    case 'T'
        multStr='\times 1e12';
    case 'P'
        multStr='\times 1e15';
    case 'E'
        multStr='\times 1e18';
    case 'Z'
        multStr='\times 1e21';
    case 'Y'
        multStr='\times 1e24';
    end
end
