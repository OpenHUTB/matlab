function copyProjectToConfigObject(project,config,forceCopy)







    if nargin<3||isempty(forceCopy)
        forceCopy=false;
    end

    validationMessages=project.getConfiguration().getTarget().validate(project);
    problemKeys={};
    if~isempty(validationMessages)
        validationMessageIterator=validationMessages.iterator();
        while validationMessageIterator.hasNext()
            message=validationMessageIterator.next();
            if message.getSeverity().equals(com.mathworks.project.api.Severity.ERROR)...
                &&~isempty(message.getParamKey())
                problemKeys{end+1}=char(message.getParamKey());%#ok<AGROW>
            end
        end
    end


    if isprop(config,'TargetLang')
        switch char(project.getConfiguration().getParamAsString('param.TargetLang'))
        case 'option.TargetLang.C'
            config.TargetLang='C';
        case 'option.TargetLang.CPP'
            config.TargetLang='C++';
        end
    end

    hardwareSupportedConfig=~isa(config,'coder.MexCodeConfig')&&~isa(config,'coder.MexConfig');
    datatypealiasSupportedConfig=isa(config,'coder.EmbeddedCodeConfig');


    if hardwareSupportedConfig
        copyProjectTargetSettings('toconfig',config,project);
    end

    forEachParam(@copyParam,...
    Target=project,...
    ConfigType=config,...
    ProductionFilter={'config'},...
    Blacklist=problemKeys,...
    ArgTypes={'param','mapping'},...
    ExtraArgs={project.getConfiguration(),config,forceCopy});

    if hardwareSupportedConfig
        copyHardwareSettingsToConfigObject(config,project,'Target');
        copyHardwareSettingsToConfigObject(config,project,'Production');
    end
    if datatypealiasSupportedConfig
        copyDataTypeAliasNamesToConfigObject(config,project);
    end

    copyGpuSettingsToConfigObject(config,project);
    syncDeepLearningConfigAndProject('toconfig',project,config);

    cleanupAnomalies(config,project,forceCopy);
end





function cleanupAnomalies(config,project,forceCopy)
    if~forceCopy&&isprop(config,'BuildConfiguration')
        if~strcmp(config.BuildConfiguration,'Specify')
            config.CustomToolchainOptions={};
        end
    end



    if isprop(config,'CodeReplacementLibrary')&&strcmp(config.CodeReplacementLibrary,'')
        defaultConfig=coder.EmbeddedCodeConfig;
        config.CodeReplacementLibrary=defaultConfig.CodeReplacementLibrary;
    end



    if isprop(config,'TargetLangStandard')
        config.TargetLangStandard=char(project.getConfiguration().getParamAsString('param.TargetLangStandard'));
    end



    if isprop(config,'InstructionSetExtensions')
        paramFromProj=char(project.getConfiguration().getParamAsString('param.InstructionSetExtensions'));
        if~isempty(paramFromProj)
            config.InstructionSetExtensions=paramFromProj;
        end
    end
end




function copyParam(param,propertyName,javaConfig,config,forceCopy)
    key=param.getKey();
    switch propertyName
    case 'CustomToolchainOptions'
        if~forceCopy&&~strcmp(config.BuildConfiguration,'Specify')

            return
        end

        javaArray=com.mathworks.toolbox.coder.hardware.ToolchainSettingsPanel.convertOptionsToArray(...
        javaConfig);

        matlabArray=cell(1,javaArray.length);
        for i=1:javaArray.length
            matlabArray{i}=char(javaArray(i));
        end

        try
            config.CustomToolchainOptions=matlabArray;
        catch ME







            if~strcmp(ME.identifier,'Coder:configSet:InValid_CustomToolchainOptions_Name_Unknown')
                rethrow(ME);
            end
        end
    case 'RowMajor'
        config.RowMajor=strcmp(char(javaConfig.getParamAsString('param.RowMajor')),...
        'option.RowMajor.RowMajor');
    otherwise
        javaValue=javaConfig.(getJavaAccessor(param))(key);
        matlabValue=getMatlabValue(param,javaValue);

        if~isempty(matlabValue)||~any(strcmp(propertyName,...
            {'CodeReplacementLibrary','TargetFunctionLibrary','InstructionSetExtensions'}))
            config.(propertyName)=matlabValue;
        end
    end
end



function s=getJavaAccessor(param)
    type=param.getType().toString();

    if strcmp(type,'BOOLEAN')
        s='getParamAsBoolean';
    elseif strcmp(type,'INT')
        s='getParamAsInt';
    elseif strcmp(type,'FILE')||strcmp(type,'DIR')
        s='getParamAsFile';
    elseif strcmp(type,'STRING_LIST')
        s='getParamAsStringList';
    elseif strcmp(type,'FILE_LIST')||strcmp(type,'DIR_LIST')

        s='getParamAsFileList';
    else
        s='getParamAsString';
    end
end




function v=getMatlabValue(param,javaValue)
    key=char(param.getKey());

    if strcmp(key,'param.DynamicMemoryAllocation')
        if strcmp(javaValue,'option.DynamicMemoryAllocation.Disabled')
            v='Off';
        elseif strcmp(javaValue,'option.DynamicMemoryAllocation.Enabled')
            v='AllVariableSizeArrays';
        else
            v='Threshold';
        end
        return;
    end

    bail=true;
    switch key
    case 'param.DynamicMemoryAllocation'
        if strcmp(javaValue,'option.DynamicMemoryAllocation.Disabled')
            v='Off';
        elseif strcmp(javaValue,'option.DynamicMemoryAllocation.Enabled')
            v='AllVariableSizeArrays';
        else
            v='Threshold';
        end
    case{'param.DynamicMemoryAllocationForVariableSizeArrays','param.DynamicMemoryAllocationForFixedSizeArrays'}
        if strcmp(javaValue,'option.DynamicMemoryAllocation.Disabled')
            v='Never';
        elseif strcmp(javaValue,'option.DynamicMemoryAllocation.Enabled')
            v='Always';
        else
            v='Threshold';
        end
    otherwise
        bail=false;
    end
    if bail
        return
    end

    type=char(param.getType().toString());
    switch type
    case 'ENUM'
        v=char(javaValue);





        if isempty(param.getOptionExpression())
            v=v(length(key)+3:end);
        end

        if strcmp(key,'param.TargetLang')&&strcmp(v,'CPP')
            v='C++';
        end
        if strcmp(key,'param.DynamicMemoryAllocationInterface')
            switch v
            case 'AUTO'
                v='Auto';
            case 'CPP'
                v='C++';
            end
        end
    case{'FILE','DIR'}
        v=com.mathworks.project.impl.util.StringUtils.quotePathIfNecessary(javaValue.getAbsolutePath());
    case{'FILE_LIST','DIR_LIST'}
        v=char(com.mathworks.project.impl.util.StringUtils.listToDelimitedString(javaValue,newline,true));
    case 'STRING'
        v=char(javaValue);
        if isFile(param)
            v=com.mathworks.project.impl.util.StringUtils.quotePathIfNecessary(javaValue);
        end
    case 'STRING_LIST'
        if isFile(param)
            v=char(com.mathworks.project.impl.util.StringUtils.listToDelimitedString(javaValue,newline,true));
        else
            v=char(com.mathworks.project.impl.util.StringUtils.listToDelimitedString(javaValue,';',false));
        end
    otherwise
        v=javaValue;
    end


    function b=isFile(p)
        style=com.mathworks.project.impl.settingsui.ParamUtils.getStringWidgetStyle(p);
        s=style.toString();
        b=strcmp('FILE_SELECTOR',s)||strcmp('DIR_SELECTOR',s);
    end
end


function copyDataTypeAliasNamesToConfigObject(config,project)
    javaConfig=project.getConfiguration();
    h=config.ReplacementTypes;
    h.double=char(javaConfig.getParamAsString('param.ReplacementTypes.double'));
    h.single=char(javaConfig.getParamAsString('param.ReplacementTypes.single'));
    h.uint8=char(javaConfig.getParamAsString('param.ReplacementTypes.uint8'));
    h.uint16=char(javaConfig.getParamAsString('param.ReplacementTypes.uint16'));
    h.uint32=char(javaConfig.getParamAsString('param.ReplacementTypes.uint32'));
    h.uint64=char(javaConfig.getParamAsString('param.ReplacementTypes.uint64'));
    h.int8=char(javaConfig.getParamAsString('param.ReplacementTypes.int8'));
    h.int16=char(javaConfig.getParamAsString('param.ReplacementTypes.int16'));
    h.int32=char(javaConfig.getParamAsString('param.ReplacementTypes.int32'));
    h.int64=char(javaConfig.getParamAsString('param.ReplacementTypes.int64'));
    h.char=char(javaConfig.getParamAsString('param.ReplacementTypes.char'));
    h.logical=char(javaConfig.getParamAsString('param.ReplacementTypes.logical'));
    h.IsExtern=javaConfig.getParamAsBoolean('param.ReplacementTypes.ImportCustomTypes');
    h.HeaderFiles=char(javaConfig.getParamAsString('param.ReplacementTypes.HeaderFiles'));
end


function copyHardwareSettingsToConfigObject(config,project,instance)
    javaConfig=project.getConfiguration();
    h=config.HardwareImplementation;
    if strcmp(instance,'Production')
        shortInstanceName='Prod';
    else
        shortInstanceName='Target';
    end

    vendor=char(javaConfig.getParamAsString(['param.HardwareVendor.',instance]));
    type=char(javaConfig.getParamAsString(['param.HardwareType.',instance]));

    h.([shortInstanceName,'HWDeviceType'])=sprintf('%s->%s',vendor,type);

    types={'Char','Short','Int','Long','LongLong','Float','Double','Pointer','SizeT','PtrDiffT'};
    for i=1:length(types)
        value=javaConfig.getParamAsInt(['param.HardwareSize',types{i},'.',instance]);
        h.([shortInstanceName,'BitPer',types{i}])=value;
    end

    h.([shortInstanceName,'WordSize'])=javaConfig.getParamAsInt(['param.HardwareSizeWord.',instance]);

    copyHardwareEnum(...
    h,...
    javaConfig,...
    'HardwareEndianness',...
    'Endianess',...
    instance,...
    shortInstanceName);

    copyHardwareEnum(...
    h,...
    javaConfig,...
    'HardwareAtomicIntegerSize',...
    'LargestAtomicInteger',...
    instance,...
    shortInstanceName);

    copyHardwareEnum(...
    h,...
    javaConfig,...
    'HardwareAtomicFloatSize',...
    'LargestAtomicFloat',...
    instance,...
    shortInstanceName);

    copyHardwareEnum(...
    h,...
    javaConfig,...
    'HardwareDivisionRounding',...
    'IntDivRoundTo',...
    instance,...
    shortInstanceName);

    h.([shortInstanceName,'ShiftRightIntArith'])=javaConfig.getParamAsBoolean(...
    ['param.HardwareArithmeticRightShift.',instance]);
    h.([shortInstanceName,'LongLongMode'])=javaConfig.getParamAsBoolean(...
    ['param.HardwareLongLongMode.',instance]);

    h.ProdEqTarget=javaConfig.getParamAsBoolean('param.SameHardware');
end


function copyHardwareEnum(...
    h,...
    javaConfig,...
    javaName,...
    matlabName,...
    instanceName,...
    shortInstanceName)

    value=char(javaConfig.getParamAsString(...
    ['param.',javaName,'.',instanceName]));
    value=extractAfter(value,['option.',javaName,'.']);

    if strcmp(javaName,'HardwareEndianness')&&~strcmp(value,'Unspecified')
        value=[value,'Endian'];
    end

    h.([shortInstanceName,matlabName])=value;
end


function copyGpuSettingsToConfigObject(config,project)

    javaConfig=project.getConfiguration();
    objective=com.mathworks.toolbox.coder.app.GenericArtifact.fromConfiguration(javaConfig);
    objective=char(objective.name());

    if strcmpi(objective,'GPU')&&javaConfig.getParamAsBoolean('param.HasGpuCoder')&&...
        isprop(config,'GpuConfig')
        gpucfg=coder.GpuCodeConfig;

        UIprefix='param.gpu.';
        getBeg='getParamAs';

        for prop=properties(gpucfg)'
            name=prop{1};
            field=gpucfg.(name);

            if isa(field,'logical')
                copyGpuBoolean(name);
            elseif isa(field,'char')
                copyGpuString(name);
            elseif~isa(field,'double')
                copyGpuInteger(name);
            end
        end

        config.GpuConfig=gpucfg;
    end

    function copyGpuBoolean(name)
        getStr=[getBeg,'Boolean'];
        gpucfg.(name)=javaConfig.(getStr)([UIprefix,name]);
    end

    function copyGpuString(name)
        getStr=[getBeg,'String'];
        gpucfg.(name)=char(javaConfig.(getStr)([UIprefix,name]));
    end

    function copyGpuInteger(name)
        getStr=[getBeg,'Int'];
        gpucfg.(name)=javaConfig.(getStr)([UIprefix,name]);
    end
end
