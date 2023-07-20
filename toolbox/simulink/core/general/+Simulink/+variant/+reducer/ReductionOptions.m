classdef(Sealed,Hidden)ReductionOptions<handle





    properties(Transient,SetAccess=private)


        TopModelOrigName(1,:)char='';


        ConfigInfos={};


        OutputFolder(1,:)char='';



        ValidateSignals(1,1)logical=true;


        Suffix(1,:)char='';


        VerboseInfoObj(1,1)Simulink.variant.utils.VerboseInfoHandler;


        IsConfigVarSpec(1,1)logical;


        GenerateReport(1,1)logical=false;


        FullRangeVariables(1,:)cell={};


        CompileMode(1,:)char='';

    end

    properties(Transient)


        TopModelFullName='';


        Command(1,:)char='';


        TopModelName(1,:)char='';


        RedModelFullName(1,:)char='';


        OrigModelDirPath(1,:)char='';


        AbsOutDirPath(1,:)char='';



        NewDirCreatedNoLog(1,1)logical=false;
        DirAddedToPath(1,1)logical=false;


        GenerateLog(1,1)logical=false;


        IsConfigSpecifiedAsVariables(1,1)logical=false;

    end

    methods

        function rOptsObj=ReductionOptions(rOptsStruct)


            if nargin==0
                return;
            end

            narginchk(1,1);


            fields=fieldnames(rOptsStruct);



            fields=setdiff(fields,{'Verbose';'UIFrameHandle';'CalledFromUI'});

            if~Simulink.variant.reducer.utils.isExcludeFilesOptionValid()
                fields=setdiff(fields,'ExcludeFiles');
            end

            for fIdx=1:numel(fields)
                rOptsObj.(fields{fIdx})=rOptsStruct.(fields{fIdx});
            end


            rOptsObj.VerboseInfoObj=Simulink.variant.utils.VerboseInfoHandler(rOptsStruct);
        end



        function setOutputFolder(rOptsObj,folder)
            rOptsObj.OutputFolder=folder;
        end



        function setConfigInfos(rOptsObj,configInfos)
            rOptsObj.ConfigInfos=configInfos;
        end

        function set.CompileMode(rOptsObj,val)
            val2=lower(val);
            if~any(strcmp(val2,{'sim','codegen'}))


                merr=MException(message('Simulink:VariantReducer:InvalidCompileMode'));
                throwAsCaller(merr);
            end
            rOptsObj.CompileMode=val2;
        end

        function val=isCodegenCompileMode(rOptsObj)
            val=strcmp(rOptsObj.CompileMode,'codegen');
        end

    end

    methods(Static)
        function rOptsStruct=getDefaultInputStruct(modelName)
            rOptsStruct=struct(...
            'TopModelOrigName',modelName,...
            'ConfigInfos',[],...
            'IsConfigVarSpec',false,...
            'OutputFolder','',...
            'ValidateSignals',true,...
            'Suffix','_r',...
            'Verbose',false,...
            'UIFrameHandle',[],...
            'CalledFromUI',false,...
            'GenerateReport',false,...
            'FullRangeVariables',[],...
            'CompileMode','sim');
        end
    end

end


