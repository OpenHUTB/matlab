classdef SummaryData<handle








    properties(SetAccess=private)

        TopModelName(1,:)char;


        CompileMode(1,:)char;


        ExcludeFiles(1,:)cell={};


        OutputFolder(1,:)char;




        ReducerFlags struct=i_newEmptyReducerFlags();


        ModelSuffix(1,:)char;


        OrigTopModelName(1,:)char;



        VarSpecAsNaN(:,1)cell;
    end

    properties(Access={?tSummaryData})

        GenerateReport(1,1)logical=false;
    end

    properties






        Configurations struct=i_newEmptyConfigStruct();


        BlocksRemoved(:,1)struct=i_newEmptyRemovedBlocksStruct();



        BlocksModified(:,1)struct=i_newEmptyRemovedBlocksStruct();


        MaskedBlocksModified(:,1)struct=i_newEmptyMaskedBlockStruct();


        BlocksAdded(:,1)struct=i_newEmptyBlocksAddedStruct();


        VariantVariablesReduced(:,1)cell;


        VariantVariablesConverted(:,1)cell;


        FileDependencies(:,1)cell;


        Callbacks(1,1)Simulink.variant.reducer.types.VRedCallback;


        Warnings;


        SFChartContainingVariantTrans(:,1)double;
    end

    methods

        function obj=SummaryData(varargin)

            if nargin==0

                return;
            end
            redOpts=varargin{1};
            obj.TopModelName=redOpts.TopModelName;
            obj.CompileMode=redOpts.CompileMode;
            if Simulink.variant.reducer.utils.isExcludeFilesOptionValid()
                obj.ExcludeFiles=redOpts.ExcludeFiles;
            end
            obj.OutputFolder=redOpts.OutputFolder;
            obj.ReducerFlags(1).PreserveSignalAttributes=redOpts.ValidateSignals;
            obj.ReducerFlags(1).Verbose=redOpts.VerboseInfoObj.VerboseFlag;
            obj.ModelSuffix=redOpts.Suffix;
            obj.OrigTopModelName=redOpts.TopModelOrigName;
            obj.GenerateReport=redOpts.GenerateReport;
            obj.VarSpecAsNaN=redOpts.FullRangeVariables(1:2:end-1);
        end

        function addModifiedBlock(obj,block,model,isVarBlkInLib)
            if~obj.GenerateReport
                return;
            end
            modBlockStruct=struct('ModelName',model,...
            'BlockPaths',block,...
            'isLibrary',isVarBlkInLib);
            logIdx=arrayfun(@(x)strcmp(x.ModelName,model),obj.BlocksModified);
            if any(logIdx)




                obj.BlocksModified(logIdx).BlockPaths=unique(...
                [obj.BlocksModified(logIdx).BlockPaths;{block}]);
            else
                obj.BlocksModified=[obj.BlocksModified;modBlockStruct];
            end
        end

        function addModifiedMaskedBlock(obj,maskedBlock)


            if isempty(maskedBlock.DeletedParams)
                return;
            end
            obj.MaskedBlocksModified=[obj.MaskedBlocksModified;maskedBlock];
        end

        function addDependentFile(obj,dependency)

            obj.FileDependencies=unique([obj.FileDependencies;dependency]);

        end
    end
end



function configStruct=i_newEmptyConfigStruct()
    configStruct=struct('Name','',...
    'Description','',...
    'ControlVariables',[],...
    'SubModelConfigurations',[]);
    controlVars=struct('Name','','Value',[]);
    controlVars(end)=[];
    configStruct.ControlVariables=controlVars;
    subModelConfigs=struct('ModelName','','ConfigurationName','');
    subModelConfigs(end)=[];
    configStruct.SubModelConfigurations=subModelConfigs;
    configStruct(end)=[];
end

function reducerFlags=i_newEmptyReducerFlags()
    reducerFlags=struct('PreserveSignalAttributes',[],...
    'Verbose',[]);
    reducerFlags(end)=[];
end

function blksAdd=i_newEmptyBlocksAddedStruct()
    blksAdd=struct('addedSS','',...
    'addedGnds','',...
    'addedTerms','',...
    'addedConstants','');
    blksAdd(end)=[];
end

function maskBlks=i_newEmptyMaskedBlockStruct()
    maskBlks=struct('BlockPath','',...
    'DeletedParams','');
    maskBlks(end)=[];
end

function remBlockStruct=i_newEmptyRemovedBlocksStruct()
    remBlockStruct=struct('ModelName','',...
    'BlockPaths',[],...
    'isLibrary',[]);
    remBlockStruct(end)=[];
end

