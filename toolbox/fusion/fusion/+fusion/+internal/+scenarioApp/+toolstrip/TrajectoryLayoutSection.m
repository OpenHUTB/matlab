classdef TrajectoryLayoutSection<fusion.internal.scenarioApp.toolstrip.Section

    properties
Enabled
    end

    methods
        function this=TrajectoryLayoutSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            hApp=this.Application;

            import matlab.ui.internal.toolstrip.*;
            this.Title=msgString(this,'TrajectoryLayoutSectionTitle');
            this.Tag='trajectorylayout';


            tzAxes=ToggleButton(msgString(this,'TZCheck'));
            tzAxes.Icon=Icon(fullfile(this.IconDirectory,'TZ_24.png'));
            tzAxes.Value=hApp.TZEnable;
            tzAxes.Tag='tzcheck';
            tzAxes.Description=msgString(this,'TZDescription');
            tzAxes.ValueChangedFcn=hApp.initCallback(@this.tzAxesCallback);

            tableShow=ToggleButton(msgString(this,'TableCheck'));
            tableShow.Icon=Icon(fullfile(this.IconDirectory,'trajectory_table_24.png'));
            tableShow.Value=hApp.TableEnable;
            tableShow.Tag='tablecheck';
            tableShow.Description=msgString(this,'TableDescription');
            tableShow.ValueChangedFcn=hApp.initCallback(@this.tableShowCallback);

            col1=addColumn(this,'HorizontalAlignment','left');
            add(col1,tableShow);
            col2=addColumn(this,'HorizontalAlignment','left');
            add(col2,tzAxes);
            this.Enabled=true;
        end


    end


    methods(Access=private)

        function tzAxesCallback(this,~,evt)
            toggleTZAxes(this.Application,evt.EventData.NewValue);
        end

        function tableShowCallback(this,~,evt)
            toggleTrajectoryTable(this.Application,evt.EventData.NewValue)
        end
    end
end
