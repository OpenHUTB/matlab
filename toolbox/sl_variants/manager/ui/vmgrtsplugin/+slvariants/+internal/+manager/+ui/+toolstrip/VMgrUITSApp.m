classdef(Hidden,Sealed)VMgrUITSApp<handle










    properties(Hidden)
        ModelHandle(1,1)double=-1;

        ReductionOptions slvariants.internal.manager.ui.toolstrip.VMgrUITSReductionOpts;

        ConfigAnalysisMode(1,:)char='';

        ConfigAnalysisObj Simulink.VariantConfigurationAnalysis;

        NavigationInfo(1,:)char='Simulink:VariantManagerUI:NavigateActiveEntry';

        ConstraintViewType(1,:)char='Simulink:VariantManagerUI:ConstraintSplitViewText';

        BlocksViewInfo(1,:)char='Simulink:VariantManagerUI:BVAllVariantMode'

        AutoGenConfigToolStripBroker(1,1)slvariants.internal.manager.ui.toolstrip.VMgrAutoGenConfigToolStripBroker;

        IsVMOpen(1,1)logical=false;
    end

    methods(Hidden)

        function obj=VMgrUITSApp(modelH)
            if nargin==0
                return;
            end
            obj.ModelHandle=modelH;


            obj.ReductionOptions=slvariants.internal.manager.ui.toolstrip.VMgrUITSReductionOpts;
            obj.ReductionOptions=obj.ReductionOptions.setOutputFolder(modelH);

            obj.AutoGenConfigToolStripBroker=slvariants.internal.manager.ui.toolstrip.VMgrAutoGenConfigToolStripBroker;
        end

        function delete(obj)
            obj.ReductionOptions.delete();
            obj.ConfigAnalysisObj.delete();
            obj.AutoGenConfigToolStripBroker.delete();
        end
    end

end


