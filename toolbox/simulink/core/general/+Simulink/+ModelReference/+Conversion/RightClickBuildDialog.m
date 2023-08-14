




classdef RightClickBuildDialog<Simulink.ModelReference.Conversion.ConversionDialog
    methods(Static,Access=public)
        function dlg=show(subsys)
            this=Simulink.ModelReference.Conversion.RightClickBuildDialog(subsys);
            dlg=DAStudio.Dialog(this);
            dlg.show;
        end
    end

    methods(Access=protected)
        function this=RightClickBuildDialog(subsys)
            subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
            this@Simulink.ModelReference.Conversion.ConversionDialog(subsys);
            this.ShowBuildTargetOption=false;
            this.RightClickBuild=true;
            this.AutoFix=true;
            this.BuildTarget=DAStudio.message('Simulink:modelReferenceAdvisor:StandaloneRTWTarget');
            this.ExpandVirtualBusPorts=true;
        end

        function results=getDialogTitle(this)
            results=DAStudio.message('Simulink:modelReferenceAdvisor:RightClickBuildDialogTitle',this.SubsystemName);
        end
    end
end
