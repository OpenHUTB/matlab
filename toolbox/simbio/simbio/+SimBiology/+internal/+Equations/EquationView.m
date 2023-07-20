classdef EquationView









    properties(Access=public)

RawReactionCode
ReactionNames
HasRateDoseX
RateDoseNameX
        RateRules=SimBiology.internal.Equations.Equation.empty;
        SpeciesRateRules=SimBiology.internal.Equations.Equation.empty;
        AlgebraicRules=SimBiology.internal.Equations.Equation.empty;
        RepeatedAssignments=SimBiology.internal.Equations.Equation.empty;
        RepeatedAssignmentRuleUUIDs={}
SpeciesInConcentrationInVaryingCompartments
ActiveDoses
ActiveEvents
        ODE=SimBiology.internal.Equations.Equation.empty;
        InitialConditions=SimBiology.internal.Equations.Equation.empty;
        ParameterValues=SimBiology.internal.Equations.Equation.empty;
        Fluxes=SimBiology.internal.Equations.Equation.empty;
        Observables=SimBiology.internal.Equations.Equation.empty;
        ObservableEvaluationOrder=[];
    end

    properties(Constant)
        ODEHeading='ODEs:';
        FluxesHeading='Fluxes:';
        AlgebraicConstraintsHeading='Algebraic Constraints:';
        RepeatedAssignmentHeading='Repeated Assignments:';
        ObservablesHeading='Observables:';
        ParameterValuesHeading='Parameter Values:';
        InitialConditionsHeading='Initial Conditions:';
    end


    methods
        function out=toString(h)
            out=[...
            printEquations(h.ODEHeading,h.ODE)...
            ,printEquations(h.FluxesHeading,h.Fluxes)...
            ,printEquations(h.AlgebraicConstraintsHeading,h.AlgebraicRules)...
            ,printEquations(h.RepeatedAssignmentHeading,h.RepeatedAssignments)...
            ,printEquations(h.ParameterValuesHeading,h.ParameterValues)...
            ,printEquations(h.InitialConditionsHeading,h.InitialConditions)...
            ,printEquations(h.ObservablesHeading,h.Observables)...
            ];
        end
    end
end
function out=printEquations(heading,equations)
    out=cell(numel(equations)+2,1);
    if~isempty(equations)
        out{1}=sprintf('%s\n',heading);
        for i=1:numel(equations)
            out{1+i}=sprintf('%s\n',equations(i).toString);
        end
        out{end}=newline;
    end
    out=[out{:}];
end