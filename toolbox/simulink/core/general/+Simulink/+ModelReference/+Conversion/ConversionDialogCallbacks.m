




classdef ConversionDialogCallbacks<handle
    methods(Static,Access=public)
        function[status,message]=dlgPostApplyCallback(this,dlg)%#ok
            status=true;
            message=[];
        end


        function dlgCloseCallback(dlg,action)
            this=dlg.getSource;
            switch(action)
            case 'ok'
                inputArguments=horzcat(this.generateInputArguments,{'UseConversionDialog',true});
                try
                    if this.RightClickBuild
                        inputArguments=[inputArguments(:)',{'ExportedFunctionSubsystem'},{true}];
                        this.SubsystemConversion=Simulink.ModelReference.Conversion.RightClickBuildExportFunction.exec(inputArguments{:});
                        slbuild(this.ReferencedModelName,'StandaloneCoderTarget','ForceTopModelBuild',true,'OkayToPushNags',true);
                    else
                        this.SubsystemConversion=Simulink.ModelReference.Conversion.SubsystemConversion.exec(inputArguments{:});
                    end
                catch me
                    sldiagviewer.reportError(me,'Category',DAStudio.message('Simulink:modelReferenceAdvisor:Category'));
                end
            end
        end
    end
end
