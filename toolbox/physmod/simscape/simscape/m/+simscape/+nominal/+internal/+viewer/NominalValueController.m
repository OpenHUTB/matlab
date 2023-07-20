





classdef NominalValueController<handle

    properties(Access=private)


Model



View


        Listeners={};
    end

    events

FigureDeleted
    end

    methods

        function this=NominalValueController(nominalValueModel,nominalValueView)

            this.Model=nominalValueModel;
            this.View=nominalValueView;


            this.addListeners();



            this.initializeViewComponent;
        end
    end

    methods(Access=private)

        function addListeners(this)

            eventCallbacks={{'AddRowSelection',@this.addRowSelectionCallback},...
            {'DeleteRowSelection',@this.deleteRowSelectionCallback},...
            {'TableCellSelected',@this.nominalValueTableCellSelectionCallback},...
            {'TableCellEdited',@(src,event)this.nominalValueTableCellEditedCallback(src,event)},...
            {'OkButtonPushed',@this.okButtonPushedCallback},...
            {'CancelButtonPushed',@this.cancelButtonPushedCallback}...
            ,{'HelpButtonPushed',@this.helpButtonPushedCallback},...
            {'ApplyButtonPushed',@this.applyButtonPushedCallback}...
            ,{'ModelNameModified',@this.updateMdlNameCallback},...
            {'FigureDeleted',@this.closeFigure}};

            this.Listeners=cellfun(@(p)addlistener(this.View,p{1:end}),eventCallbacks,...
            'UniformOutput',false);
        end

        function initializeViewComponent(this,~,~)

            apphandle=lGetAppHandle(this.Model.Name);
            if(lIsAppHandleValid(apphandle))


                figure(apphandle);
                return
            else


                this.View.createGUIComponents;
                this.loadDataInView();
            end
        end

        function loadDataInView(this)


            this.View.setTitle(this.Model.Name);


            this.View.setData(this.Model.Data);
        end

        function addRowSelectionCallback(this,~,~)

            this.Model.addRow(this.Model);
            this.View.setData(this.Model.Data);
        end

        function deleteRowSelectionCallback(this,~,~)

            selectedCellIndices=this.View.getSelectedCellIndices();
            tableSize=size(this.Model.Data);
            [currentNominalValue,currentUnit]=this.View.getRowData(selectedCellIndices);

            assert(~isempty(selectedCellIndices),'physmod:simscape:nominal:editor:InvalidCellSelection',...
            'No cell selected for delete');
            this.Model.deleteRow(selectedCellIndices);

            this.View.setData(this.Model.Data);
            if(isequal(tableSize(2),selectedCellIndices(1)))
                this.View.setSelectedCellEmpty;
            end
            this.View.setRowStatus(simscape.nominal.internal.viewer.Status.Deleted,selectedCellIndices);
            this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Deleted);
            statusPanelTitle=lGetString('StatusDeleteRowSelected',cell2mat(currentNominalValue),...
            cell2mat(currentUnit));
            this.View.setStatusPanelTitle(statusPanelTitle);
            this.View.enableApply;
            this.nominalValueTableCellSelectionCallback;
        end

        function nominalValueTableCellSelectionCallback(this,~,~)

            selectedCellIndices=this.View.getSelectedCellIndices();
            if(isempty(selectedCellIndices))
                this.View.disableDeleteRow;
            else
                this.View.enableDeleteRow;
            end
        end

        function[previousNominalValue,previousUnit]=nominalValueTableCellEditedCallback(this,src,event)

            [currentNominalValue,currentUnit]=this.View.getRowData(event.Indices);


            if(isempty(currentNominalValue{1})||str2double(currentNominalValue{1})<=0)
                currentNominalValue=cellstr(event.PreviousData);
                statusPanelTitle=lGetString('StatusEditRowValueInvalid');
                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Error);
            elseif(isempty(currentUnit{1}))
                currentUnit=cellstr(event.PreviousData);
                statusPanelTitle=lGetString('StatusEditRowUnitInvalid');
                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Error);
            else

                switch(event.Indices(2))
                case 1
                    previousNominalValue=event.PreviousData;
                    previousUnit=currentUnit;
                case 2
                    previousNominalValue=currentNominalValue;
                    previousUnit=event.PreviousData;
                end


                if(iscell(previousNominalValue))
                    previousNominalValue=cell2mat(previousNominalValue);
                end

                if(iscell(previousUnit))
                    previousUnit=cell2mat(previousUnit);
                end
                this.View.setRowStatus(simscape.nominal.internal.viewer.Status.Edited,event.Indices);
                statusPanelTitle=lGetString('StatusEditRowSelected',previousNominalValue,...
                previousUnit,cell2mat(currentNominalValue),...
                cell2mat(currentUnit));
                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Edited);
            end
            this.Model.updateData(event.Indices,currentNominalValue,currentUnit);
            this.View.setStatusPanelTitle(statusPanelTitle);
            this.View.setData(this.Model.Data);
            this.View.enableApply;
        end

        function okButtonPushedCallback(this,~,~)

            try

                NominalValues=simscape.nominal.internal.serializeSimscapeNominalValues(...
                {this.Model.Data.Values},{this.Model.Data.Units});
                simscape.nominal.internal.validateSimscapeNominalValues(NominalValues);
                set_param(this.Model.Name,'SimscapeNominalValues',NominalValues);


                this.closeFigure;

            catch ME
                tokenErrorDialogText=lGetString('TokenErrorDialogText');
                errorMsg=tokenErrorDialogText+" "+ME.message;
                tokenErrorDialogTitle=lGetString('TokenErrorDialogTitle',this.Model.Name);
                this.View.displayInvalidValueErrorDlg(errorMsg,tokenErrorDialogTitle);
                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Error);
                this.View.setStatusPanelTitle(errorMsg);
            end
        end

        function cancelButtonPushedCallback(this,~,~)


            if(strcmp(this.View.getApplyButtonStatus,"on"))
                cancelDialogText=lGetString('CancelDialogText');
                cancelDialogTitle=lGetString('CancelDialogTitle',this.Model.Name);

                selection=this.View.displayInvalidValueWarningDlg(cancelDialogText,cancelDialogTitle);
                if(strcmp(selection,lGetString('ButtonYes')))


                    this.okButtonPushedCallback();
                else

                    this.closeFigure;
                end

            else



                this.closeFigure;
            end
        end

        function helpButtonPushedCallback(this,~,~)
            helpview('simscape','SimscapeNominalValuesViewer');
        end

        function applyButtonPushedCallback(this,~,~)

            try

                NominalValues=simscape.nominal.internal.serializeSimscapeNominalValues(...
                {this.Model.Data.Values},{this.Model.Data.Units});
                simscape.nominal.internal.validateSimscapeNominalValues(NominalValues);
                set_param(this.Model.Name,'SimscapeNominalValues',NominalValues);


                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Apply);
                statusPanelTitle=lGetString('StatusApply');
                this.View.setStatusPanelTitle(statusPanelTitle);


                this.View.disableApply;

            catch ME
                tokenErrorDialogText=lGetString('TokenErrorDialogText');
                errorMsg=tokenErrorDialogText+" "+ME.message;
                tokenErrorDialogTitle=lGetString('TokenErrorDialogTitle',this.Model.Name);
                this.View.displayInvalidValueErrorDlg(errorMsg,tokenErrorDialogTitle);
                this.View.setStatusPanelState(simscape.nominal.internal.viewer.Status.Error);
                this.View.setStatusPanelTitle(errorMsg);
            end
        end

        function updateMdlNameCallback(this,~,~)
            newMdlName=this.View.getNewMdlName();
            this.Model.updateMdlName(newMdlName);
            this.View.setTitle(newMdlName);
        end

        function closeFigure(this,~,~)
            apphandle=lGetAppHandle(this.Model.Name);
            delete(apphandle);
        end
    end

end


function msgString=lGetString(messageID,varargin)

    fullId=strcat('physmod:simscape:simscape:nominal:viewer:',messageID);
    msgString=getString(message(fullId,varargin{:}));
end

function apphandle=lGetAppHandle(mdlName)
    apphandle=findall(0,'Type','figure','Tag','NominalValueViewer','Name',...
    lGetString('Title',mdlName),'-property','RunningAppInstance');
end

function res=lIsAppHandleValid(apphandle)
    res=~isempty(apphandle)&&ishandle(apphandle)&&isvalid(apphandle);
end