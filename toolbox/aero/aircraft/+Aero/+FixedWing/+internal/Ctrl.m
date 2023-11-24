classdef(Abstract)Ctrl<Aero.Aircraft.internal.Common

    properties
        MaximumValue{mustBeNumeric,mustBeReal,mustBeNonNan}=inf;
        MinimumValue{mustBeNumeric,mustBeReal,mustBeNonNan}=-inf;
        Controllable(1,1)matlab.lang.OnOffSwitchState='on';
        Symmetry(1,1)Aero.Aircraft.internal.datatype.Symmetry="Symmetric"
    end

    properties(Dependent,SetAccess=private)
ControlVariables
    end


    methods
        function ctrlVars=get.ControlVariables(obj)
            if obj.Controllable
                switch obj.Symmetry
                case "Symmetric"
                    ctrlVars=obj.Properties.Name;
                case "Asymmetric"
                    ctrlVars=obj.Properties.Name+["_1","_2"];
                end
            else
                ctrlVars=string([]);
            end
        end
    end

    methods
        function value=get.Symmetry(obj)
            value=string(obj.Symmetry);
        end
    end
end
