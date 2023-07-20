classdef AutoscalerProposalSettings<handle

















    properties(AbortSet,SetObservable,GetObservable)

        SafetyMarginForSimMinMax double=2;


        isUsingSimMinMax logical=true;


        isUsingDerivedMinMax logical=true;


        isWLSelectionPolicy logical=false;


        isAutoSignedness logical=true;


        ProposeForInherited logical=true;


        ProposeForFloatingPoint logical=true;


        DefaultWordLength int32=int32(16);


        DefaultFractionLength int32=int32(4);

    end
    properties
        scaleUsingRunName char='';
    end

    properties(SetAccess=private,Hidden)
        SimType=Simulink.CMI.CompiledSimType.ModelApi;
        LicenseType=Simulink.EngineInterfaceVal.fixedPoint;
        HandleCompile=true;
    end

    methods
        function set.SafetyMarginForSimMinMax(obj,value)

            if~(isnumeric(value)&&isreal(value)&&isfinite(value)&&value>-100)
                DAStudio.error('SimulinkFixedPoint:autoscalerProposalSettings:invalidSafetyMargin');
            end
            validateattributes(value,{'double'},{'scalar'},'','SafetyMarginForSimMinMax')
            obj.SafetyMarginForSimMinMax=value;
        end

        function set.isUsingSimMinMax(obj,value)

            value=boolean(value);
            validateattributes(value,{'logical'},{'scalar'},'','isUsingSimMinMax')
            obj.isUsingSimMinMax=value;
        end

        function set.isUsingDerivedMinMax(obj,value)

            value=boolean(value);
            validateattributes(value,{'logical'},{'scalar'},'','isUsingDerivedMinMax')
            obj.isUsingDerivedMinMax=value;
        end

        function set.isWLSelectionPolicy(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','isWLSelectionPolicy')
            obj.isWLSelectionPolicy=value;
        end

        function set.isAutoSignedness(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','isAutoSignedness')
            obj.isAutoSignedness=value;
        end

        function set.ProposeForInherited(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','proposeForInherited')
            obj.ProposeForInherited=value;
        end

        function set.ProposeForFloatingPoint(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','proposeForInherited')
            obj.ProposeForFloatingPoint=value;
        end

        function set.DefaultWordLength(obj,value)

            if~(isnumeric(value)&&isreal(value)&&isfinite(value)&&value>1&&value<=128)
                DAStudio.error('SimulinkFixedPoint:autoscalerProposalSettings:invalidDefaultWordLength');
            end
            value=int32(value);
            validateattributes(value,{'int32'},{'scalar'},'','defaultWordLength')
            obj.DefaultWordLength=value;
        end

        function set.DefaultFractionLength(obj,value)

            if~(isnumeric(value)&&isreal(value)&&isfinite(value)&&value>=-65536&&value<=65536)
                DAStudio.error('SimulinkFixedPoint:autoscalerProposalSettings:invalidDefaultFractionLength');
            end
            value=int32(value);
            validateattributes(value,{'int32'},{'scalar'},'','defaultFractionLength')
            obj.DefaultFractionLength=value;
        end
        function set.scaleUsingRunName(obj,value)
            validateattributes(value,{'char'},{'nonempty'});
            obj.scaleUsingRunName=value;
        end

    end

    methods
        function setLicenseType(this,licenseType)
            this.LicenseType=licenseType;
        end

        function setSimType(this,simType)
            this.SimType=simType;
        end

        function setHandleCompile(this,handleCompile)
            this.HandleCompile=handleCompile;
        end
    end
end





