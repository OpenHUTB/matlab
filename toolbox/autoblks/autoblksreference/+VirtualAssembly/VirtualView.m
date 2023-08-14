classdef VirtualView<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties

        ProductCatalog=''

        ProductCatalogFile=''
    end

    properties(SetAccess=private)

        Container VirtualAssembly.VirtualAppContainer

        Toolstrip VirtualAssembly.VirtualToolstrip
    end

    properties(Access=private)

        ProjPath=''
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


PassengerCarSelected
MotorcycleSelected

    end

    methods



        function obj=VirtualView(varargin)
            if~isempty(varargin)
                set(obj,varargin{:});
            end

            obj.Container=VirtualAssembly.VirtualAppContainer();
            obj.Toolstrip=VirtualAssembly.VirtualToolstrip();
            addTabs(obj.Container,obj.Toolstrip.Tabs);

            obj.wireUpContainer();
            obj.wireUpToolStrip();
        end
    end

    methods

        function openApp(obj)
            obj.Container.ProductCatalogFile=obj.ProductCatalogFile;
            obj.Toolstrip.setConfigurationToolstrip('Start');


            licStatus_ptbs=dig.isProductInstalled('Powertrain Blockset');
            licStatus_vdbs=dig.isProductInstalled('Vehicle Dynamics Blockset');

            if licStatus_ptbs&&licStatus_vdbs
                obj.Container.licStatus='vdbs and ptbs';
            else
                if licStatus_ptbs
                    obj.Container.licStatus='ptbs';
                else
                    if licStatus_vdbs
                        obj.Container.licStatus='vdbs';
                    else
                        obj.Container.licStatus='none';

                        error(message('autoblks_reference:autoerrVirtualAssembly:InvalidVDBSLicense').getString);
                    end
                end
            end


            obj.Container.openApp();
        end


        function closeApp(obj)

            obj.Toolstrip.close();
            obj.Container.closeApp();
            delete(obj);
        end

        function selectVehClass(obj)

            obj.Toolstrip.setConfigurationToolstrip('VehClass');
            obj.Container.setFeatureTreeVisibility(false);

            obj.Container.openVehClassFigDoc();

        end


        function selectVehData(obj)
            obj.Toolstrip.setConfigurationToolstrip('VehData');

            if isempty(obj.Container.VehDataFigDoc)||~isvalid(obj.Container.VehDataFigDoc)
                obj.Container.openNewSession();
            else

                tag=obj.Container.VehDataDoc.Tag;
                obj.Container.App.SelectedChild.tag=tag;
            end
        end

        function openVehScen(obj)

            obj.Container.setFeatureTreeVisibility(false);
            obj.Toolstrip.setConfigurationToolstrip('VehScen');
            if isempty(obj.Container.VehScenFigDoc)||~isvalid(obj.Container.VehScenFigDoc)
                obj.Container.setVehScenFigDoc();
            else

                tag=obj.Container.VehScene.Doc.Tag;
                obj.Container.App.SelectedChild.tag=tag;
            end
        end

        function generateNewTestScript(obj)
            obj.Container.generateTestScript('New');
        end

        function generateCurrentTestScript(obj)
            obj.Container.generateTestScript('Old');
        end

        function generateNewVirtualVehicle(obj)
            obj.Toolstrip.setConfigurationToolstrip('VehExpo');
            obj.Container.generateVirtualVehicleModel('New');
        end

        function generateCurrentVirtualVehicle(obj)
            obj.Container.generateVirtualVehicleModel('Old');
        end
    end

    methods(Access=private)
        function wireUpContainer(obj)

            addlistener(obj.Container,'PassengerCarSelected',@(~,event)requestforNewSession(obj));
            addlistener(obj.Container,'MotorcycleSelected',@(~,event)requestforNewSession(obj));

        end


        function wireUpToolStrip(obj)
            addlistener(obj.Toolstrip,'RequestForNewSession',@(~,~)requestforNewSession(obj));
            addlistener(obj.Toolstrip,'RequestForOpenSession',@(~,~)requestforOpenSession(obj));
            addlistener(obj.Toolstrip,'VehClassSelected',@(~,~)selectVehClass(obj));
            addlistener(obj.Toolstrip,'VehDataSelected',@(~,~)selectVehData(obj));
            addlistener(obj.Toolstrip,'VehScenSelected',@(~,~)openVehScen(obj));
            addlistener(obj.Toolstrip,'RequestForSaveSession',@(~,~)requestToSave(obj));
            addlistener(obj.Toolstrip,'RequestToSaveCurrentModel',@(~,~)generateCurrentVirtualVehicle(obj));
            addlistener(obj.Toolstrip,'RequestToSaveNewScript',@(~,~)generateNewTestScript(obj));
            addlistener(obj.Toolstrip,'RequestToSaveNewModel',@(~,~)generateNewVirtualVehicle(obj));
            addlistener(obj.Toolstrip,'RequestToSaveCurrentScript',@(~,~)generateCurrentTestScript(obj));
            addlistener(obj.Toolstrip,'RequestToRunSimulation',@(~,~)runSimulation(obj));
            addlistener(obj.Toolstrip,'RequestToSetUpSDI',@(~,~)setUpSDI(obj));
            addlistener(obj.Toolstrip,'RequestToShowSDI',@(~,~)showSDI(obj));
            addlistener(obj.Toolstrip,'RequestForDefaultLayout',@(~,~)requestForDefaultLayout(obj));
            addlistener(obj.Toolstrip,'RequestForVehSetup',@(~,~)requestForVehSetup(obj));
        end

        function requestforNewSession(obj)

            obj.Toolstrip.setConfigurationToolstrip('VehData');
            obj.Container.openNewSession();
        end


        function requestforOpenSession(obj)

            ok=obj.Container.openSavedSession();
            if(ok)
                obj.Toolstrip.setConfigurationToolstrip('VehData');
            end
        end

        function requestToSave(obj)
            obj.Container.saveNewSession();
        end

        function runSimulation(obj)
            cd([obj.Container.ModelPath,filesep,obj.Container.ConfigInfos.SimModel]);
            filename=[obj.Container.ProjPath,filesep,'Scripts',filesep,'TestScript.m'];
            if isfile(filename)
                TestScript;
            else
                errordlg('Cannot find the TestScript.','Run Simulation Errors','modal');
            end
        end

        function setUpSDI(obj)

            if isempty(obj.Container.DataLogFigDoc)||~isvalid(obj.Container.DataLogFigDoc)
                obj.Container.setDataLogFigDoc();

            else

                tag=obj.Container.VehDataLog.Doc.Tag;
                obj.Container.App.SelectedChild.tag=tag;
            end

            obj.Toolstrip.setConfigurationToolstrip('DataLogEditor');
        end

        function showSDI(obj)
            VirtualAssembly.sdiPlot(obj.Container.SelectedSignals);
        end


        function requestForDefaultLayout(obj)


            obj.Container.setDefaultLayout();

        end

        function requestForVehSetup(obj)
            obj.Container.setFeatureTreeVisibility(false);
            obj.Container.isNewSession=false;
            obj.Container.openVehSetup();
        end









    end


end