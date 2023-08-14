
function replacedTypes=buildDataTypeReplacement(mdl)

    slTypes={'double','single','int32','int16','int8','uint32'...
    ,'uint16','uint8','boolean','int','uint','char'...
    ,'int64','uint64'};
    codeGenTypes={'real_T','real32_T','int32_T','int16_T','int8_T','uint32_T',...
    'uint16_T','uint8_T','boolean_T','int_T','uint_T','char_T',...
    'int64_T','uint64_T'};
    slToCodeGenTypes=containers.Map(slTypes,codeGenTypes);


    replacedTypes=struct('SlType',{},...
    'CodeGenType',{},...
    'ReplTypeName',{},...
    'BaseType',{},...
    'DataScope',{}...
    );


    enableReplacement=get_param(mdl,'EnableUserReplacementTypes');
    if strcmpi(enableReplacement,'on')


        primitiveTypes={'double','single','int64','int32','int16','int8',...
        'uint64','uint32','uint16','uint8','boolean','int',...
        'uint','char'};


        replacements=get_param(mdl,'ReplacementTypes');
        fnames=fieldnames(replacements);
        for k=1:numel(fnames)
            buildInType=fnames{k};
            codeGenType=slToCodeGenTypes(buildInType);
            replName=replacements.(buildInType);
            if~isempty(replName)
                [baseType,dataScope]=readReplName(replName,...
                primitiveTypes,...
                mdl);
                assert(~isempty(baseType),'Base type cannot be empty');

                if isempty(dataScope)
                    dataScope='Auto';
                end
            else
                baseType='';
                dataScope='';
            end
            record.SlType=buildInType;
            record.CodeGenType=codeGenType;
            record.ReplTypeName=replName;
            record.BaseType=baseType;
            record.DataScope=dataScope;
            replacedTypes(end+1)=record;%#ok
        end
    else
        numTypes=numel(slTypes);
        emptyValues=cell(1,numTypes);
        emptyValues(:)={''};
        replacedTypes=struct('SlType',slTypes,...
        'CodeGenType',codeGenTypes,...
        'ReplTypeName',emptyValues,...
        'BaseType',emptyValues,...
        'DataScope',emptyValues...
        );
    end
end




function[baseType,scope]=readReplName(type,primitiveTypes,mdl)


    try
        aliasType=slResolve(type,mdl);
        resolved=true;
    catch

        resolved=false;
    end

    if resolved&&isa(aliasType,'Simulink.AliasType')

        [baseType,scope]=readAliasType(aliasType,...
        primitiveTypes);
    elseif~resolved&&any(strcmp(primitiveTypes,type))

        baseType=type;
        scope='';
    else

        [baseType,scope]=getDefaults();
    end

end


function[baseType,scope]=readAliasType(aliasType,...
    primitiveTypes)
    scope=getScope(aliasType);
    if strcmpi(scope,'Imported')
        [baseType,~]=getBaseTypeAndScope(aliasType.BaseType,...
        primitiveTypes);
    else
        [baseType,scope]=getBaseTypeAndScope(aliasType.BaseType,...
        primitiveTypes);
    end
end


function[baseType,scope]=getBaseTypeAndScope(baseType,...
    primitiveTypes)
    if any(strcmp(primitiveTypes,baseType))

        baseType=baseType;%#ok
        scope='';
    else

        [baseType,scope]=getDefaults();
    end
end


function scope=getScope(aliasType)
    assert(isa(aliasType,'Simulink.AliasType'),'Invalid alias type');
    scope=aliasType.DataScope;
    if strcmpi(scope,'Auto')&&...
        ~isempty(aliasType.HeaderFile)
        scope='Imported';
    end
end


function[baseType,scope]=getDefaults()
    baseType='double';
    scope='';
end
