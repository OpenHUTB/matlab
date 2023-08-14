classdef ExportParametersToWSDlg<controllib.ui.internal.dialog.AbstractDialog




    properties(Access='private')

        paramsVariableNameLabel;
        errorsVariableNameLabel;

        paramsVariableNameEditBox;
        errorsVariableNameEditBox;

        paramsVariableName="tform";
        errorsVariableName="errors";

        paramsValue;
        errorsValue;

        exportErrorsCheckBox;

        OKBtn;
        CancelBtn;

    end

    properties
        FigureTag="exportParametersToWSDlg";
    end

    methods
        function this=ExportParametersToWSDlg(title,paramsValue,errorsValue)
            this.Title=title;
            this.paramsValue=paramsValue;
            this.errorsValue=errorsValue;
            this.CloseMode='destroy';
        end

        function value=showDlg(this,parent)
            show(this,parent)
            uiwait(this.UIFigure);
            value=[];

        end
    end

    methods(Access='protected')
        function buildUI(this)

            figSize=[350,200];
            this.UIFigure.Position=[this.UIFigure.Position(1),...
            this.UIFigure.Position(2),figSize(1),figSize(2)];
            this.UIFigure.Resize='off';
            this.UIFigure.Tag=this.FigureTag;

            rBtnGroup=uibuttongroup(this.UIFigure,'Visible','on',...
            'Position',[10,10,330,180]);
            this.paramsVariableNameLabel=uilabel(rBtnGroup,'Text',...
            string(message('lidar:lidarCameraCalibrator:exportTformLabel')),...
            'Position',[10,150,150,30],'Tag','paramsToWS');
            this.errorsVariableNameLabel=uilabel(rBtnGroup,'Text',...
            string(message('lidar:lidarCameraCalibrator:exportErrorLabel')),...
            'Position',[10,80,150,30],'Tag','errorsToWS');

            this.paramsVariableNameEditBox=uieditfield('Value',this.paramsVariableName,...
            'Editable',true,'Parent',rBtnGroup,...
            'Position',[200,150,100,20],'Enable','on');
            this.exportErrorsCheckBox=uicheckbox(rBtnGroup,'Text',...
            string(message('lidar:lidarCameraCalibrator:exportErrorsCheckBox')),...
            'Value',0,...
            'Position',[10,110,150,30]);
            this.errorsVariableNameEditBox=uieditfield('Value',this.errorsVariableName,...
            'Editable',true,'Parent',rBtnGroup,...
            'Position',[200,80,100,20],'Enable','off');

            this.OKBtn=uibutton('Parent',this.UIFigure,'Text',...
            string(message('lidar:lidarCameraCalibrator:okBtn')),...
            'Position',[figSize(1)/2-100,20,80,30],'Tag','OkButton');
            this.CancelBtn=uibutton('Parent',this.UIFigure,'Text',...
            string(message('lidar:lidarCameraCalibrator:cancelBtn')),...
            'Position',[figSize(1)/2+5,20,80,30],'Tag','CancelButton');
        end

        function connectUI(this)

            addlistener(this.OKBtn,'ButtonPushed',@(es,ed)cbOKBtn(this));
            addlistener(this.CancelBtn,'ButtonPushed',@(es,ed)cbCancelBtn(this));

            this.paramsVariableNameEditBox.ValueChangedFcn=...
            @(es,ed)cbParamsVariableNameChanged(this,es);
            this.errorsVariableNameEditBox.ValueChangedFcn=...
            @(es,ed)cbErrorsVariableNameChanged(this,es);

            this.exportErrorsCheckBox.ValueChangedFcn=...
            @(es,ed)cbCheckBoxSelectionChanged(this,es);
        end
    end

    methods(Access='private')
        function cbOKBtn(this)

            if isempty(this.paramsVariableName)||((this.exportErrorsCheckBox.Value)&&isempty(this.errorsVariableName))
                uialert(this.UIFigure,string(message('lidar:lidarCameraCalibrator:invalidVarNameDlgMsg')),...
                string(message('lidar:lidarCameraCalibrator:invalidVarNameDlgTitle')));
                return
            end

            if~isvarname(this.paramsVariableName)||((this.exportErrorsCheckBox.Value)&&~isvarname(this.errorsVariableName))
                uialert(this.UIFigure,string(message('lidar:lidarCameraCalibrator:invalidVarNameDlgMsg')),...
                string(message('lidar:lidarCameraCalibrator:invalidVarNameDlgTitle')));
                return
            end



            if(this.exportErrorsCheckBox.Value)&&strcmp(this.paramsVariableName,this.errorsVariableName)
                tempstruct=struct;
                tempstruct.tform=this.paramsValue;
                tempstruct.errors=this.errorsValue;
                assignin('base',this.paramsVariableName,tempstruct);
                this.close();

            else
                assignin('base',this.paramsVariableName,this.paramsValue);
                if(this.exportErrorsCheckBox.Value)
                    assignin('base',this.errorsVariableName,this.errorsValue);
                end
                this.close();
            end

        end

        function cbCancelBtn(this)
            this.close();
        end

        function cbCheckBoxSelectionChanged(this,es)
            this.errorsVariableNameEditBox.Enable=es.Value;
        end

        function cbParamsVariableNameChanged(this,es)
            this.paramsVariableName=es.Value;
        end

        function cbErrorsVariableNameChanged(this,es)
            this.errorsVariableName=es.Value;
        end

    end

end
