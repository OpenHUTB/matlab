function[result,status]=createTestForSubsystemAPIHelper(obj,varargin)




    shouldThrow=true;

    if isa(obj,'sltest.testmanager.TestSuite')
        filePath=obj.TestFile.FilePath;
    else
        filePath=obj.FilePath;
    end

    [~,~,fileExt]=fileparts(filePath);
    if strcmpi(fileExt,'.m')
        error(message('stm:general:InvalidMATLABCreateTest'));
    end


    if(nargin>1)
        if contains(varargin{1},'/')
            topModel=extractBefore(varargin{1},'/');
            loc1='';
            loc2='';
            testType=sltest.testmanager.TestCaseTypes.Baseline;
            if nargin>2
                testType=parseTestCaseType(varargin{2});
            end
            if nargin>3
                loc1=varargin{3};
            end
            if nargin>4
                loc2=varargin{4};
            end
            if nargin>5
                isExcel=varargin{5};
            else
                isExcel=false;
            end
            [result,status]=stm.internal.util.createTestForSubSystem(varargin{1},...
            topModel,filePath,obj.getID(),shouldThrow,testType,...
            loc1,loc2,'',isExcel,getTFSOptions());
            return;
        end
    end

    validHarnessSources=string({...
    Simulink.harness.internal.TestHarnessSourceTypes.INPORT.name,...
    Simulink.harness.internal.TestHarnessSourceTypes.SIGNAL_EDITOR.name});
    validTestTypes=["baseline","equivalence","simulation"];

    p=inputParser;
    p.KeepUnmatched=true;
    p.PartialMatching=true;
    p.FunctionName='sltest.testmanager.createTestForComponent';

    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestFile','sltest.testmanager.TestSuite'},{'scalar','nonempty'}));
    addParameter(p,'Subsystem','',@(x)validateattributes(x,{'cell','char','string','Simulink.BlockPath'},{'nonempty'}));
    addParameter(p,'TopModel',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'TestType',validTestTypes(1),@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'InputsLocation',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'BaselineLocation',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'CreateExcelFile',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    addParameter(p,'ExcelFileLocation',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'Sheet',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'SLDVTestGeneration',"off",@(x)validateSLDVSetting(x));
    addParameter(p,'HarnessSource',"",@(x)any(validatestring(x,{...
    Simulink.harness.internal.TestHarnessSourceTypes.INPORT.name,...
    Simulink.harness.internal.TestHarnessSourceTypes.SIGNAL_EDITOR.name})));
    addParameter(p,'Simulation1Mode',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'Simulation2Mode',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'UseSubsystemInputs',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    addParameter(p,'FunctionInterface','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'CreateHarness',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    addParameter(p,'HarnessOptions',{},@(x)iscell(x));
    addParameter(p,'SimulateModelForSLDVTestGeneration',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

    p.parse(obj,varargin{:});


    import stm.internal.TestForSubsystem.*;
    [subsys,isInBatchMode]=validateAndConvertSubsystemInputToStrings(p.Results.Subsystem);
    [topModel,createForTopModel]=validateTopModelInput(p.Results.TopModel,p.Results.Subsystem,isInBatchMode,subsys);
    if~isInBatchMode
        subsys=constructFullSSPath(subsys,topModel);
    end
    validateSimulinkObjsAndMRHierarchy(topModel,subsys);


    testTypeEnum=validateTestTypeAndConvertToEnum(p.Results.TestType);


    [sim1Mode,sim2Mode]=validateSimulationModes(p,testTypeEnum);


    [isExcel,loc1,loc2]=validateAndProcessArtifactsSaveLocation(p,isInBatchMode);




    hrnsSrc=p.Results.HarnessSource;
    if~ismember(p.UsingDefaults,'HarnessSource')
        hrnsSrc=validatestring(hrnsSrc,{Simulink.harness.internal.TestHarnessSourceTypes.INPORT.name,Simulink.harness.internal.TestHarnessSourceTypes.SIGNAL_EDITOR.name});
    end
    hrnsSrc=string(hrnsSrc);


    sldvSetting=validateAndDetermineSLDVSetting(p);


    if hrnsSrc~=""&&hrnsSrc==validHarnessSources(2)&&isExcel
        error(message('stm:TestForSubsystem:ExcelPathSpecifiedWithSignalEditorAsSource'));
    end

    if sldvSetting~="off"






        if p.Results.BaselineLocation~=""||p.Results.InputsLocation~=""
            error(message('stm:TestForSubsystem:BaselineOptionsNotValidForSLDVTestGeneration'));
        end
    else




        if hrnsSrc~=""&&~p.Results.UseSubsystemInputs
            error(message('stm:TestForSubsystem:InvalidHarnessSourceSpecification'));
        end
        if~isempty(p.Results.HarnessOptions)&&p.Results.UseSubsystemInputs
            error(message('stm:TestForSubsystem:HarnessOptionsNotValidForSimStrategies'));
        end
        if p.Results.SimulateModelForSLDVTestGeneration
            error(message('stm:TestForSubsystem:SLDVArgumentSpecifiedInNonSLDVMode'));
        end
    end


    options=createTestForSubsystemOptionsStruct(p,hrnsSrc,sim1Mode,sim2Mode,sldvSetting,createForTopModel);
    validateHarnessOptions(options.harnessOptions);
    if isInBatchMode

        if options.fcnInterface~=""
            error(message('stm:TestForSubsystem:FunctionInterfaceBatchModeLimitation'));
        end

        warnIfHarnessGenNotOn(p);
    else
        if createForTopModel

            options.createHarness=p.Results.CreateHarness;
        else

            warnIfHarnessGenNotOn(p);
        end
    end

    [result,status]=stm.internal.util.createTestForSubSystem(...
    subsys,topModel,filePath,obj.getID(),shouldThrow,...
    testTypeEnum,loc1,loc2,'',isExcel,options);

end

function testType=parseTestCaseType(tempType)
    testType=sltest.testmanager.TestCaseTypes.Baseline;
    tempType=convertStringsToChars(tempType);
    if ischar(tempType)
        testType=validateTestTypeAndConvertToEnum(tempType);
    else
        testType=tempType;
    end
end

function options=getTFSOptions()
    options=struct('recordCurrentState',true,...
    'harnessSrcType','',...
    'recordOutputs','',...
    'sim1Mode','',...
    'sim2Mode','',...
    'fcnInterface','',...
    'createHarness',true,...
    'createForTopModel',false,...
    'harnessOptions',[],...
    'useSldv',false,...
    'sldvWithSimulation',false...
    );
end

function validateSLDVSetting(in)
    if islogical(in)
        validateattributes(in,{'logical'},{'scalar'});
    else
        validateattributes(in,{'char','string'},{'scalartext'});
    end
end

function testTypeEnum=validateTestTypeAndConvertToEnum(testType)
    validEnumsSet=[sltest.testmanager.TestCaseTypes.Baseline,...
    sltest.testmanager.TestCaseTypes.Equivalence,...
    sltest.testmanager.TestCaseTypes.Simulation];
    validTestTypes=["baseline","equivalence","simulation"];
    testType=validatestring(testType,validTestTypes);
    testTypeEnum=validEnumsSet(testType==validTestTypes);
end

function[sim1Mode,sim2Mode]=validateSimulationModes(p,testTypeEnum)
    modes=["","Normal","Accelerator","Rapid Accelerator",...
    "Software-in-the-Loop (SIL)","Processor-in-the-Loop (PIL)"];
    sim1Mode=validatestring(p.Results.Simulation1Mode,modes(1:3));
    sim2Mode=validatestring(p.Results.Simulation2Mode,modes);
    if testTypeEnum~=sltest.testmanager.TestCaseTypes.Equivalence&&(sim1Mode~=""||sim2Mode~="")
        error(message('stm:TestForSubsystem:SimModesForNonEquivalenceTest'));
    end
end

function[isExcel,loc1,loc2]=validateAndProcessArtifactsSaveLocation(p,isInBatchMode)
    isExcel=false;
    if(p.Results.CreateExcelFile||p.Results.ExcelFileLocation~=""||p.Results.Sheet~="")
        if isInBatchMode&&p.Results.ExcelFileLocation~=""&&~isfolder(p.Results.ExcelFileLocation)
            error(message("stm:TestForSubsystem:SaveLocMustBeDirInBatchMode","ExcelFileLocation"));
        end
        [~,~,ext]=fileparts(p.Results.ExcelFileLocation);
        if ext~=""&&~any(strcmpi(ext,xls.internal.WriteTable.SpreadsheetExts))
            error(message('stm:TestForSubsystem:IncorrectExcelFileSpecification'));
        end

        if p.Results.BaselineLocation~=""||p.Results.InputsLocation~=""


            error(message('stm:TestForSubsystem:IncorrectFunctionUsage'));
        end

        isExcel=true;
        loc1=string(p.Results.ExcelFileLocation);
        loc2=string(p.Results.Sheet);
    else
        if isInBatchMode&&p.Results.InputsLocation~=""&&~isfolder(p.Results.InputsLocation)
            error(message("stm:TestForSubsystem:SaveLocMustBeDirInBatchMode","InputsLocation"));
        end
        [~,~,ext]=fileparts(p.Results.InputsLocation);
        if ext~=""&&~(strcmpi(ext,".mat"))
            error(message('stm:TestForSubsystem:IncorrectFunctionUsage'));
        end
        if isInBatchMode&&p.Results.BaselineLocation~=""&&~isfolder(p.Results.BaselineLocation)
            error(message("stm:TestForSubsystem:SaveLocMustBeDirInBatchMode","BaselineLocation"));
        end
        [~,~,ext]=fileparts(p.Results.BaselineLocation);
        if ext~=""&&~(strcmpi(ext,".mat"))
            error(message('stm:TestForSubsystem:IncorrectFunctionUsage'));
        end

        loc1=string(p.Results.InputsLocation);
        loc2=string(p.Results.BaselineLocation);
    end
end

function sldvSetting=validateAndDetermineSLDVSetting(p)
    if islogical(p.Results.SLDVTestGeneration)
        if p.Results.SLDVTestGeneration
            sldvSetting="on";
        else
            sldvSetting="off";
        end
    else
        sldvSetting=validatestring(p.Results.SLDVTestGeneration,["off","on","EnhancedMCDC"]);
    end
end

function validateHarnessOptions(hrnssOpts)
    p=inputParser;
    p.KeepUnmatched=1;
    p.addParameter("FunctionInterfaceName","");
    p.parse(hrnssOpts{:});
    if~ismember(p.UsingDefaults,"FunctionInterfaceName")
        error(message("stm:TestForSubsystem:CannotSpecifyFunctionInterfaceInHarnessOptions"));
    end
end

function options=createTestForSubsystemOptionsStruct(p,hrnsSrc,sim1Mode,sim2Mode,sldvSetting,createForTopModel)
    options=getTFSOptions();
    options.recordCurrentState=p.Results.UseSubsystemInputs;
    options.harnessSrcType=hrnsSrc;
    options.recordOutputs='';
    options.sim1Mode=sim1Mode;
    options.sim2Mode=sim2Mode;
    options.fcnInterface=char(p.Results.FunctionInterface);
    options.createHarness=true;
    options.createForTopModel=createForTopModel;
    options.harnessOptions=p.Results.HarnessOptions;
    options.useSldv=sldvSetting~="off";
    options.sldvWithSimulation=p.Results.SimulateModelForSLDVTestGeneration;
    options.sldvBackToBackMode=slfeature('STMSldvBackToBackMode')==1&&sldvSetting=="EnhancedMCDC";
end

function warnIfHarnessGenNotOn(p)
    if~p.Results.CreateHarness
        warning(message('stm:TestForSubsystem:HarnessGenerationForcedOn'));
    end
end
