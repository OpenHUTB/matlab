function params=parseTypeImporterParams(headerFilesOrModelName,varargin)



















    CHECK_STRING_PARAM=1;
    CHECK_STRING_STRING_ARRAY_PARAM=2;
    CHECK_PARAM_VALUE_VALID=3;
    CHECK_HARDWARE_IMPLEMENTATION_PARAM=4;
    CHECK_DD_VALUE_VALID=5;

    p=inputParser;
    headerFilesParam.name='headerFiles';
    headerFilesParam.validateFcnType=CHECK_STRING_STRING_ARRAY_PARAM;
    addRequired(p,headerFilesParam.name,@(x)checkParam(x,headerFilesParam));
    paramList=getParamList();
    for i=1:numel(paramList)
        addParameter(p,paramList(i).name,paramList(i).default,@(x)checkParam(x,paramList(i)));
    end


    headerFilesOrModelName=checkString(headerFilesOrModelName);
    varargin=checkString(varargin);
    parse(p,headerFilesOrModelName,varargin{:});
    params=p.Results;

    params=processHeaderFileOrModelName(headerFilesOrModelName,params,p.UsingDefaults);

    checkConflictingParams(p.UsingDefaults);
    standardizeParamValues();
    getFormattedIncludes();
    getFormattedDefines();
    getFormattedUnDefines();
    validateOutputDir();
    getHardwareImplementation();



    function paramList=getParamList()
        field={'name','default','options','validateFcnType'};
        enumSuperClasses={'int8','int16','int32','uint8','uint16','Simulink.IntEnumType'};
        value=[{'MATFile';'';'';CHECK_STRING_PARAM},...
        {'DataDictionary';'';'';CHECK_DD_VALUE_VALID},...
        {'EnumClass';'MATLAB file';{'dynamic','MATLAB file'};CHECK_PARAM_VALUE_VALID},...
        {'EnumStorageType';'Simulink.IntEnumType';enumSuperClasses;CHECK_PARAM_VALUE_VALID},...
        {'IncludeDirs';{};'';CHECK_STRING_STRING_ARRAY_PARAM},...
        {'OutputDir';'.';'';CHECK_STRING_PARAM},...
        {'Defines';'';'';CHECK_STRING_PARAM},...
        {'UnDefines';'';'';CHECK_STRING_PARAM},...
        {'Names';'';'';CHECK_STRING_STRING_ARRAY_PARAM},...
        {'Regexp';'';'';CHECK_STRING_PARAM},...
        {'AttachHeaderFile';'on';{'off','on'};CHECK_PARAM_VALUE_VALID},...
        {'Overwrite';'off';{'off','on'};CHECK_PARAM_VALUE_VALID},...
        {'Verbose';'off';{'off','on'};CHECK_PARAM_VALUE_VALID},...
        {'HardwareImplementation';[];[];CHECK_HARDWARE_IMPLEMENTATION_PARAM},...
        {'ImportAllTypes';'off';{'off','on'};CHECK_PARAM_VALUE_VALID},...
        {'Language';'auto';{'C','C++','auto'};CHECK_PARAM_VALUE_VALID},...
        ];
        paramList=cell2struct(value,field,1);
    end




    function checkParam(x,paramInfo)
        switch paramInfo.validateFcnType
        case CHECK_STRING_PARAM
            checkStringParam(x,paramInfo);
        case CHECK_STRING_STRING_ARRAY_PARAM
            checkStringOrStringArrayParam(x,paramInfo);
        case CHECK_PARAM_VALUE_VALID
            checkParamValueValid(x,paramInfo);
        case CHECK_HARDWARE_IMPLEMENTATION_PARAM
            checkHardwareImplementationParam(x,paramInfo);
        case CHECK_DD_VALUE_VALID
            checkDDValeValid(x,paramInfo);
        otherwise
            error('Error validate function name. Should not reach here.');
        end
    end

    function checkStringParam(x,paramInfo)
        if isempty(x)||~ischar(x)
            errorId='Simulink:CustomCode:TypeImporterParamValueIsNotString';
            error(errorId,getString(message(errorId,paramInfo.name)));
        end
    end

    function checkStringOrStringArrayParam(x,paramInfo)
        if isempty(x)||~(ischar(x)||(iscellstr(x)&&~any(cellfun(@(s)isempty(s),x))))
            errorId='Simulink:CustomCode:TypeImporterParamValueIsNotStringOrStringArray';
            error(errorId,getString(message(errorId,paramInfo.name)));
        end
    end

    function checkHardwareImplementationParam(x,paramInfo)
        if~isempty(x)&&...
            ~isa(x,'coder.HardwareImplementation')&&...
            ~isa(x,'Simulink.ConfigSet')&&...
            ~isa(x,'Simulink.HardwareCC')
            errorId='Simulink:CustomCode:TypeImporterParamValueIsNotHardwareImplementation';
            error(errorId,getString(message(errorId,paramInfo.name)));
        end
    end

    function checkParamValueValid(x,paramInfo)
        validatestring(x,paramInfo.options,'',paramInfo.name);
    end

    function checkDDValeValid(x,paramInfo)



        if isempty(x)||(~ischar(x)&&~isa(x,'Simulink.data.DataDictionary'))
            errorId='Simulink:CustomCode:TypeImporterParamValueIsNotString';
            error(errorId,getString(message(errorId,paramInfo.name)));
        end
    end

    function checkConflictingParams(UsingDefaults)

        if(~isempty(params.Names)&&~isempty(params.Regexp))
            errorId='Simulink:CustomCode:TypeImporterParamNotSupportSimultaneously';
            error(errorId,getString(message(errorId,'Names','Regexp')));
        end


        if(~isempty(params.MATFile)&&~isempty(params.DataDictionary))
            errorId='Simulink:CustomCode:TypeImporterParamNotSupportSimultaneously';
            error(errorId,getString(message(errorId,'MATFile','DataDictionary')));
        end


        if(~isempty(params.DataDictionary)&&strcmpi(params.EnumClass,'MATLAB file'))

            if~ismember('EnumClass',UsingDefaults)
                errorId='Simulink:CustomCode:TypeImporterParamDataDictionaryAndEnumClassConflict';
                error(errorId,getString(message(errorId)));
            else
                params.EnumClass='dynamic';
            end
        end
    end

    function standardizeParamValues()
        for n=1:numel(paramList)
            if paramList(n).validateFcnType==CHECK_PARAM_VALUE_VALID
                params.(paramList(n).name)=...
                validatestring(params.(paramList(n).name),...
                paramList(n).options,'',paramList(n).name);
            end
        end
    end

    function validateOutputDir()
        if isempty(params.OutputDir)
            params.OutputDir='.';
        elseif~(exist(params.OutputDir,'dir')==7)
            errorId='Simulink:CustomCode:TypeImporterParamValueOutputDirInvalid';
            error(errorId,getString(message(errorId,strrep(params.OutputDir,'\','\\'))));
        end
    end

    function getFormattedIncludes()
        if ischar(params.IncludeDirs)
            params.IncludeDirs={params.IncludeDirs};
        elseif isrow(params.IncludeDirs)
            params.IncludeDirs=transpose(params.IncludeDirs);
        end
    end

    function getFormattedDefines()
        if isempty(params.Defines)
            params.Defines={};
        else
            userdefs=regexp(params.Defines,'(?:[-/]D)?(\w+(=("[^"]*"|\w*))?)','tokens');
            params.Defines=[userdefs{:}]';
        end
    end

    function getFormattedUnDefines()
        if isempty(params.UnDefines)
            params.UnDefines={};
        else
            params.UnDefines=regexprep(strsplit(params.UnDefines),'^-U|^/U','')';
        end
    end

    function output=checkString(input)
        output=input;
        if~isempty(input)
            if iscell(input)
                for num=1:numel(input)
                    if isstring(input{num})
                        output{num}=stringToChar(input{num});
                    end
                end
            elseif isstring(input)
                output=stringToChar(input);
            end
        end
    end

    function charOutput=stringToChar(stringInput)
        if numel(stringInput)==1
            charOutput=char(stringInput);
        else
            charOutput=cellstr(stringInput);
        end
    end

    function getHardwareImplementation()





        if isempty(params.HardwareImplementation)

            params.HardwareImplementation=coder.HardwareImplementation;
        elseif isa(params.HardwareImplementation,'Simulink.ConfigSet')

            params.HardwareImplementation=params.HardwareImplementation.getComponent('Hardware Implementation');
        end


        if isa(params.HardwareImplementation,'Simulink.HardwareCC')
            params.hostHardwareImplementation=Simulink.HardwareCC;
        elseif isa(params.HardwareImplementation,'coder.HardwareImplementation')
            params.hostHardwareImplementation=coder.HardwareImplementation;
        else
            assert(false,'Unexpected error.');
        end
    end
end