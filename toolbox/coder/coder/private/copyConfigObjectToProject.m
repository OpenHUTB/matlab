function copyConfigObjectToProject(config,project)








    cfg=project.getConfiguration();
    cfgSerializer=coder.internal.ConfigSerializerStrategy.create(cfg);

    artifact=cfgSerializer.getParamAsString('param.artifact');
    configIsMex=isa(config,'coder.MexCodeConfig')||isa(config,'coder.MexConfig');
    datatypealiasSupportedConfig=isa(config,'coder.EmbeddedCodeConfig');


    if~cfgSerializer.getParamAsBoolean('param.configImportActive')
        cfgSerializer.setParamAsBoolean('param.configImportActive',true);
        clearImportFlag=onCleanup(@()cfgSerializer.setParamAsBoolean('param.configImportActive',false));
    end

    if configIsMex
        if~strcmp(artifact,'option.target.artifact.mex')...
            &&~strcmp(artifact,'option.target.artifact.mex.instrumented')
            artifact='option.target.artifact.mex';
        end
    else
        if isa(config,'coder.EmbeddedCodeConfig')
            cfgSerializer.setParamAsBoolean('var.ecoderEnabled',true);
        elseif isa(config,'coder.CodeConfig')
            cfgSerializer.setParamAsBoolean('var.ecoderEnabled',false);
        end
        if strcmp(config.OutputType,'EXE')
            artifact='option.target.artifact.exe';
        elseif strcmp(config.OutputType,'LIB')
            artifact='option.target.artifact.lib';
        elseif strcmp(config.OutputType,'DLL')
            artifact='option.target.artifact.dll';
        end
    end

    cfgSerializer.setParamAsString('param.artifact',artifact);

    if coder.internal.gui.isGpuCoderIntegrationEnabled()


        copyGpuSettingsToProject(config,cfgSerializer);
    end


    if isprop(config,'TargetLang')
        switch config.TargetLang
        case 'C'
            cfgSerializer.setParamAsString('param.TargetLang','option.TargetLang.C');
        case 'C++'
            cfgSerializer.setParamAsString('param.TargetLang','option.TargetLang.CPP');
        end
    end

    forEachParam(@copyParam,...
    Target=project,...
    ConfigType=config,...
    ProductionFilter={'config'},...
    ArgTypes={'param','mapping'},...
    ExtraArgs={project.getConfiguration(),config,cfgSerializer});

    if~configIsMex
        if isempty(config.HardwareImplementation)
            config.HardwareImplementation=coder.HardwareImplementation;
        end

        copyHardwareSettingsToProject(config,cfgSerializer);
        copyProjectTargetSettings('toproject',config,project);
    end

    if datatypealiasSupportedConfig
        copyDataTypeAliasNamesToProject(config,cfgSerializer);
    end

    syncDeepLearningConfigAndProject('toproject',project,config);

    if coder.internal.gui.isGpuCoderIntegrationEnabled()


        copyGpuSettingsToProject(config,cfgSerializer);
    end

    cleanupAnomalies(config,project);
end


function cleanupAnomalies(config,project)


    if isprop(config,'InstructionSetExtensions')
        paramFromConfig=config.InstructionSetExtensions;
        availableIS=loc_getAvailableInstructionSetExtensions(config);
        if~ismember(paramFromConfig,availableIS)
            param='None';
        else
            param=paramFromConfig;
        end
        project.getConfiguration().setParamAsString('param.InstructionSetExtensions',param);
    end
end



function copyParam(param,property,cfg,config,serializer)
    key=char(param.getKey());

    switch key
    case 'param.CustomToolchainOptions'
        com.mathworks.toolbox.coder.hardware.ToolchainSettingsPanel.copyOptions(...
        config.CustomToolchainOptions,cfg);
    case 'param.RowMajor'
        if config.RowMajor
            projectValue='option.RowMajor.RowMajor';
        else
            projectValue='option.RowMajor.ColumnMajor';
        end
        serializer.setParamAsString('param.RowMajor',projectValue);
    otherwise
        javaValue=getJavaValue(param,config.(property));
        serializer.(getJavaModifier(param))(key,javaValue);
    end
end



function s=getJavaModifier(param)
    type=param.getType().toString();

    if strcmp(type,'BOOLEAN')
        s='setParamAsBoolean';
    elseif strcmp(type,'INT')
        s='setParamAsInt';
    elseif strcmp(type,'FILE')||strcmp(type,'DIR')
        s='setParamAsFile';
    elseif strcmp(type,'STRING_LIST')
        s='setParamAsStringList';
    elseif strcmp(type,'FILE_LIST')||strcmp(type,'DIR_LIST')
        s='setParamAsFileList';
    else
        s='setParamAsString';
    end
end



function v=getJavaValue(param,matlabValue)
    import com.mathworks.project.impl.util.StringUtils;
    type=param.getType().toString();
    key=char(param.getKey());
    switch key
    case 'param.DynamicMemoryAllocation'
        if strcmp(matlabValue,'Off')
            v='option.DynamicMemoryAllocation.Disabled';
        elseif strcmp(matlabValue,'AllVariableSizeArrays')
            v='option.DynamicMemoryAllocation.Enabled';
        else
            v='option.DynamicMemoryAllocation.Threshold';
        end
    case{'param.DynamicMemoryAllocationForVariableSizeArrays','param.DynamicMemoryAllocationForFixedSizeArrays'}
        switch matlabValue
        case 'Never'
            v='option.DynamicMemoryAllocation.Disabled';
        case 'Always'
            v='option.DynamicMemoryAllocation.Enabled';
        otherwise
            v='option.DynamicMemoryAllocation.Threshold';
        end
    case 'param.CodeReplacementLibrary'
        try
            tr=emcGetTargetRegistry();
            v=coder.internal.getTfl(tr,matlabValue).Name;
        catch %#ok<CTCH>

            v=matlabValue;
        end
    case{'param.CustomInclude','param.CustomSource','param.CustomLibrary'}
        if iscellstr(matlabValue)||isstring(matlabValue)
            matlabValue=strjoin(matlabValue,pathsep);
        end
        v=StringUtils.delimitedStringToList(matlabValue,...
        strjoin(unique([pathsep,newline,";"]),''));
    otherwise
        switch char(type)
        case 'ENUM'
            if strcmp(key,'param.TargetLang')
                v='option.TargetLang.C';
                if strcmp(matlabValue,'C++')
                    v='option.TargetLang.CPP';
                end
            elseif strcmp(key,'param.DynamicMemoryAllocationInterface')
                switch matlabValue
                case 'Auto'
                    v='option.DynamicMemoryAllocationInterface.AUTO';
                case 'C++'
                    v='option.DynamicMemoryAllocationInterface.CPP';
                case 'C'
                    v='option.DynamicMemoryAllocationInterface.C';
                end
            elseif~isempty(param.getOptionExpression)
                v=matlabValue;
            else
                v=['option.',key(7:end),'.',matlabValue];
            end
        case{'FILE','DIR'}
            v=java.io.File(matlabValue);
        case 'STRING_LIST'
            delim=sprintf(', \n');
            if strcmp(key,'param.ReservedNameArray')&&~ischar(matlabValue)
                nVal=numel(matlabValue);
                if nVal==1
                    v=StringUtils.delimitedStringToList(matlabValue,delim);
                else
                    pValue=matlabValue(1);
                    for i=2:nVal
                        pValue=join([pValue,matlabValue(i)],";");
                    end
                    v=StringUtils.delimitedStringToList(pValue,delim);
                end
            else
                v=StringUtils.delimitedStringToList(matlabValue,delim);
            end
        case{'FILE_LIST','DIR_LIST'}
            delim=sprintf(', \n;');
            strings=StringUtils.delimitedStringToList(matlabValue,delim);
            v=java.util.List;
            stringIterator=strings.iterator();
            while stringIterator.hasNext()
                v.add(java.io.File(stringIterator.next()));
            end
        otherwise
            v=matlabValue;
        end
    end
end


function copyHardwareSettingsToProject(config,serializer)
    h=config.HardwareImplementation;

    suppressKey='var.SuppressHardwareChange';
    serializer.setParamAsBoolean(suppressKey,true);
    paramCleanup=onCleanup(@()serializer.setParamAsBoolean(suppressKey,false));

    serializer.setParamAsBoolean('param.SameHardware',h.ProdEqTarget);
    doCopyHardwareSettingsToProject('Production','Prod');
    doCopyHardwareSettingsToProject('Target','Target');


    function doCopyHardwareSettingsToProject(instance,shortInstanceName)
        serializer.setParamAsString(...
        ['param.HardwareVendor.',instance],...
        h.VendorName(instance));
        serializer.setParamAsString(...
        ['param.HardwareType.',instance],...
        h.TypeName(instance));

        types={'Char','Short','Int','Long','LongLong','Float','Double','Pointer','SizeT','PtrDiffT'};
        for i=1:length(types)
            serializer.setParamAsInt(...
            ['param.HardwareSize',types{i},'.',instance],...
            h.([shortInstanceName,'BitPer',types{i}]));
        end

        serializer.setParamAsInt(...
        ['param.HardwareSizeWord.',instance],...
        h.([shortInstanceName,'WordSize']));

        endianness=h.([shortInstanceName,'Endianess']);
        if~strcmp(endianness,'Unspecified')
            endianness=endianness(1:length(endianness)-length('Endian'));
        end
        serializer.setParamAsString(...
        ['param.HardwareEndianness.',instance],...
        ['option.HardwareEndianness.',endianness]);

        atomicInteger=h.([shortInstanceName,'LargestAtomicInteger']);
        serializer.setParamAsString(...
        ['param.HardwareAtomicIntegerSize.',instance],...
        ['option.HardwareAtomicIntegerSize.',atomicInteger]);

        atomicFloat=h.([shortInstanceName,'LargestAtomicFloat']);
        serializer.setParamAsString(...
        ['param.HardwareAtomicFloatSize.',instance],...
        ['option.HardwareAtomicFloatSize.',atomicFloat]);

        divisionRounding=h.([shortInstanceName,'IntDivRoundTo']);
        serializer.setParamAsString(...
        ['param.HardwareDivisionRounding.',instance],...
        ['option.HardwareDivisionRounding.',divisionRounding]);

        serializer.setParamAsBoolean(...
        ['param.HardwareArithmeticRightShift.',instance],...
        h.([shortInstanceName,'ShiftRightIntArith']));

        serializer.setParamAsBoolean(...
        ['param.HardwareLongLongMode.',instance],...
        h.([shortInstanceName,'LongLongMode']));
    end
end


function copyDataTypeAliasNamesToProject(config,serializer)
    h=config.ReplacementTypes;


    delimHeaderFiles=convertToDelimitedString(h.HeaderFiles);

    serializer.setParamAsString('param.ReplacementTypes.double',h.double);
    serializer.setParamAsString('param.ReplacementTypes.single',h.single);
    serializer.setParamAsString('param.ReplacementTypes.uint8',h.uint8);
    serializer.setParamAsString('param.ReplacementTypes.uint16',h.uint16);
    serializer.setParamAsString('param.ReplacementTypes.uint32',h.uint32);
    serializer.setParamAsString('param.ReplacementTypes.uint64',h.uint64);
    serializer.setParamAsString('param.ReplacementTypes.int8',h.int8);
    serializer.setParamAsString('param.ReplacementTypes.int16',h.int16);
    serializer.setParamAsString('param.ReplacementTypes.int32',h.int32);
    serializer.setParamAsString('param.ReplacementTypes.int64',h.int64);
    serializer.setParamAsString('param.ReplacementTypes.char',h.char);
    serializer.setParamAsString('param.ReplacementTypes.logical',h.logical);
    serializer.setParamAsString('param.ReplacementTypes.HeaderFiles',delimHeaderFiles);
    serializer.setParamAsBoolean('param.ReplacementTypes.ImportCustomTypes',h.IsExtern);

end


function delimHeaderFiles=convertToDelimitedString(headerFiles)



    if ischar(headerFiles)
        delimHeaderFiles=string(headerFiles);
    elseif~isempty(headerFiles)

        nVal=numel(headerFiles);
        if nVal==1
            delimHeaderFiles=string(headerFiles{1});
        else
            pValue=headerFiles(1);
            for i=2:nVal
                pValue=join([pValue,headerFiles(i)],";");
            end
            delimHeaderFiles=string(pValue{:});
        end
    else
        delimHeaderFiles=string(headerFiles);
    end

end


function copyGpuSettingsToProject(config,serializer)
    if isprop(config,'GpuConfig')&&...
        ~isempty(config.GpuConfig)&&...
        serializer.getParamAsBoolean('param.HasGpuCoder')

        gpucfg=config.GpuConfig;

        UIprefix='param.gpu.';
        setBeg='setParamAs';

        for prop=properties(gpucfg)'
            name=prop{1};
            field=gpucfg.(name);

            if strcmp(name,'Enabled')
                continue;
            end
            if isa(field,'logical')


                copyGpuParam(name,'Boolean');
            elseif isa(field,'char')
                copyGpuParam(name,'String');
            elseif~isa(field,'double')
                copyGpuParam(name,'Int');
            end
        end

        serializer.setParamAsString('param.objective','option.objective.gpu');
    end

    function copyGpuParam(name,type)
        setStr=[setBeg,type];
        serializer.(setStr)([UIprefix,name],gpucfg.(name));
    end
end

function availableIS=loc_getAvailableInstructionSetExtensions(config)
    prodEqTgt=config.HardwareImplementation.ProdEqTarget;
    isERT=isa(config,'coder.EmbeddedCodeConfig');
    if prodEqTgt
        hwDeviceType=config.HardwareImplementation.ProdHWDeviceType;
    else
        hwDeviceType=config.HardwareImplementation.TargetHWDeviceType;
    end
    [~,availableIS]=RTW.getAvailableInstructionSets(hwDeviceType,isERT);
end


