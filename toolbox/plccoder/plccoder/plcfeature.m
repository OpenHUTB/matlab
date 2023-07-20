function retVal=plcfeature(varargin)








    narginchk(1,2);

    persistent featureMap;

    retVal=[];

    if isempty(featureMap)
        featureMap=containers.Map('KeyType','char','ValueType','double');
        featureMap('UseCGConfig')=1;
        featureMap('TestCGConfig')=0;
        featureMap('PLCInOutVar')=1;
        featureMap('PLCMultiTB')=1;
        featureMap('PLCInstrument')=0;
        featureMap('PLCGlobalVarToInOutVar')=0;
        featureMap('PLCMdlref')=0;
        featureMap('PLCParam')=0;
        featureMap('PLCSimOnServer')=0;
        featureMap('PLCUseInstanceName')=1;
        featureMap('PLCLadderImportStateflow')=0;
        featureMap('PLCLadderImportDisableConformanceCheck')=0;
        featureMap('PLCLadderImportEnableLadder2ladder')=0;
        featureMap('PLCLadderImportAnimation')=1;
        featureMap('PLCPPLevel')=0;
        featureMap('PLCLogging')=1;
        featureMap('PLCLoggingDriverProg')=0;
        featureMap('PLCSFAnimation')=0;
        featureMap('PLCLadderCG')=0;
        featureMap('PLCLadderDebug')=0;
        featureMap('PLCUseLinkedLDLib')=0;
        featureMap('PLCLadderDataInference')=1;
        featureMap('PLCLadderBlockHierarchyCheck')=1;
        featureMap('PLCInvalidSolverMultirate')=1;
        featureMap('PLCInvalidSolverTB')=1;
        featureMap('UnsupportedTypesReporting')=1;
        featureMap('UserDefinedInstructions')=1;
        featureMap('PLCUnsupportedFixpointMultiwordError')=1;
        featureMap('RunPointerElimination')=0;
        featureMap('CheckLibraryBlocks')=1;
        featureMap('DisableBlockReplacement')=0;
        featureMap('AggressiveFunctionGeneration')=1;
        featureMap('PLCForEachBlockCG')=0;
        featureMap('CheckLibraryMATLABFunction')=1;
        featureMap('EmitPLCOpenXSDSchema')=1;
    end


    SLF_List={...
    'PLCVarDims',...
    'PLCExternallyDefinedBlocks',...
    'PLCExternallyDefinedBlocks2',...
    'DisablePLCInlining',...
    };

    for i=1:numel(SLF_List)
        featureMap(SLF_List{i})=slfeature(SLF_List{i});
    end


    if nargin==1&&ischar(varargin{1})&&strcmp(varargin{1},'drevil')
        dumpFeature(featureMap,SLF_List);
        return;
    end


    if nargin==2
        if strcmp(varargin{1},'PLCExternallyDefinedBlocks')
            slfeature('PLCExternallyDefinedBlocks',varargin{2});
            slfeature('PLCExternallyDefinedBlocks2',double(~varargin{2}));
        elseif strcmp(varargin{1},'PLCExternallyDefinedBlocks2')
            slfeature('PLCExternallyDefinedBlocks2',varargin{2});
            slfeature('PLCExternallyDefinedBlocks',double(~varargin{2}));
        else
            if any(strcmp(SLF_List,varargin{1}))
                slfeature(varargin{1},varargin{2});
                featureMap(varargin{1})=slfeature(varargin{1});
            else
                featureMap(varargin{1})=varargin{2};
            end
        end
    end


    if featureMap.isKey(varargin{1})
        retVal=featureMap(varargin{1});
    end
end

function dumpFeature(featureMap,SLF_List)
    key_list=keys(featureMap);
    fprintf(1,'PLC Features:\n');
    fprintf(1,'-----------------------------------------------------\n');
    for i=1:length(key_list)
        fprintf(1,'%-36s: %d\n',key_list{i},featureMap(key_list{i}));
    end
    for i=1:length(SLF_List)
        fprintf(1,'%-36s: %d\n',SLF_List{i},plcfeature(SLF_List{i}));
    end
    fprintf(1,'-----------------------------------------------------\n');
end


