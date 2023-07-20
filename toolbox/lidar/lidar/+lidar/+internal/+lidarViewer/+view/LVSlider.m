







classdef LVSlider<handle

    properties(Access=private)

        Figure matlab.ui.Figure
        TimePanel matlab.ui.container.Panel

        FirstFrameButton matlab.ui.control.Button
        PreviousFrameButton matlab.ui.control.Button
PlayPauseButton
        NextFrameButton matlab.ui.control.Button
        LastFrameButton matlab.ui.control.Button
        SliderUI matlab.ui.control.Slider
    end

    properties(Access=private)

Spacing




        ArePlayBackButtonsAdded(1,1)logical=false;
    end

    properties(Dependent,Hidden)

Length
Width
PanelHeight
    end

    properties

TimeVector
        CurrentTime=[]
    end

    properties(Access=private,Hidden)
        IsPlayMode logical

StartEBHandle
CurrentEBHandle
EndEBHandle

HasHour
HasMin
    end

    properties(Constant,Hidden)
        PanelOffsetX=10;
        PanelOffsetY=5;
        ICON_PATH=fullfile(matlabroot,'toolbox','vision','vision','+vision','+internal','+videoLabeler','+tool');
    end

    events
FrameChangeRequest
    end




    methods
        function this=LVSlider(fig)
            this.Figure=fig;
            this.addUIComponents();
            this.IsPlayMode=false;
        end


        function resize(this)

            this.setPosition();
            this.setPlaybackButtonPosition();
        end


        function reset(this)

            this.CurrentTime=[];
            this.TimeVector=[];
        end


        function enable(this)
            this.FirstFrameButton.Enable="on";
            this.SliderUI.Enable=true;
            this.LastFrameButton.Enable="on";
            this.PlayPauseButton.Enable="on";
            this.PreviousFrameButton.Enable="on";
            this.NextFrameButton.Enable="on";
            this.setCurrentEBState(true);

            try
                this.updatePlayBackControlsState();
            catch
                return;
            end
        end


        function disable(this)
            this.FirstFrameButton.Enable="off";
            this.SliderUI.Enable=false;
            this.LastFrameButton.Enable="off";
            this.PlayPauseButton.Enable="off";
            this.PreviousFrameButton.Enable="off";
            this.NextFrameButton.Enable="off";
            this.setCurrentEBState(false);
        end
    end




    methods(Access=private)
        function addUIComponents(this)



            this.Spacing=2;


            this.TimePanel=uipanel('Parent',this.Figure,'BorderType','none','AutoResizeChildren','off');


            this.setPosition();


            addSlider(this);
        end


        function addSlider(this)

            this.SliderUI=uislider(this.Figure,...
            'ValueChangedFcn',@(~,evt)this.sliderMoved(evt),...
            'ValueChangingFcn',@(~,evt)this.sliderMoving(evt),...
            'MinorTicks',[],'MajorTicks',[]);

        end


        function addStartCurrentEndTimes(this)



            offSetX=10;

            info.labelText=getString(message('lidar:lidarViewer:StartTimeLabel'));
            info.startX=offSetX;
            info.hourTag='Start hour';
            info.minTag='Start min';
            info.secTag='Start sec';
            [this.StartEBHandle,endX]=createTimeLabelAndEditBoxes(this,info,1);


            info.labelText=getString(message('lidar:lidarViewer:CurrentTimeLabel'));
            info.startX=endX+2*offSetX;
            info.hourTag='Current hour';
            info.minTag='Current min';
            info.secTag='Current sec';
            [this.CurrentEBHandle,endX]=createTimeLabelAndEditBoxes(this,info,2);


            info.labelText=getString(message('lidar:lidarViewer:EndTimeLabel'));
            info.startX=endX+2*offSetX;
            info.hourTag='End hour';
            info.minTag='End min';
            info.secTag='End sec';
            [this.EndEBHandle,~]=createTimeLabelAndEditBoxes(this,info,3);


            attachEBCallback(this);
        end


        function addPlayBackButtons(this)




            this.ArePlayBackButtonsAdded=true;

            params.parent=this.Figure;

            addFirstFrameButton(this,params);


            addPreviousFrameButton(this,params);


            addPlayPauseButton(this,params);


            addNextFrameButton(this,params);


            addLastFrameButton(this,params);


            this.setPlaybackButtonPosition();
        end


        function addFirstFrameButton(this,params)

            params.icon=fullfile(this.ICON_PATH,'tobeginning.png');
            params.tag='firstFrameBtn';
            params.enable='off';
            params.tooltip=getString(message('lidar:lidarViewer:FirstFrameTooltip'));
            this.FirstFrameButton=this.createPlayBackButton(params);
            set(this.FirstFrameButton,'ButtonPushedFcn',@(~,~)this.firstFrameButtonPressed());
        end


        function addPreviousFrameButton(this,params)

            params.icon=fullfile(this.ICON_PATH,'topreviousframe.png');
            params.tag='previousFrameBtn';
            params.enable='off';
            params.tooltip=getString(message('lidar:lidarViewer:PreviousFrameTooltip'));
            this.PreviousFrameButton=this.createPlayBackButton(params);
            set(this.PreviousFrameButton,'ButtonPushedFcn',@(~,~)this.previousFrameButtonPressed());
        end


        function addPlayPauseButton(this,params)

            params.icon=fullfile(this.ICON_PATH,'play.png');
            params.tag='playBtn';
            params.enable='on';
            params.tooltip=getString(message('lidar:lidarViewer:PlayTooltip'));
            this.PlayPauseButton=this.createPlayBackButton(params);
            set(this.PlayPauseButton,'ButtonPushedFcn',@(~,~)this.playPauseButtonPressed());
        end


        function addNextFrameButton(this,params)

            params.icon=fullfile(this.ICON_PATH,'tonextframe.png');
            params.tag='nextFrameBtn';
            params.enable='on';
            params.tooltip=getString(message('lidar:lidarViewer:NextFrameTooltip'));
            this.NextFrameButton=this.createPlayBackButton(params);
            set(this.NextFrameButton,'ButtonPushedFcn',@(~,~)this.nextFrameButtonPressed());
        end


        function addLastFrameButton(this,params)

            params.icon=fullfile(this.ICON_PATH,'toend.png');
            params.tag='lastFrameBtn';
            params.enable='on';
            params.tooltip=getString(message('lidar:lidarViewer:LastFrameTooltip'));
            this.LastFrameButton=this.createPlayBackButton(params);
            set(this.LastFrameButton,'ButtonPushedFcn',@(~,~)this.lastFrameButtonPressed());
        end


        function attachEBCallback(this)

            if(this.HasHour)
                set(this.CurrentEBHandle.hHourEB,'ValueChangedFcn',{@this.CurrentEBCallback,1});
            end
            if(this.HasMin)
                set(this.CurrentEBHandle.hMinEB,'ValueChangedFcn',{@this.CurrentEBCallback,2});
            end
            set(this.CurrentEBHandle.hSecEB,'ValueChangedFcn',{@this.CurrentEBCallback,3});
        end


        function[hEB,endX]=createTimeLabelAndEditBoxes(this,info,sceEBoxID)


            timeLabel=info.labelText;


            if this.HasHour
                timeFormatStr='hh:mm:ss.sssss';
            elseif this.HasMin
                timeFormatStr='mm:ss.sssss';
            else
                timeFormatStr='ss.sssss';
            end

            offsetY=5;
            timeLabelX=info.startX;
            timeLabelY=offsetY;
            timeLabelW=length(timeLabel)*14;
            timeLabelH=19;


            params.parent=this.TimePanel;
            params.position=[timeLabelX,timeLabelY,timeLabelW,timeLabelH];
            params.string=timeLabel;
            params.sceEBoxID=sceEBoxID;
            this.createLabel(params);

            timeValueX=timeLabelX;
            timeValueY=timeLabelY+timeLabelH+offsetY;
            timeValueW=length(timeFormatStr)*8;
            timeValueH=22;


            params.position=[timeValueX,timeValueY,timeValueW,timeValueH];
            hTimeValuePanel=this.createPanel(params);
            if sceEBoxID==2
                hTimeValuePanel.BackgroundColor=[1,1,1];
            end
            params.parent=hTimeValuePanel;
            endX=timeValueX+timeValueW;


            hourX=0;
            hourY=0;
            hourH=timeValueH;

            if this.HasHour

                hourW=22.8;

                params.position=[hourX,hourY,hourW,hourH];
                params.ebString='00';
                hEB.hHourEB=createBorderlessEditBox(this,params,info.hourTag);


                hColonX=hourX+hourW+0.5;
                hColonY=hourY+1.5;
                hColonW=5.6;
                hColonH=hourH;

                params.position=[hColonX,hColonY,hColonW,hColonH];
                hEB.hHourColon=this.createColonLabel(params);
            else
                assert(~this.HasHour);
                hEB.hHourEB=[];
                hColonX=hourX;
                hColonW=0;
            end


            if this.HasMin
                minX=hColonX+hColonW;
                minY=hourY;
                minW=22.8;
                minH=hourH;

                params.position=[minX,minY,minW,minH];
                params.ebString='00';
                hEB.hMinEB=createBorderlessEditBox(this,params,info.minTag);


                mColonX=minX+minW+0.5;
                mColonY=hourY+1.5;
                mColonW=5.6;
                mColonH=hourH;

                params.position=[mColonX,mColonY,mColonW,mColonH];
                hEB.hMinColon=this.createColonLabel(params);
            else
                hEB.hMinEB=[];
                mColonX=hourX;
                mColonW=0;
            end


            minX=mColonX+mColonW;
            minY=hourY;
            minW=65.4;
            minH=hourH;

            params.position=[minX,minY,minW,minH];
            params.ebString='00.00000';
            hEB.hSecEB=createBorderlessEditBox(this,params,info.secTag);

        end


        function hEB=createBorderlessEditBox(this,params,tag)


            hPanel=this.createPanel(params);
            hPanel.BorderType='none';
            params.position=[0,0,params.position(3)+10,params.position(4)+4];
            if this.HasHour
                params.TooltipString='Time (h:m:s)';
            elseif this.HasMin
                params.TooltipString='Time (m:s)';
            else
                params.TooltipString='Time (s)';
            end

            hEB=uieditfield(hPanel,'text',...
            'position',params.position,...
            'Enable','off',...
            'backgroundColor',[1,1,1],...
            'Value',params.ebString,...
            'Tag',[strrep(tag,' ','_'),'_EB'],...
            'Tooltip',params.TooltipString);
            if params.sceEBoxID==2
                hEB.Enable='on';
            end
            set(hEB,'UserData',params.ebString);
        end
    end




    methods(Access=private)

        function firstFrameButtonPressed(this)

            index=this.getCurrentTimeIndex();
            if(isempty(index)||index==1)
                return;
            end
            this.CurrentTime=this.TimeVector(1);
            this.update();
            this.frameChangeRequest();
        end


        function previousFrameButtonPressed(this)

            index=this.getCurrentTimeIndex();
            if(isempty(index)||index==1)
                return;
            end
            this.CurrentTime=this.TimeVector(index-1);
            this.update();
            this.frameChangeRequest();
        end


        function lastFrameButtonPressed(this)

            index=this.getCurrentTimeIndex();
            if(isempty(index)||index==length(this.TimeVector))
                return;
            end
            this.CurrentTime=this.TimeVector(end);
            this.update();
            this.frameChangeRequest();
        end


        function CurrentEBCallback(this,hObject,~,hmsEBoxID)

            val=str2double(hObject.Value);
            if~isnan(val)
                val=saturateMinOrsSecValue(this,val,hmsEBoxID);
                tMin=getTimeFromEB(this,this.StartEBHandle);
                tCurrent=getTimeFromEBwithVal(this,this.CurrentEBHandle,val,hmsEBoxID);
                tMax=getTimeFromEB(this,this.EndEBHandle);

                currentTs=saturateTimeValue(this,tCurrent,tMin,tMax);

                this.CurrentTime=seconds(currentTs);
                this.update();
                this.frameChangeRequest();
            else
                hObject.Value=hObject.UserData;
            end
        end


        function sliderMoving(this,evt)

            currentTime=this.getCurrentTimeFromPosition(evt.Value);
            if~isequal(currentTime,this.CurrentTime)
                this.CurrentTime=currentTime;
                this.updateStartCurrentEndTimes();
                this.updatePlayBackControlsState();
                this.frameChangeRequest();
            end
        end


        function sliderMoved(this,evt)

            currentTime=this.getCurrentTimeFromPosition(evt.Value);
            if~isequal(currentTime,this.CurrentTime)
                this.CurrentTime=currentTime;
                this.updateStartCurrentEndTimes();
                this.updatePlayBackControlsState();
                this.frameChangeRequest();
            end
        end
    end

    methods(Hidden,Access=?lidar.internal.lidarViewer.LVView)


        function nextFrameButtonPressed(this)

            index=this.getCurrentTimeIndex();
            if(isempty(index)||index==length(this.TimeVector))
                return;
            end
            this.CurrentTime=this.TimeVector(index+1);
            this.update();
            this.frameChangeRequest();
        end


        function playPauseButtonPressed(this,~,~)


            this.IsPlayMode=~(this.IsPlayMode);

            this.togglePlayPauseButtonUI();
            if(this.IsPlayMode)
                this.setStateOfLeftPBButtons('off');
                this.setStateOfRightPBButtons('off');
            else
                this.setStateOfLeftPBButtons('on');
                this.setStateOfRightPBButtons('on');
            end


            this.setCurrentEBState(~this.IsPlayMode);

            index=this.getCurrentTimeIndex();
            while this.IsPlayMode&&index~=length(this.TimeVector)
                this.CurrentTime=this.TimeVector(index+1);
                this.adjustSliderPosition();
                this.updateStartCurrentEndTimes();
                this.frameChangeRequest();
                index=find(eq(this.TimeVector,this.CurrentTime));
            end

            this.updatePlayBackControlsState();
            if(index==length(this.TimeVector))
                this.IsPlayMode=~(this.IsPlayMode);
                this.togglePlayPauseButtonUI();
                this.setStateOfLeftPBButtons('on');
            end



            this.setCurrentEBState(~this.IsPlayMode);


            this.frameChangeRequest();
        end
    end




    methods
        function setTimeVector(this,timeVector,hasTimingInfo)

            if isempty(timeVector)
                return;
            end


            this.TimeVector=timeVector;
            this.CurrentTime=this.TimeVector(1);

            this.SliderUI.Limits=[1,numel(this.TimeVector)+1];

            this.setPosition();


            deleteTimerPanel(this);


            this.TimePanel.Visible=hasTimingInfo;


            hasHourMin(this);
            this.addStartCurrentEndTimes();


            if~this.ArePlayBackButtonsAdded
                this.addPlayBackButtons();
            end


            this.update();
        end


        function time=getCurrentTime(this)

            time=this.CurrentTime;
        end


        function setSliderState(this,state)

            this.FirstFrameButton.Enable=state;
            this.PreviousFrameButton.Enable=state;
            this.NextFrameButton.Enable=state;
            this.LastFrameButton.Enable=state;
            this.SliderUI.Enable=state;

            if(state==false)
                stateOnOff='off';
            else
                stateOnOff='on';
            end
            this.PlayPauseButton.Enable=stateOnOff;

            this.setCurrentEBState(stateOnOff);
            if state
                this.updatePlayBackControlsState();
            end
        end


        function resizeSlider(this)

            this.setPosition();
        end


        function updateCurrentTimeWithFrameNum(this,frameNum)

            this.CurrentTime=this.TimeVector(frameNum);
            this.update();
            this.frameChangeRequest();
        end
    end




    methods(Access=private)
        function adjustSliderPosition(this)


            idx=getCurrentTimeIndex(this);
            if idx==numel(this.TimeVector)


                idx=idx+1;
            end
            this.SliderUI.Value=idx;
        end


        function frameChangeRequest(this)
            evt=lidar.internal.lidarViewer.events.FrameChangeRequestEventData(this.CurrentTime,this.IsPlayMode);
            notify(this,'FrameChangeRequest',evt);
        end


        function index=getCurrentTimeIndex(this)






            idx=find(this.TimeVector>=this.CurrentTime,1);
            if isempty(idx)
                index=numel(this.TimeVector);
            else
                value=this.TimeVector(idx);
                if value~=this.CurrentTime
                    index=max(1,idx-1);
                else
                    index=idx;
                end
            end
        end


        function hasHourMin(this)


            if(this.TimeVector(end)>=seconds(3600))
                this.HasHour=true;
                this.HasMin=true;
            elseif(this.TimeVector(end)>=seconds(60))
                this.HasHour=false;
                this.HasMin=true;
            else
                this.HasHour=false;
                this.HasMin=false;
            end
        end


        function updateStartCurrentEndTimes(this)

            setStartTime(this);
            setCurrentTime(this);
            setEndTime(this);
        end


        function update(this)


            this.adjustSliderPosition();
            this.updateStartCurrentEndTimes();
            this.updatePlayBackControlsState();
        end


        function setCurrentEBState(this,state)


            if state
                bgColor=[1,1,1];
            else
                bgColor=[0.94,0.94,0.94];
            end
            if this.HasHour
                this.CurrentEBHandle.hHourEB.Enable=state;
                this.CurrentEBHandle.hHourColon.BackgroundColor=bgColor;
            end
            if this.HasMin
                this.CurrentEBHandle.hMinEB.Enable=state;
                this.CurrentEBHandle.hMinColon.BackgroundColor=bgColor;
            end
            this.CurrentEBHandle.hSecEB.Enable=state;
            this.CurrentEBHandle.hSecColon.BackgroundColor=bgColor;
        end


        function setCurrentTime(this)


            setEBsTimeAt(this,this.CurrentEBHandle,seconds(this.CurrentTime));
        end


        function setStartTime(this)

            setEBsTimeAt(this,this.StartEBHandle,seconds(this.TimeVector(1)));
        end


        function setEndTime(this)

            setEBsTimeAt(this,this.EndEBHandle,seconds(this.TimeVector(end)));
        end


        function setEBsTimeAt(this,hEBs,t)

            [hStr,mStr,sStr]=splitAndFormatTime(this,t);
            if this.HasHour
                setEBStringAndUserData(this,hEBs.hHourEB,hStr);
            end

            if this.HasMin
                setEBStringAndUserData(this,hEBs.hMinEB,mStr);
            end


            setEBStringAndUserData(this,hEBs.hSecEB,sStr);
        end


        function setEBStringAndUserData(~,handle,valStr)

            set(handle,'Value',valStr);
            set(handle,'UserData',valStr);
        end


        function[hStr,mStr,sStr]=splitAndFormatTime(this,ts)


            [h,m,s]=this.splitTime(ts);
            if this.HasHour
                hStr=sprintf('%02d',h);
            else
                hStr=0;
            end
            if this.HasMin
                mStr=sprintf('%02d',m);
            else
                mStr=0;
            end
            sStr=this.formatSec(s);
        end


        function[h,m,s]=splitTime(this,ts)


            h=floor(ts/3600);
            s=ts-3600*h;
            m=floor(s/60);
            s=s-60*m;
            s=this.ceilTo5Decimal(s);
        end


        function currentTime=getCurrentTimeFromPosition(this,pos)


            if pos==this.SliderUI.Limits(2)
                pos=pos-1;
            end
            currentTime=this.TimeVector(floor(pos));





        end


        function setPosition(this)


            try

                this.TimePanel.Position=[this.PanelOffsetX,this.PanelOffsetY,this.Figure.Position(3)*0.43,this.PanelHeight*0.65];

                length=this.Figure.Position(3);
                height=this.Figure.Position(4);


                this.SliderUI.Position=[2*this.PanelOffsetX,height*0.75,length-4*this.PanelOffsetX,3];
            catch
            end
        end


        function setPlaybackButtonPosition(this)

            try
                offsetX=4;
                startX=this.Figure.Position(3)*0.45;
                w=26;
                h=w;
                posY=this.Figure.Position(4)*0.3;

                this.FirstFrameButton.Position=[startX,posY,w,h];

                startX=startX+w+offsetX;
                this.PreviousFrameButton.Position=[startX,posY,w,h];

                startX=startX+w+offsetX;
                this.PlayPauseButton.Position=[startX,posY,w,h];

                startX=startX+w+offsetX;
                this.NextFrameButton.Position=[startX,posY,w,h];

                startX=startX+w+offsetX;
                this.LastFrameButton.Position=[startX,posY,w,h];
            catch
            end
        end


        function setStateOfLeftPBButtons(this,state)


            this.FirstFrameButton.Enable=state;
            this.PreviousFrameButton.Enable=state;
        end


        function setStateOfRightPBButtons(this,state)


            this.NextFrameButton.Enable=state;
            this.LastFrameButton.Enable=state;
        end


        function updatePlayBackControlsState(this)

            if(this.TimeVector(1)==this.TimeVector(end))
                this.setStateOfLeftPBButtons('off');
                this.setStateOfRightPBButtons('off');
                this.PlayPauseButton.Enable='off';
            else
                this.setStateOfLeftPBButtons('on');
                this.PlayPauseButton.Enable='on';
                this.setStateOfRightPBButtons('on');

                if(this.CurrentTime==this.TimeVector(1))
                    this.setStateOfLeftPBButtons('off');
                else
                    if(this.CurrentTime==this.TimeVector(end))
                        this.setStateOfRightPBButtons('off');
                        this.setStateOfLeftPBButtons('on');
                        this.PlayPauseButton.Enable='off';
                    end
                end
            end
        end


        function t=getTimeFromEB(this,hEB)

            t=0;
            if this.HasHour
                t=t+str2double(hEB.hHourEB.Value)*3600;
            end
            if this.HasMin
                t=t+str2double(hEB.hMinEB.Value)*60;
            end

            t=t+str2double(hEB.hSecEB.Value);
        end


        function t=getTimeFromEBwithVal(this,hEB,val,hmsEBoxID)


            t=0;
            if this.HasHour
                if(hmsEBoxID==1)
                    t=t+val*3600;
                else
                    t=t+str2double(hEB.hHourEB.Value)*3600;
                end
            end
            if this.HasMin
                if(hmsEBoxID==2)
                    t=t+val*60;
                else
                    t=t+str2double(hEB.hMinEB.Value)*60;
                end
            end
            if(hmsEBoxID==3)
                t=t+val;
            else
                t=t+str2double(hEB.hSecEB.Value);
            end
        end


        function val=saturateMinOrsSecValue(~,val,hmsEBoxID)


            if(hmsEBoxID==2)||(hmsEBoxID==3)
                if(val<0)
                    val=0;
                elseif(val>59)
                    val=59;
                end
            end
        end


        function tOut=saturateTimeValue(~,tIn,tMin,tMax)


            tOut=tIn;
            if(tIn<tMin)
                tOut=tMin;
            elseif(tIn>tMax)
                tOut=tMax;
            end
        end


        function togglePlayPauseButtonUI(this)

            if this.IsPlayMode
                icon=fullfile(this.ICON_PATH,'pause.png');
                tag='pauseBtn';
                tooltip=getString(message('lidar:lidarViewer:PauseTooltip'));
            else
                icon=fullfile(this.ICON_PATH,'play.png');
                tag='playBtn';
                tooltip=getString(message('lidar:lidarViewer:PlayTooltip'));
            end
            this.PlayPauseButton.Icon=icon;
            drawnow();
            this.PlayPauseButton.Tag=tag;
            this.PlayPauseButton.Tooltip=tooltip;
        end


        function deleteTimerPanel(this)

            delete(this.TimePanel.Children);
        end
    end




    methods
        function length=get.Length(this)
            length=this.Figure.Position(3)-this.Spacing*2;
        end

        function width=get.Width(this)
            width=this.Figure.Position(4)-this.Spacing*2;
        end

        function panelHeight=get.PanelHeight(this)
            panelHeight=this.Figure.Position(4);
        end
    end

    methods(Static)

        function stLabelControl=createLabel(params)

            stLabelControl=uilabel('parent',params.parent,...
            'position',params.position,...
            'HorizontalAlignment','left',...
            'Text',params.string);
        end


        function hPanel=createPanel(params)

            hPanel=uipanel('Parent',params.parent,...
            'Position',params.position,...
            'BorderType','Line',...
            'Visible','on');
        end


        function btnHandle=createPlayBackButton(params)

            btnHandle=uibutton('Parent',params.parent,...
            'Text','',...
            'Enable',params.enable,...
            'Tooltip',params.tooltip,...
            'Tag',params.tag,...
            'Icon',params.icon,...
            'IconAlignment','center');
        end


        function stLabelControl=createColonLabel(params)


            stLabelControl=uilabel('parent',params.parent,...
            'position',params.position,...
            'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'Text',':');
        end


        function outVal=ceilTo5Decimal(inVal)

            strVal=sprintf('%0.5f',double(inVal));
            outVal=str2double(strVal);
            if(outVal<inVal)
                outVal=outVal+0.00001;
            end
        end


        function s=formatSec(s)

            intPart=floor(s);
            fractPart=s-intPart;
            intPartStr=sprintf('%02d',intPart);
            fractPart=sprintf('%0.4f',fractPart);
            s=[intPartStr,fractPart(2:end)];
        end
    end
end


