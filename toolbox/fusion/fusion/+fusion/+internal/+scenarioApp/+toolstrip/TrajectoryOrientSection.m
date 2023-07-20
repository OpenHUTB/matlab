classdef TrajectoryOrientSection<fusion.internal.scenarioApp.toolstrip.Section

    properties
Enabled
    end

    properties(SetAccess=protected,Hidden)
OrientDropDown
OrientLabel
CourseDropDownLabel
CourseDropDown
    end

    methods
        function this=TrajectoryOrientSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            hApp=this.Application;

            import matlab.ui.internal.toolstrip.*;
            this.Title=msgString(this,'TrajectoryOrientSectionTitle');
            this.Tag='trajectoryorient';

            dropDownItems={msgString(this,'AutoOption');
            msgString(this,'TableOption')};

            this.CourseDropDownLabel=Label(msgString(this,'AutoCourse'));
            this.CourseDropDownLabel.Tag="courselabel";
            this.CourseDropDown=DropDown;
            this.CourseDropDown.Tag='coursedropdown';
            this.CourseDropDown.Description=msgString(this,'AutoCourseDescription');
            this.CourseDropDown.ValueChangedFcn=hApp.initCallback(@this.onAutoCourse);
            this.CourseDropDown.Items=dropDownItems;


            this.OrientLabel=Label(msgString(this,'AutoOrient'));
            this.OrientLabel.Tag="OrientLabel";
            this.OrientDropDown=DropDown;
            this.OrientDropDown.Tag='orientdropdown';
            this.OrientDropDown.Description=msgString(this,'AutoOrientDescription');
            this.OrientDropDown.ValueChangedFcn=hApp.initCallback(@this.onAutoOrient);
            this.OrientDropDown.Items=dropDownItems;


            col1=addColumn(this,'HorizontalAlignment','right');
            add(col1,this.CourseDropDownLabel);
            add(col1,this.OrientLabel);
            addEmptyControl(col1);

            addColumn(this);
            col2=addColumn(this,'HorizontalAlignment','left');
            add(col2,this.CourseDropDown);
            add(col2,this.OrientDropDown);
            addEmptyControl(col2);
            this.Enabled=true;
        end

        function update(this)
            currentPlatform=this.Application.DataModel.CurrentPlatform;
            enableSection=~isempty(currentPlatform);
            this.OrientDropDown.Enabled=enableSection;
            this.OrientDropDown.Enabled=enableSection;
            this.CourseDropDown.Enabled=enableSection;
            if enableSection
                traj=currentPlatform.TrajectorySpecification;
                this.OrientDropDown.SelectedIndex=2-traj.AutoBank;
                this.CourseDropDown.SelectedIndex=2-traj.AutoCourse;
            end
        end
    end


    methods(Access=private)
        function onAutoOrient(this,~,evt)
            setAutoPitch(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
            setAutoBank(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
        end

        function onAutoCourse(this,~,evt)
            setAutoCourse(this.Application,isequal(evt.EventData.NewValue,msgString(this,'AutoOption')));
        end
    end
end
