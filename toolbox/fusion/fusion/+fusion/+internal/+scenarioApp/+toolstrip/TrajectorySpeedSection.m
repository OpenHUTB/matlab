classdef TrajectorySpeedSection<fusion.internal.scenarioApp.toolstrip.Section

    properties
Enabled
    end

    properties(SetAccess=protected,Hidden)
TimeLabel
GroundSpeedLabel
ClimbRateLabel

TimeDropdown
GroundSpeedDropDown
ClimbRateDropDown
    end

    methods
        function this=TrajectorySpeedSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            hApp=this.Application;

            import matlab.ui.internal.toolstrip.*;
            this.Title=msgString(this,'TrajectorySpeedSectionTitle');
            this.Tag='trajectoryspeed';

            dropDownItems={msgString(this,'AutoOption');
            msgString(this,'TableOption')};

            this.TimeLabel=Label(msgString(this,'TimeLabel'));
            this.TimeLabel.Tag='timelabel';
            this.TimeDropdown=DropDown;
            this.TimeDropdown.Tag='timedropdown';
            this.TimeDropdown.Description=msgString(this,'TimeDescription');
            this.TimeDropdown.ValueChangedFcn=hApp.initCallback(@this.onAutoTime);
            this.TimeDropdown.Items=dropDownItems;


            this.GroundSpeedLabel=Label(msgString(this,'GroundSpeedLabel'));
            this.GroundSpeedLabel.Tag='groundspeedlabel';
            this.GroundSpeedDropDown=DropDown;
            this.GroundSpeedDropDown.Tag='groundspeeddropdown';
            this.GroundSpeedDropDown.Description=msgString(this,'GroundSpeedDescription');
            this.GroundSpeedDropDown.ValueChangedFcn=hApp.initCallback(@this.onAutoGroundSpeed);
            this.GroundSpeedDropDown.Items=dropDownItems;

            this.ClimbRateLabel=Label(msgString(this,'ClimbRateLabel'));
            this.ClimbRateLabel.Tag='climbratelabel';
            this.ClimbRateDropDown=DropDown;
            this.ClimbRateDropDown.Tag='climbratedropdown';
            this.ClimbRateDropDown.Description=msgString(this,'ClimbRateDescription');
            this.ClimbRateDropDown.ValueChangedFcn=hApp.initCallback(@this.onAutoClimbRate);
            this.ClimbRateDropDown.Items=dropDownItems;


            col1=addColumn(this,'HorizontalAlignment','right');
            add(col1,this.TimeLabel);
            add(col1,this.GroundSpeedLabel);
            add(col1,this.ClimbRateLabel);


            addColumn(this);

            col3=addColumn(this,'HorizontalAlignment','center');
            add(col3,this.TimeDropdown);
            add(col3,this.GroundSpeedDropDown);
            add(col3,this.ClimbRateDropDown);

            this.Enabled=true;
        end

        function update(this)
            currentPlatform=this.Application.DataModel.CurrentPlatform;
            enableSection=~isempty(currentPlatform);
            this.TimeDropdown.Enabled=enableSection;
            this.GroundSpeedDropDown.Enabled=enableSection;
            this.ClimbRateDropDown.Enabled=enableSection;
            if enableSection
                traj=currentPlatform.TrajectorySpecification;
                this.TimeDropdown.SelectedIndex=2-traj.AutoTime;
                this.GroundSpeedDropDown.SelectedIndex=2-traj.AutoGroundSpeed;
                this.ClimbRateDropDown.SelectedIndex=2-traj.AutoClimbRate;
            end
        end
    end


    methods(Access=private)
        function onAutoTime(this,~,evt)
            setAutoTime(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
        end

        function onAutoGroundSpeed(this,~,evt)
            setAutoGroundSpeed(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
        end

        function onAutoClimbRate(this,~,evt)
            setAutoClimbRate(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
        end
    end
end
