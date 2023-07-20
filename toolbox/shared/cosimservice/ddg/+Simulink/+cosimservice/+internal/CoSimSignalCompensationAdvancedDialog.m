classdef CoSimSignalCompensationAdvancedDialog<handle
    properties
        backgroundColor=[255,255,223];
        rowItemDlgSource=[]
config
    end


    methods(Access=public)
        function this=CoSimSignalCompensationAdvancedDialog(rowItemDlgSource)
            this.rowItemDlgSource=rowItemDlgSource;
            this.config=rowItemDlgSource.inputConfig;
        end

        function dlgstruct=getDialogSchema(this)
            extrapMethodPopup.Name=DAStudio.message('CoSimService:PortConfig:ExtrapolationMethod');
            extrapMethodPopup.Type='combobox';
            extrapMethodPopup.Tag='extrapolation_method_popup';
            extrapMethodPopup.ToolTip=DAStudio.message('CoSimService:PortConfig:ExtrapolationMethod_ToolTip');
            extrapMethodPopup.Entries={...

            DAStudio.message('CoSimService:PortConfig:Linear'),...
            DAStudio.message('CoSimService:PortConfig:Quadratic'),...
            DAStudio.message('CoSimService:PortConfig:Cubic')};
            extrapMethodPopup.Values=[1,2,3];
            switch this.config.ExtrapolationMethod
            case 'ZeroOrderHold'
                extrapMethodPopup.Value=DAStudio.message('CoSimService:PortConfig:ZOH');
            case 'LinearExtrapolation'
                extrapMethodPopup.Value=DAStudio.message('CoSimService:PortConfig:Linear');
            case 'QuadraticExtrapolation'
                extrapMethodPopup.Value=DAStudio.message('CoSimService:PortConfig:Quadratic');
            case 'CubicExtrapolation'
                extrapMethodPopup.Value=DAStudio.message('CoSimService:PortConfig:Cubic');
            end
            extrapMethodPopup.ColSpan=[1,2];
            extrapMethodPopup.RowSpan=[1,1];

            attenuationFactorEdit.Name=DAStudio.message('CoSimService:PortConfig:ExtrapolationCoefficient');
            attenuationFactorEdit.Type='edit';
            attenuationFactorEdit.Tag='attenuation_factor_edit';
            attenuationFactorEdit.Value=this.config.ExtrapolationCoefficient;
            attenuationFactorEdit.Visible=false;
            attenuationFactorEdit.ColSpan=[1,2];
            attenuationFactorEdit.RowSpan=[2,2];

            compensateFactorEdit.Name=DAStudio.message('CoSimService:PortConfig:SignalCorrectionCoefficient');
            compensateFactorEdit.Type='edit';
            compensateFactorEdit.Tag='compensate_factor_edit';
            compensateFactorEdit.ToolTip=DAStudio.message('CoSimService:PortConfig:SignalCorrectionCoefficient_ToolTip');
            compensateFactorEdit.Value=this.config.CompensationCoefficient;
            compensateFactorEdit.ColSpan=[1,2];
            compensateFactorEdit.RowSpan=[2,2];
















            enableInterpolationCheckBox.Name=DAStudio.message('CoSimService:PortConfig:EnableInterpolation');
            enableInterpolationCheckBox.Type='checkbox';
            enableInterpolationCheckBox.Tag='enable_interpolation_checkbox';
            if slfeature('EnableCoSimSignalInterpolation')
                enableInterpolationCheckBox.Visible=true;
            else
                enableInterpolationCheckBox.Visible=false;
            end
            switch this.config.EnableInterpolation
            case 'true'
                enableInterpolationCheckBox.Value=1;
            case 'false'
                enableInterpolationCheckBox.Value=0;
            end
            enableInterpolationCheckBox.ColSpan=[1,2];
            enableInterpolationCheckBox.RowSpan=[3,3];

            items={extrapMethodPopup,attenuationFactorEdit,...
            compensateFactorEdit,...
            enableInterpolationCheckBox};

            dlgstruct.DialogTitle=[DAStudio.message('CoSimService:PortConfig:CoSimDialogAdvancedTitle')];
            dlgstruct.DialogTag='CoSimSignalCompensationConfigurationAdvanced';

            dlgstruct.LayoutGrid=[3,2];
            dlgstruct.Transient=false;
            dlgstruct.DialogStyle='Normal';
            dlgstruct.ExplicitShow=true;
            dlgstruct.Sticky=true;
            dlgstruct.Items=items;

            dlgstruct.PreApplyMethod='coSimAdvancedPreApplyCallback';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};

            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'ShowCouplingElementParameterDialog'};
        end

        function[status,errmsg]=coSimAdvancedPreApplyCallback(this,dlg)
            cfg=[];

            try
                switch dlg.getWidgetValue('extrapolation_method_popup')
                case 0
                    cfg.ExtrapolationMethod='ZeroOrderHold';
                case 1
                    cfg.ExtrapolationMethod='LinearExtrapolation';
                case 2
                    cfg.ExtrapolationMethod='QuadraticExtrapolation';
                case 3
                    cfg.ExtrapolationMethod='CubicExtrapolation';
                end

                cfg.ExtrapolationCoefficient=dlg.getWidgetValue('attenuation_factor_edit');

                cfg.CompensationMethod='BuiltIn';
                cfg.CompensationCoefficient=dlg.getWidgetValue('compensate_factor_edit');

                cfg.DetectSignalJumpAndReset='false';







                switch dlg.getWidgetValue('enable_interpolation_checkbox')
                case 0
                    cfg.EnableInterpolation='false';
                case 1
                    cfg.EnableInterpolation='true';
                end

                if~isempty(cfg)
                    for i=fieldnames(cfg)'
                        this.config.(i{1})=cfg.(i{1});
                    end
                end
                this.rowItemDlgSource.inputConfig=this.config;
            catch E


                throwAsCaller(E);
            end

            status=true;
            errmsg='';
        end

        function show(this,dlg)
            parentPos=this.rowItemDlgSource.dlgSource.dialog.position;
            dlg.position(1:2)=floor(parentPos(1:2)+0.5*parentPos(3:4)-0.5*dlg.position(3:4));

            dlg.show();
        end
    end

    methods(Static)
        function create()


        end

        function opendlg(src)
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
        end
    end
end
