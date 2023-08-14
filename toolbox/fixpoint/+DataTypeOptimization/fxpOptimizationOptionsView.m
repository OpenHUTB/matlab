classdef fxpOptimizationOptionsView<internal.matlab.inspector.InspectorProxyMixin
















    properties(SetAccess=private)

AdvancedOptions
AllowableWordLengths
MaxIterations
MaxTime
Patience
ObjectiveFunction
UseParallel
Verbosity
    end

    properties(Constant,Hidden)
        OptimizationParametersID="SimulinkFixedPoint:dataTypeOptimization:optimizationParametersViewOnly";
        StoppingCriteriaID="SimulinkFixedPoint:dataTypeOptimization:stoppingCriteriaViewOnly";
        AdvancedOptionsID="SimulinkFixedPoint:dataTypeOptimization:advancedOptionsViewOnly";
    end

    methods
        function this=fxpOptimizationOptionsView(options)

            this@internal.matlab.inspector.InspectorProxyMixin(options);


            this.AdvancedOptions=options.AdvancedOptions;
            this.AllowableWordLengths=options.AllowableWordLengths;
            this.MaxIterations=options.MaxIterations;
            this.MaxTime=options.MaxTime;
            this.Patience=options.Patience;
            this.ObjectiveFunction=options.ObjectiveFunction;
            this.UseParallel=options.UseParallel;
            this.Verbosity=options.Verbosity;


            g1=this.createGroup(message(this.OptimizationParametersID).getString,...
            '','');
            g1.addProperties('AllowableWordLengths','ObjectiveFunction','UseParallel','Verbosity');
            g1.Expanded=true;


            g2=this.createGroup(message(this.StoppingCriteriaID).getString,...
            '','');
            g2.addProperties('MaxIterations','MaxTime','Patience');
            g2.Expanded=true;


            g3=this.createGroup(message(this.AdvancedOptionsID).getString,'','');
            g3.addProperties('AdvancedOptions');
            g3.Expanded=false;
        end
    end
end

