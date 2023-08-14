function result=copyProjectTargetSettings(mode,config,javaConfig)













    assert(any(strcmp(mode,{'toconfig','toproject','tocode'})));

    if isa(javaConfig,'com.mathworks.project.impl.model.Project')
        javaConfig=javaConfig.getConfiguration();
    end

    assert(isa(javaConfig,'com.mathworks.project.impl.model.Configuration'));

    switch mode
    case 'toconfig'
        result=copyTargetSettingsToConfigObject(config);
    case 'toproject'
        result=copyTargetSettingsToProject(config);
    case 'tocode'
        result=convertTargetSettingsToCodeSchema();
    otherwise
        result=[];
    end



    function config=copyTargetSettingsToConfigObject(config)


        function assignProp(obj,prop,value)
            obj.(prop)=value;
        end

        doCopyToMatlab(struct(...
        'commit',...
        @(hardware)assignProp(config,'Hardware',hardware),...
        'applySetting',...
        @assignProp));
    end


    function codeSchema=convertTargetSettingsToCodeSchema()





        codeSchema=struct('Name','','Settings',containers.Map());

        function dumpCode(hardware)
            codeSchema.Name=hardware.Name;
        end

        function addPropMod(key,value)
            codeSchema.Settings(key)=value;
        end

        doCopyToMatlab(struct(...
        'commit',...
        @dumpCode,...
        'applySetting',...
        @(hardware,key,value)addPropMod(key,value)));
    end


    function config=copyTargetSettingsToProject(config)


        if~isprop(config,'Hardware')

            return;
        end

        import com.mathworks.toolbox.coder.target.CoderTargetUtils;
        hasTarget=~isempty(config.Hardware);

        if hasTarget
            hardware=config.Hardware;
            defaultHardware=coder.hardware(hardware.Name);
            javaMap=java.util.HashMap();


            cellfun(@(prop)qualifiedCopy(hardware,prop,javaMap,defaultHardware),...
            properties(config.Hardware));

            CoderTargetUtils.applyHardwareProperties(javaConfig,...
            hardware.Name,...
            javaMap,...
            true);
        end

        CoderTargetUtils.autoSetActiveTargetType(javaConfig,hasTarget);
    end


    function doCopyToMatlab(binding)
        validateBinding(binding);

        import com.mathworks.toolbox.coder.plugin.Utilities;
        import com.mathworks.toolbox.coder.target.CoderTargetUtils;
        import com.mathworks.toolbox.coder.hardware.HardwareType;
        import com.mathworks.toolbox.coder.app.CoderRegistry;

        activeType=Utilities.getActiveTargetType(javaConfig);

        if~activeType.equals(HardwareType.TARGET)


            binding.commit([]);
            return
        end

        hardwareName=char(Utilities.getActiveTargetName(javaConfig));
        hardware=projectCoderHardware(hardwareName);

        xmlHardware=CoderTargetUtils.unmarshallFromConfiguration(javaConfig);
        if~isempty(xmlHardware)
            xmlHardware=xmlHardware.findByName(hardwareName);
        end

        if~isempty(xmlHardware)
            javaMap=xmlHardware.getValues();




            if~CoderRegistry.getInstance().isGui(javaConfig)



                mappings=mapLegacyTargetSettings(hardwareName,char(xmlHardware.getVersion()));
                keys=mappings.keys();
                for i=1:numel(keys)
                    srcKey=keys{i};
                    destKey=mappings(srcKey);

                    if~isempty(destKey)
                        javaMap.put(destKey,javaMap.remove(srcKey));
                    else
                        javaMap.remove(srcKey);
                    end
                end
            end

            javaIt=javaMap.entrySet().iterator();

            while javaIt.hasNext()
                entry=javaIt.next();
                propName=char(entry.getKey());

                if isprop(hardware,propName)
                    binding.applySetting(hardware,propName,convertBoxedJavaToMatlab(entry.getValue(),hardware.(propName)));
                end
            end

            binding.commit(hardware);
        end
    end
end


function converted=convertBoxedJavaToMatlab(value,currentValue)
    import com.mathworks.toolbox.coder.target.StorageType;

    if~isempty(value)
        type=StorageType.fromValue(value);
        assert(~isempty(type));

        if strfind(class(value),'java')==1
            if type.isNumber()
                assert(isa(value,'java.lang.Number'));
                converted=value.doubleValue();
            elseif type.isLogical()
                assert(isa(value,'java.lang.Boolean'));
                converted=value.booleanValue();
            else
                converted=char(value.toString());
            end
        else
            converted=value;
        end
    else
        converted=[];
    end




    if~strcmp(class(converted),class(currentValue))
        if islogical(currentValue)
            if isnumeric(converted)
                converted=logical(converted);
            elseif ischar(converted)
                converted=strcmpi(converted,'true');
            end
        elseif isnumeric(currentValue)&&ischar(converted)
            converted=str2double(converted);
        elseif ischar(currentValue)
            converted=num2str(converted);
        end
    end
end


function validateBinding(binding)
    assert(isstruct(binding)&&all(isfield(binding,...
    {'commit','applySetting'}))&&isa(binding.commit,'function_handle')...
    &&isa(binding.applySetting,'function_handle'));
end


function qualifiedCopy(node,keyPath,javaMap,defaultNode)
    if strcmp(keyPath,'Name')

        return;
    end

    value=node.(keyPath);

    if~isempty(value)
        if isstruct(value)

            cellfun(@(field)qualifiedCopy([keyPath,'.',field],node.(field),...
            javaMap,defaultNode.(field)),fields(value));
        elseif~isobject(value)&&(ischar(value)||isscalar(value))

            if ischar(value)
                nonDefault=~strcmp(value,defaultNode.(keyPath));
            else
                nonDefault=value~=defaultNode.(keyPath);
            end
            if nonDefault

                javaMap.put(keyPath,value);
            end
        end
    end
end
