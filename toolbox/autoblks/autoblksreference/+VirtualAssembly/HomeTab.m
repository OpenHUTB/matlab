classdef HomeTab<handle



    properties
Tab
    end

    properties(Access=private)
        FSection VirtualAssembly.FileSection
        CSection VirtualAssembly.ConfigSection
        ESection VirtualAssembly.ExportSection
        OSection VirtualAssembly.OperateSection
        RSection VirtualAssembly.ResultsSection
        LSection VirtualAssembly.LayoutSection
    end

    events
RequestForNewSession
RequestForOpenSession
RequestForSaveSession
VehClassSelected
VehDataSelected
VehScenSelected
RequestToSaveNewModel
RequestToRunSimulation
RequestToSetUpSDI
RequestToShowSDI
RequestForDefaultLayout
RequestForCalibration
    end

    methods
        function obj=HomeTab()

            obj.Tab=matlab.ui.internal.toolstrip.Tab('Composer');
            obj.Tab.Tag='homeTab';
            createTab(obj);

        end

        function enable(this)
            this.Tab.enableAll();
        end


        function disable(this)
            this.Tab.disableAll();
        end
    end

    methods
        function setSaveButton(obj,status)
            obj.FSection.SaveButton.Enabled=status;
        end

        function setVehClassStatus(obj,status)
            obj.CSection.VehClassButton.Enabled=status;
        end

        function setToolstripStatus(obj,sectionname,buttonname)
            obj.FSection.NewButton.Enabled=true;
            obj.FSection.OpenButton.Enabled=true;
            obj.LSection.DefaultLayoutButton.Enabled=true;
            obj.CSection.CalibraButton.Enabled=false;
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

        function setExportButtonPopUp(obj)
            saveButtonOptions={'Generate New Test Script','Save to Current Test Script'};

            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;
            popup=PopupList();


            icon=SAVE_DIRTY_16;
            saveToNew=obj.createListItemHelper(...
            saveButtonOptions{1},@(~,~)obj.savetonewscript(),...
            'saveToNewScript',icon);
            popup.add(saveToNew);


            icon=SAVE_AS_16;
            saveToCurrent=obj.createListItemHelper(...
            saveButtonOptions{2},@(~,~)obj.savetocurrentscript(),...
            'saveToCurrentScript',icon);
            popup.add(saveToCurrent);

            obj.ESection.ExportButton.Popup=popup;

        end

        function setConfirmButtonPopUp(obj)
            saveButtonOptions={'Generate New Model','Save to Current Model'};

            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;
            popup=PopupList();


            icon=SAVE_DIRTY_16;
            saveToNew=obj.createListItemHelper(...
            saveButtonOptions{1},@(~,~)obj.savetonewmodel(),...
            'saveToNewModel',icon);
            popup.add(saveToNew);


            icon=SAVE_AS_16;
            saveToCurrent=obj.createListItemHelper(...
            saveButtonOptions{2},@(~,~)obj.savetocurrentmodel(),...
            'saveToCurrentModel',icon);
            popup.add(saveToCurrent);

            obj.ESection.ConfirmButton.Popup=popup;

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

            obj.ESection.ConfirmButton.ButtonPushedFcn=@(~,~)savetonewmodel(obj);

            obj.OSection.RunButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToRunSimulation');

            obj.CSection.LoggingButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToSetUpSDI');
            obj.RSection.SDIButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestToShowSDI');
            obj.LSection.DefaultLayoutButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestForDefaultLayout');

            obj.CSection.CalibraButton.ButtonPushedFcn=@(~,~)notify(obj,'RequestForCalibration');
        end

        function savetonew(obj)
            notify(obj,'RequestToSave');
        end

        function savetocurrentscript(obj)
            notify(obj,'RequestToSaveCurrentScript');
        end

        function savetonewscript(obj)
            notify(obj,'RequestToSaveNewScript');
        end

        function savetocurrentmodel(obj)
            notify(obj,'RequestToSaveCurrentModel');
        end

        function savetonewmodel(obj)
            notify(obj,'RequestToSaveNewModel');
        end

        function popup=getExportButtonPopup(obj)

            if isempty(obj.ESection.ExportButton.Popup)
                obj.setExportButtonPopUp();
            end
            popup=obj.ESection.ExportButton.Popup;
        end

        function popup=getConfirmButtonPopup(obj)

            if isempty(obj.ESection.ConfirmButton.Popup)
                obj.setConfirmButtonPopUp();
            end
            popup=obj.ESection.ConfirmButton.Popup;
        end

        function defaultLayout(obj)
            notify(obj,'RequestForDefaultLayout');
        end

    end

    methods(Static,Access=private)
        function dropDownEntry=createListItemHelper(text,funcHandle,tag,icon)


            if nargin>3
                dropDownEntry=matlab.ui.internal.toolstrip.ListItem(text,icon);
            else
                dropDownEntry=matlab.ui.internal.toolstrip.ListItem(text);
            end
            dropDownEntry.Tag=tag;
            dropDownEntry.ItemPushedFcn=funcHandle;
        end
    end
end