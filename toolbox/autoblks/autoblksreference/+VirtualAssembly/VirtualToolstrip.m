classdef VirtualToolstrip<handle




    properties

TabGroup

Tab

    end

    properties(Access=private)
        FSection VirtualAssembly.FileSection
        CSection VirtualAssembly.ConfigSection
        ESection VirtualAssembly.ExportSection
        OSection VirtualAssembly.OperateSection
        RSection VirtualAssembly.ResultsSection
        LSection VirtualAssembly.LayoutSection
        ToolstripTag='VirtualVehicleConfigTabs'
    end

    properties(Dependent,SetAccess=private)
Tabs
    end

    events

RequestForNewSession
RequestForOpenSession
RequestForSaveSession
VehClassSelected
VehDataSelected
VehScenSelected
RequestToSaveCurrentScript
RequestToSaveNewScript
RequestToSaveCurrentModel
RequestToSaveNewModel
RequestToRunSimulation
RequestToSetUpSDI
RequestToShowSDI
RequestForDefaultLayout
RequestForVehSetup
    end


    methods



        function obj=VirtualToolstrip()

            obj.TabGroup=matlab.ui.internal.toolstrip.TabGroup();
            obj.TabGroup.Tag=makeAppTag(obj);

            obj.Tab=matlab.ui.internal.toolstrip.Tab('Composer');
            obj.Tab.Tag='homeTab';
            createTab(obj);

            add(obj.TabGroup,obj.Tab);
            obj.TabGroup.SelectedTab=obj.Tab;



        end


        function close(obj)

            obj.disableAll();
        end


        function disableAll(obj)

            obj.Tab.disableAll();
        end

        function enableAll(obj)

            obj.Tab.enableAll();
        end

    end




    methods
        function tTag=makeAppTag(obj)
            tTag=obj.ToolstripTag+"_"+matlab.lang.internal.uuid;
        end
        function tool=get.Tabs(obj)
            tool=obj.TabGroup;
        end

        function setConfigurationToolstrip(obj,buttonname)
            obj.setToolstripStatus('Configuration',buttonname);
        end


        function setToolstripStatus(obj,sectionname,buttonname)
            obj.FSection.NewButton.Enabled=true;
            obj.FSection.OpenButton.Enabled=true;
            obj.LSection.DefaultLayoutButton.Enabled=true;
            obj.CSection.VehSetupButton.Enabled=true;
            if strcmpi(sectionname,'configuration')
                switch buttonname
                case 'Start'
                    obj.FSection.NewButton.Enabled=true;
                    obj.FSection.SaveButton.Enabled=false;

                    obj.CSection.VehDataButton.Enabled=false;
                    obj.CSection.VehScenButton.Enabled=false;
                    obj.CSection.VehSetupButton.Enabled=false;
                    obj.ESection.ConfirmButton.Enabled=false;
                    obj.OSection.RunButton.Enabled=false;
                    obj.CSection.LoggingButton.Enabled=false;
                    obj.RSection.SDIButton.Enabled=false;
                case 'VehClass'
                    obj.FSection.SaveButton.Enabled=false;

                    obj.CSection.VehDataButton.Enabled=false;
                    obj.CSection.VehScenButton.Enabled=false;
                    obj.CSection.VehSetupButton.Enabled=false;
                    obj.ESection.ConfirmButton.Enabled=false;
                    obj.OSection.RunButton.Enabled=false;
                    obj.CSection.LoggingButton.Enabled=false;
                    obj.RSection.SDIButton.Enabled=false;
                case 'VehData'
                    obj.FSection.SaveButton.Enabled=true;

                    obj.CSection.VehDataButton.Enabled=true;
                    obj.CSection.VehScenButton.Enabled=true;
                    obj.CSection.VehSetupButton.Enabled=true;
                    obj.ESection.ConfirmButton.Enabled=true;
                    obj.OSection.RunButton.Enabled=false;
                    obj.CSection.LoggingButton.Enabled=true;
                    obj.RSection.SDIButton.Enabled=false;
                case 'VehScen'
                    obj.FSection.SaveButton.Enabled=true;

                    obj.CSection.VehDataButton.Enabled=true;
                    obj.CSection.VehScenButton.Enabled=true;
                    obj.CSection.VehSetupButton.Enabled=true;
                    obj.ESection.ConfirmButton.Enabled=true;
                    obj.OSection.RunButton.Enabled=false;
                    obj.CSection.LoggingButton.Enabled=true;
                    obj.RSection.SDIButton.Enabled=false;
                case 'DataLogEditor'
                    obj.FSection.SaveButton.Enabled=true;

                    obj.CSection.VehDataButton.Enabled=true;
                    obj.CSection.VehScenButton.Enabled=true;
                    obj.CSection.VehSetupButton.Enabled=true;
                    obj.ESection.ConfirmButton.Enabled=true;
                    obj.CSection.LoggingButton.Enabled=true;
                case 'VehExpo'
                    obj.FSection.SaveButton.Enabled=true;

                    obj.CSection.VehDataButton.Enabled=true;
                    obj.CSection.VehScenButton.Enabled=true;
                    obj.CSection.VehSetupButton.Enabled=true;
                    obj.ESection.ConfirmButton.Enabled=true;
                    obj.OSection.RunButton.Enabled=true;
                    obj.CSection.LoggingButton.Enabled=true;
                    obj.RSection.SDIButton.Enabled=true;
                otherwise
                    obj.FSection.SaveButton.Enabled=true;

                    obj.CSection.VehDataButton.Enabled=true;
                    obj.CSection.VehScenButton.Enabled=true;
                    obj.CSection.VehSetupButton.Enabled=true;
                    obj.ESection.ConfirmButton.Enabled=true;
                    obj.OSection.RunButton.Enabled=true;
                    obj.CSection.LoggingButton.Enabled=true;
                    obj.RSection.SDIButton.Enabled=true;
                end
            end
        end

        function setVehSetupBtn(obj,status)
            obj.CSection.VehSetupButton.Enabled=status;
        end

    end

    methods(Access=private)
























        function createTab(obj)



            tab=obj.Tab;

            obj.FSection=VirtualAssembly.FileSection(tab);
            obj.CSection=VirtualAssembly.ConfigSection(tab);
            obj.ESection=VirtualAssembly.ExportSection(tab);
            obj.OSection=VirtualAssembly.OperateSection(tab);
            obj.RSection=VirtualAssembly.ResultsSection(tab);
            obj.LSection=VirtualAssembly.LayoutSection(tab);
            installListenners(obj);

        end

        function installListenners(obj)

            obj.FSection.NewButton.ButtonPushedFcn=@(~,event)notify(obj,'VehClassSelected');
            obj.FSection.OpenButton.ButtonPushedFcn=@(~,event)notify(obj,'RequestForOpenSession');
            obj.FSection.SaveButton.ButtonPushedFcn=@(~,event)notify(obj,'RequestForSaveSession');


            obj.CSection.VehDataButton.ButtonPushedFcn=@(~,~)notify(obj,'VehDataSelected');
            obj.CSection.VehScenButton.ButtonPushedFcn=@(~,~)notify(obj,'VehScenSelected');

            obj.ESection.ConfirmButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToSaveNewModel');

            obj.OSection.RunButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToRunSimulation');

            obj.CSection.LoggingButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToSetUpSDI');
            obj.RSection.SDIButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToShowSDI');
            obj.LSection.DefaultLayoutButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestForDefaultLayout');

            obj.CSection.VehSetupButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestForVehSetup');
        end
    end
end