classdef(Sealed=true,Hidden=true)SwitchedLinearWorkflow<handle



    properties(GetAccess=public,SetAccess=private,Hidden=true)

        DiscreteVariableData={};

        StateSpaceParametersDeamon=struct;


        SimscapeModel='';


        SolverConfiguration={};


        DynamicSystemObj={};



        NonlinearBlocks={};



        MulitBodyBlocks={};
        EventBlocks={};
        SourceBlocks={};
        SinkBlocks={};
        ForEachBlocks={};

        InvalidSPSBlocks={};


        StateSpaceParameters=struct;


        HDLModel='';

        HDLModelSettingsFile='';

        HDLVnlModel='';

        linearModel='';
        linearModelVldn='';

        HDLSubsystems=[];



        SimscapeSubsystem=[];

        spsBlks={};


        SpsPssConverterBlks={};

        linearizationInfo=struct;


        SwitchesToLinearize={};
        DiodesToLinearize={};
        IGBTsTOLinearize={};
        nlInductorsToLinearize={};



        PartSolvers=struct;

        SolverTypes=[];


    end


    properties(Hidden=true)

        NumberOfSolverIterations=5;


        UseFixedCost=false;


        NumFixedCostIters=0;


        NumberOfDifferentialVariables=0;



        MaxAllowedIters=15;


    end


    properties(Hidden=true)

        HDLModelPrefix='gmStateSpaceHDL_';
        HDLVnlModelSuffix='_vnl';


        linearModelPrefix='gmLinearized_';


        HDLAlgorithmDataType='single';

        precisionVal=0;




        GenerateValidation=false;


        ValidationToleranceSingle=1e-3;
        ValidationToleranceDouble=1e-8;


        ValidationTolerance=1e-3;

        ValidationToleranceUser=[];


        SingleRateModel=true;

        linearize=false;

        listOfSwitches=[];
        modelOrderReductionValLogic=false;
        modelOrderReductionValTol=1e-3;



        GenerateAutomaticLayout=true;

        FailedReplacementID='';

        FailedReplacementMessage='';

        UseRAM='Auto';

        UseRAMThreshold=200;
    end


    properties(GetAccess=public,SetAccess=private,Hidden=true)

        ProjectDir='';
    end


    properties(Access=private)


        StateSpaceInputMap={};


        StateSpaceOutputMap={};

    end

    methods(Hidden=true)
        function obj=SwitchedLinearWorkflow(simscapeModel)

            obj.SimscapeModel=simscapeModel;
        end
    end

    methods(Access=public,Hidden=true)

        discretizeEquations(obj);


        checkSolverConfiguration(obj)

        checkSwitchedLinear(obj)

        reduceModelOrder(obj)
        numSwitches=checkNumberSwitches(obj)



        extractionEquations(obj)

        generateHDLModel(obj)

        setHDLDataType(obj,type)


        resetLinearModel(obj);
    end

    methods

        runWorkflow(obj)
    end
end


