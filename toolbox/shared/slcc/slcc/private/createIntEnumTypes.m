function EnumNameList=createIntEnumTypes(EnumArray,params)





    EnumNameList={};
    if isempty(params)||isempty(EnumArray)
        return;
    end

    enumStorageType=params.EnumStorageType;
    enumTemplatePath=fullfile(matlabroot,'toolbox','shared','slcc','slcc','private','EnumClassDefinitionTemplate.m');

    CellOfEnumNames={EnumArray.Name};

    [EnumNameList,index,~]=unique(CellOfEnumNames);

    if isempty(EnumNameList)
        return;
    end

    enumSLDDObjArray(numel(EnumNameList))=Simulink.data.dictionary.EnumTypeDefinition;
    isImportToSLDD=~isempty(params.DataDictionary);

    for i=1:numel(EnumNameList)
        ClassName=EnumArray(index(i)).Name;
        [num,~]=size(EnumArray(index(i)).LabelStrings);
        if(num==0)
            continue;
        end
        CellOfEnums=cell(1,num);
        for j=1:num
            CellOfEnums(j)=cellstr(EnumArray(index(i)).LabelStrings(j,:));
        end
        EnumValues=EnumArray(index(i)).Values;
        defaultEnumValue=char(CellOfEnums(1));
        zeroIndex=find(EnumValues==0);
        if~isempty(zeroIndex)
            defaultEnumValue=char(CellOfEnums(zeroIndex(1)));
        end
        headerFile=EnumArray(index(i)).HeaderFile;
        if strcmpi(params.EnumClass,'MATLAB file')
            getCustomTemplateFromSLCC(enumTemplatePath,ClassName,CellOfEnums,...
            EnumValues,defaultEnumValue,headerFile);
        else
            extraArgins={'DataScope','Imported'};
            if~isempty(headerFile)
                extraArgins=[extraArgins,{'HeaderFile',headerFile}];%#ok<*AGROW>
            end
            if~isequal(params.EnumStorageType,'Simulink.IntEnumType')
                extraArgins=[extraArgins,{'StorageType',params.EnumStorageType}];
            end

            Simulink.defineIntEnumType(ClassName,CellOfEnums,EnumValues,'DefaultValue',defaultEnumValue,extraArgins{:});
            if isImportToSLDD
                enumSLDDObjArray(i)=Simulink.dd.createEnumTypeSpecFromMCOSEnum(ClassName);
                Simulink.clearIntEnumType(ClassName);
            end
        end
    end


    if isImportToSLDD
        if ischar(params.DataDictionary)
            slddFilePath=fullfile(params.OutputDir,params.DataDictionary);
            if isempty(regexp(params.DataDictionary,'.+\.sldd$','ONCE'))
                slddFilePath=sprintf('%s.sldd',slddFilePath);
            end

            if exist(slddFilePath,'file')
                dictionaryObj=Simulink.data.dictionary.open(slddFilePath);
            else

                dictionaryObj=Simulink.data.dictionary.create(slddFilePath);
            end

            context=getSection(dictionaryObj,'Design Data');
            for i=1:numel(EnumNameList)
                assignin(context,EnumNameList{i},enumSLDDObjArray(i));
            end


            saveChanges(dictionaryObj);
            close(dictionaryObj);
        elseif isa(params.DataDictionary,'Simulink.data.DataDictionary')

            for i=1:numel(EnumNameList)
                assignin(params.DataDictionary.DataSource,EnumNameList{i},enumSLDDObjArray(i));
            end
        end
    end



    function getCustomTemplateFromSLCC(fileName,ClassName,CellOfEnums,EnumValues,defaultEnumValue,headerFile)
        fid=fopen(fileName,'r');
        strBuffer=fread(fid,'*char')';
        fclose(fid);
        strBuffer=regexprep(strBuffer,'ENUMTYPENAME',ClassName);
        strBuffer=regexprep(strBuffer,'ENUMSTORAGETYPE',enumStorageType);

        literalsBuffer='';
        for k=1:length(CellOfEnums)
            if(k>1)
                literalsBuffer=sprintf('%s,\n\t\t%s(%i)',literalsBuffer,CellOfEnums{k},EnumValues(k));
            else
                literalsBuffer=sprintf('%s%s(%i)',literalsBuffer,CellOfEnums{k},EnumValues(k));
            end
        end

        strBuffer=regexprep(strBuffer,'LITERALS',literalsBuffer);
        strBuffer=regexprep(strBuffer,'ENUMDEFAULTVALUE',defaultEnumValue);
        strBuffer=regexprep(strBuffer,'ENUMHEADERFILE',headerFile);

        EnumClassfileName=[ClassName,'.m'];
        enumClassFilePath=fullfile(params.OutputDir,EnumClassfileName);
        fid=fopen(enumClassFilePath,'w');
        fprintf(fid,'%s',strBuffer);
        fclose(fid);
    end

end
