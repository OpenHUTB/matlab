classdef SimulationSettingsDialog<matlabshared.application.Dialog&...
    matlabshared.application.ComponentBanner&...
    driving.internal.scenarioApp.UITools

    properties(Hidden)
hSampleTime
hSampleTimeLabel
hStopCondition
hStopConditionLabel
hStopTime
hStopTimeLabel
hUseCustomSeed
hCustomSeed
hAxesOrientationLabel
hAxesOrientation
    end


    properties(Hidden,Dependent)
StopCondition
AxesOrientation
    end


    properties(Access=protected)
NewScenarioListener
    end


    methods
        function this=SimulationSettingsDialog(varargin)
            this@matlabshared.application.Dialog(varargin{:});
            this.NewScenarioListener=event.listener(this.Application,'NewScenario',@this.onNewScenario);
        end


        function condition=get.StopCondition(this)
            condition=this.Application.Simulator.Player.StopCondition;
        end


        function orientation=get.AxesOrientation(this)
            orientation=this.Application.AxesOrientation;
        end


        function close(this)
            close@matlabshared.application.Dialog(this);
            clearAllMessages(this);
        end


        function refresh(this)
            app=this.Application;
            player=app.Simulator.Player;
            setPopupValue(this,'StopCondition');
            this.hSampleTime.String=app.SampleTime*1000;
            stopTime=player.StopTime;
            if isinf(stopTime)
                stopTime=10;
            end
            this.hStopTime.UserData=stopTime;

            seed=app.CustomSeed;
            if isempty(seed)
                value=false;
                string='0';
            else
                value=true;
                string=seed;
            end
            this.hUseCustomSeed.Value=value;
            this.hCustomSeed.UserData=string;

            if app.ShowAxesOrientation
                setPopupValue(this,'AxesOrientation');
            end
            this.HasUnappliedChanges=false;
            update(this);
            clearAllMessages(this);
        end


        function update(this)
            update@matlabshared.application.Dialog(this);
            player=this.Application.Simulator.Player;
            if isStopped(player)
                enab='on';
            else
                enab='off';
            end
            set([this.hSampleTime,this.hSampleTimeLabel,this.hStopCondition,this.hStopConditionLabel],'Enable',enab);
            condition=getPopupValue(this,'StopCondition');
            hstoptime=this.hStopTime;
            if strcmp(condition,'time')
                string=hstoptime.UserData;
                stopEnab=enab;
            else
                stopEnab='off';
                string='';
            end
            set([hstoptime,this.hStopTimeLabel],'Enable',stopEnab);
            hstoptime.String=string;

            hUseSeed=this.hUseCustomSeed;
            hSeed=this.hCustomSeed;
            if hUseSeed.Value
                string=hSeed.UserData;
                seedEnab=enab;
            else
                string='';
                seedEnab='off';
            end
            hUseSeed.Enable=enab;
            hSeed.Enable=seedEnab;
            hSeed.String=string;
        end
    end


    methods(Hidden)

        function onNewScenario(this,~,~)
            refresh(this);
        end


        function stopTimeCallback(this,h,~)
            h.UserData=h.String;
            genericCallback(this);
        end


        function success=apply(this,~,~)
            success=false;
            clearAllMessages(this);

            shouldDirty=false;

            app=this.Application;
            player=app.Simulator.Player;
            condition=getPopupValue(this,'StopCondition');

            hTime=this.hStopTime;
            if strcmp(condition,'time')
                stopTime=str2double(hTime.String);
                if isinf(stopTime)
                    stopTime=nan;
                end
            else
                stopTime=inf;
            end
            sampleTime=str2double(this.hSampleTime.String);

            if this.hUseCustomSeed.Value
                customSeed=str2double(this.hCustomSeed.String);
            else
                customSeed=[];
            end

            err='';
            if isnan(stopTime)||stopTime<=0
                err=getString(message('driving:scenarioApp:InvalidStopTime'));
            elseif isnan(sampleTime)||sampleTime<=0
                err=getString(message('driving:scenarioApp:InvalidSampleTime'));
            elseif~isempty(customSeed)&&(isnan(customSeed)||customSeed<0||customSeed>2^32-1||abs(round(customSeed)-customSeed)>0.001)
                err=getString(message('driving:scenarioApp:InvalidCustomSeed'));
            end
            if~isempty(err)
                errorMessage(this,err,'');
                return;
            end
            sensorSpecs=app.SensorSpecifications;
            applySampleTime=true;
            updateBEP=false;
            oldSeed=app.CustomSeed;
            if~isempty(sensorSpecs)&&~isstruct(sensorSpecs(1).Sensor)
                updateBEP=~isequal(oldSeed,customSeed);
                [updateIntervals,changed]=driving.internal.scenarioApp.SensorSpecification.fixUpdateIntervals(...
                [sensorSpecs.UpdateInterval],sampleTime);
                if changed
                    updateStr=getString(message('driving:scenarioApp:Update'));
                    revertStr=getString(message('driving:scenarioApp:Revert'));
                    title=getString(message('driving:scenarioApp:UpdateUpdateIntervalTitle'));
                    question=getString(message('driving:scenarioApp:UpdateUpdateIntervalQuestion'));
                    btn=questdlg(question,title,updateStr,revertStr,updateStr);
                    if strcmp(btn,updateStr)
                        for indx=1:numel(sensorSpecs)
                            release(sensorSpecs(indx).Sensor);
                            sensorSpecs(indx).UpdateInterval=updateIntervals(indx);
                        end

                        updateBEP=true;
                        update(app.SensorProperties);
                    else
                        applySampleTime=false;
                        this.hSampleTime.String=app.SampleTime*1000;
                    end
                end
            end
            resetNumSamples=false;
            if~strcmp(player.StopCondition,condition)
                shouldDirty=true;
                resetNumSamples=true;
                player.StopCondition=condition;
            end
            if player.StopTime~=stopTime
                shouldDirty=true;
                resetNumSamples=true;
                player.StopTime=stopTime;
            end
            if~isequal(app.CustomSeed,customSeed)
                shouldDirty=true;
                app.CustomSeed=customSeed;
            end
            if applySampleTime&&app.SampleTime~=sampleTime/1000
                shouldDirty=true;
                resetNumSamples=true;
                app.SampleTime=sampleTime/1000;
            end
            if resetNumSamples
                clearNumSamples(player);
            end

            if app.ShowAxesOrientation
                newOrientation=getPopupValue(this,'AxesOrientation');
            else
                newOrientation='ENU';
            end
            if~strcmp(newOrientation,app.AxesOrientation)
                updateBEP=true;
                edit=driving.internal.scenarioApp.undoredo.SetDesignerProperty(app,'AxesOrientation',newOrientation);
                addEditNoApply(app,edit);
                app.AxesOrientation=newOrientation;
                update(app.RoadProperties);
                update(app.ActorProperties);
                sensorProps=app.SensorProperties;
                if~isempty(sensorProps)
                    update(sensorProps);
                end
            end

            if updateBEP
                updateBirdsEyePlot(app);
            end

            if shouldDirty
                setDirty(app);
            end
            success=true;
        end


        function name=getName(~)
            name=getString(message('driving:scenarioApp:SimulationSettingsTitle'));
        end


        function tag=getTag(~)
            tag='SimulationSettings';
        end
    end


    methods(Access=protected)

        function fig=createFigure(this)
            if ispc
                width=250;
            else
                width=280;
            end
            fig=createFigure@matlabshared.application.Dialog(this,...
            'Position',getCenterPosition(this.Application,[width,200]));
            showAxesOrientation=this.Application.ShowAxesOrientation;

            hpanel=this.hPanel;
            set(hpanel,'Tag','SimulationSettingsPanel',...
            'Title',getString(message('driving:scenarioApp:SimulationSettingsPanelTitle')));
            createLabelEditPair(this,hpanel,'SampleTime',@this.genericCallback,...
            'TooltipString',getString(message('driving:scenarioApp:SampleTimeDescription')));
            seedDesc=getString(message('driving:scenarioApp:UseCustomSeedDescription'));
            createLabelEditPair(this,hpanel,'StopCondition',@this.genericCallback,'popupmenu');
            setupPopup(this,'StopCondition','first','last','time');
            createLabelEditPair(this,hpanel,'StopTime',@this.stopTimeCallback);
            createCheckbox(this,hpanel,'UseCustomSeed',@this.genericCallback,...
            'TooltipString',seedDesc);
            createEditbox(this,hpanel,'CustomSeed',@this.stopTimeCallback,...
            'TooltipString',seedDesc);

            vw=[0,0,0,1];
            if showAxesOrientation
                createLabelEditPair(this,hpanel,'AxesOrientation',@this.genericCallback,'popupmenu');
                setupPopup(this,'AxesOrientation','ENU','NED');

                vw=[0,vw];
            end
            layout=matlabshared.application.layout.ScrollableGridBagLayout(hpanel,...
            'VerticalGap',3,...
            'HorizontalGap',3,...
            'HorizontalWeights',[0,1],...
            'VerticalWeights',vw);
            labelWidth=layout.getMinimumWidth([this.hSampleTimeLabel,this.hStopConditionLabel,this.hStopTimeLabel]);

            topInset=layout.LabelOffset;
            labelInputs={'Anchor','NorthWest',...
            'TopInset',topInset,...
            'MinimumHeight',20-topInset,...
            'MinimumWidth',labelWidth};
            add(layout,this.hSampleTimeLabel,1,1,labelInputs{:},'TopInset',topInset+15);
            add(layout,this.hSampleTime,1,2,'Fill','Horizontal','TopInset',15);
            add(layout,this.hStopConditionLabel,2,1,labelInputs{:});
            add(layout,this.hStopCondition,2,2,'Fill','Horizontal');
            add(layout,this.hStopTimeLabel,3,1,'LeftInset',8,'Anchor','West',...
            'TopInset',topInset,'MinimumHeight',20-topInset,...
            'MinimumWidth',layout.getMinimumWidth(this.hStopTimeLabel));
            add(layout,this.hStopTime,3,2,'Fill','Horizontal');
            add(layout,this.hUseCustomSeed,4,1,'Anchor','NorthWest',...
            'MinimumWidth',layout.getMinimumWidth(this.hUseCustomSeed)+20);
            add(layout,this.hCustomSeed,4,2,'Anchor','North','Fill','Horizontal');
            if showAxesOrientation
                add(layout,this.hAxesOrientationLabel,5,1,labelInputs{:});
                add(layout,this.hAxesOrientation,5,2,'Anchor','North','Fill','Horizontal');
            end
            update(layout,true);
        end
    end
end



