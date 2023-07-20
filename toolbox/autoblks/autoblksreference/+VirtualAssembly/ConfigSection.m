classdef ConfigSection<handle




    properties
        VehClassButton matlab.ui.internal.toolstrip.Button

        VehDataButton matlab.ui.internal.toolstrip.Button

        VehScenButton matlab.ui.internal.toolstrip.Button

        LoggingButton matlab.ui.internal.toolstrip.Button

        VehSetupButton matlab.ui.internal.toolstrip.Button

Tag
    end

    properties(Access=private)
Tab
    end

    events
OpenDataLogging
    end

    methods



        function obj=ConfigSection(tab)
            obj.Tab=tab;
            obj.createWidgtes();
            obj.addButtons();
            obj.Tag='ConfigSection';
        end
    end




    methods(Access=private)
        function createWidgtes(obj)


            obj.createVehDataButton();
            obj.createVehSetupButton();
            obj.createVehScenButton();
            obj.createDataLoggingButton();
        end


        function addButtons(obj)

            section=addSection(obj.Tab,"Configure");
            section.Tag='ConfigSection';

            column=section.addColumn();
            column.add(obj.VehSetupButton);

            column=section.addColumn();
            column.add(obj.VehDataButton);

            column=section.addColumn();
            column.add(obj.VehScenButton);

            column=section.addColumn();
            column.add(obj.LoggingButton);
        end



        function createVehDataButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','DataIcon.png');
            label1="Data and";
            label2="Calibration";
            label=join([label1,label2],newline);
            obj.VehDataButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.VehDataButton.Tag='VehData';
            obj.VehDataButton.Description="Config Vehicle Data";
            obj.VehDataButton.Enabled=false;
        end

        function createVehScenButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','DrivingRoadNetwork_24.png');
            label1="Scenario";
            label2="and Test";
            label=join([label1,label2],newline);
            obj.VehScenButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.VehScenButton.Tag='Select Vehicle Scenario';
            obj.VehScenButton.Description="Select Vehicle Scenario";
            obj.VehScenButton.Enabled=false;
        end

        function createDataLoggingButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','SignalEditor.png');
            label="Logging";
            obj.LoggingButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.LoggingButton.Tag='openDataLogBtn';
            obj.LoggingButton.Description="Open data logging";
            obj.LoggingButton.Enabled=false;
        end

        function createVehSetupButton(obj)

            import matlab.ui.internal.toolstrip.Icon.*;
            icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Tools_24.png');
            label="Setup";
            obj.VehSetupButton=matlab.ui.internal.toolstrip.Button(label,icon);
            obj.VehSetupButton.Tag='VehSetupBtn';
            obj.VehSetupButton.Description="VehSetup";
            obj.VehSetupButton.Enabled=false;

        end
    end
end