classdef PeripheralCodegenHook<handle

    properties
PeripheralHeaderFile
ModelPeripheralHeaderFile
ModelPeripheralSourceFile
    end


    properties(Access=protected)
        PeriphIncludeFiles StringWriter=StringWriter.empty;
        PeriphTypedefs StringWriter=StringWriter.empty;
        PeriphDefines StringWriter=StringWriter.empty;
    end


    properties(Access=protected)
        HdrIncludeFiles StringWriter=StringWriter.empty;
        HdrDefines StringWriter=StringWriter.empty;
        HdrTypedefs StringWriter=StringWriter.empty;
        HdrVariableDeclaration StringWriter=StringWriter.empty;
        HdrPrototypes StringWriter=StringWriter.empty;
    end


    properties(Access=protected)
        SrcIncludeFiles StringWriter=StringWriter.empty;
        SrcVariableDefinitions StringWriter=StringWriter.empty;
        SrcFunctions StringWriter=StringWriter.empty;
    end


    properties
ModelObj
PeripheralType
HardwareBoard
PeripheralInfo
BuildInfo
    end


    properties(Access=protected)
Models
PeripheralStoredData
GroupPeripheralStoredData
    end


    methods
        function obj=PeripheralCodegenHook(hObj,peripheralType)
            if ischar(hObj)
                obj.ModelObj=hObj;
            elseif isa(hObj,'RTW.BuildInfo')
                obj.ModelObj=hObj.ModelName;
                obj.BuildInfo=hObj;
            else
                hCS=hObj.getConfig;
                obj.ModelObj=get_param(getModel(hCS),'Name');
            end
            obj.PeripheralType=peripheralType;
            obj.HardwareBoard=get_param(obj.ModelObj,'HardwareBoard');
            obj.PeripheralInfo=codertarget.peripherals.PeripheralInfo(codertarget.peripherals.utils.getDefFileNameForBoard(getActiveConfigSet(obj.ModelObj)));
            [obj.Models,obj.PeripheralStoredData,obj.GroupPeripheralStoredData]=codertarget.peripherals.utils.getPeripheralInfoFromRefModels(obj.ModelObj);
        end


        function PeriphHeaderFile=generatePeripheralHeaderFile(obj,headerFilePath)
            if nargin>1
                narginchk(2,2);
            else
                narginchk(1,1);
                headerFilePath='';
            end
            PeriphHeaderFile=managePeripheralHeaderFile(obj);

            fprintf('### Writing %s peripheral header file %s\n',obj.PeripheralType,PeriphHeaderFile);
            HdrContents=StringWriter;
            macro=upper(sprintf('__%s__',matlab.lang.makeValidName(PeriphHeaderFile)));
            addcr(HdrContents,sprintf('#ifndef %s',macro));
            addcr(HdrContents,sprintf('#define %s',macro));

            addcr(HdrContents,' ');
            if~isempty(obj.PeriphIncludeFiles)
                addcr(HdrContents,char(obj.PeriphIncludeFiles));
            end
            if~isempty(obj.PeriphDefines)
                addcr(HdrContents,char(obj.PeriphDefines));
            end
            if~isempty(obj.PeriphTypedefs)
                addcr(HdrContents,char(obj.PeriphTypedefs));
            end

            indentCode(HdrContents,'c');
            addcr(HdrContents,sprintf('#endif /* %s */',macro));

            if~isempty(headerFilePath)
                mainSrcDir=headerFilePath;
            else
                if~isempty(obj.BuildInfo)
                    mainSrcDir=getSourcePaths(obj.BuildInfo,1,'BuildDir');
                    mainSrcDir=mainSrcDir{1};
                else
                    mainSrcDir='.';
                end
            end
            write(HdrContents,fullfile(mainSrcDir,PeriphHeaderFile));
        end


        function generatePeripheralFiles(obj,createPeriphHeader)
            if nargin<2
                createPeriphHeader=true;
            else
                createPeriphHeader=logical(createPeriphHeader);
            end

            AllDevices=getAllDevices(obj);
            if~isempty(AllDevices)

                if createPeriphHeader
                    PeriphHeaderFile=generatePeripheralHeaderFile(obj);
                else
                    PeriphHeaderFile=codertarget.peripherals.utils.getPeripheralDataHdrName(obj.ModelObj,obj.PeripheralType);
                end
                PeriphModelHeaderFile=generatePeripheralDeclarationHdrFile(obj,AllDevices,PeriphHeaderFile);
                generatePeripheralInitializationSrcFile(obj,AllDevices,PeriphModelHeaderFile);
            end
        end
    end


    methods(Access=protected)

        function peripheralHeaderFileName=managePeripheralHeaderFile(obj)
            peripheralTypeInfo=getParameters(obj.PeripheralInfo,obj.PeripheralType);

            if isstruct(obj.PeripheralStoredData)&&isfield(obj.PeripheralStoredData,obj.PeripheralType)
                obj.PeriphIncludeFiles=StringWriter;
                addcr(obj.PeriphIncludeFiles,sprintf('#include "%s.h"','rtwtypes'));
                obj.PeriphTypedefs=StringWriter;
                addcr(obj.PeriphTypedefs,'typedef struct {');
                for i=1:numel(peripheralTypeInfo)
                    ParamDataType=getParameterDataType(obj,peripheralTypeInfo(i));
                    addcr(obj.PeriphTypedefs,sprintf('%s %s;',ParamDataType,peripheralTypeInfo(i).Storage));
                    if~isempty(peripheralTypeInfo(i).HeaderFile)
                        addcr(obj.PeriphIncludeFiles,sprintf('#include "%s.h"',peripheralTypeInfo(i).HeaderFile));
                    end
                end
                TypeName=codertarget.peripherals.utils.getPeripheralDataStructType(obj.PeripheralType);
                addcr(obj.PeriphTypedefs,['} ',TypeName,';']);
                peripheralHeaderFileName=codertarget.peripherals.utils.getPeripheralDataHdrName(obj.ModelObj,obj.PeripheralType);
            else
                peripheralHeaderFileName='';
            end
        end


        function typeName=getParameterDataType(~,parameterInfo)

            if isempty(parameterInfo.CodeInfoValueType)
                if isempty(parameterInfo.ValueType)
                    typeName='uint32_T';
                else
                    switch parameterInfo.ValueType
                    case 'double'
                        typeName='real_T';
                    case 'single'
                        typeName='real32_T';
                    case{'logical','boolean_T'}
                        typeName='int8_T';
                    otherwise
                        typeName=[parameterInfo.ValueType,'_T'];
                    end
                end
            else
                typeName=parameterInfo.CodeInfoValueType;
            end
        end


        function allDevices=getAllDevices(obj)
            if isstruct(obj.PeripheralStoredData)&&isfield(obj.PeripheralStoredData,obj.PeripheralType)
                allDevices=obj.PeripheralStoredData.(obj.PeripheralType);
                assert(isstruct(allDevices),'%s device type is expected to be a structure.',obj.PeripheralType);

                blockIDs={allDevices.ID};
                commentedIdx=cellfun(@(x)isequal(get_param(codertarget.peripherals.utils.getBlockPath(x),'Commented'),'on'),blockIDs);
                if any(commentedIdx)
                    allDevices(commentedIdx)=[];
                end
            else
                allDevices=[];
            end
        end


        function updateModelPeripheralHeaderInclude(obj,peripheralHeaderFileName)

            if isempty(obj.HdrIncludeFiles)
                obj.HdrIncludeFiles=StringWriter;
            end
            addcr(obj.HdrIncludeFiles,['#include "',peripheralHeaderFileName,'"']);
        end


        function updateModelPeripheralHeaderVariableDeclaration(obj,deviceBlock)
            if isempty(obj.HdrVariableDeclaration)
                obj.HdrVariableDeclaration=StringWriter;
            end
            blockPath=codertarget.peripherals.utils.getBlockPath(deviceBlock.ID);
            variableType=codertarget.peripherals.utils.getPeripheralDataStructType(obj.PeripheralType);
            variableName=codertarget.peripherals.utils.getBlockSID(blockPath,true);
            addcr(obj.HdrVariableDeclaration,sprintf('extern %s %s;',variableType,variableName));
        end


        function updateModelPeripheralHeaderPrototype(obj)
            if isempty(obj.HdrPrototypes)
                obj.HdrPrototypes=StringWriter;
            end

            functioName=message('codertarget:peripherals:ModelPeripheralDataInitFcn',obj.ModelObj,obj.PeripheralType).getString();
            addcr(obj.HdrPrototypes,sprintf('extern void %s(void);',functioName));
        end


        function updateModelPeripheralSourceInclude(obj,mdlPeripheralHeader)
            if isempty(obj.SrcIncludeFiles)
                obj.SrcIncludeFiles=StringWriter;
            end
            addcr(obj.SrcIncludeFiles,sprintf('#include "%s"',mdlPeripheralHeader));
        end


        function updateModelPeripheralSourceVariableDefinitions(obj,deviceBlock)
            if isempty(obj.SrcVariableDefinitions)
                obj.SrcVariableDefinitions=StringWriter;
            end
            blockPath=codertarget.peripherals.utils.getBlockPath(deviceBlock.ID);
            variableType=codertarget.peripherals.utils.getPeripheralDataStructType(obj.PeripheralType);
            variableName=codertarget.peripherals.utils.getBlockSID(blockPath,true);
            addcr(obj.SrcVariableDefinitions,sprintf('%s %s;',variableType,variableName));
        end


        function functionName=startStructureInitFunction(obj)
            if isempty(obj.SrcFunctions)
                obj.SrcFunctions=StringWriter;
            end
            functionName=message('codertarget:peripherals:ModelPeripheralDataInitFcn',obj.ModelObj,obj.PeripheralType).getString();
            addcr(obj.SrcFunctions,sprintf('void %s(void) {',functionName));
        end


        function endStructureInitFunction(obj)
            assert(~isempty(obj.SrcFunctions),'Structure init function not started.');
            addcr(obj.SrcFunctions,'}');
        end


        function updateModelPeripheralInitStructureFunction(obj,deviceBlock)
            blockPath=codertarget.peripherals.utils.getBlockPath(deviceBlock.ID);
            variableName=codertarget.peripherals.utils.getBlockSID(blockPath,true);
            blockInfo=getBlockParameters(obj.PeripheralInfo,obj.PeripheralType);
            groupInfo=getGroupParameters(obj.PeripheralInfo,obj.PeripheralType);
            deviceInfo=[blockInfo,groupInfo];
            addcr(obj.SrcFunctions,sprintf('/* Initialize structure %s required for block: %s */',variableName,blockPath));

            paramsList={deviceInfo.Storage};

            for paramIdx=1:numel(paramsList)
                if isfield(deviceBlock,paramsList{paramIdx})
                    paramValue=deviceBlock.(paramsList{paramIdx});
                    baseWrks=evalin('base','whos');
                    if(isStringScalar(paramValue)||ischar(paramValue))...
                        &&(ismember(paramValue,{baseWrks(:).name})...
                        ||strcmp(paramValue,'pi'))
                        paramValue=num2str(evalin('base',paramValue));
                    end
                elseif~isempty(obj.GroupPeripheralStoredData)&&...
                    isfield(obj.GroupPeripheralStoredData.(obj.PeripheralType),paramsList{paramIdx})

                    paramValue=obj.GroupPeripheralStoredData.(obj.PeripheralType).(paramsList{paramIdx});
                    baseWrks=evalin('base','whos');
                    if(isStringScalar(paramValue)||ischar(paramValue))...
                        &&(ismember(paramValue,{baseWrks(:).name})...
                        ||strcmp(paramValue,'pi'))
                        paramValue=num2str(evalin('base',paramValue));
                    end
                else
                    paramValue=deviceInfo(paramIdx).Value;
                end
                typeName=getParameterDataType(obj,deviceInfo(paramIdx));
                switch deviceInfo(paramIdx).Type
                case 'combobox'
                    if startsWith(deviceInfo(paramIdx).Entries,'callback:')
                        if startsWith(deviceInfo(paramIdx).CodeInfoValueType,'callback')
                            codeParamValue=feval(deviceInfo(paramIdx).CodeInfoValueName,paramValue);
                            codeParamValue=num2str(codeParamValue);
                        else
                            codeParamValue=num2str(0);
                        end
                    else
                        elements=strsplit(deviceInfo(paramIdx).Entries,';');
                        elementsEmpty=cellfun(@(x)isempty(strtrim(x)),elements);
                        if any(elementsEmpty)
                            elements(elementsEmpty)=[];
                        end
                        assert(any(strcmp(elements,paramValue)),message('codertarget:peripherals:StorageValueNotFound',paramsList{paramIdx},paramValue));
                        if~isempty(deviceInfo(paramIdx).CodeInfoValueName)
                            codeValues=strsplit(deviceInfo(paramIdx).CodeInfoValueName,';');
                            assert(isequal(numel(elements),numel(codeValues)),message('codertarget:peripherals:DropdownElementsCountMismatch',paramsList{paramIdx}));
                            codeParamValue=codeValues{strcmp(elements,paramValue)};
                        else
                            codeParamValue=find(strcmp(elements,paramValue));
                            codeParamValue=sprintf('%d',codeParamValue-1);
                        end
                    end
                case 'edit'
                    if isequal(typeName,'char*')
                        typeName='';
                        codeParamValue=['"',paramValue,'"'];
                    else
                        codeParamValue=paramValue;
                    end
                case 'checkbox'
                    if isa(paramValue,'logical')
                        codeParamValue=char('0'+paramValue);
                    elseif isequal(paramValue,'on')
                        codeParamValue='1';
                    elseif isequal(paramValue,'off')
                        codeParamValue='0';
                    else
                        paramValueLoc=eval(lower(paramValue));
                        if logical(paramValueLoc)
                            codeParamValue='1';
                        else
                            codeParamValue='0';
                        end
                    end

                    if startsWith(deviceInfo(paramIdx).Entries,'callback:')

                    else
                        if~isempty(deviceInfo(paramIdx).CodeInfoValueName)
                            codeValues=strsplit(deviceInfo(paramIdx).CodeInfoValueName,';');

                            codeValuesEmpty=cellfun(@(x)isempty(strtrim(x)),codeValues);
                            if any(codeValuesEmpty)
                                codeValues(codeValues)=[];
                            end
                            assert(numel(codeValues)==2,sprintf('For logical %s parameter, number of elements should contain two values separated with semicolon.',deviceInfo(paramIdx).Storage));
                            codeParamValue=codeValues{(codeParamValue-'0')+1};
                        end
                    end
                otherwise
                    error(message('codertarget:peripherals:DropdownElementsCountMismatch',deviceInfo(paramIdx).Type));
                end
                idxNum=regexp(paramsList{paramIdx},'_(\d+)','match');
                arrName=strrep(paramsList{paramIdx},idxNum,'');
                idxNum=strrep(idxNum,'_','');
                idxNumLogic2=regexp(paramsList{paramIdx},'\d+$','match');

                if~isempty(idxNum)
                    arrIdx=idxNum{1};
                    arrStorage=[arrName{1},'[',arrIdx,']'];
                elseif~isempty(idxNumLogic2)
                    arrIdx=idxNumLogic2{1};
                    arrName=regexp(paramsList{paramIdx},'\d+$','split');
                    arrStorage=[arrName{1},'[',arrIdx,']'];
                    arrName=arrName{1};
                else
                    arrStorage=paramsList{paramIdx};
                    arrName=arrStorage;
                end
                if~isempty(groupInfo)&&any(contains({groupInfo.Storage},arrName))

                    l_storage=arrStorage;
                    try
                        arrStorage=codertarget.peripherals.(obj.PeripheralInfo.Name)(deviceBlock,obj.PeripheralType,l_storage);
                        if~isempty(arrStorage)
                            if isempty(typeName)
                                addcr(obj.SrcFunctions,sprintf('%s.%s = %s %s;',variableName,arrStorage,typeName,codeParamValue));
                            elseif isequal(typeName,'callback')
                                typeName='uint16_T';
                                addcr(obj.SrcFunctions,sprintf('%s.%s = (%s)%s;',variableName,arrStorage,typeName,codeParamValue));
                            else
                                addcr(obj.SrcFunctions,sprintf('%s.%s = (%s)%s;',variableName,arrStorage,typeName,codeParamValue));
                            end
                        end
                    catch

                    end
                else
                    if isempty(typeName)
                        addcr(obj.SrcFunctions,sprintf('%s.%s = %s %s;',variableName,arrStorage,typeName,codeParamValue));
                    elseif isequal(typeName,'callback')
                        typeName='uint16_T';
                        addcr(obj.SrcFunctions,sprintf('%s.%s = (%s)%s;',variableName,arrStorage,typeName,codeParamValue));
                    else
                        addcr(obj.SrcFunctions,sprintf('%s.%s = (%s)%s;',variableName,arrStorage,typeName,codeParamValue));
                    end
                end
            end

        end


        function manageModelPeripheralSource(obj,deviceBlock)

            updateModelPeripheralSourceVariableDefinitions(obj,deviceBlock);

            updateModelPeripheralInitStructureFunction(obj,deviceBlock);
        end


        function periphModelHeaderFile=generatePeripheralDeclarationHdrFile(obj,deviceBlocks,periphHeaderFile)
            updateModelPeripheralHeaderInclude(obj,periphHeaderFile);
            updateModelPeripheralHeaderPrototype(obj);

            for i=1:numel(deviceBlocks)
                updateModelPeripheralHeaderVariableDeclaration(obj,deviceBlocks(i));
            end
            periphModelHeaderFile=message('codertarget:peripherals:ModelPeripheralDataDefFile',obj.ModelObj,obj.PeripheralType,'.h').getString();

            fprintf('### Writing model %s peripheral header file %s\n',obj.PeripheralType,periphModelHeaderFile);

            hdrContents=StringWriter;
            macro=sprintf('__%s__',matlab.lang.makeValidName(periphModelHeaderFile));
            addcr(hdrContents,sprintf('#ifndef %s',macro));
            addcr(hdrContents,sprintf('#define %s',macro));

            if~isempty(obj.HdrIncludeFiles)
                addcr(hdrContents,char(obj.HdrIncludeFiles));
            end
            if~isempty(obj.HdrDefines)
                addcr(hdrContents,char(obj.HdrDefines));
            end
            if~isempty(obj.HdrTypedefs)
                addcr(hdrContents,char(obj.HdrTypedefs));
            end
            if~isempty(obj.HdrVariableDeclaration)
                addcr(hdrContents,char(obj.HdrVariableDeclaration));
            end
            if~isempty(obj.HdrPrototypes)
                addcr(hdrContents,char(obj.HdrPrototypes));
            end
            addcr(hdrContents,sprintf('#endif /* %s */',macro));
            indentCode(hdrContents,'c');

            if~isempty(obj.BuildInfo)
                mainSrcDir=getSourcePaths(obj.BuildInfo,1,'BuildDir');
                mainSrcDir=mainSrcDir{1};
            else
                mainSrcDir='.';
            end
            write(hdrContents,fullfile(mainSrcDir,periphModelHeaderFile));
        end


        function periphModelSourceFile=generatePeripheralInitializationSrcFile(obj,deviceBlocks,mdlPeripheralHeader)
            updateModelPeripheralSourceInclude(obj,mdlPeripheralHeader);

            startStructureInitFunction(obj);
            arrayfun(@(x)manageModelPeripheralSource(obj,x),deviceBlocks);
            endStructureInitFunction(obj);
            periphModelSourceFile=message('codertarget:peripherals:ModelPeripheralDataDefFile',obj.ModelObj,obj.PeripheralType,'.c').getString();

            fprintf('### Writing model %s peripheral header file %s\n',obj.PeripheralType,periphModelSourceFile);

            srcContents=StringWriter;
            if~isempty(obj.SrcIncludeFiles)
                addcr(srcContents,char(obj.SrcIncludeFiles));
            end
            if~isempty(obj.SrcVariableDefinitions)
                addcr(srcContents,char(obj.SrcVariableDefinitions));
            end
            if~isempty(obj.SrcFunctions)
                addcr(srcContents,char(obj.SrcFunctions));
            end

            indentCode(srcContents,'c');

            if~isempty(obj.BuildInfo)
                mainSrcDir=getSourcePaths(obj.BuildInfo,1,'BuildDir');
                mainSrcDir=mainSrcDir{1};
            else
                mainSrcDir='.';
            end
            write(srcContents,fullfile(mainSrcDir,periphModelSourceFile));

            if~isempty(obj.BuildInfo)
                addSourceFiles(obj.BuildInfo,periphModelSourceFile,mainSrcDir,'SkipForSil');
            end
        end
    end
end


