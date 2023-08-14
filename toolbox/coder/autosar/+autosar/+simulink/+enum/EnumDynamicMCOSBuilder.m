classdef EnumDynamicMCOSBuilder<autosar.simulink.enum.EnumAbstractBuilder





    properties(Access=private)
        MsgStream;
        EnumStrs;
    end

    methods(Access=public)
        function this=EnumDynamicMCOSBuilder()

            this.MsgStream=autosar.mm.util.MessageStreamHandler.instance();
            this.EnumStrs=containers.Map();
        end




        function addEnumeration(this,name,...
            literalNames,literalValues,...
            defaultValue,storageType,...
            addClassNameToEnumNames,description,...
            headerFile,~)


            [enumTypeDefinitionStr,errCode,errorArguments]=autosar.simulink.enum.EnumDynamicMCOSBuilder.defineEnumerationClass(...
            name,literalValues,literalNames,defaultValue,...
            storageType,char(string(addClassNameToEnumNames)),description,headerFile);
            if~isempty(errCode)
                this.MsgStream.createError(errCode,[{name},errorArguments]);
            end

            this.EnumStrs(name)=enumTypeDefinitionStr;
        end






        function createEnumsFile(this,destFile)

            enumFile=[];


            keys=this.EnumStrs.keys();
            for ii=1:numel(keys)
                enumStr=this.EnumStrs(keys{ii});

                if isempty(enumFile)

                    enumFile=rtw.connectivity.CodeWriter.create('filename',destFile);
                    msg=DAStudio.message('RTW:autosar:createEnumTypes',destFile);
                    autosar.mm.util.MessageReporter.print(msg);
                end


                enumFile.writeLine(enumStr);
            end


            if~isempty(enumFile)
                enumFile.close();

                enumFileExist=exist(fullfile(pwd,destFile),'file')~=0;
                if~enumFileExist
                    assert(false,[' Enum file ',destFile,' does not exist but it should']);
                end
            end
        end

    end

    methods(Static,Access=private)

        function[defineIntEnumTypeStr,errCode,errorArguments]=defineEnumerationClass(...
            enumName,enumLiteralValues,enumLiteralNames,defaultValue,...
            matlabStorageType,addClassNameToEnumNamesStr,enumDesc,headerFile)
            errCode=[];
            errorArguments={};
            enumNamesStr='{';
            sep='';
            for ii=1:numel(enumLiteralNames)
                enumNamesStr=sprintf('%s%s''%s''',enumNamesStr,sep,enumLiteralNames{ii});
                sep=',';
            end
            enumNamesStr=sprintf('%s}',enumNamesStr);

            mprops=meta.class.fromName(enumName);

            defineIntEnumTypeStr=sprintf(['Simulink.defineIntEnumType( ''%s'', ...\n',...
            '   %s, ...\n',...
            '   %s, ...\n'],...
            enumName,...
            enumNamesStr,...
            mat2str(enumLiteralValues));
            if~isempty(defaultValue)
                defineIntEnumTypeStr=[defineIntEnumTypeStr,sprintf(...
                '   ''DefaultValue'', ''%s'', ...\n',defaultValue)];
            end
            if~isempty(matlabStorageType)
                if~isempty(mprops)&&...
                    strcmp(Simulink.data.getEnumTypeInfo(enumName,'StorageType'),'int')&&...
                    any(strcmp(matlabStorageType,{'int32','uint32'}))







                else
                    defineIntEnumTypeStr=[defineIntEnumTypeStr,sprintf(...
                    '   ''StorageType'', ''%s'', ...\n',matlabStorageType)];
                end
            end


            if~isempty(enumDesc)
                singleQuote='''';
                doubleQuote=[singleQuote,singleQuote];
                enumDesc=strrep(enumDesc,singleQuote,doubleQuote);
                enumDesc=strrep(enumDesc,newline,'\n');
                enumDesc=strrep(enumDesc,sprintf('\r'),'\r');
                enumDesc=['   ''Description'', sprintf(''',enumDesc,'''), ... ',newline];
            end

            if~isempty(headerFile)
                defineIntEnumTypeStr=[defineIntEnumTypeStr,sprintf(...
                '   ''HeaderFile'', ''%s'', ...\n',...
                headerFile)];
            end

            modifyingDefineIntEnumTypeStr=[defineIntEnumTypeStr,sprintf([...
            '%s',...
            '   ''AddClassNameToEnumNames'', %s);\n'],...
            enumDesc,...
            addClassNameToEnumNamesStr)];

            defineIntEnumTypeStr=[defineIntEnumTypeStr,sprintf([...
            '%s',...
            '   ''AddClassNameToEnumNames'', %s);\n'],...
            enumDesc,...
            addClassNameToEnumNamesStr)];

            if~isempty(mprops)










                enumFileExist=exist(enumName,'file');
                classDefinitionExistsForEnum=...
                ((enumFileExist==2)||(enumFileExist==6))&&...
                Simulink.data.isSupportedEnumClass(enumName);

                if classDefinitionExistsForEnum


                    [enumsConsistent,errCode,errorArguments]=autosar.simulink.enum.EnumDynamicMCOSBuilder.areEnumDefinitionsConsistent(...
                    enumName,enumLiteralNames,enumLiteralValues,matlabStorageType,headerFile);
                    if~enumsConsistent
                        assert(~isempty(errCode),'errCode should not be empty when enums are not consistent.');
                        return;
                    end
                else
                    try
                        eval(modifyingDefineIntEnumTypeStr);
                    catch ME
                        if strcmp(ME.identifier,'Simulink:DataType:DynamicEnum_CannotModifyStorageType')




                            inMemoryStorageType=Simulink.data.getEnumTypeInfo(enumName,'StorageType');
                            errCode='RTW:autosar:badEnumStorageTypeMismatch';
                            errorArguments={matlabStorageType,inMemoryStorageType};
                        else
                            rethrow(ME);
                        end
                    end
                end
            else

                try
                    eval(defineIntEnumTypeStr);
                catch ME
                    if strcmp(ME.identifier,'Simulink:DataType:DynamicEnum_EnumValuesOutOfRange')




                        errCode='RTW:autosar:enumeralValueExceedsRangeOfStorageType';
                        errorArguments={matlabStorageType,num2str(enumLiteralValues)};
                    else
                        rethrow(ME);
                    end
                end
            end
        end

        function[enumsConsistent,errCode,errArgs]=areEnumDefinitionsConsistent(...
            existingEnumName,newEnumLiteralNames,newEnumLiteralValues,...
            newStorageType,newHeaderFile)

            enumsConsistent=true;
            errCode='';
            errArgs={};

            headerFile=Simulink.data.getEnumTypeInfo(existingEnumName,'HeaderFile');
            if~strcmp(headerFile,newHeaderFile)
                enumsConsistent=false;
                errCode='autosarstandard:common:enumHeaderFileIncorrect';
                errArgs=newHeaderFile;
                return;
            end


            [enumVals,enumNames]=enumeration(existingEnumName);


            [sortedEnumNames1,sortedIdx1]=sort(enumNames);
            [sortedEnumNames2,sortedIdx2]=sort(newEnumLiteralNames(:));
            if(~isequal(sortedEnumNames1,sortedEnumNames2))||...
                ~isequal(double(enumVals(sortedIdx1)),newEnumLiteralValues(sortedIdx2)')
                enumsConsistent=false;
                errCode='RTW:autosar:badEnumValues';
                return;
            end

            existingStorageType=Simulink.data.getEnumTypeInfo(existingEnumName,'StorageType');







            if~isempty(newStorageType)&&...
                ((strcmp(existingStorageType,'int')&&~any(strcmp(newStorageType,{'int32','uint32'})))||...
                (~strcmp(existingStorageType,'int')&&~strcmp(existingStorageType,newStorageType)))
                errCode='RTW:autosar:badEnumStorageTypeMismatch';
                errArgs={newStorageType,existingStorageType};
            end
        end

    end
end


