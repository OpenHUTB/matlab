classdef Controller<handle

    properties(Hidden)
Model
View
AutoUpdateString
Listeners
    end


    methods
        function obj=Controller(model,view)
            obj.Model=model;
            obj.View=view;
            obj.AutoUpdateString='Update';

            obj.listenFileButtons()
            obj.listenDefaultLayoutButtons()
            obj.listenConfiguration()
            obj.listenAddButtons()
            obj.listenDeleteButton()
            obj.listenPlotButton()
            obj.listenAutoUpdateButton();
            obj.listenAutoUpdateCheckbox();
            obj.listenAutoUpdateRadioButtons();
            obj.listenExportButton()

            obj.Listeners.SystemParameterChanged=...
            addlistener(obj.View.Parameters,'SystemParameterChanged',...
            @(h,data)systemParameterChanged(obj.Model,data));
            obj.Listeners.ElementParameterChanged=...
            addlistener(obj.View.Parameters,'ElementParameterChanged',...
            @(h,data)elementParameterChanged(obj.Model,data));
            obj.Listeners.InsertionRequested=...
            addlistener(obj.View,'InsertionRequested',...
            @(h,data)insertionRequested(obj.Model,data));
            obj.Listeners.DeletionRequested=...
            addlistener(obj.View,'DeletionRequested',...
            @(h,data)deletionRequested(obj.Model,data));
            obj.Listeners.ElementSelected=...
            addlistener(obj.View.Canvas,'ElementSelected',...
            @(h,data)elementSelected(obj.Model,data));

            obj.Listeners.SystemParameterInvalid=...
            addlistener(obj.Model,'SystemParameterInvalid',...
            @(h,data)systemParameterInvalid(obj.View,data));
            obj.Listeners.ElementParameterInvalid=...
            addlistener(obj.Model,'ElementParameterInvalid',...
            @(h,data)elementParameterInvalid(obj.View,data));
            obj.Listeners.ParameterChanged=...
            addlistener(obj.Model,'ParameterChanged',...
            @(h,data)parameterChanged(obj.View,data));
            obj.Listeners.NewModel=...
            addlistener(obj.Model,'NewModel',...
            @(h,data)newModel(obj,data));
            obj.Listeners.NewName=...
            addlistener(obj.Model,'NewName',...
            @(h,data)newName(obj.View,data.Name));
            obj.Listeners.ElementInserted=...
            addlistener(obj.Model,'ElementInserted',...
            @(h,data)elementInserted(obj.View,data));
            obj.Listeners.ElementDeleted=...
            addlistener(obj.Model,'ElementDeleted',...
            @(h,data)elementDeleted(obj.View,data));
            obj.Listeners.SelectedElement=...
            addlistener(obj.Model,'SelectedElement',...
            @(h,data)selectedElement(obj.View,data));
        end
    end


    methods(Access=private)
        function listenFileButtons(obj)
            addlistener(obj.View.Toolstrip.NewBtn,'ButtonPushed',...
            @(h,e)newPopupActions(obj.Model,'Blank canvas'));
            addlistener(obj.View.Toolstrip.OpenBtn,'ButtonPushed',...
            @(h,e)openAction(obj.Model));

            addlistener(obj.View.Toolstrip.SaveBtn,'ButtonPushed',...
            @(h,e)saveAction(obj.Model));
            items=obj.View.Toolstrip.SaveBtn.Popup.getChildByIndex();
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)savePopupActions(obj.Model,items(i).Tag));
            end
        end


        function listenDefaultLayoutButtons(obj)
            addlistener(obj.View.Toolstrip.DefaultLayoutBtn,'ButtonPushed',...
            @(h,e)defaultLayoutAction(obj.View,'Default Layout'));
        end


        function listenConfiguration(obj)
            addlistener(obj.View.Toolstrip.BERtargetEdit,'ValueChanged',@(h,e)obj.changeConfig('BERtarget','BERtargetEdit'));
            addlistener(obj.View.Toolstrip.SymbolTimeEdit,'ValueChanged',@(h,e)obj.changeConfig('SymbolTime','SymbolTimeEdit'));
            addlistener(obj.View.Toolstrip.SamplesPerSymbolDropdown,'ValueChanged',@(h,e)obj.changeConfig('SamplesPerSymbol','SamplesPerSymbolDropdown'));
            addlistener(obj.View.Toolstrip.ModulationDropdown,'ValueChanged',@(h,e)obj.changeConfig('Modulation','ModulationDropdown'));
            addlistener(obj.View.Toolstrip.SignalingDropdown,'ValueChanged',@(h,e)obj.changeConfig('Signaling','SignalingDropdown'));
            addlistener(obj.View.Toolstrip.JitterBtn,'ButtonPushed',@(h,e)jitterAction(obj.Model,obj.View.Toolstrip.JitterBtn.Tag));
        end


        function changeConfig(obj,paramName,paramViewName)
            if strcmpi(paramName,'SymbolTime')&&str2double(obj.View.Toolstrip.(paramViewName).Value)>0

                obj.Model.SerdesDesign.(paramName)=str2double(obj.View.Toolstrip.(paramViewName).Value)*1e-12;
            else
                obj.Model.SerdesDesign.(paramName)=obj.View.Toolstrip.(paramViewName).Value;
            end
            if isempty(obj.Model.SerdesDesign.(paramName))

                obj.View.Toolstrip.(paramViewName).Value="";
                obj.Model.IsChanged=true;
            elseif isnumeric(obj.Model.SerdesDesign.(paramName))&&...
                obj.Model.SerdesDesign.(paramName)==str2double(obj.View.Toolstrip.(paramViewName).Value)||...
                ~isnumeric(obj.Model.SerdesDesign.(paramName))&&...
                strcmp(obj.Model.SerdesDesign.(paramName),obj.View.Toolstrip.(paramViewName).Value)||...
                strcmpi(paramName,'SymbolTime')&&...
                obj.Model.SerdesDesign.(paramName)==str2double(obj.View.Toolstrip.(paramViewName).Value)*1e-12

                serdesplot(obj.Model.SerdesDesign,{obj.AutoUpdateString,obj.View});
                if strcmpi(paramName,'Signaling')
                    obj.View.Parameters.ChannelDialog.updateLayout();
                end
                obj.Model.IsChanged=true;
            elseif isnumeric(obj.Model.SerdesDesign.(paramName))

                if isnan(obj.Model.SerdesDesign.(paramName))
                    obj.View.Toolstrip.(paramViewName).Value='';
                elseif strcmpi(paramName,'SymbolTime')

                    obj.View.Toolstrip.(paramViewName).Value=num2str(obj.Model.SerdesDesign.(paramName)*1e12);
                else
                    obj.View.Toolstrip.(paramViewName).Value=num2str(obj.Model.SerdesDesign.(paramName));
                end
            else

                obj.View.Toolstrip.(paramViewName).Value=obj.Model.SerdesDesign.(paramName);
            end
        end


        function listenAddButtons(obj)
            obj.View.Toolstrip.AgcBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'AGC');
            obj.View.Toolstrip.FfeBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'FFE');
            obj.View.Toolstrip.VgaBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'VGA');
            obj.View.Toolstrip.SatAmpBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'SAT_AMP');
            obj.View.Toolstrip.DfeCdrBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'DFE_CDR');
            obj.View.Toolstrip.CdrBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'CDR');
            obj.View.Toolstrip.CtleBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'CTLE');
            obj.View.Toolstrip.TransparentBtn.ItemPushedFcn=@(h,e)addAction(obj.View,'Transparent');
        end


        function listenDeleteButton(obj)
            addlistener(obj.View.Toolstrip.DeleteBtn,'ButtonPushed',...
            @(h,e)deleteAction(obj.View));
        end


        function listenPlotButton(obj)
            items=obj.View.Toolstrip.PlotBtn.Popup.getChildByIndex();
            addlistener(obj.View.Toolstrip.PlotBtn,'ButtonPushed',...
            @(h,e)serdesplot(obj.Model.SerdesDesign,{items(1).Tag,obj.View}));
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)serdesplot(obj.Model.SerdesDesign,{items(i).Tag,obj.View}));
            end
        end


        function listenAutoUpdateButton(obj)
            addlistener(obj.View.Toolstrip.AutoUpdateBtn,'ButtonPushed',...
            @(h,e)serdesplot(obj.Model.SerdesDesign,{'Update',obj.View}));
        end


        function listenAutoUpdateCheckbox(obj)
            obj.View.Toolstrip.AutoUpdateCheckbox.ValueChangedFcn=@(h,~)actionAutoUpdateCheckbox(obj,obj.View);
        end


        function listenAutoUpdateRadioButtons(obj)
            autoUpdateRadioBtn=obj.View.Toolstrip.AutoUpdateRadioBtn;
            manualUpdateRadioBtn=obj.View.Toolstrip.ManualUpdateRadioBtn;
            autoUpdateRadioBtn.ValueChangedFcn=@(h,e)actionAutoUpdateRadioBtn(obj,autoUpdateRadioBtn);
            manualUpdateRadioBtn.ValueChangedFcn=@(h,e)actionAutoUpdateRadioBtn(obj,manualUpdateRadioBtn);
        end


        function actionAutoUpdateRadioBtn(obj,radioBtn)
            if radioBtn==obj.View.Toolstrip.AutoUpdateRadioBtn
                obj.View.Toolstrip.AutoUpdateCheckbox.Value=obj.View.Toolstrip.AutoUpdateRadioBtn.Value;
            else
                obj.View.Toolstrip.AutoUpdateCheckbox.Value=~obj.View.Toolstrip.ManualUpdateRadioBtn.Value;
            end
            obj.actionAutoUpdateCheckbox;
        end


        function actionAutoUpdateCheckbox(obj,~)
            obj.View.Toolstrip.toggleAutoUpdateButton();
            obj.Model.IsAutoUpdate=obj.View.Toolstrip.isAutoUpdate;
            obj.Model.SerdesDesign.AutoAnalyze=obj.View.Toolstrip.AutoUpdateCheckbox.Value;
            if obj.View.Toolstrip.isAutoUpdate
                obj.AutoUpdateString='Update';
                serdesplot(obj.Model.SerdesDesign,{'Update',obj.View});
            else
                obj.AutoUpdateString='DirtyState';
            end
        end


        function listenExportButton(obj)
            items=obj.View.Toolstrip.ExportBtn.Popup.getChildByIndex();
            addlistener(obj.View.Toolstrip.ExportBtn,'ButtonPushed',...
            @(h,e)exportPopupActions(obj.Model,items(1).Tag));
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',...
                @(h,e)exportPopupActions(obj.Model,items(i).Tag));
            end
        end
    end


    methods(Hidden)
        function newModel(obj,data)
            obj.Listeners.SystemParameterChanged.Enabled=false;
            newView(obj.View,data.Name,data.SerdesDesign)
            obj.Listeners.SystemParameterChanged.Enabled=true;
        end
    end
end
