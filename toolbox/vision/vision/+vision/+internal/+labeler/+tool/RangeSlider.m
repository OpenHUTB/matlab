





























































classdef RangeSlider<handle
    properties(Access=private)
        FigHandle;
        SliderPanel;
        TimePanel;
        Xoffset;
        XposImagePanel;
        ScrubberPanel;
        ScrubberPos;

        BtnRelListner4Scrubber=[];
        BtnRelListner4LeftRightFlag=[];
        BtnDwnlListner4Scrubber=[];
        BtnDwnlListner4LeftFlag=[];
        BtnDwnlListner4RightFlag=[];

        BtnDwnlListner4LeftHLine=[];
        BtnDwnlListner4MiddleHLine=[];


        LeftFlagPanel;
        LeftPolePanel;


        RightFlagPanel;
        RightPolePanel;


        FullHLinePanel;
        LeftHLinePanel;
        MiddleHLinePanel;
        RightHLinePanel;


        HasHour;
        HasMin;
        StartEBHandle;
        EndEBHandle;
        CurrentEBHandle;

        StartEBPanelHandle;
        EndEBPanelHandle;
        CurrentEBPanelHandle;


        DurationPanel;

        OrigPointerForBtn;
        OrigPointerForFig;


KeyPressCallback


PlayBackAndRangeSliderBtnHandle


        SnapUnsnapBtnHandle;
        PlayBackSection=struct('FirstFrameBtnHandle',[],...
        'PreviousFrameBtnHandle',[],...
        'PlayPauseBtnHandle',[],...
        'NextFrameBtnHandle',[],...
        'LastFrameBtnHandle',[]);

        FullHLineLength;
        CharWidthInPixels;
        CharHeightInPixels;

        OrigFigUnits;
        IsSnapMode=false;

        IsScrubberBtnUpCalled=false;
        IsScrubberBtnDown=false;
        IsLeftOrRightFlagBtnDown=false;

        IsSnapModeBeforeFreeze;

        IsFlagEnabledB4FreezePlayMode=true;
        IsFlagEnabledB4FreezeOtherMode=true;
        IsStEnEBEnabledB4FreezePlayMode=true;
        IsStEnEBEnabledB4FreezeOtherMode=true;
        IsSUBtnEnabledB4FreezePlayMode=false;
        IsSUBtnEnabledB4FreezeOtherMode=false;

        minStartXforPlaybackPanel;
        PlaybackPanelWidth;
        SnapUnsnapBtnWidth;
        PlaybackPanelHandle;

        IsPauseHit=false;
        IsInPlayModeFreeze=false;


        FLAG_BGCOLOR_ENABLE=[0.7020,0,0];
        FLAG_BGCOLOR_DRAGGED=[1,0.61,0];
        FLAG_BGCOLOR_DISBALE=[0.65,0.65,0.65];

        SCRUBBER_BGCOLOR_ENABLE=[0.9608,0.9608,0.9608];
        SCRUBBER_BGCOLOR_DRAGGED=[1,0.61,0];
        SCRUBBER_BGCOLOR_DISABLE=[0.65,0.65,0.65];

        DEFAULT_BGCOLOR=[0.9412,0.9412,0.9412];

        TIME_EB_BGCOLOR_ENABLE=[1,1,1];
        TIME_EB_BGCOLOR_DISABLE=[0.9216,0.9216,0.9216];


        START_EB_ID=1;
        CURRENT_EB_ID=2;
        END_EB_ID=3;

        HOUR_EB_ID=1;
        MIN_EB_ID=2;
        SEC_EB_ID=3;


        LEFT_FLAG_REGULAR_POS=0;
        LEFT_FLAG_EXTEREME_LEFT=1;
        LEFT_FLAG_AT_SCRUBBER_MIDX=2;

        RIGHT_FLAG_REGULAR_POS=0;
        RIGHT_FLAG_EXTEREME_RIGHT=1;
        RIGHT_FLAG_AT_SCRUBBER_MIDX=2;

        SCRUBBER_REGULAR_POS=0;
        SCRUBBER_EXTEREME_LEFT=1;
        SCRUBBER_EXTEREME_RIGHT=2;

        ICON_PATH=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool');
        SETTING_ICON_PATH=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool');

        TEST_MODE=false;
    end
    properties



        VideoStartTime;




        VideoEndTime;




TimeVector




        ScrubberCurrentTime;




        IntervalStartTime;




        IntervalEndTime;



        CurrentTimeUpdateDone=false;





        IsSelectiveFreeze=false;



        TimeNow;



        DrawInteractive;



IsDoingSnap



IsVideoPaused

    end

    properties(Access=public)

        MasterSignal=[];
PrevSetupSelectionInAutomation
    end

    properties(Access=private)


SignalData


ShowSettingButton


LastReadIndex

LastQueryTimestamp

TempTimeVector

PrevSetupSelection
CurrentTimeBeforeAutomation
EndTimeBeforeAutomation
StartTimeBeforeAutomation
    end

    properties(Access=private)

PlayBackAndRangeSliderSetUpDialogFig
PlayBackAndRangeSliderSetUpFigPos

PlayBackControlsPanel
PlayBackControlsPanelPos

PlaybackControlsText
PlaybackControlsTextPos

PlayBackControlsPanelText
PlayBackControlsPanelTextPos

SignalInfoPanel
SignalInfoPanelPos

SignalInfoPanelText
SignalInfoPanelTextPos

SignalInfoText
SignalInfoTextPos

RangeSliderInfoText
RangeSliderInfoTextPos

AllSignalsInfoText
AllSignalsInfoTextPos

MinTimeStampText
MinTimeStampTextPos

MinTimeStampEdit
MinTimeStampEditPos

MaxTimeStampText
MaxTimeStampTextPos

MaxTimeStampEdit
MaxTimeStampEditPos

TimeStampsPushButton
TimeStampsPushButtonPos

MasterSignalText
MasterSignalTextPos

FrameRateText
FrameRateTextPos

FrameRateEdit
FrameRateEditPos

MinTimeForAllTextPos
MinTimeForAllEditPos

MaxTimeForAllTextPos
MaxTimeForAllEditPos

MinTimeForAllEdit
MinTimeForAllText

MaxTimeForAllEdit
MaxTimeForAllText

AllTimeStampsText
AllTimeStampsTextPos

TimeStampsFromWorkSpaceText
TimeStampsFromWorkSpaceTextPos

SignalNamesPopup
SignalNamesPopupPos

OKButtonPos
CancelButtonPos

OKButton
CancelButton

PlayBackAndRangeSliderSetupPos

        InAutomation=false;

        VideoStartTimeBeforeAutomation;
        VideoEndTimeBeforeAutomation;

    end

    properties(Constant)

        LoadingDlgWidth=500;
        LoadingDlgHeight=480;

        OKCancelButtonY=5;
        OKCancelButtonHeight=25;
        OKCancelButtonWidth=45;

        HeightPadding=100;
        WidthPadding=5;

        TextHeight=25;
        TextWidth=100;

        LeftPadding=5;
        RightPadding=280;

        RangeSliderInfoYPadding=190;
    end

    properties(GetAccess=public,SetAccess=private)
        CaughtExceptionDuringPlay=false;
    end

    events

ScrubberPressed


ScrubberMoved


ScrubberReleased


CurrentTimeChanged


UpdateValue


FirstFrameRequested


LastFrameRequested


PrevFrameRequested


NextFrameRequested


PlayInit


PlayLoop


PlayEnd




FrameChangeEvent


StartOrEndTimeUpdated


MasterSignalChanged
    end
    methods

        function obj=RangeSlider(containerObj,signalData,showSettingButton)


            retrieveParamsFromObject(obj,containerObj);
            obj.ShowSettingButton=showSettingButton;
            setDefaultMasterSignal(obj,signalData);


            hasHourMin(obj);
            charToPixel(obj);
            getFigUnits(obj);


            createSliderLayout(obj);
            createTimeLayout(obj);
            setStartTime(obj);
            setCurrentTime(obj);
            setEndTime(obj);
            setDuration(obj);


            addBtnDwnlListner4Scrubber(obj);
            addBtnDwnlListner4LeftRightFlags(obj);

            addBtnDwnlListner4LeftHLine(obj);
            addBtnDwnlListner4MiddleHLine(obj);

            setSnapUnsnapBtnCallback(obj);
            drawnow;
        end


        function val=get.ScrubberCurrentTime(this)

            val=getSliderCurrentTime(this);
        end


        function val=get.IntervalStartTime(this)

            val=getSliderStartTime(this);
        end


        function val=get.IntervalEndTime(this)

            val=getSliderEndTime(this);
        end


        function enableRangeSliderSetting(this)
            this.PlayBackAndRangeSliderBtnHandle.Enable='on';
        end


        function disableRangeSliderSetting(this)
            this.PlayBackAndRangeSliderBtnHandle.Enable='off';
            set(this.SnapUnsnapBtnHandle,'enable','off');
            set(this.SnapUnsnapBtnHandle,'Value',0);
        end


        function setSignalNamesPopupInAutomation(obj,signalNames,timeVector,algorithmConfiguration)
            obj.InAutomation=true;

            [validSignalNames,validTimeVectors]=setSignalNamesInPopup(obj,signalNames,...
            algorithmConfiguration);


            obj.SignalData.SignalName=validSignalNames;
            obj.SignalData.TimeVectors=validTimeVectors;
            settings=getRangeSliderTimeSettings(obj);


            idx=find(obj.MasterSignal==validSignalNames);
            if(~isempty(settings.RadioButtonSelection))
                if(settings.RadioButtonSelection(1)&&~isempty(idx))
                    obj.MasterSignal=validSignalNames(idx);
                else
                    obj.MasterSignal=validSignalNames(1);
                end
            else
                obj.MasterSignal=validSignalNames(1);
            end
            obj.PrevSetupSelectionInAutomation=[0,1];




            obj.VideoStartTimeBeforeAutomation=obj.VideoStartTime;
            obj.VideoEndTimeBeforeAutomation=obj.VideoEndTime;
            obj.CurrentTimeBeforeAutomation=obj.ScrubberCurrentTime;
            obj.StartTimeBeforeAutomation=obj.IntervalStartTime;
            obj.EndTimeBeforeAutomation=obj.IntervalEndTime;


            obj.TimeVector=timeVector;
            if(~isequal(r4(obj.IntervalEndTime),r4(obj.VideoEndTime))...
                &&r4(obj.VideoEndTime)<r4(obj.IntervalEndTime))
                updateRangeSliderForAutomation(obj,obj.IntervalStartTime,obj.VideoEndTime);
            else
                updateRangeSliderForAutomation(obj,obj.IntervalStartTime,obj.IntervalEndTime);
            end


            if(r4(obj.VideoEndTime)>r4(obj.IntervalEndTime))
                obj.SnapUnsnapBtnHandle.Value=1;
                if(obj.SnapUnsnapBtnHandle.Value)
                    snapUnsnapCallback(obj,[],[]);
                    obj.SnapUnsnapBtnHandle.Value=0;
                end
            end


            setDurationPlaybackInAutomation(obj);
            disableLeftRightFlags(obj);
            currentETstart=areCurrentAndStartTimeSame(obj);
            if(currentETstart)
                disableLeftPBButtons(obj);
            end
        end


        function[validSignalNames,validTimeVectors]=setSignalNamesInPopup(obj,signalNames,algorithmConfiguration)
            validSignalNames=cell(numel(signalNames),1);
            validTimeVectors=cell(numel(signalNames),1);
            isAlgoForward=algorithmConfiguration.AutomateForward;
            isAlgoStartAtCurrentTime=algorithmConfiguration.StartAtCurrentTime;
            for idx=1:numel(signalNames)
                signalIdx=find(ismember(obj.SignalData.SignalName,signalNames(idx)));
                timeVector_i=seconds(obj.SignalData.TimeVectors{signalIdx});
                if numel(timeVector_i)>1
                    frameRate=(timeVector_i(2)-timeVector_i(1));
                else
                    frameRate=1;
                end
                tEnd=timeVector_i(end)+frameRate;

                tf=isSignalValidForMasterSignalPopup(obj,tEnd,isAlgoForward,isAlgoStartAtCurrentTime);
                if(tf)
                    validSignalNames{idx}=obj.SignalData.SignalName(signalIdx);
                    validTimeVectors(idx)=obj.SignalData.TimeVectors(signalIdx);
                end

            end
            validSignalNames=string(validSignalNames(~cellfun('isempty',validSignalNames)));
            validTimeVectors=validTimeVectors(~cellfun('isempty',validTimeVectors));
        end


        function tf=isSignalValidForMasterSignalPopup(obj,tEnd,isAlgoForward,isAlgoStartAtCurrentTime)
            if(isAlgoForward)
                if(isAlgoStartAtCurrentTime)

                    tf=(tEnd<=obj.IntervalEndTime||...
                    tEnd>=obj.IntervalEndTime)&&...
                    obj.ScrubberCurrentTime<=tEnd&&...
                    tEnd>=obj.IntervalStartTime;
                else

                    tf=obj.IntervalStartTime<=tEnd...
                    &&(tEnd>=obj.IntervalEndTime...
                    ||tEnd<=obj.IntervalEndTime);
                end
            else
                if(isAlgoStartAtCurrentTime)

                    tf=(tEnd<=obj.IntervalEndTime||...
                    tEnd>=obj.IntervalEndTime)&&...
                    tEnd>=obj.IntervalStartTime;
                else

                    tf=(tEnd<=obj.IntervalEndTime||...
                    tEnd>=obj.IntervalEndTime)...
                    &&obj.IntervalStartTime<=tEnd;
                end
            end
        end


        function setDurationPlaybackInAutomation(obj)

            setDuration(obj,obj.IntervalEndTime);
            currentETend=areCurrentAndEndTimeSame(obj);
            currentETstart=areCurrentAndStartTimeSame(obj);
            if(~currentETend&&~currentETstart)
                updatePlayBackControlState(obj);
            end


            set(obj.SnapUnsnapBtnHandle,'enable','off');
            set(obj.SnapUnsnapBtnHandle,'Value',0);
        end


        function resetSignalPopupOutsideAutomation(obj,signalData,masterSignal,timeVector)
            obj.SignalData.SignalName=signalData.SignalName;
            obj.SignalData.TimeVectors=signalData.TimeVectors;
            obj.MasterSignal=masterSignal;
            obj.InAutomation=false;


            settings=getRangeSliderTimeSettings(obj);
            if(~isempty(settings.RadioButtonSelection))
                if(settings.RadioButtonSelection(1))
                    idx=obj.SignalData.SignalName==masterSignal;
                    obj.TimeVector=seconds(signalData.TimeVectors{idx});
                else
                    obj.TimeVector=timeVector;
                end
            else
                idx=obj.SignalData.SignalName==masterSignal;
                obj.TimeVector=seconds(signalData.TimeVectors{idx});
            end


            updateRangeSliderForAutomation(obj,obj.VideoStartTime,obj.VideoEndTime);
            obj.SnapUnsnapBtnHandle.Value=0;
            snapUnsnapCallback(obj,[],[]);
            setDuration(obj);
            updateSliderCurrentTime(obj);
        end


        function exceptionDuringPlayListener(this,varargin)
            this.CaughtExceptionDuringPlay=true;
        end


        function resetExceptionDuringPlay(this)
            this.CaughtExceptionDuringPlay=false;
        end


        function notifyFrameChangeEvent(this)
            notify(this,'FrameChangeEvent');


        end


        function resizeSliderPanelForFig(obj,newContainerW)
            wFull=newContainerW;
            fullHLine_w=wFull-2*obj.Xoffset;

            obj.FullHLineLength=max(fullHLine_w,1);

            resizeFullHLine(obj);
            if obj.IsSnapMode
                moveBackFlagsScrubberHLinesInSnapMode(obj);
            else
                moveBackFlagsScrubberHLinesInUnsnapMode(obj);
            end
            movePlaybackButtons(obj);
            moveSnapUnsnapButton(obj);

            if(~obj.ShowSettingButton)
                movePlayBackSetUpButton(obj);
            end
        end


        function freezeInterval(obj)
            saveSnapUnsnapBtnStateBeforeFreeze(obj);
            if canChangeStateOfSnapUnsnapBtn(obj)
                if mustSwitchToSnapMode(obj)

                    obj.SnapUnsnapBtnHandle.Value=1;
                    snapUnsnapCallback(obj,[],[]);
                end
                disableSnapUnsnapBtn(obj);
            end
            saveStateAndDisableLeftRightFlags(obj);
            saveStateAndDisable2TimeEditBoxes(obj);
        end


        function freezeInteraction(obj,playbackControlState)

            if nargin>1&&~playbackControlState
                disableAllPBButtons(obj);
            end

            disableScrubber(obj);
            disableCurrentEditBox(obj);
        end


        function unfreezeInterval(obj)
            if canChangeStateOfSnapUnsnapBtn(obj)
                if mustSwitchToSnapMode(obj)

                    obj.SnapUnsnapBtnHandle.Value=0;
                    snapUnsnapCallback(obj,[],[]);
                end
                enableSnapUnsnapBtn(obj);
            end
            restoreLeftRightFlagsAtUnfreeze(obj);
            restore2TimeEditBoxesAtUnfreeze(obj);

        end


        function unfreezeInteraction(obj,playbackControlState)

            if nargin>1&&playbackControlState

                updatePlayBackControlState(obj);
            end

            enableScrubber(obj);
            enableCurrentEditBox(obj);


        end


        function updateLeftIntervalToTime(obj,startTime)

            setEBsTimeAt(obj,obj.StartEBHandle,startTime);




            if~obj.IsSnapMode
                moveLeftFlagFamilyForEditBoxTimes(obj);
            end
        end


        function updateRightIntervalToTime(obj,endTime)

            setEBsTimeAt(obj,obj.EndEBHandle,endTime);




            if~obj.IsSnapMode
                moveRightFlagFamilyForEditBoxTimes(obj);
            end
        end



        function updateLabelerCurrentTime(obj,t,drawInteractive)

            t=clipCurrentTime(obj,t);
            obj.CurrentTimeUpdateDone=false;


            updateRangeSliderAtCurrentTime(obj,t);
            obj.DrawInteractive=drawInteractive;




            notify(obj,'UpdateValue');
            obj.CurrentTimeUpdateDone=true;



            notifyFrameChangeEvent(obj);
        end


        function moveScrubberFamilyAtTime(obj,t)

            setCurrentTimeAt(obj,t);
            if obj.IsSnapMode
                moveScrubberForEditBoxTimesInSnapMode(obj);
            else
                moveScrubberForEditBoxTimesInUnSnapMode(obj);
            end
            obj.LastQueryTimestamp=t;
        end


        function updateRangeSliderForNewVideo(obj,...
            videoStartT,videoEndT)





            hasHourMin(obj);


            restoreBtnEBoxFlagStateInUnsnapMode(obj)
            deleteUIControlsInTextLayout(obj);


            createTimeLayout(obj);
            setStartTime(obj);
            setCurrentTime(obj);
            setEndTime(obj);
            setDuration(obj);


            addBtnDwnlListner4Scrubber(obj);

            addBtnDwnlListner4MiddleHLine(obj);
            addBtnDwnlListner4LeftHLine(obj);
            addBtnDwnlListner4LeftRightFlags(obj);
            setSnapUnsnapBtnCallback(obj);

            moveScrubberForEditBoxTimesInUnSnapMode(obj);

            moveLeftFlagFamilyToExtremeLeft(obj);
            moveRightFlagFamilyToExtremeRight(obj);
        end


        function updateRangeSliderAtCurrentTime(this,t)




            moveScrubberFamilyAtTime(this,t);
            updatePlayBackControlState(this);
        end


        function updateRangeSlider(obj,settings,startEndTime)

            if~isempty(settings)
                obj.MasterSignal=settings.MasterSignal;
                obj.TimeVector=settings.TimeVector;
                obj.PrevSetupSelection=settings.RadioButtonSelection;

                updateRangeSliderForNewVideo(obj,obj.VideoStartTime,obj.VideoEndTime);
            end

            startT=startEndTime(1);
            endT=startEndTime(2);

            setEBsTimeAt(obj,obj.StartEBHandle,startT);
            setEBsTimeAt(obj,obj.EndEBHandle,endT);

            moveLeftFlagFamilyForEditBoxTimes(obj);
            moveRightFlagFamilyForEditBoxTimes(obj);
        end


        function updateRangeSliderForAutomation(obj,...
            startT,endT)

            if endT<obj.VideoEndTime||startT>=obj.VideoStartTime
                enableSnapUnsnapBtn(obj);
            end

            setEBsTimeAt(obj,obj.StartEBHandle,startT);
            setEBsTimeAt(obj,obj.EndEBHandle,endT);


            addBtnDwnlListner4Scrubber(obj);

            addBtnDwnlListner4MiddleHLine(obj);
            addBtnDwnlListner4LeftHLine(obj);
            addBtnDwnlListner4LeftRightFlags(obj);
            setSnapUnsnapBtnCallback(obj);

            moveScrubberForEditBoxTimesInUnSnapMode(obj);

            moveLeftFlagFamilyToExtremeLeft(obj);
            moveRightFlagFamilyToExtremeRight(obj);

        end


        function updateRangeSliderInAutomation(obj,...
            startT,endT)

            if(obj.CurrentTimeBeforeAutomation>endT)
                setEBsTimeAt(obj,obj.CurrentEBHandle,startT);
                setEBsTimeAt(obj,obj.StartEBHandle,startT);
                setEBsTimeAt(obj,obj.EndEBHandle,endT);
                setDuration(obj,endT);
            elseif(obj.CurrentTimeBeforeAutomation<endT&&startT<obj.CurrentTimeBeforeAutomation)
                setEBsTimeAt(obj,obj.CurrentEBHandle,obj.CurrentTimeBeforeAutomation);
                setEBsTimeAt(obj,obj.StartEBHandle,startT);
                setEBsTimeAt(obj,obj.EndEBHandle,endT);
                setDuration(obj,endT);
            else
                setEBsTimeAt(obj,obj.CurrentEBHandle,obj.CurrentTimeBeforeAutomation);
                setEBsTimeAt(obj,obj.StartEBHandle,startT);
                setEBsTimeAt(obj,obj.EndEBHandle,endT);
                setDuration(obj,endT);
            end


            addBtnDwnlListner4Scrubber(obj);

            addBtnDwnlListner4MiddleHLine(obj);
            addBtnDwnlListner4LeftHLine(obj);
            addBtnDwnlListner4LeftRightFlags(obj);
            setSnapUnsnapBtnCallback(obj);

            moveLeftFlagFamilyToExtremeLeft(obj);
            moveRightFlagFamilyToExtremeRight(obj);

        end


        function[startTime,endTime]=checkValidIntervalsInAutomation(obj,masterSignalChanged)
            if(masterSignalChanged&&obj.MasterSignalText.Value)

                [startTime,endTime]=checkMasterSignalIntervals(obj);
            elseif(obj.AllTimeStampsText.Value)

                if(obj.StartTimeBeforeAutomation>=obj.VideoStartTime&&...
                    obj.EndTimeBeforeAutomation<=obj.VideoEndTime)
                    startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                    endTime=min(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
                elseif(obj.StartTimeBeforeAutomation>=obj.VideoStartTime&&...
                    obj.EndTimeBeforeAutomation>=obj.VideoEndTime)
                    startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                    endTime=max(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
                else
                    startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                    endTime=max(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
                end
            else

                startTime=obj.IntervalStartTime;
                endTime=obj.IntervalEndTime;
            end
        end


        function[startTime,endTime]=checkMasterSignalIntervals(obj)

            if((obj.StartTimeBeforeAutomation>=obj.VideoStartTime&&...
                obj.EndTimeBeforeAutomation>=obj.VideoEndTime))
                startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                endTime=min(obj.VideoEndTimeBeforeAutomation,obj.VideoEndTime);
            elseif((obj.StartTimeBeforeAutomation<=obj.VideoStartTime&&...
                obj.EndTimeBeforeAutomation<=obj.VideoEndTime))
                startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                endTime=min(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
            elseif((obj.StartTimeBeforeAutomation>=obj.VideoStartTime&&...
                obj.EndTimeBeforeAutomation<=obj.VideoEndTime))
                startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                endTime=min(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
            else
                startTime=max(obj.StartTimeBeforeAutomation,obj.VideoStartTime);
                endTime=max(obj.EndTimeBeforeAutomation,obj.VideoEndTime);
            end
        end


        function updateSnapButtonStatus(obj,snapButtonStatus)
            setEnableStateOfSnapButton(obj);
            if snapButtonStatus
                obj.SnapUnsnapBtnHandle.Value=1;
                snapUnsnapCallback(obj);
            end
        end


        function flag=get.IsVideoPaused(this)
            flag=this.IsPauseHit;
        end


        function firstFrameCallback(this,~,~)





            if~isFirstFrPBButtonEnabled(this)
                return;
            end

            notify(this,'FirstFrameRequested');
            if this.CaughtExceptionDuringPlay

                resetExceptionDuringPlay(this);
            end

            moveScrubberFamilyToStart(this);



            notifyFrameChangeEvent(this);
        end


        function previousFrameCallback(this,~,~)

            if~isPrevFrPBButtonEnabled(this)
                return;
            end

            enablePlayPausePBButton(this);
            changePauseToPlay(this);
            enableRightPBButtons(this);

            notify(this,'PrevFrameRequested');
            if this.CaughtExceptionDuringPlay

                resetExceptionDuringPlay(this);
            end

            notifyFrameChangeEvent(this);
        end


        function nextFrameCallback(this,~,~)

            if~isNextFrPBButtonEnabled(this)
                return;
            end

            enablePlayPausePBButton(this);
            changePauseToPlay(this);
            enableLeftPBButtons(this);

            notify(this,'NextFrameRequested');

            if this.CaughtExceptionDuringPlay

                resetExceptionDuringPlay(this);
            end

            notifyFrameChangeEvent(this);
        end


        function lastFrameReached(this)
            disableRightPBButtons(this);
            enableLeftPBButtons(this);
        end


        function moveScrubberFamilyToEnd(this)

            disablePlayPausePBButton(this);
            changePlayToPause(this);

            enableLeftPBButtons(this);
            disableRightPBButtons(this);

            tEnd=this.IntervalEndTime;
            moveScrubberFamilyAtTime(this,tEnd);
        end


        function moveScrubberFamilyToStart(this)

            enablePlayPausePBButton(this);
            changePauseToPlay(this);

            disableLeftPBButtons(this);
            enableRightPBButtons(this);

            tStart=getSliderStartTime(this);
            moveScrubberFamilyAtTime(this,tStart);

        end


        function lastFrameCallback(this,~,~)

            if~isLastFrPBButtonEnabled(this)
                return;
            end

            notify(this,'LastFrameRequested');
            if this.CaughtExceptionDuringPlay

                resetExceptionDuringPlay(this);
            end

            lastFrameReached(this);

            moveScrubberFamilyAtTime(this,this.TimeVector(this.LastReadIndex));



            notifyFrameChangeEvent(this);
        end


        function playPauseCallback(obj,arg2,~)


            if isempty(arg2)
                flag=obj.PlayBackSection.PlayPauseBtnHandle.Value;
                obj.PlayBackSection.PlayPauseBtnHandle.Value=~flag;
            end

            changeIconTooltip(obj);

            if needToChangeToPauseMode(obj)
                obj.IsPauseHit=false;
                obj.playVideo();
            else
                obj.IsPauseHit=true;
                obj.pauseVideo();
            end
        end


        function flag=get.IsDoingSnap(obj)
            flag=obj.SnapUnsnapBtnHandle.Value;
        end


        function moveLeftIntervalToCurrentTime(this)

            setStartTimeAsCurrentTime(this);
            moveLeftFlagFamilyForEditBoxTimes(this);
            enableSUBtnForLeftFlagMove(this);
        end


        function moveRightIntervalToCurrentTime(this)

            setEndTimeAsCurrentTime(this);
            moveRightFlagFamilyForEditBoxTimes(this);
            enableSUBtnForRightFlagMove(this);
        end


        function disableRangeSlider(this)
            this.disableAllPBButtons();
            this.disableScrubber();
            this.disableLeftRightFlags();
        end


        function enableRangeSlider(this)
            this.enableAllPBButtons();
            this.enableScrubber();
            this.enableLeftRightFlags();
        end


        function disableEditBoxes(this)
            this.disableStartCurrentEndEditBoxes();
            this.disableRangeSliderSetting();
        end


        function disableStartCurrentEndEditBoxes(this)
            this.disableCurrentEditBox();
            this.disableStartEndEditBoxes();
        end


        function freezeSliderLine(this)
            this.removeBtnDwnlListner4LeftHLine();
            this.removeBtnDwnlListner4MiddleHLine();
        end


        function unfreezeSliderLine(this)
            this.addBtnDwnlListner4LeftHLine();
            this.addBtnDwnlListner4MiddleHLine();
        end


        function enableEditBoxes(this)
            this.enableStartCurrentEndEditBoxes();
            this.enableRangeSliderSetting();
        end


        function enableStartCurrentEndEditBoxes(this)
            this.enableCurrentEditBox();
            this.enableStartEndEditBoxes();
        end


        function disableLeftRightFlags(obj)


            setBGcolorOfLeftRightFlags(obj,obj.FLAG_BGCOLOR_DISBALE);
            deleteBtnDwnlListner4LeftRightFlags(obj);
        end


        function enableLeftRightFlags(obj)


            setBGcolorOfLeftRightFlags(obj,obj.FLAG_BGCOLOR_ENABLE);
            addBtnDwnlListner4LeftRightFlags(obj);
        end


        function hideContent(this)
            this.SliderPanel.Visible='off';
            this.TimePanel.Visible='off';
        end


        function showContent(this)
            this.SliderPanel.Visible='on';
            this.TimePanel.Visible='on';
        end


        function reset(this)
            if isvalid(this)
                if ishandle(this.FigHandle)
                    delete(this.LeftFlagPanel);
                    delete(this.LeftPolePanel);
                    delete(this.RightFlagPanel);
                    delete(this.RightPolePanel);
                    delete(this.FullHLinePanel);
                    delete(this.LeftHLinePanel);
                    delete(this.MiddleHLinePanel);
                    delete(this.RightHLinePanel);
                    delete(this.ScrubberPanel);
                    delete(this.PlaybackPanelHandle);
                    delete(this.StartEBPanelHandle);
                    delete(this.EndEBPanelHandle);
                    delete(this.CurrentEBPanelHandle);
                    delete(this.DurationPanel);
                    delete(this.PlayBackAndRangeSliderBtnHandle);
                    delete(this.SnapUnsnapBtnHandle);

                    delete(this.PlayBackSection.FirstFrameBtnHandle);
                    delete(this.PlayBackSection.PreviousFrameBtnHandle);
                    delete(this.PlayBackSection.PlayPauseBtnHandle);
                    delete(this.PlayBackSection.NextFrameBtnHandle);
                    delete(this.PlayBackSection.LastFrameBtnHandle);

                    this.LeftFlagPanel=[];
                    this.LeftPolePanel=[];
                    this.RightFlagPanel=[];
                    this.RightPolePanel=[];
                    this.FullHLinePanel=[];
                    this.LeftHLinePanel=[];
                    this.MiddleHLinePanel=[];
                    this.RightHLinePanel=[];
                    this.ScrubberPanel=[];
                    this.PlaybackPanelHandle=[];
                    this.StartEBHandle=[];
                    this.EndEBHandle=[];
                    this.CurrentEBHandle=[];
                    this.StartEBPanelHandle=[];
                    this.EndEBPanelHandle=[];
                    this.CurrentEBPanelHandle=[];
                    this.DurationPanel=[];
                    this.PlayBackAndRangeSliderBtnHandle=[];
                    this.SnapUnsnapBtnHandle=[];
                    this.PlayBackSection=struct('FirstFrameBtnHandle',[],...
                    'PreviousFrameBtnHandle',[],...
                    'PlayPauseBtnHandle',[],...
                    'NextFrameBtnHandle',[],...
                    'LastFrameBtnHandle',[]);

                end
            end
            delete(this);
        end


        function updateSliderCurrentTime(obj)
            t=getSliderCurrentTime(obj);
            updateLabelerCurrentTime(obj,t,true);
        end
    end

    methods

        function startT=get.VideoStartTime(obj)
            startT=obj.TimeVector(1);
        end

        function endT=get.VideoEndTime(obj)
            tEnd=getSignalEndTimePlusFrameRate(obj);
            endT=ceilTo5Decimal(tEnd);
        end

        function lastReadIdx=get.LastReadIndex(obj)
            import vision.internal.videoLabeler.tool.signalLoading.helpers.*

            [lastReadIdx,~]=getTimeToIndex(obj.TimeVector,obj.LastQueryTimestamp);
        end
    end

    methods(Access=private)


        function[endT,tv]=getVideoEndTime(obj,signalName)
            [tEnd,tv]=getSignalEndTimePlusFrameRate(obj,signalName);
            endT=ceilTo5Decimal(tEnd);
        end


        function tEnd=readjustEndTimeForAny(obj,tEnd)
            if tEnd==obj.VideoEndTime
                tEnd=obj.TimeVector(end);
            end
        end


        function tEnd=readjustEndTimeForSignal(obj,tEnd,signalName)

            [tEnd2,tv]=getVideoEndTime(obj,signalName);
            if tEnd==tEnd2
                tEnd=tv(end);
            end
        end


        function enableSUBtnForLeftFlagMove(obj)
            if~isLeftPoleAtExtremeLeft(obj)
                enableSnapUnsnapBtn(obj);
            end
        end


        function enableSUBtnForRightFlagMove(obj)
            if~isRightPoleAtExtremeRight(obj)
                enableSnapUnsnapBtn(obj);
            end
        end


        function moveLeftFlagFamilyForEditBoxTimes(obj)
            oldUnits=getOldUnitsAndSetToPixels(obj,obj.FigHandle);

            startT=obj.VideoStartTime;
            ebStartTime=getTimeFromEB(obj,obj.StartEBHandle);
            endT=obj.VideoEndTime;

            leftFlag_rightVBorder=getPositionForTime(obj,ebStartTime,startT,endT);


            leftFlagPos_tmp=get(obj.LeftFlagPanel,'position');
            flagW=leftFlagPos_tmp(3);
            leftFlagPos_tmp(1)=leftFlag_rightVBorder-flagW+1;
            if all(isfinite(leftFlagPos_tmp))
                set(obj.LeftFlagPanel,'position',leftFlagPos_tmp);
            end


            setLeftPolePos(obj,leftFlag_rightVBorder);


            setLeftHLinePos(obj,leftFlag_rightVBorder);


            restoreUnits(obj,obj.FigHandle,oldUnits);

            notify(obj,'StartOrEndTimeUpdated');

        end


        function setStartTimeAsCurrentTime(obj)
            if obj.HasHour
                copyEBStringAndUserData(obj,obj.CurrentEBHandle.hHourEB,obj.StartEBHandle.hHourEB);
            end

            if obj.HasMin
                copyEBStringAndUserData(obj,obj.CurrentEBHandle.hMinEB,obj.StartEBHandle.hMinEB);
            end


            copyEBStringAndUserData(obj,obj.CurrentEBHandle.hSecEB,obj.StartEBHandle.hSecEB);
        end


        function t=getSliderStartTime(obj)
            t=getTimeFromEB(obj,obj.StartEBHandle);
        end


        function t=getSliderCurrentTime(obj)
            t=getTimeFromEB(obj,obj.CurrentEBHandle);
        end


        function t=getSliderEndTime(obj)
            t=getTimeFromEB(obj,obj.EndEBHandle);
        end


        function flag=isFirstFrPBButtonEnabled(this)
            flag=strcmp(this.PlayBackSection.FirstFrameBtnHandle.Enable,...
            'on');
        end


        function flag=isPrevFrPBButtonEnabled(this)
            flag=strcmp(this.PlayBackSection.PreviousFrameBtnHandle.Enable,...
            'on');
        end


        function flag=isNextFrPBButtonEnabled(this)
            flag=strcmp(this.PlayBackSection.NextFrameBtnHandle.Enable,...
            'on');
        end


        function flag=isLastFrPBButtonEnabled(this)
            flag=strcmp(this.PlayBackSection.LastFrameBtnHandle.Enable,...
            'on');
        end


        function flag=isPlayPausePBButtonEnabled(this)
            flag=strcmp(this.PlayBackSection.PlayPauseBtnHandle.Enable,...
            'on');
        end


        function t=clipCurrentTime(obj,t)
            tS=getSliderStartTime(obj);
            tE=getSliderEndTime(obj);
            if t<tS
                t=tS;
            elseif t>tE
                t=tE;
            end
        end


        function retrieveParamsFromObject(obj,containerObj)
            obj.FigHandle=containerObj.FigHandle;
            obj.KeyPressCallback=containerObj.FigHandle.KeyPressFcn;
            obj.Xoffset=containerObj.Xoffset;
            obj.XposImagePanel=containerObj.XposImagePanel;
            obj.TimePanel=containerObj.TimePanel;
            obj.SliderPanel=containerObj.SliderPanel;
        end


        function hasHourMin(obj)
            if(obj.VideoEndTime>=3600)
                obj.HasHour=true;
                obj.HasMin=true;
            elseif(obj.VideoEndTime>=60)
                obj.HasHour=false;
                obj.HasMin=true;
            else
                obj.HasHour=false;
                obj.HasMin=false;
            end
        end


        function charToPixel(obj)
            figUnit='pixels';
            tmpPos=[0,0,1,1];
            charInPixels=hgconvertunits(obj.FigHandle,tmpPos,'char',figUnit,obj.FigHandle);






            obj.CharWidthInPixels=charInPixels(3);
            obj.CharHeightInPixels=charInPixels(4);

        end


        function getFigUnits(obj)
            obj.OrigFigUnits=get(obj.FigHandle,'units');
        end


        function oldUnits=getOldUnitsAndSetToPixels(~,h)
            oldUnits=get(h,'units');
            set(h,'units','pixels');
        end


        function restoreUnits(~,h,oldUnits)
            set(h,'units',oldUnits);
        end


        function createSliderLayout(obj)

            FULL_HLINE_HEIGHT=5;
            SCRUBBER_WIDTH=15;
            SCRUBBER_HEIGHT=11;
            FLAG_WIDTH=8;
            FLAG_HEIGHT=7;
            POLE_WIDTH=2;
            CLEARANCE_VERT=10;


            oldUnits=getOldUnitsAndSetToPixels(obj,obj.SliderPanel);
            pos=get(obj.SliderPanel,'position');
            wFull=pos(3);
            hFull=pos(4);





            params.parent=obj.SliderPanel;
            fullHLine_w=wFull-2*obj.Xoffset;
            MM=6;
            fullHLine_y=floor(hFull/2)-floor(FULL_HLINE_HEIGHT/2)-MM;
            params.position=[obj.Xoffset,fullHLine_y,fullHLine_w,FULL_HLINE_HEIGHT];
            params.backgroundColor=obj.DEFAULT_BGCOLOR;
            params.borderWidth=1;
            params.highlightColor=[0.8,0.8,0.8];
            params.tag='FullHLinePanel';


            obj.FullHLinePanel=createPanel(params);
            addAssert(obj,obj.FullHLinePanel,'createSliderLayout');


            fullHLine_endX=wFull-obj.Xoffset;
            posH=get(obj.FullHLinePanel,'position');
            obj.FullHLineLength=posH(3);

            leftPoleEndX=obj.Xoffset;
            scrubberMidX=obj.Xoffset;
            rightPoleStartX=fullHLine_endX-1;







            startX=leftPoleEndX;
            params.position=[startX,fullHLine_y,fullHLine_endX-startX,FULL_HLINE_HEIGHT];
            params.backgroundColor=[0.1686,0.5686,0.9686];

            params.tag='LeftHLinePanel';


            obj.LeftHLinePanel=createPanel(params);
            addAssert(obj,obj.LeftHLinePanel,'createSliderLayout');






            startX=scrubberMidX;
            params.position=[startX,fullHLine_y,fullHLine_endX-startX,FULL_HLINE_HEIGHT];
            params.backgroundColor=[0.6353,0.8431,1.0000];

            params.tag='MiddleHLinePanel';


            obj.MiddleHLinePanel=createPanel(params);
            addAssert(obj,obj.MiddleHLinePanel,'createSliderLayout');






            startX=rightPoleStartX;
            params.position=[startX,fullHLine_y,fullHLine_endX-startX,FULL_HLINE_HEIGHT];
            params.backgroundColor=obj.DEFAULT_BGCOLOR;
            params.borderWidth=1;
            params.tag='RightHLinePanel';


            obj.RightHLinePanel=createPanel(params);
            addAssert(obj,obj.RightHLinePanel,'createSliderLayout');


            pole_y=5;
            startX=leftPoleEndX-POLE_WIDTH+1;
            pole_h=hFull-pole_y-CLEARANCE_VERT-FLAG_HEIGHT;
            params.position=[startX,pole_y,POLE_WIDTH,pole_h];
            params.backgroundColor=obj.FLAG_BGCOLOR_ENABLE;
            params.borderWidth=0;
            params.tag='LeftPolePanel';
            obj.LeftPolePanel=createPanel(params);
            obj.LeftPolePanel.BorderType='none';


            flagY=pole_y+pole_h-1;
            startX=leftPoleEndX-FLAG_WIDTH+1;
            params.position=[startX,flagY,FLAG_WIDTH,FLAG_HEIGHT];
            params.backgroundColor=obj.FLAG_BGCOLOR_ENABLE;
            params.borderWidth=0;
            params.tag='LeftFlagPanel';
            obj.LeftFlagPanel=createPanel(params);
            obj.LeftFlagPanel.BorderType='none';





            startX=rightPoleStartX;
            params.position=[startX,pole_y,POLE_WIDTH,pole_h];
            params.backgroundColor=obj.FLAG_BGCOLOR_ENABLE;
            params.borderWidth=0;
            params.tag='RightPolePanel';
            obj.RightPolePanel=createPanel(params);
            obj.RightPolePanel.BorderType='none';


            params.position=[startX,flagY,FLAG_WIDTH,FLAG_HEIGHT];
            params.backgroundColor=obj.FLAG_BGCOLOR_ENABLE;
            params.borderWidth=0;
            params.tag='RightFlagPanel';
            obj.RightFlagPanel=createPanel(params);
            obj.RightFlagPanel.BorderType='none';


            startX=scrubberMidX-floor(SCRUBBER_WIDTH/2);
            startY=(hFull/2)-(SCRUBBER_HEIGHT/2)-MM;
            params.position=[startX,startY,SCRUBBER_WIDTH,SCRUBBER_HEIGHT];
            params.backgroundColor=obj.SCRUBBER_BGCOLOR_ENABLE;
            params.borderWidth=1;
            params.highlightColor=[0.5,0.5,0.5];
            params.tag='ScrubberPanel';
            obj.ScrubberPanel=createPanel(params);

            set(obj.FigHandle,'Interruptible','off')
            set(obj.FigHandle,'BusyAction','cancel')

            restoreUnits(obj,obj.SliderPanel,oldUnits);
        end


        function resizeFullHLine(obj)
            pos=get(obj.FullHLinePanel,'position');
            pos(3)=obj.FullHLineLength;
            set(obj.FullHLinePanel,'position',pos);
        end


        function addBtnDwnlListner4MiddleHLine(obj)
            if isempty(obj.BtnDwnlListner4MiddleHLine)
                obj.BtnDwnlListner4MiddleHLine=...
                addlistener(obj.MiddleHLinePanel,'ButtonDown',@obj.hLineBtnDownCallback);
            end
        end


        function removeBtnDwnlListner4MiddleHLine(obj)

            delete(obj.BtnDwnlListner4MiddleHLine);
            obj.BtnDwnlListner4MiddleHLine=[];
        end


        function addBtnDwnlListner4LeftHLine(obj)
            if isempty(obj.BtnDwnlListner4LeftHLine)
                obj.BtnDwnlListner4LeftHLine=...
                addlistener(obj.LeftHLinePanel,'ButtonDown',@obj.hLineBtnDownCallback);
            end
        end


        function removeBtnDwnlListner4LeftHLine(obj)

            delete(obj.BtnDwnlListner4LeftHLine);
            obj.BtnDwnlListner4LeftHLine=[];
        end


        function addBtnDwnlListner4Scrubber(obj)
            if isempty(obj.BtnDwnlListner4Scrubber)
                obj.BtnDwnlListner4Scrubber=...
                addlistener(obj.ScrubberPanel,'ButtonDown',@obj.scrubberBtnDownCallback);
            end
        end


        function removeBtnDwnlListner4Scrubber(obj)

            delete(obj.BtnDwnlListner4Scrubber);
            obj.BtnDwnlListner4Scrubber=[];
        end


        function addBtnDwnlListner4LeftRightFlags(obj)
            if isempty(obj.BtnDwnlListner4LeftFlag)
                obj.BtnDwnlListner4LeftFlag=...
                addlistener(obj.LeftFlagPanel,'ButtonDown',@obj.leftFlagBtnDownCallback);
            end
            if isempty(obj.BtnDwnlListner4RightFlag)
                obj.BtnDwnlListner4RightFlag=...
                addlistener(obj.RightFlagPanel,'ButtonDown',@obj.rightFlagBtnDownCallback);
            end
        end


        function deleteBtnDwnlListner4LeftRightFlags(obj)

            delete(obj.BtnDwnlListner4LeftFlag);
            obj.BtnDwnlListner4LeftFlag=[];

            delete(obj.BtnDwnlListner4RightFlag);
            obj.BtnDwnlListner4RightFlag=[];
        end


        function isValid=isNumericValue(~,val)


            isValid=~isnan(val);
        end


        function val=saturateMinOrSecValue(obj,val,hmsEBoxID)

            if(hmsEBoxID==obj.MIN_EB_ID)||(hmsEBoxID==obj.SEC_EB_ID)
                if(val<0)
                    val=0;
                elseif(val>59)
                    val=59;
                end
            end
        end


        function[valNew,valStrNew]=getFormattedValue(obj,val,hmsEBoxID)


            if(hmsEBoxID==obj.HOUR_EB_ID)||(hmsEBoxID==obj.MIN_EB_ID)
                valNew=floor(val);
                valStrNew=sprintf('%02d',valNew);
            else
                valStrNew=formatSec(val);
                valNew=str2double(valStrNew);
            end
        end


        function[tOut,isSaturated]=saturateTimeValue(~,tIn,tMin,tMax)
            tOut=tIn;
            isSaturated=false;
            if(tIn<tMin)
                tOut=tMin;
                isSaturated=true;
            elseif(tIn>tMax)
                tOut=tMax;
                isSaturated=true;
            end
        end


        function saturateSetAndSaveEBvalues(obj,hObject,valNew,valStrNew,sceEBoxID,hmsEBoxID)




            if(sceEBoxID==obj.START_EB_ID)
                startTs=getTimeFromEBwithVal(obj,obj.StartEBHandle,valNew,hmsEBoxID);
                currentTs=getTimeFromEB(obj,obj.CurrentEBHandle);

                [startTs,isSaturated]=saturateTimeValue(obj,startTs,obj.VideoStartTime,currentTs);
                setAndSaveValuesInEBs(obj,hObject,obj.StartEBHandle,valStrNew,startTs,isSaturated);
            elseif(sceEBoxID==obj.CURRENT_EB_ID)
                startTs=getTimeFromEB(obj,obj.StartEBHandle);
                currentTs=getTimeFromEBwithVal(obj,obj.CurrentEBHandle,valNew,hmsEBoxID);
                endTs=getTimeFromEB(obj,obj.EndEBHandle);
                [currentTs,isSaturated]=saturateTimeValue(obj,currentTs,startTs,endTs);
                setAndSaveValuesInEBs(obj,hObject,obj.CurrentEBHandle,valStrNew,currentTs,isSaturated);
            else

                currentTs=getTimeFromEB(obj,obj.CurrentEBHandle);
                endTs=getTimeFromEBwithVal(obj,obj.EndEBHandle,valNew,hmsEBoxID);
                [endTs,isSaturated]=saturateTimeValue(obj,endTs,currentTs,obj.VideoEndTime);
                setAndSaveValuesInEBs(obj,hObject,obj.EndEBHandle,valStrNew,endTs,isSaturated);
            end
        end


        function restorePrevValidValue(~,hObject)

            lastValStr=get(hObject,'UserData');
            set(hObject,'string',lastValStr);
        end


        function setAndSaveValuesInEBs(obj,hObject,hEBs,valStrNew,ts,isSaturated)
            if isSaturated
                setEBsTimeAt(obj,hEBs,ts);
            else
                setAndSaveValueInEB(obj,hObject,valStrNew);
            end
        end


        function setAndSaveValueInEB(~,hObject,valStrNew)
            set(hObject,'string',valStrNew);
            set(hObject,'UserData',valStrNew);
        end


        function moveRightFlagFamilyForEditBoxTimes(obj)
            oldUnits=getOldUnitsAndSetToPixels(obj,obj.FigHandle);

            startT=obj.VideoStartTime;
            ebEndTime=getTimeFromEB(obj,obj.EndEBHandle);
            endT=obj.VideoEndTime;

            rightFlag_leftVBorder=getPositionForTime(obj,ebEndTime,startT,endT);


            rightFlagPos_tmp=get(obj.RightFlagPanel,'position');
            rightFlagPos_tmp(1)=rightFlag_leftVBorder;
            if all(isfinite(rightFlagPos_tmp))
                set(obj.RightFlagPanel,'position',rightFlagPos_tmp);
            end


            setRightPolePos(obj,rightFlag_leftVBorder);


            setRightHLinePos(obj,rightFlag_leftVBorder);


            restoreUnits(obj,obj.FigHandle,oldUnits);

            notify(obj,'StartOrEndTimeUpdated');
        end


        function xPos=getPositionForTime(obj,thisTime,startT,endT)







            fullHLen_inRange=obj.FullHLineLength-1;
            xPos=floor(((fullHLen_inRange/(endT-startT))*(thisTime-startT))+0.5);


            if xPos<0
                xPos=0;
            elseif xPos>fullHLen_inRange
                xPos=fullHLen_inRange;
            end
            xPos=xPos+obj.Xoffset;








        end


        function saveFlagStateBeforeFreeze(obj)
            hasBtnDwnlListner=~isempty(obj.BtnDwnlListner4LeftFlag);
            if obj.IsInPlayModeFreeze
                obj.IsFlagEnabledB4FreezePlayMode=hasBtnDwnlListner;
            else
                obj.IsFlagEnabledB4FreezeOtherMode=hasBtnDwnlListner;
            end
        end


        function saveStartEndEBStateBeforeFreeze(obj)
            enState=get(obj.StartEBHandle.hSecEB,'enable');
            if obj.IsInPlayModeFreeze
                obj.IsStEnEBEnabledB4FreezePlayMode=strcmpi(enState,'on');
            else
                obj.IsStEnEBEnabledB4FreezeOtherMode=strcmpi(enState,'on');
            end
        end


        function saveStateAndDisableLeftRightFlags(obj)
            saveFlagStateBeforeFreeze(obj);
            if canChangeStateOfFlags(obj)
                disableLeftRightFlags(obj);
            end
        end


        function restoreLeftRightFlagsAtUnfreeze(obj)
            if canChangeStateOfFlags(obj)
                enableLeftRightFlags(obj);
            end
        end


        function saveSnapUnsnapBtnStateBeforeFreeze(obj)
            enState=get(obj.SnapUnsnapBtnHandle,'enable');
            if obj.IsInPlayModeFreeze
                obj.IsSUBtnEnabledB4FreezePlayMode=strcmpi(enState,'on');
            else
                obj.IsSUBtnEnabledB4FreezeOtherMode=strcmpi(enState,'on');
            end
            obj.IsSnapModeBeforeFreeze=obj.IsSnapMode;
        end


        function freezeInPlay(obj)
            if~obj.IsSelectiveFreeze
                freezeInterval(obj);
            end
            freezeInteraction(obj);
        end


        function unfreezeInPlayEndOrPause(obj)
            unfreezeInteraction(obj);
            if~obj.IsSelectiveFreeze
                unfreezeInterval(obj);
            end
        end


        function setEnableStateOfSnapButton(obj)
            startT=getTimeFromEB(obj,obj.StartEBHandle);
            endT=getTimeFromEB(obj,obj.EndEBHandle);


            if(round(startT,04)==round(obj.VideoStartTime,04))&&(round(endT,04)==round(obj.VideoEndTime,04))
                set(obj.SnapUnsnapBtnHandle,'enable','off');
            else
                set(obj.SnapUnsnapBtnHandle,'enable','on');
            end
        end


        function repositionUIwidgets(obj,sceEBoxID)


            if obj.IsSnapMode
                assert(sceEBoxID==obj.CURRENT_EB_ID)
                moveScrubberForEditBoxTimesInSnapMode(obj);
            else
                if(sceEBoxID==obj.START_EB_ID)

                    moveLeftFlagFamilyForEditBoxTimes(obj);
                elseif(sceEBoxID==obj.CURRENT_EB_ID)

                    moveScrubberForEditBoxTimesInUnSnapMode(obj);
                else

                    moveRightFlagFamilyForEditBoxTimes(obj);
                end
                setEnableStateOfSnapButton(obj);
            end
        end


        function timeEditBoxCallback(obj,hObject,~,sceEBoxID,hmsEBoxID)




            val=str2double(hObject.String);
            if isNumericValue(obj,val)
                val=saturateMinOrSecValue(obj,val,hmsEBoxID);
                [valNew,valStrNew]=getFormattedValue(obj,val,hmsEBoxID);
                saturateSetAndSaveEBvalues(obj,hObject,valNew,valStrNew,sceEBoxID,hmsEBoxID);

                repositionUIwidgets(obj,sceEBoxID);
                if(sceEBoxID==obj.CURRENT_EB_ID)
                    notify(obj,'CurrentTimeChanged');
                    notifyFrameChangeEvent(obj);
                end
                updatePlayBackControlState(obj);
            else
                restorePrevValidValue(obj,hObject);
            end

        end


        function attachEBCallbacks(obj)
            if obj.HasHour
                set(obj.StartEBHandle.hHourEB,'callback',{@obj.timeEditBoxCallback,obj.START_EB_ID,obj.HOUR_EB_ID});
            end
            if obj.HasMin
                set(obj.StartEBHandle.hMinEB,'callback',{@obj.timeEditBoxCallback,obj.START_EB_ID,obj.MIN_EB_ID});
            end
            set(obj.StartEBHandle.hSecEB,'callback',{@obj.timeEditBoxCallback,obj.START_EB_ID,obj.SEC_EB_ID});

            if obj.HasHour
                set(obj.CurrentEBHandle.hHourEB,'callback',{@obj.timeEditBoxCallback,obj.CURRENT_EB_ID,obj.HOUR_EB_ID});
            end
            if obj.HasMin
                set(obj.CurrentEBHandle.hMinEB,'callback',{@obj.timeEditBoxCallback,obj.CURRENT_EB_ID,obj.MIN_EB_ID});
            end
            set(obj.CurrentEBHandle.hSecEB,'callback',{@obj.timeEditBoxCallback,obj.CURRENT_EB_ID,obj.SEC_EB_ID});

            if obj.HasHour
                set(obj.EndEBHandle.hHourEB,'callback',{@obj.timeEditBoxCallback,obj.END_EB_ID,obj.HOUR_EB_ID});
            end
            if obj.HasMin
                set(obj.EndEBHandle.hMinEB,'callback',{@obj.timeEditBoxCallback,obj.END_EB_ID,obj.MIN_EB_ID});
            end
            set(obj.EndEBHandle.hSecEB,'callback',{@obj.timeEditBoxCallback,obj.END_EB_ID,obj.SEC_EB_ID});
        end


        function createTimeLayout(obj)


            info.labelText=getString(message('vision:labeler:StartTimeLabel'));
            info.startX=3;
            info.hourTag='Start Hour';
            info.minTag='Start min';
            info.secTag='Start sec';
            [obj.StartEBHandle,obj.StartEBPanelHandle,endX,~]=createTimeLabelAndEditBoxes(obj,info);



            clearanceX=5*(obj.CharWidthInPixels);
            info.labelText=getString(message('vision:labeler:CurrentTimeLabel'));
            info.startX=endX+clearanceX;
            info.hourTag='Current Hour';
            info.minTag='Current min';
            info.secTag='Current sec';
            [obj.CurrentEBHandle,obj.CurrentEBPanelHandle,endX,~]=createTimeLabelAndEditBoxes(obj,info);



            info.labelText=getString(message('vision:labeler:EndTimeLabel'));
            info.startX=endX+clearanceX;
            info.hourTag='End Hour';
            info.minTag='End min';
            info.secTag='End sec';
            [obj.EndEBHandle,obj.EndEBPanelHandle,endX,~]=createTimeLabelAndEditBoxes(obj,info);



            info.labelText=getString(message('vision:labeler:MaxTimeLabel'));
            info.startX=endX+clearanceX;
            info.hourTag='End Hour';
            info.minTag='End min';
            info.secTag='End sec';
            [endX,endY]=createDurationLabel(obj,info);


            attachEBCallbacks(obj);


            info.startX=endX+clearanceX;
            info.endY=endY;
            info.prevControlEndX=endX;
            endX=createPlaybackControlsLayout(obj,info);


            info.startX=endX+clearanceX;
            info.prevControlEndX=endX;
            createSnapLayout(obj,info);


            if(~obj.ShowSettingButton)
                info.startX=endX+clearanceX;
                info.prevControlEndX=endX;
                createPlayBackAndRangeSliderSetupLayout(obj,info);
            end
        end


        function bgColor=getBGColorForPlaybackBtn(obj)
            bgColor=get(obj.TimePanel,'BackgroundColor');
        end


        function createPlayPauseBtn(obj,params)

            obj.PlayBackSection.PlayPauseBtnHandle=uicontrol('parent',params.parent,...
            'Units','pixels',...
            'position',params.position,...
            'HorizontalAlignment','right',...
            'backgroundColor',params.backgroundColor,...
            'Style','togglebutton',...
            'Max',1,'Min',0,...
            'Tag',params.tag,...
            'String','',...
            'TooltipString',params.tooltipString,...
            'KeyPressFcn',obj.KeyPressCallback);
            setPlayPauseButtonImageTTString(obj,params.image,params.tooltipString);
        end


        function h=createPlaybackButton(obj,params)
            h=uicontrol('parent',params.parent,...
            'Units','pixels',...
            'Tag',params.tag,...
            'position',params.position,...
            'HorizontalAlignment','right',...
            'backgroundColor',params.backgroundColor,...
            'Style','pushbutton',...
            'Enable',params.enable,...
            'String','',...
            'TooltipString',params.tooltipString,...
            'KeyPressFcn',obj.KeyPressCallback);
            im=imread(params.image);

            set(h,'cdata',im);
        end


        function deleteUIControlsInTextLayout(obj)
            controlsOnTimePanel=findall(obj.TimePanel,'-property','Visible');
            pause(1);
            delete(controlsOnTimePanel(2:end));
        end


        function addBeginningButton(this,params)

            params.image=fullfile(this.ICON_PATH,'tobeginning.png');
            params.tag='btnBeginning';
            params.tooltipString=getString(message('vision:labeler:BeginningButtonTooltip'));
            params.enable='off';
            h=createPlaybackButton(this,params);
            set(h,'callback',@this.firstFrameCallback);
            this.PlayBackSection.FirstFrameBtnHandle=h;
        end


        function addPreviousFrameButton(this,params)

            params.image=fullfile(this.ICON_PATH,'topreviousframe.png');
            params.tag='btnPreviousFrame';
            params.tooltipString=getString(message('vision:labeler:PreviousFrameButtonTooltip'));
            params.enable='off';
            h=createPlaybackButton(this,params);
            set(h,'callback',@this.previousFrameCallback);
            this.PlayBackSection.PreviousFrameBtnHandle=h;
        end


        function addPlayPauseButton(this,params)

            params.image=fullfile(this.ICON_PATH,'play.png');
            params.tag='btnPlay';
            params.tooltipString=getString(message('vision:labeler:PlayButtonTooltip'));
            createPlayPauseBtn(this,params);
            setPlayPauseBtnCallback(this);
        end


        function addNextFrameButton(this,params)

            params.image=fullfile(this.ICON_PATH,'tonextframe.png');
            params.tag='btnNextFrame';
            params.tooltipString=getString(message('vision:labeler:NextFrameButtonTooltip'));
            params.enable='on';
            h=createPlaybackButton(this,params);
            set(h,'callback',@this.nextFrameCallback);
            this.PlayBackSection.NextFrameBtnHandle=h;
        end


        function addEndingButton(this,params)

            params.image=fullfile(this.ICON_PATH,'toend.png');
            params.tag='btnEnding';
            params.tooltipString=getString(message('vision:labeler:EndingButtonTooltip'));
            params.enable='on';
            h=createPlaybackButton(this,params);
            set(h,'callback',@this.lastFrameCallback);
            this.PlayBackSection.LastFrameBtnHandle=h;
        end


        function startX=getStartXforPlaybackPanel(obj)

            pos=get(obj.TimePanel,'position');
            fullW=pos(3);
            startX=floor(fullW/2)-floor(obj.PlaybackPanelWidth/2);
            if startX<obj.minStartXforPlaybackPanel
                startX=obj.minStartXforPlaybackPanel;
            end
        end


        function startX=getStartXforSnapUnsnapButton(obj)

            pos=get(obj.PlaybackPanelHandle,'position');
            minStartX=pos(1)+pos(3)+20;

            pos=get(obj.TimePanel,'position');
            fullW=pos(3);
            startX=fullW-obj.SnapUnsnapBtnWidth-3;
            if startX<minStartX
                startX=minStartX;
            end
        end


        function endX=createPlaybackControlsLayout(obj,info)
            clearanceX=5;
            obj.minStartXforPlaybackPanel=info.startX+clearanceX;
            w=16+10;
            h=w;
            offsetX=2;
            obj.PlaybackPanelWidth=(w+offsetX)*5+offsetX;
            params.parent=obj.TimePanel;
            pos_y=info.endY-h;
            startX=getStartXforPlaybackPanel(obj);
            params.position=[startX,pos_y,142,h];
            params.backgroundColor=get(params.parent,'backgroundColor');
            params.borderWidth=0;
            params.highlightColor=[0.8,0.8,0.8];
            params.tag='playback control panel';
            obj.PlaybackPanelHandle=createPanel(params);
            obj.PlaybackPanelHandle.BorderType='None';


            params.parent=obj.PlaybackPanelHandle;

            startX=offsetX;


            endX=startX+w;
            params.position=[startX,1,w,h];
            addBeginningButton(obj,params);

            startX=endX+offsetX;
            endX=startX+w;
            params.position=[startX,1,w,h];
            addPreviousFrameButton(obj,params);

            startX=endX+offsetX;
            endX=startX+w;
            params.position=[startX,1,w,h];
            addPlayPauseButton(obj,params);

            startX=endX+offsetX;
            endX=startX+w;
            params.position=[startX,1,w,h];
            addNextFrameButton(obj,params);

            startX=endX+offsetX;
            endX=startX+w;
            params.position=[startX,1,w,h];
            addEndingButton(obj,params);

        end


        function createSnapLayout(obj,info)


            params.parent=obj.TimePanel;
            obj.SnapUnsnapBtnWidth=180;
            w=obj.SnapUnsnapBtnWidth;
            stX=getStartXforSnapUnsnapButton(obj);
            h=16+10;
            pos_y=info.endY-h;
            params.position=[stX,pos_y,w,h];


            params.backgroundColor=get(params.parent,'backgroundColor');

            createSnapUnsnapBtn(obj,params);

        end


        function setString(obj,str)
            set(obj.SnapUnsnapBtnHandle,'String',str);
        end


        function setBGcolorOfLeftRightFlags(obj,bgColor)

            set(obj.LeftFlagPanel,'backgroundcolor',bgColor);

            set(obj.LeftPolePanel,'backgroundcolor',bgColor);

            set(obj.RightFlagPanel,'backgroundcolor',bgColor);

            set(obj.RightPolePanel,'backgroundcolor',bgColor);
        end


        function setBGcolorOfScrubber(obj,bgColor)
            set(obj.ScrubberPanel,'backgroundcolor',bgColor);
        end


        function disableScrubber(obj)


            setBGcolorOfScrubber(obj,obj.SCRUBBER_BGCOLOR_DISABLE);
            removeBtnDwnlListner4Scrubber(obj);
        end


        function enableScrubber(obj)


            setBGcolorOfScrubber(obj,obj.SCRUBBER_BGCOLOR_ENABLE);
            addBtnDwnlListner4Scrubber(obj);

            addBtnDwnlListner4MiddleHLine(obj);
            addBtnDwnlListner4LeftHLine(obj);
        end


        function disableSnapUnsnapBtn(obj)
            set(obj.SnapUnsnapBtnHandle,'enable','off');
        end


        function enableSnapUnsnapBtn(obj)
            set(obj.SnapUnsnapBtnHandle,'enable','on');
        end


        function restoreSnapUnsnapBtnAtUnfreeze(obj)
            if obj.IsSUBtnEnabledB4FreezePlayMode
                set(obj.SnapUnsnapBtnHandle,'enable','on');
            end
        end


        function saveStateAndDisable2TimeEditBoxes(obj)
            saveStartEndEBStateBeforeFreeze(obj);
            if canChangeStateOfStEnEB(obj)
                disableStartEndEditBoxes(obj);
            end
        end


        function saveStateAndDisable3TimeEditBoxes(obj)
            saveStateAndDisable2TimeEditBoxes(obj);

            disableCurrentEditBox(obj);
        end


        function flag=canChangeStateOfStEnEB(obj)
            if obj.IsInPlayModeFreeze
                flag=obj.IsStEnEBEnabledB4FreezePlayMode;
            else
                flag=obj.IsStEnEBEnabledB4FreezeOtherMode;
            end
        end


        function flag=canChangeStateOfFlags(obj)
            if obj.IsInPlayModeFreeze
                flag=obj.IsFlagEnabledB4FreezePlayMode;
            else
                flag=obj.IsFlagEnabledB4FreezeOtherMode;
            end
        end


        function flag=mustSwitchToSnapMode(obj)
            if obj.IsInPlayModeFreeze
                flag=false;
            else
                if obj.IsSnapModeBeforeFreeze

                    flag=false;
                else
                    flag=true;
                end
            end
        end


        function flag=canChangeStateOfSnapUnsnapBtn(obj)
            if obj.IsInPlayModeFreeze
                flag=obj.IsSUBtnEnabledB4FreezePlayMode;
            else
                flag=obj.IsSUBtnEnabledB4FreezeOtherMode;
            end
        end


        function restore2TimeEditBoxesAtUnfreeze(obj)
            if canChangeStateOfStEnEB(obj)
                enableStartEndEditBoxes(obj);
            end
        end


        function disableStartEndEditBoxes(obj)
            setStatesOfStartEndEditBoxes(obj,'off',obj.TIME_EB_BGCOLOR_DISABLE)
        end


        function enableStartEndEditBoxes(obj)
            setStatesOfStartEndEditBoxes(obj,'on',obj.TIME_EB_BGCOLOR_ENABLE)
        end


        function disableCurrentEditBox(obj)
            setStatesOfCurrentEditBoxes(obj,'off',obj.TIME_EB_BGCOLOR_DISABLE)
        end


        function enableCurrentEditBox(obj)
            setStatesOfCurrentEditBoxes(obj,'on',obj.TIME_EB_BGCOLOR_ENABLE)
        end


        function setStatesOfCurrentEditBoxes(obj,state,panelBGcolor)


            if obj.HasHour
                set(obj.CurrentEBHandle.hHourEB,'enable',state);
                set(obj.CurrentEBHandle.hHourColon,'backgroundcolor',panelBGcolor);
            end
            if obj.HasMin
                set(obj.CurrentEBHandle.hMinEB,'enable',state);
                set(obj.CurrentEBHandle.hMinColon,'backgroundcolor',panelBGcolor);
            end
            set(obj.CurrentEBHandle.hSecEB,'enable',state);
            set(obj.CurrentEBPanelHandle,'backgroundcolor',panelBGcolor);
        end


        function setStatesOfStartEndEditBoxes(obj,state,panelBGcolor)


            if obj.HasHour
                set(obj.StartEBHandle.hHourEB,'enable',state);
                set(obj.StartEBHandle.hHourColon,'backgroundcolor',panelBGcolor);
            end
            if obj.HasMin
                set(obj.StartEBHandle.hMinEB,'enable',state);
                set(obj.StartEBHandle.hMinColon,'backgroundcolor',panelBGcolor);
            end
            set(obj.StartEBHandle.hSecEB,'enable',state);
            set(obj.StartEBPanelHandle,'backgroundcolor',panelBGcolor);


            if obj.HasHour
                set(obj.EndEBHandle.hHourEB,'enable',state);
                set(obj.EndEBHandle.hHourColon,'backgroundcolor',panelBGcolor);
            end
            if obj.HasMin
                set(obj.EndEBHandle.hMinEB,'enable',state);
                set(obj.EndEBHandle.hMinColon,'backgroundcolor',panelBGcolor);
            end
            set(obj.EndEBHandle.hSecEB,'enable',state);
            set(obj.EndEBPanelHandle,'backgroundcolor',panelBGcolor);
        end


        function saveStateAndDisableSnapUnsnapBtn(obj)
            saveSnapUnsnapBtnStateBeforeFreeze(obj);
            if obj.IsSUBtnEnabledB4FreezePlayMode
                disableSnapUnsnapBtn(obj);
            end
        end


        function movePlaybackButtons(obj)
            pos=get(obj.PlaybackPanelHandle,'position');
            pos(1)=getStartXforPlaybackPanel(obj);
            if all(isfinite(pos))
                set(obj.PlaybackPanelHandle,'position',pos);
            end
        end


        function moveSnapUnsnapButton(obj)
            pos=get(obj.SnapUnsnapBtnHandle,'position');
            pos(1)=getStartXforSnapUnsnapButton(obj);
            if all(isfinite(pos))
                set(obj.SnapUnsnapBtnHandle,'position',pos);
            end
        end


        function movePlayBackSetUpButton(obj)
            pos=get(obj.PlayBackAndRangeSliderBtnHandle,'position');
            pos(1)=getStartXforPlayBackAndRangeSliderSetupButton(obj);
            if all(isfinite(pos))
                set(obj.PlayBackAndRangeSliderBtnHandle,'position',pos);
            end
        end


        function moveScrubberForEditBoxTimesInSnapMode(obj)
            startT=getTimeFromEB(obj,obj.StartEBHandle);
            currentT=getTimeFromEB(obj,obj.CurrentEBHandle);
            endT=getTimeFromEB(obj,obj.EndEBHandle);

            scrubberMidX=getScrubberMidXFromTime(obj,startT,currentT,endT);
            moveScrubberFamily(obj,scrubberMidX);
            obj.LastQueryTimestamp=obj.ScrubberCurrentTime;
        end


        function moveScrubberForEditBoxTimesInUnSnapMode(obj)
            startT=obj.VideoStartTime;
            currentT=getTimeFromEB(obj,obj.CurrentEBHandle);
            endT=obj.VideoEndTime;

            scrubberMidX=getScrubberMidXFromTime(obj,startT,currentT,endT);
            moveScrubberFamily(obj,scrubberMidX);
            obj.LastQueryTimestamp=obj.ScrubberCurrentTime;
        end


        function moveBackFlagsScrubberHLinesInSnapMode(obj)
            moveLeftFlagFamilyToExtremeLeft(obj);
            moveRightFlagFamilyToExtremeRight(obj);
            moveScrubberForEditBoxTimesInSnapMode(obj);
        end


        function moveBackFlagsScrubberHLinesInUnsnapMode(obj)
            moveLeftFlagFamilyForEditBoxTimes(obj);
            moveRightFlagFamilyForEditBoxTimes(obj);
            moveScrubberForEditBoxTimesInUnSnapMode(obj);
        end


        function enableSnapUnsnapButton(obj)
            set(obj.SnapUnsnapBtnHandle,'enable','on');
        end


        function restoreBtnEBoxFlagStateInUnsnapMode(obj)
            if obj.IsSnapMode
                setString(obj,vision.getMessage('vision:labeler:ZoomInTimeInterval'));
                enableLeftRightFlags(obj);
                setStatesOfStartEndEditBoxes(obj,'on',obj.TIME_EB_BGCOLOR_ENABLE);
                obj.IsSnapMode=false;
            end
        end


        function flag=needToChangeToPauseMode(obj)



            flag=obj.PlayBackSection.PlayPauseBtnHandle.Value;
        end


        function setPlayPauseButtonImageTTString(obj,imFile,tooltipString)
            im=imread(imFile);

            set(obj.PlayBackSection.PlayPauseBtnHandle,'cdata',im,...
            'tooltipString',tooltipString);
        end


        function changePauseToPlay(obj)
            imFile=fullfile(obj.ICON_PATH,'play.png');
            tooltipString=getString(message('vision:labeler:PlayButtonTooltip'));
            setPlayPauseButtonImageTTString(obj,imFile,tooltipString);
            obj.PlayBackSection.PlayPauseBtnHandle.Value=false;
        end


        function changePlayToPause(obj)
            imFile=fullfile(obj.ICON_PATH,'pause.png');
            tooltipString=getString(message('vision:labeler:PauseButtonTooltip'));
            setPlayPauseButtonImageTTString(obj,imFile,tooltipString);
            obj.PlayBackSection.PlayPauseBtnHandle.Value=true;
        end


        function changeIconTooltip(obj)

            if needToChangeToPauseMode(obj)
                imFile=fullfile(obj.ICON_PATH,'pause.png');
                tooltipString=getString(message('vision:labeler:PauseButtonTooltip'));

            else
                imFile=fullfile(obj.ICON_PATH,'play.png');
                tooltipString=getString(message('vision:labeler:PlayButtonTooltip'));
            end
            setPlayPauseButtonImageTTString(obj,imFile,tooltipString);
        end


        function playVideo(this)


            this.disableLeftRightPBButtons();
            this.IsInPlayModeFreeze=true;
            notify(this,'PlayInit');
            this.freezeInPlay();

            notify(this,'PlayLoop');

            if ishandle(this.FigHandle)&&this.CaughtExceptionDuringPlay
                pauseVideo(this);
                changePauseToPlay(this);
                this.CaughtExceptionDuringPlay=false;
                return;
            end




            if this.CaughtExceptionDuringPlay

                pauseVideo(this);
                changePauseToPlay(this);

                resetExceptionDuringPlay(this);
                return;
            end

            if ishandle(this.FigHandle)&&(~this.IsPauseHit)




                this.moveScrubberFamilyAtTime(this.IntervalEndTime);
                notify(this,'PlayEnd');

                this.unfreezeInPlayEndOrPause();
                this.IsInPlayModeFreeze=false;
                this.disablePlayPausePBButton();

                this.enableLeftPBButtons();
                notifyFrameChangeEvent(this);


            end
        end


        function pauseVideo(this)



            this.enableLeftRightPBButtons();
            notify(this,'PlayEnd');
            this.unfreezeInPlayEndOrPause();
            this.IsInPlayModeFreeze=false;
        end


        function setStateOfLeftPBButtons(this,state)

            this.PlayBackSection.FirstFrameBtnHandle.Enable=state;
            this.PlayBackSection.PreviousFrameBtnHandle.Enable=state;
        end


        function setStateOfRightPBButtons(this,state)

            this.PlayBackSection.NextFrameBtnHandle.Enable=state;
            this.PlayBackSection.LastFrameBtnHandle.Enable=state;
        end


        function setStateOfPlayPausePBButton(this,state)

            this.PlayBackSection.PlayPauseBtnHandle.Enable=state;
        end


        function disableLeftPBButtons(this)

            setStateOfLeftPBButtons(this,'off');
        end


        function enableLeftPBButtons(this)

            setStateOfLeftPBButtons(this,'on');
        end


        function disableLeftRightPBButtons(this)

            setStateOfLeftPBButtons(this,'off');
            setStateOfRightPBButtons(this,'off');
        end


        function enableLeftRightPBButtons(this)

            setStateOfLeftPBButtons(this,'on');
            setStateOfRightPBButtons(this,'on');
        end


        function disableRightPBButtons(this)

            setStateOfRightPBButtons(this,'off');
        end


        function enableRightPBButtons(this)

            setStateOfRightPBButtons(this,'on');
        end


        function enablePlayPausePBButton(this)
            setStateOfPlayPausePBButton(this,'on');
        end


        function disablePlayPausePBButton(this)
            setStateOfPlayPausePBButton(this,'off');
        end


        function disableAllPBButtons(this)
            disableLeftPBButtons(this);
            disablePlayPausePBButton(this);
            disableRightPBButtons(this);
        end


        function enableAllPBButtons(this)
            enableLeftPBButtons(this);
            enablePlayPausePBButton(this);
            enableRightPBButtons(this);
        end


        function disableForwardPBButtons(this)
            disablePlayPausePBButton(this);
            disableRightPBButtons(this);
        end


        function snapUnsnapCallback(obj,~,~)

            if obj.IsDoingSnap
                setString(obj,vision.getMessage('vision:labeler:ZoomOutTimeInterval'));
                moveLeftFlagFamilyToExtremeLeft(obj);
                moveRightFlagFamilyToExtremeRight(obj);
                moveScrubberForEditBoxTimesInSnapMode(obj);


                enableSnapUnsnapButton(obj);

                disableLeftRightFlags(obj);
                setStatesOfStartEndEditBoxes(obj,'off',obj.TIME_EB_BGCOLOR_DISABLE);
                obj.IsSnapMode=true;
            else
                restoreBtnEBoxFlagStateInUnsnapMode(obj);
                moveBackFlagsScrubberHLinesInUnsnapMode(obj);
            end
        end


        function setSnapUnsnapBtnCallback(obj)
            set(obj.SnapUnsnapBtnHandle,'callback',@obj.snapUnsnapCallback)
        end


        function setPlayPauseBtnCallback(obj)
            set(obj.PlayBackSection.PlayPauseBtnHandle,'callback',@obj.playPauseCallback)
        end


        function setEBStringAndUserData(~,handle,valStr)
            set(handle,'String',valStr);
            set(handle,'UserData',valStr);
        end


        function copyEBStringAndUserData(~,handleFrom,handleTo)
            valStr=get(handleFrom,'String');
            set(handleTo,'String',valStr);
            set(handleTo,'UserData',valStr);
        end


        function setEBsTimeAt(obj,hEBs,t)
            [hStr,mStr,sStr]=splitAndFormatTime(obj,t);
            if obj.HasHour
                setEBStringAndUserData(obj,hEBs.hHourEB,hStr);
            end

            if obj.HasMin
                setEBStringAndUserData(obj,hEBs.hMinEB,mStr);
            end


            setEBStringAndUserData(obj,hEBs.hSecEB,sStr);
        end


        function setCurrentTimeAt(obj,t)
            setEBsTimeAt(obj,obj.CurrentEBHandle,t);
        end


        function setCurrentTime(obj)
            setEBsTimeAt(obj,obj.CurrentEBHandle,obj.VideoStartTime);
        end


        function setStartTime(obj)
            setEBsTimeAt(obj,obj.StartEBHandle,obj.VideoStartTime);
        end


        function setEndTime(obj)
            setEBsTimeAt(obj,obj.EndEBHandle,obj.VideoEndTime);
        end


        function setDuration(obj,varargin)
            if(nargin>1)
                endTime=varargin{1};
            else
                endTime=obj.VideoEndTime;
            end
            [hStr,mStr,sStr]=splitAndFormatTime(obj,endTime);

            str='';
            if obj.HasHour
                str=[hStr,':'];
            end
            if obj.HasMin
                str=[str,mStr,':'];
            end

            str=[str,sStr];
            set(obj.DurationPanel,'String',str);
        end


        function setEndTimeAsCurrentTime(obj)
            if obj.HasHour
                copyEBStringAndUserData(obj,obj.CurrentEBHandle.hHourEB,obj.EndEBHandle.hHourEB);
            end

            if obj.HasMin
                copyEBStringAndUserData(obj,obj.CurrentEBHandle.hMinEB,obj.EndEBHandle.hMinEB);
            end


            copyEBStringAndUserData(obj,obj.CurrentEBHandle.hSecEB,obj.EndEBHandle.hSecEB);
        end


        function newCurrTimeInSec=setCurrentTimeAsStartTime(obj)
            if obj.HasHour
                copyEBStringAndUserData(obj,obj.StartEBHandle.hHourEB,obj.CurrentEBHandle.hHourEB);
            end

            if obj.HasMin
                copyEBStringAndUserData(obj,obj.StartEBHandle.hMinEB,obj.CurrentEBHandle.hMinEB);
            end


            copyEBStringAndUserData(obj,obj.StartEBHandle.hSecEB,obj.CurrentEBHandle.hSecEB);
            newCurrTimeInSec=getTimeFromEB(obj,obj.StartEBHandle);
        end


        function newCurrTimeInSec=setCurrentTimeAsEndTime(obj)
            if obj.HasHour
                copyEBStringAndUserData(obj,obj.EndEBHandle.hHourEB,obj.CurrentEBHandle.hHourEB);
            end

            if obj.HasMin
                copyEBStringAndUserData(obj,obj.EndEBHandle.hMinEB,obj.CurrentEBHandle.hMinEB);
            end


            copyEBStringAndUserData(obj,obj.EndEBHandle.hSecEB,obj.CurrentEBHandle.hSecEB);
            newCurrTimeInSec=getTimeFromEB(obj,obj.EndEBHandle);
        end


        function[hEB,hTimeValuePanel,endX,endY]=createTimeLabelAndEditBoxes(obj,info)


            timeLabelX=info.startX;
            timeLabelY=5;

            timeLabel=info.labelText;

            clearanceW=obj.CharWidthInPixels;
            clearanceH=floor(obj.CharHeightInPixels/2);
            timeLabelW=length(timeLabel)*obj.CharWidthInPixels*4;
            timeLabelH=obj.CharHeightInPixels+5;

            params.parent=obj.TimePanel;
            params.position=[timeLabelX,timeLabelY,timeLabelW,timeLabelH];
            params.backgroundColor=get(params.parent,'backgroundColor');
            params.string=timeLabel;
            createLabel(params);


            if obj.HasHour
                timeFormatStr='hh:mm:ss.sssss';
            elseif obj.HasMin
                timeFormatStr='mm:ss.sssss';
            else
                timeFormatStr='ss.sssss';
            end

            magicNumberFullW=getAdjValueForFullEditBox(obj);
            timeValueW=length(timeFormatStr)*obj.CharWidthInPixels+clearanceW*4+magicNumberFullW;
            timeValueH=22;
            timeValueX=timeLabelX;
            timeValueY=timeLabelY+timeLabelH+5;
            params.position=[timeValueX,timeValueY,timeValueW,timeValueH];
            endY=timeValueY+timeValueH;
            params.backgroundColor=[1,1,1];
            params.borderWidth=1;
            params.highlightColor=[0.8,0.8,0.8];

            params.tag='';
            hTimeValuePanel=createPanel(params);
            params.parent=hTimeValuePanel;

            timeValueEndX=timeValueX+timeValueW;
            endX=timeValueEndX;

            hourX=1;
            hourY=floor(clearanceH/2);
            maxNumHourChars=2;
            hourH=obj.CharHeightInPixels;

            [magicNumberHr,magicNumberMin,magicNumberSec]=getAdjValueForThisEditBox(obj);

            if obj.HasHour

                hourW=maxNumHourChars*obj.CharWidthInPixels+clearanceW+magicNumberHr;

                params.position=[hourX,hourY,hourW,hourH];
                params.ebString='00';
                hEB.hHourEB=createBorderlessEditBox(obj,params,info.hourTag);


                hColonX=hourX+hourW;
                hColonY=hourY;
                hColonW=obj.CharWidthInPixels;
                hColonH=hourH;

                params.position=[hColonX,hColonY,hColonW,hColonH];
                hEB.hHourColon=createColonLabel(params);
            else
                assert(~obj.HasHour);
                hEB.hHourEB=[];
                hColonX=hourX;
                hColonW=0;
            end


            if obj.HasMin
                minX=hColonX+hColonW;
                minY=hourY;
                maxNumMinChars=2;
                minW=maxNumMinChars*obj.CharWidthInPixels+clearanceW+magicNumberMin;
                minH=hourH;

                params.position=[minX,minY,minW,minH];
                params.ebString='00';
                hEB.hMinEB=createBorderlessEditBox(obj,params,info.minTag);


                mColonX=minX+minW;
                mColonY=hourY;
                mColonW=obj.CharWidthInPixels;
                mColonH=hourH;

                params.position=[mColonX,mColonY,mColonW,mColonH];
                hEB.hMinColon=createColonLabel(params);
            else

                hEB.hMinEB=[];
                mColonX=hourX;
                mColonW=0;
            end

            minX=mColonX+mColonW;
            minY=hourY;
            maxNumSecChars=8;
            minW=maxNumSecChars*obj.CharWidthInPixels+clearanceW+magicNumberSec;
            minH=hourH;

            params.position=[minX,minY,minW,minH];
            params.ebString='00.00000';
            hEB.hSecEB=createBorderlessEditBox(obj,params,info.secTag);
        end


        function[endX,endY]=createDurationLabel(obj,info)


            timeLabelX=info.startX;
            timeLabelY=5;

            timeLabel=info.labelText;

            clearanceW=obj.CharWidthInPixels;
            timeLabelW=length(timeLabel)*obj.CharWidthInPixels*4;
            timeLabelH=obj.CharHeightInPixels+5;

            params.parent=obj.TimePanel;
            params.position=[timeLabelX,timeLabelY,timeLabelW,timeLabelH];
            params.backgroundColor=get(params.parent,'backgroundColor');
            params.string=timeLabel;
            createLabel(params);


            if obj.HasHour
                timeFormatStr='hh:mm:ss.sssss';
            elseif obj.HasMin
                timeFormatStr='mm:ss.sssss';
            else
                timeFormatStr='ss.sssss';
            end
            magicNumberDur=10;
            timeValueW=length(timeFormatStr)*obj.CharWidthInPixels+clearanceW*4+magicNumberDur;
            timeValueH=22;
            timeValueX=timeLabelX;
            timeValueY=timeLabelY+timeLabelH+1;
            params.position=[timeValueX,timeValueY,timeValueW,timeValueH];
            params.string=timeLabel;
            endY=timeValueY+timeValueH;

            obj.DurationPanel=createLabel(params);

            timeValueEndX=timeValueX+timeValueW;
            endX=timeValueEndX;

        end


        function hEB=createBorderlessEditBox(obj,params,ebTag)

            params.backgroundColor=get(params.parent,'backgroundColor');
            params.borderWidth=0;
            params.tag='';
            hPanel=createPanel(params);
            hPanel.BorderType='None';
            if ispc
                params.position=[0,0,params.position(3)+2,params.position(4)+2];
            else
                params.position=[-1,-1,params.position(3)+4,params.position(4)+4];
            end

            if obj.HasHour
                params.TooltipString='Time (h:m:s)';
            elseif obj.HasMin
                params.TooltipString='Time (m:s)';
            else
                params.TooltipString='Time (s)';
            end

            hEB=uicontrol('parent',hPanel,...
            'Tag',ebTag,...
            'position',params.position,...
            'HorizontalAlignment','right',...
            'backgroundColor',[1,1,1],...
            'Style','edit',...
            'String',params.ebString,...
            'TooltipString',params.TooltipString);
            set(hEB,'UserData',params.ebString);
        end


        function changeScrubberColorOnMouseButtonDown(obj,hObject)

            set(hObject,'backgroundcolor',obj.SCRUBBER_BGCOLOR_DRAGGED);
        end


        function changeLeftFlagColorOnMouseButtonDown(obj,hObject)

            set(hObject,'backgroundcolor',obj.FLAG_BGCOLOR_DRAGGED);
            set(obj.LeftPolePanel,'backgroundcolor',obj.FLAG_BGCOLOR_DRAGGED);
        end


        function changeRightFlagColorOnMouseButtonDown(obj,hObject)

            set(hObject,'backgroundcolor',obj.FLAG_BGCOLOR_DRAGGED);
            set(obj.RightPolePanel,'backgroundcolor',obj.FLAG_BGCOLOR_DRAGGED);
        end


        function hLineBtnDownCallback(obj,~,~)

            mouseClickType=get(obj.FigHandle,'SelectionType');
            if~strcmp(mouseClickType,'normal')
                return;
            end

            [oldUnits,newPointXwrtSliderPanel]=setFigInPixelGetGrabPt(obj);
            scrubberPos_tmp=get(obj.ScrubberPanel,'position');
            scrubberPos_tmp(1)=newPointXwrtSliderPanel;

            leftPolePos_tmp=get(obj.LeftPolePanel,'position');
            rightPolePos_tmp=get(obj.RightPolePanel,'position');


            scrubberHalfW=floor(scrubberPos_tmp(3)/2);

            xL=(leftPolePos_tmp(1)+leftPolePos_tmp(3)-1)-scrubberHalfW;

            xR=rightPolePos_tmp(1)-scrubberHalfW;

            newScrubberPos=scrubberPos_tmp;
            cond=obj.SCRUBBER_REGULAR_POS;
            if(scrubberPos_tmp(1)<=xL)||(scrubberPos_tmp(1)>=xR)

                restoreUnits(obj,obj.FigHandle,oldUnits);
                return;
            else
                if all(isfinite(newScrubberPos))
                    set(obj.ScrubberPanel,'position',newScrubberPos);
                end
            end


            scrubberMidX=newScrubberPos(1)+scrubberHalfW;
            setMiddleHLinePos(obj,scrubberMidX);
            addAssert(obj,obj.MiddleHLinePanel,'figScrubberMotionCallback');


            updateCurrentTime(obj,scrubberMidX,cond);

            if all(isfinite(newScrubberPos))
                notify(obj,'ScrubberMoved');
                notifyFrameChangeEvent(obj);

                if(isPlayPausePBButtonEnabled(obj)&&~obj.IsVideoPaused)...
                    &&obj.IsInPlayModeFreeze
                    disableLeftPBButtons(obj);
                    disableRightPBButtons(obj);
                else
                    enableAllPBButtons(obj);
                    changePauseToPlay(obj);




                    obj.figScrubberButtonUpCallback();
                end
            end


            restoreUnits(obj,obj.FigHandle,oldUnits);
        end


        function scrubberBtnDownCallback(obj,hObject,~)

            if~obj.IsScrubberBtnDown
                obj.IsScrubberBtnDown=true;
            else

                return;
            end




            obj.IsScrubberBtnUpCalled=false;


            changeScrubberColorOnMouseButtonDown(obj,hObject);
            notify(obj,'ScrubberPressed');


            origWindowButtonMotionFcn=get(obj.FigHandle,'WindowButtonMotionFcn');
            setappdata(obj.FigHandle,'origWinBtnMotFcn_FromScrubber',origWindowButtonMotionFcn);



            set(obj.FigHandle,'WindowButtonMotionFcn',@obj.figScrubberMotionCallback);
            saveOldSetNewMPointerForBtn(obj);











            if isempty(obj.BtnRelListner4Scrubber)
                obj.BtnRelListner4Scrubber=addlistener(obj.FigHandle,...
                'WindowMouseRelease',@obj.figScrubberButtonUpCallback);
            end
        end


        function saveOldSetNewMPointerForBtn(obj)
            obj.OrigPointerForBtn=get(obj.FigHandle,'pointer');
            if ispc
                set(obj.FigHandle,'pointer','right');
            else
                set(obj.FigHandle,'pointer','hand');
            end
        end


        function restoreMPointerForBtn(obj)
            if~isempty(obj.OrigPointerForBtn)
                set(obj.FigHandle,'pointer',obj.OrigPointerForBtn);
            end
        end


        function saveOldSetNewMPointerForFig(obj)
            obj.OrigPointerForFig=get(obj.FigHandle,'pointer');
            if ispc
                set(obj.FigHandle,'pointer','right');
            else
                set(obj.FigHandle,'pointer','hand');
            end
        end


        function restoreMPointerForFig(obj)
            if~isempty(obj.OrigPointerForFig)
                set(obj.FigHandle,'pointer',obj.OrigPointerForFig);
            end
        end

        function leftFlagBtnDownCallback(obj,hObject,~)

            if~obj.IsLeftOrRightFlagBtnDown
                obj.IsLeftOrRightFlagBtnDown=true;
            else

                return;
            end


            changeLeftFlagColorOnMouseButtonDown(obj,hObject);


            origWindowButtonMotionFcn=get(obj.FigHandle,'WindowButtonMotionFcn');
            setappdata(obj.FigHandle,'origWinBtnMotFcn_FromLeftRightFlag',origWindowButtonMotionFcn);



            set(obj.FigHandle,'WindowButtonMotionFcn',@obj.figLeftFlagMotionCallback);
            saveOldSetNewMPointerForBtn(obj);


            if isempty(obj.BtnRelListner4LeftRightFlag)
                obj.BtnRelListner4LeftRightFlag=addlistener(obj.FigHandle,...
                'WindowMouseRelease',@obj.figLeftOrRightFlagButtonUpCallback);
            end

        end


        function rightFlagBtnDownCallback(obj,hObject,~)

            if~obj.IsLeftOrRightFlagBtnDown
                obj.IsLeftOrRightFlagBtnDown=true;
            else

                return;
            end


            changeRightFlagColorOnMouseButtonDown(obj,hObject);


            origWindowButtonMotionFcn=get(obj.FigHandle,'WindowButtonMotionFcn');
            setappdata(obj.FigHandle,'origWinBtnMotFcn_FromLeftRightFlag',origWindowButtonMotionFcn);



            set(obj.FigHandle,'WindowButtonMotionFcn',@obj.figRightFlagMotionCallback);
            saveOldSetNewMPointerForBtn(obj);


            if isempty(obj.BtnRelListner4LeftRightFlag)
                obj.BtnRelListner4LeftRightFlag=addlistener(obj.FigHandle,...
                'WindowMouseRelease',@obj.figLeftOrRightFlagButtonUpCallback);
            end

        end


        function[oldUnits,newPointXwrtSliderPanel]=setFigInPixelGetGrabPt(obj)

            oldUnits=getOldUnitsAndSetToPixels(obj,obj.FigHandle);
            newPoint=get(obj.FigHandle,'currentPoint');



            newPointXwrtSliderPanel=newPoint(1)-obj.XposImagePanel;
        end


        function currentT=getTimeForPosition(obj,scrubberMidX,startT,endT)







            fullHLen_inRange=obj.FullHLineLength-1;
            currentT=((endT-startT)/fullHLen_inRange)*scrubberMidX+startT;
        end


        function scrubberMidX=getScrubberMidXFromTime(obj,startT,currentT,endT)








            fullHLen_inRange=obj.FullHLineLength-1;
            if(endT~=startT)
                scrubberMidXwrtStartTpos=floor((fullHLen_inRange/(endT-startT))*(currentT-startT));
                scrubberMidX=scrubberMidXwrtStartTpos+obj.Xoffset;
            else
                scrubberMidX=obj.Xoffset;
            end
        end


        function newEndT=updateTimeValue(obj,hThisEB,posXwrtPanel,startT,endT)

            pos=get(obj.FullHLinePanel,'position');
            posXwrtFullHLine=posXwrtPanel-pos(1);
            newEndT=getTimeForPosition(obj,posXwrtFullHLine,startT,endT);

            [hStr,mStr,sStr]=splitAndFormatTime(obj,newEndT);

            if obj.HasHour
                set(hThisEB.hHourEB,'String',hStr);
                set(hThisEB.hHourEB,'UserData',hStr);
            end

            if obj.HasMin
                set(hThisEB.hMinEB,'String',mStr);
                set(hThisEB.hMinEB,'UserData',mStr);
            end

            set(hThisEB.hSecEB,'String',sStr);
            set(hThisEB.hSecEB,'UserData',sStr);
        end


        function updateEndTime(obj,rightFlag_leftVBorder,cond)





            startT=obj.VideoStartTime;
            endT=obj.VideoEndTime;

            if(cond==obj.RIGHT_FLAG_REGULAR_POS)
                updateTimeValue(obj,obj.EndEBHandle,rightFlag_leftVBorder,startT,endT);
            elseif(cond==obj.RIGHT_FLAG_EXTEREME_RIGHT)
                setEndTime(obj);
            else
                setEndTimeAsCurrentTime(obj);
            end
        end


        function updateStartTime(obj,leftFlag_rightVBorder,cond)





            startT=obj.VideoStartTime;
            endT=obj.VideoEndTime;

            if(cond==obj.LEFT_FLAG_REGULAR_POS)
                updateTimeValue(obj,obj.StartEBHandle,leftFlag_rightVBorder,startT,endT);
            elseif(cond==obj.LEFT_FLAG_EXTEREME_LEFT)
                setStartTime(obj);
            else
                setStartTimeAsCurrentTime(obj);
            end
        end


        function updateCurrentTime(obj,scrubberMidX,cond)




            if obj.IsSnapMode
                startT=getTimeFromEB(obj,obj.StartEBHandle);
                endT=getTimeFromEB(obj,obj.EndEBHandle);
            else
                startT=obj.VideoStartTime;
                endT=obj.VideoEndTime;
            end
            if(cond==obj.SCRUBBER_REGULAR_POS)
                updateTimeValue(obj,obj.CurrentEBHandle,scrubberMidX,startT,endT);
            elseif(cond==obj.SCRUBBER_EXTEREME_LEFT)
                setCurrentTimeAsStartTime(obj);
            else
                setCurrentTimeAsEndTime(obj);
            end
        end


        function addAssert(obj,HLinePanel,id)
            if obj.TEST_MODE
                HLinePos=get(HLinePanel,'position');
                pos=get(obj.FullHLinePanel,'position');
                endX=pos(1)+pos(3)-1;

                if(HLinePos(1)+HLinePos(3)-1)~=endX
                    error(['WRONG:',id,': HLinePos(1)+HLinePos(3)-1) ~= endX']);
                end
            end
        end


        function figScrubberMotionCallback(obj,~,~)

            [oldUnits,newPointXwrtSliderPanel]=setFigInPixelGetGrabPt(obj);
            scrubberPos_tmp=get(obj.ScrubberPanel,'position');
            scrubberPos_tmp(1)=newPointXwrtSliderPanel;


            leftPolePos_tmp=get(obj.LeftPolePanel,'position');
            rightPolePos_tmp=get(obj.RightPolePanel,'position');


            scrubberHalfW=floor(scrubberPos_tmp(3)/2);

            xL=(leftPolePos_tmp(1)+leftPolePos_tmp(3)-1)-scrubberHalfW;

            xR=rightPolePos_tmp(1)-scrubberHalfW;

            newScrubberPos=scrubberPos_tmp;
            cond=obj.SCRUBBER_REGULAR_POS;
            if(scrubberPos_tmp(1)<=xL)
                newScrubberPos(1)=xL;
                cond=obj.SCRUBBER_EXTEREME_LEFT;
            end
            if(scrubberPos_tmp(1)>=xR)
                newScrubberPos(1)=xR;
                cond=obj.SCRUBBER_EXTEREME_RIGHT;
            end
            if all(isfinite(newScrubberPos))
                set(obj.ScrubberPanel,'position',newScrubberPos);
            end


            scrubberMidX=newScrubberPos(1)+scrubberHalfW;
            setMiddleHLinePos(obj,scrubberMidX);
            addAssert(obj,obj.MiddleHLinePanel,'figScrubberMotionCallback');


            updateCurrentTime(obj,scrubberMidX,cond);


















            if~obj.IsScrubberBtnUpCalled

                notify(obj,'ScrubberMoved');


                wasInterrupted=obj.checkAfterScrubberMovedEvt(oldUnits);
                if wasInterrupted
                    return;
                end

                notifyFrameChangeEvent(obj);
            end

            drawnow;


            restoreUnits(obj,obj.FigHandle,oldUnits);
        end


        function figLeftFlagMotionCallback(obj,~,~)


            [oldUnits,newPointXwrtSliderPanel]=setFigInPixelGetGrabPt(obj);

            scrubberPos_tmp=get(obj.ScrubberPanel,'position');
            scrubberMidX=scrubberPos_tmp(1)+floor(scrubberPos_tmp(3)/2);


            leftFlagPos_tmp=get(obj.LeftFlagPanel,'position');
            flagW=leftFlagPos_tmp(3);
            flagStartX=newPointXwrtSliderPanel;
            leftFlag_rightVBorder=flagStartX+flagW-1;

            min_leftFlag_rightVBorder=obj.Xoffset;
            cond=obj.LEFT_FLAG_REGULAR_POS;
            if(leftFlag_rightVBorder<=min_leftFlag_rightVBorder)
                leftFlag_rightVBorder=min_leftFlag_rightVBorder;
                cond=obj.LEFT_FLAG_EXTEREME_LEFT;
            end

            if(leftFlag_rightVBorder>=scrubberMidX)
                leftFlag_rightVBorder=scrubberMidX;
                cond=obj.LEFT_FLAG_AT_SCRUBBER_MIDX;
            end
            leftFlagPos_tmp(1)=leftFlag_rightVBorder-flagW+1;
            if all(isfinite(leftFlagPos_tmp))
                set(obj.LeftFlagPanel,'position',leftFlagPos_tmp);
            end


            setLeftPolePos(obj,leftFlag_rightVBorder);


            setLeftHLinePos(obj,leftFlag_rightVBorder);


            updateStartTime(obj,leftFlag_rightVBorder,cond);


            restoreUnits(obj,obj.FigHandle,oldUnits);
        end


        function figRightFlagMotionCallback(obj,~,~)


            [oldUnits,newPointXwrtSliderPanel]=setFigInPixelGetGrabPt(obj);

            scrubberPos_tmp=get(obj.ScrubberPanel,'position');
            scrubberMidX=scrubberPos_tmp(1)+floor(scrubberPos_tmp(3)/2);


            rightFlagPos_tmp=get(obj.RightFlagPanel,'position');
            flagStartX=newPointXwrtSliderPanel;
            rightFlag_leftVBorder=flagStartX;

            cond=obj.RIGHT_FLAG_REGULAR_POS;
            if(rightFlag_leftVBorder<=(scrubberMidX))
                rightFlag_leftVBorder=scrubberMidX;
                cond=obj.RIGHT_FLAG_AT_SCRUBBER_MIDX;
            end

            max_rightFlag_leftVBorder=obj.FullHLineLength+obj.Xoffset-1;
            if(rightFlag_leftVBorder>=max_rightFlag_leftVBorder)
                rightFlag_leftVBorder=max_rightFlag_leftVBorder;
                cond=obj.RIGHT_FLAG_EXTEREME_RIGHT;
            end
            rightFlagPos_tmp(1)=rightFlag_leftVBorder;
            if all(isfinite(rightFlagPos_tmp))
                set(obj.RightFlagPanel,'position',rightFlagPos_tmp);
            end


            setRightPolePos(obj,rightFlag_leftVBorder);


            setRightHLinePos(obj,rightFlag_leftVBorder);


            updateEndTime(obj,rightFlag_leftVBorder,cond);


            restoreUnits(obj,obj.FigHandle,oldUnits);
        end


        function flag=isLeftPoleAtExtremeLeft(obj)

            posV=get(obj.LeftPolePanel,'position');
            leftPoleEndX=posV(1)+posV(3)-1;
            posF=get(obj.FullHLinePanel,'position');
            fullHLineStartX=posF(1);
            flag=(leftPoleEndX==fullHLineStartX);
        end

        function flag=isRightPoleAtExtremeRight(obj)

            posV=get(obj.RightPolePanel,'position');
            leftPoleStartX=posV(1);
            posF=get(obj.FullHLinePanel,'position');
            fullHLineEndX=posF(1)+posF(3)-1;
            flag=(leftPoleStartX==fullHLineEndX);
        end


        function flag=areCurrentAndEndTimeSame(this)
            flag=(getSliderCurrentTime(this)==getSliderEndTime(this));
        end


        function flag=areCurrentAndStartTimeSame(this)
            flag=(getSliderCurrentTime(this)==getSliderStartTime(this));
        end


        function updatePlayBackControlState(this)
            currentETend=areCurrentAndEndTimeSame(this);
            currentETstart=areCurrentAndStartTimeSame(this);
            if(currentETend&&currentETstart)
                disableAllPBButtons(this);
            else
                enableAllPBButtons(this);

                if currentETend
                    disableForwardPBButtons(this);
                    this.changePlayToPause();
                else
                    if currentETstart
                        disableLeftPBButtons(this);
                    end
                    this.changePauseToPlay();
                end
            end
        end


        function figScrubberButtonUpCallback(obj,~,~)



            obj.IsScrubberBtnDown=false;

            obj.IsScrubberBtnUpCalled=true;


            set(obj.ScrubberPanel,'backgroundcolor',obj.SCRUBBER_BGCOLOR_ENABLE)


            origWindowButtonMotionFcn=getappdata(obj.FigHandle,'origWinBtnMotFcn_FromScrubber');
            set(obj.FigHandle,'WindowButtonMotionFcn',origWindowButtonMotionFcn);


            set(obj.FigHandle,'units',obj.OrigFigUnits);

            restoreMPointerForBtn(obj);


            if~(obj.CaughtExceptionDuringPlay)


                notify(obj,'ScrubberReleased');
            end

            updatePlayBackControlState(obj);


            setappdata(obj.FigHandle,'origWinBtnMotFcn_FromScrubber',[]);









            if(~obj.IsScrubberBtnDown)

                delete(obj.BtnRelListner4Scrubber);
                obj.BtnRelListner4Scrubber=[];
            end
        end


        function figLeftOrRightFlagButtonUpCallback(obj,~,~)



            obj.IsLeftOrRightFlagBtnDown=false;

            restoreMPointerForBtn(obj);
            if obj.IsSnapMode
                return;
            end

            set(obj.LeftFlagPanel,'backgroundcolor',obj.FLAG_BGCOLOR_ENABLE)
            set(obj.RightFlagPanel,'backgroundcolor',obj.FLAG_BGCOLOR_ENABLE)






            set(obj.LeftPolePanel,'backgroundcolor',obj.FLAG_BGCOLOR_ENABLE);
            set(obj.RightPolePanel,'backgroundcolor',obj.FLAG_BGCOLOR_ENABLE);

            if(isLeftPoleAtExtremeLeft(obj)&&...
                isRightPoleAtExtremeRight(obj))
                set(obj.SnapUnsnapBtnHandle,'enable','off');
            else
                set(obj.SnapUnsnapBtnHandle,'enable','on');
            end

            set(obj.FigHandle,'WindowButtonMotionFcn','','units',obj.OrigFigUnits);

            updatePlayBackControlState(obj);


            origWindowButtonMotionFcn=getappdata(obj.FigHandle,'origWinBtnMotFcn_FromLeftRightFlag');
            set(obj.FigHandle,'WindowButtonMotionFcn',origWindowButtonMotionFcn);


            setappdata(obj.FigHandle,'origWinBtnMotFcn_FromLeftRightFlag',[]);


            delete(obj.BtnRelListner4LeftRightFlag);
            obj.BtnRelListner4LeftRightFlag=[];

            notify(obj,'StartOrEndTimeUpdated');
        end


        function t=getTimeFromEBwithVal(obj,hEB,val,hmsEBoxID)

            t=0;
            if obj.HasHour
                if(hmsEBoxID==obj.HOUR_EB_ID)
                    t=t+val*3600;
                else
                    t=t+str2double(get(hEB.hHourEB,'string'))*3600;
                end
            end
            if obj.HasMin
                if(hmsEBoxID==obj.MIN_EB_ID)
                    t=t+val*60;
                else
                    t=t+str2double(get(hEB.hMinEB,'string'))*60;
                end
            end
            if(hmsEBoxID==obj.SEC_EB_ID)
                t=t+val;
            else
                t=t+str2double(get(hEB.hSecEB,'string'));
            end
        end


        function t=getTimeFromEB(obj,hEB)

            t=0;
            if obj.HasHour
                t=t+str2double(get(hEB.hHourEB,'string'))*3600;
            end
            if obj.HasMin
                t=t+str2double(get(hEB.hMinEB,'string'))*60;
            end

            t=t+str2double(get(hEB.hSecEB,'string'));
        end


        function setMiddleHLinePos(obj,scrubberMidX)

            middleHLinePos_tmp=get(obj.MiddleHLinePanel,'position');
            if obj.TEST_MODE
                HLine_endX=middleHLinePos_tmp(1)+middleHLinePos_tmp(3)-1;
                assert(HLine_endX==(obj.FullHLineLength+obj.Xoffset-1));
            end

            HLine_endX=obj.FullHLineLength+obj.Xoffset-1;

            middleHLinePos_tmp(1)=scrubberMidX;
            middleHLinePos_tmp(3)=max(HLine_endX-middleHLinePos_tmp(1)+1,1);
            if all(isfinite(middleHLinePos_tmp))
                set(obj.MiddleHLinePanel,'position',middleHLinePos_tmp);
            end
        end


        function setLeftHLinePos(obj,leftFlag_rightVBorder)
            leftHLinePos_tmp=get(obj.LeftHLinePanel,'position');
            if obj.TEST_MODE
                HLine_endX=leftHLinePos_tmp(1)+leftHLinePos_tmp(3)-1;
                assert(HLine_endX==(obj.FullHLineLength+obj.Xoffset-1));
            end

            HLine_endX=obj.FullHLineLength+obj.Xoffset-1;

            leftHLinePos_tmp(1)=leftFlag_rightVBorder;
            leftHLinePos_tmp(3)=max(HLine_endX-leftHLinePos_tmp(1)+1,1);
            if all(isfinite(leftHLinePos_tmp))
                set(obj.LeftHLinePanel,'position',leftHLinePos_tmp);
            end
            addAssert(obj,obj.LeftHLinePanel,'setLeftHLinePos');
        end


        function setRightPolePos(obj,rightFlag_leftVBorder)
            rightPolePos_tmp=get(obj.RightPolePanel,'position');
            rightPolePos_tmp(1)=rightFlag_leftVBorder;
            if all(isfinite(rightPolePos_tmp))
                set(obj.RightPolePanel,'position',rightPolePos_tmp);
            end
        end


        function setLeftPolePos(obj,leftFlag_rightVBorder)

            leftPolePos_tmp=get(obj.LeftPolePanel,'position');
            w=leftPolePos_tmp(3);
            leftPolePos_tmp(1)=leftFlag_rightVBorder-w+1;
            if all(isfinite(leftPolePos_tmp))
                set(obj.LeftPolePanel,'position',leftPolePos_tmp);
            end
        end


        function setRightHLinePos(obj,rightFlag_leftVBorder)

            rightHLinePos_tmp=get(obj.RightHLinePanel,'position');

            if obj.TEST_MODE
                HLine_endX=rightHLinePos_tmp(1)+rightHLinePos_tmp(3)-1;
                assert(HLine_endX==(obj.FullHLineLength+obj.Xoffset-1));
            end

            HLine_endX=obj.FullHLineLength+obj.Xoffset-1;
            rightHLinePos_tmp(1)=rightFlag_leftVBorder;
            rightHLinePos_tmp(3)=max(HLine_endX-rightHLinePos_tmp(1)+1,1);
            if all(isfinite(rightHLinePos_tmp))
                set(obj.RightHLinePanel,'position',rightHLinePos_tmp);
            end
            addAssert(obj,obj.RightHLinePanel,'setRightHLinePos');
        end


        function moveScrubberFamily(obj,scrubberMidX)


            scrubberPos_tmp=get(obj.ScrubberPanel,'position');
            scrubberW=scrubberPos_tmp(3);
            startX=scrubberMidX-floor(scrubberW/2);
            scrubberPos_tmp(1)=startX;
            if all(isfinite(scrubberPos_tmp))
                set(obj.ScrubberPanel,'position',scrubberPos_tmp);
            end


            setMiddleHLinePos(obj,scrubberMidX);
            addAssert(obj,obj.MiddleHLinePanel,'moveScrubberFamily');
        end


        function moveLeftFlagFamilyToEndX(obj,leftFlag_rightVBorder)


            leftFlagPos_tmp=get(obj.LeftFlagPanel,'position');
            flagW=leftFlagPos_tmp(3);
            leftFlagPos_tmp(1)=leftFlag_rightVBorder-flagW+1;
            if all(isfinite(leftFlagPos_tmp))
                set(obj.LeftFlagPanel,'position',leftFlagPos_tmp);
            end


            setLeftPolePos(obj,leftFlag_rightVBorder)


            setLeftHLinePos(obj,leftFlag_rightVBorder);
        end


        function moveLeftFlagFamilyToExtremeLeft(obj)

            pos=get(obj.FullHLinePanel,'position');
            leftFlag_rightVBorder=pos(1);
            moveLeftFlagFamilyToEndX(obj,leftFlag_rightVBorder);
            notify(obj,'StartOrEndTimeUpdated');
        end


        function moveRightFlagFamilyToEndX(obj,rightFlag_leftVBorder)


            rightFlagPos_tmp=get(obj.RightFlagPanel,'position');
            rightFlagPos_tmp(1)=rightFlag_leftVBorder;
            if all(isfinite(rightFlagPos_tmp))
                set(obj.RightFlagPanel,'position',rightFlagPos_tmp);
            end


            setRightPolePos(obj,rightFlag_leftVBorder)


            setRightHLinePos(obj,rightFlag_leftVBorder);
        end


        function moveRightFlagFamilyToExtremeRight(obj)

            rightFlag_leftVBorder=obj.FullHLineLength+obj.Xoffset-1;
            moveRightFlagFamilyToEndX(obj,rightFlag_leftVBorder);
            notify(obj,'StartOrEndTimeUpdated');
        end


        function createSnapUnsnapBtn(obj,params)

            obj.SnapUnsnapBtnHandle=uicontrol('parent',params.parent,...
            'Units','pixels',...
            'position',params.position,...
            'HorizontalAlignment','right',...
            'backgroundColor',params.backgroundColor,...
            'Style','togglebutton',...
            'Max',1,'Min',0,...
            'Tag','Snap Unsnap',...
            'String',vision.getMessage('vision:labeler:ZoomInTimeInterval'),...
            'Enable','off',...
            'KeyPressFcn',obj.KeyPressCallback,...
            'TooltipString',vision.getMessage('vision:labeler:ZoomInTimeIntervalToolTip'));
        end


        function imOut=blendAlphaImageWithBG(~,imIn,bgColor,a)
            assert(ismatrix(imIn));
            imIn=im2double(imIn);
            imOut=zeros([size(imIn),3],'like',imIn);
            a=double(a)/255;

            for i=1:3
                imOut(:,:,i)=bgColor(i)*(1-a)+a.*imIn(:,:);
            end
        end


        function[hStr,mStr,sStr]=splitAndFormatTime(obj,ts)
            [h,m,s]=splitTime(ts);
            if obj.HasHour
                hStr=sprintf('%02d',h);
            else
                hStr='';
            end
            if obj.HasMin
                mStr=sprintf('%02d',m);
            else
                mStr='';
            end
            sStr=formatSec(s);
        end


        function magicNumber=getAdjValueForFullEditBox(obj)

            if obj.HasHour
                if ispc
                    magicNumber=10;
                else
                    magicNumber=0;
                end
            elseif obj.HasMin
                if ispc
                    magicNumber=0;
                else
                    magicNumber=-5;
                end
            else
                magicNumber=-7;
            end
        end


        function[magicNumberHr,magicNumberMin,magicNumberSec]=getAdjValueForThisEditBox(obj)

            if obj.HasMin
                if ispc
                    magicNumberSec=5;
                else
                    magicNumberSec=0;
                end
            else
                magicNumberSec=5;
            end

            if obj.HasHour
                if ispc
                    magicNumberMin=3;
                else
                    magicNumberMin=-2;
                end
            else
                magicNumberMin=3;
            end

            magicNumberHr=3;
        end


        function wasInterrupted=checkAfterScrubberMovedEvt(obj,oldUnits)



            if obj.CaughtExceptionDuringPlay



                obj.figScrubberButtonUpCallback();
                resetExceptionDuringPlay(obj);

                restoreUnits(obj,obj.FigHandle,oldUnits);
                wasInterrupted=true;
                return;
            end






            if obj.IsScrubberBtnUpCalled


                obj.figScrubberButtonUpCallback();
                restoreUnits(obj,obj.FigHandle,oldUnits);
                wasInterrupted=true;
                return;
            end



            wasInterrupted=false;
        end
    end





    methods


        function setDefaultMasterSignal(obj,signalData)


            signalNames=signalData.SignalName;
            timeVectors=signalData.TimeVectors;
            numSignals=numel(signalNames);

            if numSignals>0

                frameRates=zeros(numSignals,1);

                for sigId=1:numSignals
                    if(length(timeVectors{sigId})>1)
                        frameRates(sigId)=seconds(timeVectors{sigId}(2))-seconds(timeVectors{sigId}(1));
                    else
                        frameRates(sigId)=seconds(timeVectors{sigId}(1));
                    end
                end

                [~,masterSignalIdx]=min(frameRates);
                obj.MasterSignal=signalNames(masterSignalIdx);

                obj.TimeVector=seconds(timeVectors{masterSignalIdx});
                obj.LastQueryTimestamp=obj.TimeVector(1);
                obj.SignalData=signalData;
            end

        end


        function tStart=getSignalStartTime(obj)
            tStart=obj.TimeVector(1);
        end


        function tEnd=getSignalEndTime(obj)
            tEnd=obj.TimeVector(end);
        end


        function tStart=getRangeSliderStartTimeWithCheck(obj)
            tStart=obj.IntervalStartTime;

            if tStart==obj.VideoStartTime
                tStart=obj.TimeVector(1);
            end
        end


        function tEnd=getRangeSliderEndTimeWithCheck(obj,signalName)
            tEnd=obj.IntervalEndTime;

            if nargin<2
                tEnd=readjustEndTimeForAny(obj,tEnd);
            else
                tEnd=readjustEndTimeForSignal(obj,tEnd,signalName);
            end
        end


        function tCur=getRangeSliderCurrentTimeWithCheck(obj)

            tCur=obj.ScrubberCurrentTime;
            tEnd=obj.IntervalEndTime;

            if tCur==tEnd
                tCur=getRangeSliderEndTimeWithCheck(obj);
            end
        end


        function[tEnd,tv]=getSignalEndTimePlusFrameRate(obj,signalName)

            if nargin<2
                tv=obj.TimeVector;
            else
                sigIdx=(obj.SignalData.SignalName==signalName);
                tv=seconds(obj.SignalData.TimeVectors{sigIdx});
            end
            if numel(tv)>1
                frameRate=tv(2)-tv(1);
            else



                frameRate=1;
            end
            tEnd=tv(end)+frameRate;
        end


        function timeVector=getSignalTimeVector(obj)
            timeVector=obj.TimeVector;
        end


        function nextFramTime=getNextFrameTime(obj)
            lastReadIdx=obj.LastReadIndex;
            numTs=numel(obj.TimeVector);
            nextIdx=min(numTs,lastReadIdx+1);
            nextFramTime=obj.TimeVector(nextIdx);
        end


        function prevFrameTime=getPrevFrameTime(obj)
            lastReadIdx=obj.LastReadIndex;
            prevIdx=max(1,lastReadIdx-1);
            prevFrameTime=obj.TimeVector(prevIdx);
        end


        function lastFrameTime=getLastReadFrameTime(obj)
            lastFrameTime=obj.TimeVector(obj.LastReadIndex);
        end


        function playTimeVector=getPlayTimeVector(obj)
            tCur=obj.ScrubberCurrentTime;
            tEnd=obj.IntervalEndTime;
            playTimeVector=getTimeVectorInRange(obj,tCur,tEnd);
        end


        function timeVector=getTimeVectorInRange(obj,tStart,tEnd)

            fullTimeVector=obj.TimeVector;

            isValid=fullTimeVector>=tStart&fullTimeVector<=tEnd;
            timeVector=fullTimeVector(isValid)';

            import vision.internal.videoLabeler.tool.signalLoading.helpers.*

            if~isempty(timeVector)
                if tStart~=timeVector(1)
                    [~,ts]=getTimeToIndex(fullTimeVector,tStart);
                    timeVector=[ts,timeVector];
                end

                if tEnd~=timeVector(end)&&...
                    timeVector(end)~=fullTimeVector(end)

                    [~,ts]=getTimeToIndex(fullTimeVector,tEnd);
                    [~,tCheck]=getTimeToIndex(fullTimeVector,timeVector(end));

                    if ts~=tCheck
                        timeVector=[timeVector,tEnd];
                    end
                end
            end
        end


        function updateRangeSliderWithAddedSignals(obj,signalData)
            newSignalNames=signalData.SignalName;
            newTimeVectors=signalData.TimeVectors;

            currentSignalNames=obj.SignalData.SignalName;

            indices=find(~ismember(newSignalNames.SignalNames,currentSignalNames));

            obj.SignalData.SignalName=[obj.SignalData.SignalName;newSignalNames.SignalNames(indices)];
            obj.SignalData.TimeVectors=[obj.SignalData.TimeVectors;newTimeVectors(indices)];
        end


        function updateRangeSliderWithRemovedSignals(obj,removedSignalNames,...
            updateLabeler)
            currentSignalNames=obj.SignalData.SignalName;

            indices=ismember(currentSignalNames,removedSignalNames);

            obj.SignalData.SignalName(indices)=[];
            obj.SignalData.TimeVectors(indices)=[];

            timeVectUpdated=false;


            if any(removedSignalNames==obj.MasterSignal)

                numSignals=numel(obj.SignalData.SignalName);
                timeVectors=obj.SignalData.TimeVectors;

                if numSignals>0

                    frameRates=zeros(numSignals,1);

                    for sigId=1:numSignals
                        if(length(timeVectors{sigId})>1)
                            frameRates(sigId)=seconds(timeVectors{sigId}(2))-...
                            seconds(timeVectors{sigId}(1));
                        else
                            frameRates(sigId)=seconds(timeVectors{sigId}(1));
                        end
                    end

                    [~,masterSignalIdx]=min(frameRates);
                end


                if~isempty(obj.PrevSetupSelection)


                    if(obj.PrevSetupSelection(1)==1)

                        obj.MasterSignal=obj.SignalData.SignalName(masterSignalIdx);
                        obj.TimeVector=seconds(timeVectors{masterSignalIdx});
                        obj.LastQueryTimestamp=obj.TimeVector(1);
                        timeVectUpdated=true;



                    elseif(obj.PrevSetupSelection(2)==1||obj.PrevSetupSelection(3)==1)
                        obj.MasterSignal=obj.SignalData.SignalName(masterSignalIdx);
                    end
                else
                    obj.MasterSignal=obj.SignalData.SignalName(masterSignalIdx);
                    obj.TimeVector=seconds(timeVectors{masterSignalIdx});
                    obj.LastQueryTimestamp=obj.TimeVector(1);
                    timeVectUpdated=true;

                end
            end



            if~isempty(obj.PrevSetupSelection)
                if(obj.PrevSetupSelection(2)==1)
                    allTimeVectors=obj.SignalData.TimeVectors;
                    allTimeStamps=[];
                    for i=1:numel(allTimeVectors)
                        allTimeStamps=[allTimeStamps;allTimeVectors{i}];%#ok<AGROW>
                    end
                    obj.TimeVector=unique(seconds(allTimeStamps));
                    timeVectUpdated=true;
                end
            end



            if timeVectUpdated
                updateRangeSliderForNewVideo(obj,obj.VideoStartTime,obj.VideoEndTime)

                if updateLabeler
                    t=getSliderCurrentTime(obj);
                    updateLabelerCurrentTime(obj,t,true);
                end
            end
        end


        function settings=getRangeSliderTimeSettings(obj)
            settings=struct();
            settings.MasterSignal=obj.MasterSignal;
            settings.TimeVector=obj.TimeVector;
            settings.RadioButtonSelection=obj.PrevSetupSelection;
        end


        function updateLastQueryTime(obj,ts)
            obj.LastQueryTimestamp=ts;
        end
    end

    methods(Access=private)

        function createPlayBackAndRangeSliderSetupLayout(obj,info)


            params.parent=obj.TimePanel;
            obj.PlayBackAndRangeSliderSetupPos=26;
            w=obj.PlayBackAndRangeSliderSetupPos;
            stX=getStartXforPlayBackAndRangeSliderSetupButton(obj);
            h=16+10;
            pos_y=info.endY-h;
            params.position=[stX,pos_y,w,h];
            params.image=fullfile(obj.SETTING_ICON_PATH,'TimeSettings.png');
            params.backgroundColor=get(params.parent,'backgroundColor');
            createPlayBackAndRangeSliderSetupBtn(obj,params);

            setPlayBackAndRangeSliderSetUpBtnCallback(obj);
        end


        function createPlayBackAndRangeSliderSetupBtn(obj,params)

            obj.PlayBackAndRangeSliderBtnHandle=uicontrol('parent',params.parent,...
            'Units','pixels',...
            'position',params.position,...
            'HorizontalAlignment','right',...
            'backgroundColor',params.backgroundColor,...
            'Style','pushbutton',...
            'Tag','PlayBackAndRangeSliderSetup',...
            'String','',...
            'Enable','on',...
            'KeyPressFcn',obj.KeyPressCallback,...
            'TooltipString',vision.getMessage('vision:labeler:PlayBackAndRangeSliderSetupToolTip'));

            [im,~,alpha]=imread(params.image);

            imOut=blendAlphaImageWithBG(obj,im(:,:,1),[1,1,1],alpha);

            set(obj.PlayBackAndRangeSliderBtnHandle,'cdata',imOut);
        end


        function setPlayBackAndRangeSliderSetUpBtnCallback(obj)
            set(obj.PlayBackAndRangeSliderBtnHandle,'callback',@obj.playBackAndRangeSliderSetupCallback)
        end


        function playBackAndRangeSliderSetupCallback(obj,~,~)

            calculatePositions(obj);

            [minTsAll,maxTsAll]=computeMinAndMaxOfAllSignals(obj);
            frameRate=calculateFrameRateMaster(obj);
            lowFrameRate=calculateLowFrameRate(obj);
            maxTsAll=formatTimeForPlayBackControl(ceilTo5Decimal(maxTsAll+lowFrameRate));
            masterSignalId=find(obj.SignalData.SignalName==obj.MasterSignal,1);

            if isempty(obj.PrevSetupSelection)
                obj.PrevSetupSelection=[1,0,0];
            end

            if isempty(obj.PrevSetupSelectionInAutomation)
                obj.PrevSetupSelectionInAutomation=[0,1];
            end
            if~vision.internal.labeler.jtfeature('useAppContainer')
                obj.PlayBackAndRangeSliderSetUpDialogFig=figure(...
                'Name',vision.getMessage('vision:labeler:PlayBackAndControlSettings'),...
                'Position',obj.PlayBackAndRangeSliderSetUpFigPos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'WindowStyle','modal',...
                'MenuBar','none',...
                'Resize','off',...
                'Visible','on',...
                'Tag','PlayBackAndRangeSliderSetUpDlgFigure');

                obj.PlaybackControlsText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:PlaybackControls'),...
                'HorizontalAlignment','left',...
                'Position',obj.PlaybackControlsTextPos,...
                'fontweight','bold',...
                'Tag','PlaybackControlsTxt');

                obj.PlayBackControlsPanel=uipanel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Units','pixels',...
                'HighlightColor',[0.2,0.2,0.2],...
                'Position',obj.PlayBackControlsPanelPos,...
                'Tag','PlayBackControlsPanel');

                obj.PlayBackControlsPanelText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:PlayBackControlsPanelText'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.PlayBackControlsPanelTextPos,...
                'Tag','PlayBackControlsPanelTxt');

                obj.SignalInfoPanel=uipanel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Units','pixels',...
                'HighlightColor',[0.2,0.2,0.2],...
                'Position',obj.SignalInfoPanelPos,...
                'Tag','SignalInfoPanel');

                obj.SignalInfoPanelText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:SignalInfoPanelText'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.SignalInfoPanelTextPos,...
                'Tag','SignalInfoPanelText');

                obj.SignalInfoText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:SignalInformation'),...
                'HorizontalAlignment','left',...
                'Position',obj.SignalInfoTextPos,...
                'fontweight','bold',...
                'Tag','singalInfoTxt');

                obj.MasterSignalText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','radiobutton',...
                'String',vision.getMessage('vision:labeler:MasterSignal'),...
                'Enable','on',...
                'HorizontalAlignment','left',...
                'Value',obj.PrevSetupSelection(1),...
                'Position',obj.MasterSignalTextPos,...
                'Callback',@obj.masterSignalRadioBtnCallback,...
                'Tag','MasterSignalInfoTxt');

                obj.SignalNamesPopup=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','popupMenu',...
                'String',obj.SignalData.SignalName,...
                'Enable','off',...
                'Value',masterSignalId,...
                'Position',obj.SignalNamesPopupPos,...
                'Callback',@obj.masterSignalPopupCallback,...
                'Tag','loadDlgSignalSourceList');

                obj.FrameRateText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:FrameRate'),...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Position',obj.FrameRateTextPos,...
                'Tag','FrameRateText');

                obj.FrameRateEdit=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',[num2str(1/frameRate),' ','Hz'],...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Position',obj.FrameRateEditPos,...
                'Tag','FrameRateEdit');

                obj.AllTimeStampsText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','radiobutton',...
                'String',vision.getMessage('vision:labeler:AllTimeStamps'),...
                'Enable','on',...
                'Value',obj.PrevSetupSelection(2),...
                'HorizontalAlignment','left',...
                'Position',obj.AllTimeStampsTextPos,...
                'Callback',@obj.allTimestampsRadioBtnCallback,...
                'Tag','AllTimeStampsTxt');

                obj.TimeStampsFromWorkSpaceText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','radiobutton',...
                'String',vision.getMessage('vision:labeler:TimeStampsFromWorkSpace'),...
                'Enable','on',...
                'Value',obj.PrevSetupSelection(3),...
                'HorizontalAlignment','left',...
                'Position',obj.TimeStampsFromWorkSpaceTextPos,...
                'Callback',@obj.timeStampsFromWSRadioBtnCallback,...
                'Tag','TimeStampsFromWorkSpaceText');

                obj.TimeStampsPushButton=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','pushbutton',...
                'String',vision.getMessage('vision:labeler:TimeStampsPushButton'),...
                'Enable','off',...
                'Position',obj.TimeStampsPushButtonPos,...
                'Callback',@obj.timestampsPushBtnCallback,...
                'Tag','TimeStampsPushButton');

                obj.RangeSliderInfoText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:RangeSliderInfo'),...
                'HorizontalAlignment','left',...
                'Position',obj.RangeSliderInfoTextPos,...
                'fontweight','bold',...
                'Tag','RangeSliderInfoTxt');

                obj.MinTimeStampText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:RangeSliderStartTime'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeStampTextPos,...
                'Tag','MinTimeStampText');

                obj.MinTimeStampEdit=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',formatTimeForPlayBackControl(obj.VideoStartTime),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeStampEditPos,...
                'Tag','MinTimeStampEdit');

                obj.MaxTimeStampText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:RangeSliderEndTime'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeStampTextPos,...
                'Tag','MaxTimeStampText');

                obj.MaxTimeStampEdit=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',formatTimeForPlayBackControl(obj.VideoEndTime),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeStampEditPos,...
                'Tag','MaxTimeStampEdit');

                obj.AllSignalsInfoText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:AllSignalsInfo'),...
                'HorizontalAlignment','left',...
                'Position',obj.AllSignalsInfoTextPos,...
                'fontweight','bold',...
                'Tag','AllSignalsInfoText');

                obj.MinTimeForAllEdit=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',formatTimeForPlayBackControl(minTsAll),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeForAllEditPos,...
                'Tag','MinTimeForAllEdit');

                obj.MinTimeForAllText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:MinTimeForAllSignals'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeForAllTextPos,...
                'Tag','MinTimeForAllText');

                obj.MaxTimeForAllEdit=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',maxTsAll,...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeForAllEditPos,...
                'Tag','MaxTimeForAllEdit');

                obj.MaxTimeForAllText=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:MaxTimeForAllSignals'),...
                'ForegroundColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeForAllTextPos,...
                'Tag','MaxTimeForAllText');
            else

                obj.PlayBackAndRangeSliderSetUpDialogFig=uifigure(...
                'Name',vision.getMessage('vision:labeler:PlayBackAndControlSettings'),...
                'Position',obj.PlayBackAndRangeSliderSetUpFigPos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'WindowStyle','modal',...
                'MenuBar','none',...
                'Resize','off',...
                'Visible','on',...
                'Tag','PlayBackAndRangeSliderSetUpDlgFigure');

                obj.PlaybackControlsText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:PlaybackControls'),...
                'HorizontalAlignment','left',...
                'Position',obj.PlaybackControlsTextPos,...
                'fontweight','bold',...
                'Tag','PlaybackControlsTxt');

                obj.PlayBackControlsPanel=uipanel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Units','pixels',...
                'Position',obj.PlayBackControlsPanelPos,...
                'Tag','PlayBackControlsPanel');

                obj.PlayBackControlsPanelText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:PlayBackControlsPanelText'),...
                'HorizontalAlignment','left',...
                'Position',obj.PlayBackControlsPanelTextPos,...
                'Tag','PlayBackControlsPanelTxt');

                obj.SignalInfoPanel=uipanel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Units','pixels',...
                'Position',obj.SignalInfoPanelPos,...
                'Tag','SignalInfoPanel');

                obj.SignalInfoPanelText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:SignalInfoPanelText'),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.SignalInfoPanelTextPos,...
                'Tag','SignalInfoPanelText');

                obj.SignalInfoText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:SignalInformation'),...
                'HorizontalAlignment','left',...
                'Position',obj.SignalInfoTextPos,...
                'fontweight','bold',...
                'Tag','singalInfoTxt');

                radioBtnsPositions=[obj.LeftPadding+20,obj.RightPadding+20...
                ,obj.TextWidth+300,obj.TextHeight+90];
                bg=uibuttongroup('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Units','Pixels',...
                'Position',radioBtnsPositions,...
                'Visible','on',...
                'BorderType','none',...
                'SelectionChangedFcn',@obj.radioButtonsSelectionCallback);

                obj.MasterSignalText=uiradiobutton('Parent',bg,...
                'Text',vision.getMessage('vision:labeler:MasterSignal'),...
                'Enable','on',...
                'Value',obj.PrevSetupSelection(1),...
                'Position',[5,80,200,25],...
                'Tag','MasterSignalInfoTxt');

                obj.SignalNamesPopup=uidropdown('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Items',obj.SignalData.SignalName,...
                'Enable','off',...
                'Value',obj.SignalData.SignalName(masterSignalId),...
                'Position',obj.SignalNamesPopupPos,...
                'ValueChangedFcn',@obj.masterSignalPopupCallback,...
                'Tag','loadDlgSignalSourceList');

                obj.FrameRateText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:FrameRate'),...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Position',obj.FrameRateTextPos,...
                'Tag','FrameRateText');

                obj.FrameRateEdit=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',[num2str(1/frameRate),' ','Hz'],...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Position',obj.FrameRateEditPos,...
                'Tag','FrameRateEdit');

                obj.AllTimeStampsText=uiradiobutton('Parent',bg,...
                'Text',vision.getMessage('vision:labeler:AllTimeStamps'),...
                'Enable','on',...
                'Value',obj.PrevSetupSelection(2),...
                'Position',[5,30,200,25],...
                'Tag','AllTimeStampsTxt');

                obj.TimeStampsFromWorkSpaceText=uiradiobutton('Parent',bg,...
                'Text',vision.getMessage('vision:labeler:TimeStampsFromWorkSpace'),...
                'Enable','on',...
                'Value',obj.PrevSetupSelection(3),...
                'Position',[5,0,200,25],...
                'Tag','TimeStampsFromWorkSpaceText');


                obj.TimeStampsPushButton=uibutton('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:TimeStampsPushButton'),...
                'Enable','off',...
                'Position',obj.TimeStampsPushButtonPos,...
                'ButtonPushedFcn',@obj.timestampsPushBtnCallback,...
                'Tag','TimeStampsPushButton');

                obj.RangeSliderInfoText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:RangeSliderInfo'),...
                'HorizontalAlignment','left',...
                'Position',obj.RangeSliderInfoTextPos,...
                'fontweight','bold',...
                'Tag','RangeSliderInfoTxt');

                obj.MinTimeStampText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:RangeSliderStartTime'),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeStampTextPos,...
                'Tag','MinTimeStampText');

                obj.MinTimeStampEdit=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',formatTimeForPlayBackControl(obj.VideoStartTime),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeStampEditPos,...
                'Tag','MinTimeStampEdit');

                obj.MaxTimeStampText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:RangeSliderEndTime'),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeStampTextPos,...
                'Tag','MaxTimeStampText');

                obj.MaxTimeStampEdit=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',formatTimeForPlayBackControl(obj.VideoEndTime),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeStampEditPos,...
                'Tag','MaxTimeStampEdit');

                obj.AllSignalsInfoText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:AllSignalsInfo'),...
                'HorizontalAlignment','left',...
                'Position',obj.AllSignalsInfoTextPos,...
                'fontweight','bold',...
                'Tag','AllSignalsInfoText');

                obj.MinTimeForAllEdit=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',formatTimeForPlayBackControl(minTsAll),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeForAllEditPos,...
                'Tag','MinTimeForAllEdit');

                obj.MinTimeForAllText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:MinTimeForAllSignals'),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MinTimeForAllTextPos,...
                'Tag','MinTimeForAllText');

                obj.MaxTimeForAllEdit=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',maxTsAll,...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeForAllEditPos,...
                'Tag','MaxTimeForAllEdit');

                obj.MaxTimeForAllText=uilabel('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Text',vision.getMessage('vision:labeler:MaxTimeForAllSignals'),...
                'FontColor',[0.3,0.3,0.3],...
                'HorizontalAlignment','left',...
                'Position',obj.MaxTimeForAllTextPos,...
                'Tag','MaxTimeForAllText');
            end


            if~obj.InAutomation
                if~isempty(obj.PrevSetupSelection)
                    if obj.PrevSetupSelection(1)==1
                        masterSignalRadioBtnCallback(obj);
                    elseif obj.PrevSetupSelection(2)==1
                        allTimestampsEnableOptions(obj);
                    elseif obj.PrevSetupSelection(3)==1
                        timeStampsFromWSRadioBtnCallback(obj);
                    end
                else
                    masterSignalRadioBtnCallback(obj);
                end
            end

            if obj.InAutomation
                if obj.PrevSetupSelectionInAutomation(1)
                    obj.MasterSignalText.Value=1;
                else
                    obj.MasterSignalText.Value=0;
                end
            end

            if obj.InAutomation
                if obj.PrevSetupSelectionInAutomation(2)
                    obj.AllTimeStampsText.Value=1;
                else
                    obj.AllTimeStampsText.Value=0;
                end
            end

            if obj.InAutomation
                obj.TimeStampsFromWorkSpaceText.Enable='off';
                obj.TimeStampsFromWorkSpaceText.Value=0;
            end


            if obj.InAutomation
                if~isempty(obj.PrevSetupSelectionInAutomation)
                    if obj.PrevSetupSelectionInAutomation(1)==1
                        masterSignalRadioBtnCallback(obj);
                    elseif obj.PrevSetupSelectionInAutomation(2)==1
                        allTimestampsEnableOptions(obj);
                    end
                else
                    allTimestampsEnableOptions(obj);
                end
            end
            if useAppContainer
                obj.CancelButtonPos(3)=obj.CancelButtonPos(3)+5;
            end
            addOKCancelButton(obj);
        end


        function masterSignalRadioBtnCallback(obj,~,~)
            obj.SignalNamesPopup.Enable='on';
            obj.FrameRateText.Enable='on';
            obj.FrameRateEdit.Enable='on';
            obj.TimeStampsPushButton.Enable='off';
            obj.AllTimeStampsText.Value=0;
            obj.TimeStampsFromWorkSpaceText.Value=0;

            masterSignalPopupCallback(obj);

        end


        function radioButtonsSelectionCallback(obj,~,~)
            if(obj.MasterSignalText.Value)
                masterSignalRadioBtnCallback(obj);
            elseif(obj.AllTimeStampsText.Value)
                allTimestampsRadioBtnCallback(obj);
            elseif(obj.TimeStampsFromWorkSpaceText.Value)
                timeStampsFromWSRadioBtnCallback(obj);
            else

            end
        end


        function masterSignalPopupCallback(obj,~,~)
            if~useAppContainer
                if(iscell(obj.SignalNamesPopup.String))
                    selectedSignalName=obj.SignalNamesPopup.String{obj.SignalNamesPopup.Value};
                else
                    obj.SignalNamesPopup.String=cellstr(obj.SignalNamesPopup.String);
                    selectedSignalName=obj.SignalNamesPopup.String{obj.SignalNamesPopup.Value};
                end
            else
                if(iscell(obj.SignalNamesPopup.Items))
                    selectedSignalName=obj.SignalNamesPopup.Value;
                else
                    obj.SignalNamesPopup.String=cellstr(obj.SignalNamesPopup.Items);
                    selectedSignalName=obj.SignalNamesPopup.Value;
                end
            end

            signalNames=obj.SignalData.SignalName;
            timeVectors=obj.SignalData.TimeVectors;

            obj.MasterSignal=signalNames(signalNames==selectedSignalName);
            obj.TempTimeVector=seconds(timeVectors{signalNames==selectedSignalName});

            frameRate=calculateFrameRateMaster(obj);

            if~useAppContainer()
                obj.MinTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));

                obj.FrameRateEdit.String=[num2str(1/frameRate),' ','Hz'];
            else
                obj.MinTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));

                obj.FrameRateEdit.Text=[num2str(1/frameRate),' ','Hz'];
            end
        end


        function allTimestampsRadioBtnCallback(obj,~,~)


            allTimestampsEnableOptions(obj);

            allTimeVectors=obj.SignalData.TimeVectors;
            allTimeStamps=[];

            for i=1:numel(allTimeVectors)
                allTimeStamps=[allTimeStamps;allTimeVectors{i}];%#ok<AGROW>
            end

            obj.TempTimeVector=unique(seconds(allTimeStamps));
            frameRate=calculateFrameRateMaster(obj);

            if~useAppContainer
                obj.MinTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));

                obj.MasterSignalText.Value=0;
                obj.TimeStampsFromWorkSpaceText.Value=0;
            else
                obj.MinTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));

                obj.MasterSignalText.Value=0;
                obj.TimeStampsFromWorkSpaceText.Value=0;
            end
        end


        function allTimestampsEnableOptions(obj)
            obj.SignalNamesPopup.Enable='off';
            obj.FrameRateText.Enable='off';
            obj.FrameRateEdit.Enable='off';
            obj.TimeStampsPushButton.Enable='off';
        end


        function timeStampsFromWSRadioBtnCallback(obj,~,~)

            obj.SignalNamesPopup.Enable='off';
            obj.FrameRateText.Enable='off';
            obj.FrameRateEdit.Enable='off';
            obj.TimeStampsPushButton.Enable='on';
            obj.MasterSignalText.Value=0;
            obj.AllTimeStampsText.Value=0;

            if~useAppContainer
                obj.MinTimeStampEdit.String=formatTimeForPlayBackControl(obj.VideoStartTime);
                obj.MaxTimeStampEdit.String=formatTimeForPlayBackControl(obj.VideoEndTime);
            else
                obj.MinTimeStampEdit.Text=formatTimeForPlayBackControl(obj.VideoStartTime);
                obj.MaxTimeStampEdit.Text=formatTimeForPlayBackControl(obj.VideoEndTime);
            end
        end


        function timestampsPushBtnCallback(obj,~,~)

            variableTypes={'duration'};
            variableDisp={'duration'};
            [timestamps,~,isCanceled]=vision.internal.uitools.getVariablesFromWS(variableTypes,variableDisp);

            if isCanceled
                return;
            end


            if(isduration(timestamps))
                timestamps=seconds(timestamps);
            end

            if(isrow(timestamps))
                timestamps=timestamps';
            end

            obj.TempTimeVector=timestamps;

            updateSignaInfoView(obj);
        end


        function updateSignaInfoView(obj)

            if(length(obj.TempTimeVector)>1)
                frameRate=obj.TempTimeVector(2)-obj.TempTimeVector(1);
            else
                frameRate=1;
            end
            if~useAppContainer
                obj.MinTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.String=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));
            else
                obj.MinTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(1)));
                obj.MaxTimeStampEdit.Text=formatTimeForPlayBackControl(ceilTo5Decimal(obj.TempTimeVector(end)+frameRate));
            end
        end


        function calculatePositions(obj)

            screenSize=get(0,'ScreenSize');

            screenWidth=screenSize(3);
            screenHeight=screenSize(4);

            x=(screenWidth-obj.LoadingDlgWidth)/2;
            y=(screenHeight-obj.LoadingDlgHeight)/2;

            obj.PlayBackAndRangeSliderSetUpFigPos=[x,y,obj.LoadingDlgWidth,obj.LoadingDlgHeight];


            okButtonX=(obj.LoadingDlgWidth/2)-(obj.OKCancelButtonWidth)-10;
            cancelButtonX=(obj.LoadingDlgWidth/2)+10;

            obj.OKButtonPos=[okButtonX,obj.OKCancelButtonY...
            ,obj.OKCancelButtonWidth,obj.OKCancelButtonHeight];

            obj.CancelButtonPos=[cancelButtonX,obj.OKCancelButtonY...
            ,obj.OKCancelButtonWidth,obj.OKCancelButtonHeight];


            obj.PlayBackControlsPanelPos=[obj.LeftPadding+10,290...
            ,obj.TextWidth+370,obj.TextHeight+105];

            obj.PlayBackControlsPanelTextPos=[obj.LeftPadding+30,420...
            ,obj.TextWidth+300,obj.TextHeight];

            obj.PlaybackControlsTextPos=[obj.LeftPadding+30,445...
            ,obj.TextWidth+75,obj.TextHeight];

            obj.MasterSignalTextPos=[obj.LeftPadding+30,obj.RightPadding+100...
            ,obj.TextWidth+100,obj.TextHeight];

            obj.SignalNamesPopupPos=[obj.LeftPadding+220,obj.RightPadding+100...
            ,obj.TextWidth+80,obj.TextHeight];

            obj.FrameRateTextPos=[obj.LeftPadding+60,obj.RightPadding+70...
            ,obj.TextWidth,obj.TextHeight];

            obj.FrameRateEditPos=[obj.LeftPadding+220,obj.RightPadding+70...
            ,obj.TextWidth+150,obj.TextHeight];

            obj.AllTimeStampsTextPos=[obj.LeftPadding+30,obj.RightPadding+45...
            ,obj.TextWidth+20,obj.TextHeight];

            obj.TimeStampsFromWorkSpaceTextPos=[obj.LeftPadding+30,obj.RightPadding+15...
            ,obj.TextWidth+150,obj.TextHeight];

            obj.TimeStampsPushButtonPos=[obj.LeftPadding+280,obj.RightPadding+15...
            ,obj.TextWidth+20,obj.TextHeight];


            obj.SignalInfoPanelPos=[obj.LeftPadding+10,35...
            ,obj.TextWidth+370,obj.TextHeight+170];

            obj.SignalInfoTextPos=[obj.LeftPadding+30,255...
            ,obj.TextWidth+75,obj.TextHeight];

            obj.SignalInfoPanelTextPos=[obj.LeftPadding+30,230...
            ,obj.TextWidth+300,obj.TextHeight];

            obj.RangeSliderInfoTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding...
            ,obj.TextWidth+75,obj.TextHeight];

            obj.MinTimeStampTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding-30...
            ,obj.TextWidth+90,obj.TextHeight];

            obj.MinTimeStampEditPos=[obj.LeftPadding+220,obj.RangeSliderInfoYPadding-30...
            ,obj.TextWidth+90,obj.TextHeight];

            obj.MaxTimeStampTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding-2*30...
            ,obj.TextWidth+50,obj.TextHeight];

            obj.MaxTimeStampEditPos=[obj.LeftPadding+220,obj.RangeSliderInfoYPadding-2*30...
            ,obj.TextWidth+90,obj.TextHeight];

            obj.AllSignalsInfoTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding-3*30...
            ,obj.TextWidth+75,obj.TextHeight];

            obj.MinTimeForAllTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding-4*30...
            ,obj.TextWidth+50,obj.TextHeight];

            obj.MinTimeForAllEditPos=[obj.LeftPadding+220,obj.RangeSliderInfoYPadding-4*30...
            ,obj.TextWidth+90,obj.TextHeight];

            obj.MaxTimeForAllTextPos=[obj.LeftPadding+30,obj.RangeSliderInfoYPadding-5*30...
            ,obj.TextWidth+50,obj.TextHeight];

            obj.MaxTimeForAllEditPos=[obj.LeftPadding+220,obj.RangeSliderInfoYPadding-5*30...
            ,obj.TextWidth+90,obj.TextHeight];
        end


        function addOKCancelButton(obj)
            if~useAppContainer()
                obj.OKButton=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','pushbutton',...
                'Position',obj.OKButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','on',...
                'Callback',@obj.onOK,...
                'Tag','loadDlgOKButton');

                obj.CancelButton=uicontrol('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Style','pushbutton',...
                'Position',obj.CancelButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'Callback',@obj.onCancel,...
                'Tag','loadDlgCancelButton');
            else
                obj.OKButton=uibutton('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Position',obj.OKButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','on',...
                'ButtonPushedFcn',@obj.onOK,...
                'Tag','loadDlgOKButton');

                obj.CancelButton=uibutton('Parent',obj.PlayBackAndRangeSliderSetUpDialogFig,...
                'Position',obj.CancelButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'ButtonPushedFcn',@obj.onCancel,...
                'Tag','loadDlgCancelButton');
            end
        end


        function onOK(obj,~,~)

            obj.OKButton.Enable='off';
            obj.CancelButton.Enable='off';
            masterSignalChanged=~isequal(obj.TimeVector,obj.TempTimeVector);
            obj.TimeVector=obj.TempTimeVector;


            if masterSignalChanged&&~obj.InAutomation
                updateRangeSliderForNewVideo(obj,obj.VideoStartTime,obj.VideoEndTime)
                t=getSliderCurrentTime(obj);
                updateLabelerCurrentTime(obj,t,true);
            end

            if(obj.InAutomation)


                [startTime,endTime]=checkValidIntervalsInAutomation(obj,masterSignalChanged);


                if(r4(startTime)<r4(obj.VideoStartTime))
                    startTime=obj.VideoStartTime;
                end




                if(obj.AllTimeStampsText.Value)
                    if(~isequal(r4(endTime),r4(obj.VideoEndTime))&&r4(obj.VideoEndTime)<r4(endTime))
                        endTime=obj.VideoEndTime;
                    end
                end


                if(masterSignalChanged)
                    updateRangeSliderInAutomation(obj,startTime,endTime);
                    disableLeftRightFlags(obj);
                    updateSliderCurrentTime(obj);
                end
                obj.PrevSetupSelectionInAutomation=[obj.MasterSignalText.Value,obj.AllTimeStampsText.Value];
            else

                obj.PrevSetupSelection=[obj.MasterSignalText.Value,obj.AllTimeStampsText.Value,...
                obj.TimeStampsFromWorkSpaceText.Value];
            end


            close(obj.PlayBackAndRangeSliderSetUpDialogFig);

            if masterSignalChanged
                notify(obj,'MasterSignalChanged');
            end
        end


        function onCancel(obj,~,~)
            close(obj.PlayBackAndRangeSliderSetUpDialogFig);

            obj.TempTimeVector=[];
        end


        function[minTs,maxTs]=computeMinAndMaxOfAllSignals(obj)

            timeVectors=obj.SignalData.TimeVectors;

            minTs=min(timeVectors{1});
            maxTs=max(timeVectors{1});

            for idx=1:numel(timeVectors)
                minTs=min(minTs,min(timeVectors{idx}));
                maxTs=max(maxTs,max(timeVectors{idx}));
            end

            minTs=seconds(minTs);
            maxTs=seconds(maxTs);
        end


        function frameRate=calculateFrameRateMaster(obj)

            timeVectors=obj.SignalData.TimeVectors;
            signalNames=obj.SignalData.SignalName;

            timeVector=timeVectors{signalNames==obj.MasterSignal};
            if(length(timeVector)>1)
                frameRate=seconds(timeVector(2)-timeVector(1));
            else
                frameRate=1;
            end
        end


        function lowFrameRate=calculateLowFrameRate(obj)
            timeVectors=obj.SignalData.TimeVectors;
            frameRates=[];

            for i=1:numel(timeVectors)
                timeVector=timeVectors{i};
                if(length(timeVector)>1)
                    frameRate=seconds(timeVector(2)-timeVector(1));
                else
                    frameRate=1;
                end
                frameRates=[frameRates;frameRate];%#ok<AGROW>
            end
            lowFrameRate=max(frameRates);
        end


        function startX=getStartXforPlayBackAndRangeSliderSetupButton(obj)

            pos=get(obj.PlaybackPanelHandle,'position');
            minStartX=pos(1)+pos(3)+20;

            pos=get(obj.TimePanel,'position');
            fullW=pos(3);
            startX=fullW-obj.PlayBackAndRangeSliderSetupPos-185;
            if startX<minStartX
                startX=minStartX;
            end
        end

    end

end


function outVal=ceilTo5Decimal(inVal)
    strVal=sprintf('%0.5f',double(inVal));
    outVal=str2double(strVal);
    if(outVal<inVal)
        outVal=outVal+0.00001;
    end

end


function[h,m,s]=splitTime(ts)

    h=fix(ts/3600);
    s=ts-3600*h;
    m=fix(s/60);
    s=s-60*m;

    s=ceilTo5Decimal(s);
end


function s=formatSec(s)


    intPart=floor(s);
    fractPart=s-intPart;

    intPartStr=sprintf('%02d',intPart);
    fractPart=sprintf('%0.5f',fractPart);

    s=[intPartStr,fractPart(2:end)];
end


function str=formatTimeForPlayBackControl(s)

    if(s>=3600)
        hasHour=true;
        hasMin=true;
    elseif(s>=60)
        hasHour=false;
        hasMin=true;
    else
        hasHour=false;
        hasMin=false;
    end

    [h,m,s]=splitTime(s);

    if hasHour
        hStr=sprintf('%02d',h);
    else
        hStr='';
    end

    if hasMin
        mStr=sprintf('%02d',m);
    else
        mStr='';
    end

    sStr=formatSec(s);

    str='';
    if hasHour
        str=[hStr,':'];
    end

    if hasMin
        str=[str,mStr,':'];
    end

    str=[str,sStr];
end


function stLabelControl=createColonLabel(params)
    stLabelControl=uicontrol('parent',params.parent,...
    'position',params.position,...
    'backgroundColor',[1,1,1],...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String',':');

end


function stLabelControl=createLabel(params)
    stLabelControl=uicontrol('parent',params.parent,...
    'position',params.position,...
    'backgroundColor',params.backgroundColor,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'String',params.string);
end


function hPanel=createPanel(params)
    if~useAppContainer
        hPanel=uipanel('parent',params.parent,...
        'Units','pixels',...
        'Tag',params.tag,...
        'backgroundColor',params.backgroundColor,...
        'borderWidth',params.borderWidth,...
        'Position',params.position,...
        'BorderType','Line',...
        'HighlightColor',params.highlightColor,...
        'Visible','on');
    else
        hPanel=uipanel('parent',params.parent,...
        'Units','pixels',...
        'Tag',params.tag,...
        'backgroundColor',params.backgroundColor,...
        'Position',params.position,...
        'BorderType','Line',...
        'Visible','on');
    end
end




function r=r4(v)
    r=round(v,04);
end

function TF=useAppContainer()
    TF=vision.internal.labeler.jtfeature('UseAppContainer');
end
