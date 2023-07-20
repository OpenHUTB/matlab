classdef TypeWriter<autosar.mm.mm2ara.ARAWriter












    properties(SetAccess=immutable,GetAccess=private)
        AnchorDirectory;
    end

    methods(Access=public)
        function this=TypeWriter(TypeBuilder,schemaVer,anchorDir)
            this=this@autosar.mm.mm2ara.ARAWriter(TypeBuilder,schemaVer);
            this.AnchorDirectory=anchorDir;
        end

        function write(this)


            qNames=this.ARABuilder.RefTypesQNameToARADataMap.keys;
            values=this.ARABuilder.RefTypesQNameToARADataMap.values;

            writtenHeaderFileNames=cell(1,length(qNames));
            writtenHeaderFilePaths=cell(1,length(qNames));

            for dataTypeIdx=1:length(qNames)
                m3iType=values{dataTypeIdx};
                [namespaceStr,nsCellArray]=...
                autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
                m3iType,namespaceSeparator='/');
                fileName=['impl_type_',lower(m3iType.Name),'.h'];
                folderPath=fullfile(this.AraFileLocation,namespaceStr);
                if exist(folderPath,'dir')~=7
                    mkdir(folderPath);
                end
                filePath=fullfile(folderPath,fileName);
                switch(class(m3iType))
                case 'Simulink.metamodel.types.Matrix'
                    this.addMatrixType(m3iType,nsCellArray,filePath);
                case 'Simulink.metamodel.types.Structure'
                    this.addStructureType(m3iType,nsCellArray,filePath);
                case{'Simulink.metamodel.types.Boolean','Simulink.metamodel.types.PrimitiveType',...
                    'Simulink.metamodel.types.FloatingPoint','Simulink.metamodel.types.FixedPoint',...
                    'Simulink.metamodel.types.Integer'}
                    this.addPrimitiveType(m3iType,nsCellArray,filePath);
                case 'Simulink.metamodel.types.Enumeration'
                    this.addEnumerationType(m3iType,nsCellArray,filePath);
                otherwise
                    assert(false,'m3iType "%s" not handled by ara generator.',class(m3iType));
                end
                writtenHeaderFileNames{dataTypeIdx}=fileName;
                writtenHeaderFilePaths{dataTypeIdx}=[namespaceStr,fileName];
            end
            autosar.code.CodeReplacementHelper.updateAraDataTypeHeaderPaths(...
            this.ARABuilder.getModelName(),this.AnchorDirectory,...
            writtenHeaderFileNames,writtenHeaderFilePaths);
        end
    end

    methods(Static,Access=public)
        function usingTypeName=getUsingTypeName(m3iType)



            usingTypeName=m3iType.Name;

            if m3iType.containerM3I.isvalid()
                if isa(m3iType.containerM3I,'Simulink.metamodel.types.StructElement')&&...
                    ~m3iType.containerM3I.Type.isvalid()&&...
                    m3iType.containerM3I.InlineType.isvalid()
                    usingTypeName=['il_rt_',m3iType.Name];
                end
            end
        end
    end

    methods(Static,Access=private)

        function typeName=getAraSupportedTypeNameForNumericType(m3iType)
            nrBits=m3iType.Length.value;
            assert(m3iType.Length.unit==Simulink.metamodel.types.DataSizeUnitKind.Bit,...
            'Support for other units is not added yet.');
            isSigned=m3iType.IsSigned;

            if(nrBits<=8)
                nrBits='8';
            elseif(nrBits<=16)
                nrBits='16';
            elseif(nrBits<=32)
                nrBits='32';
            elseif(nrBits<=64)
                nrBits='64';
            end
            if isSigned
                typeName=['int',nrBits,'_t'];
            else
                typeName=['uint',nrBits,'_t'];
            end
        end

        function attribValue=getSwBaseTypeNativeDeclaration(m3iType)


            if~isempty(m3iType.SwBaseType)
                keyValueMap=containers.Map;
                m3iSwBaseType=m3iType.SwBaseType;
                toolInfo=m3iSwBaseType.getExternalToolInfo('ARXML_SwBaseTypeInfo').externalId;
                if~isempty(toolInfo)
                    tokens=regexp(toolInfo,'#','split');
                    if numel(tokens)>0
                        numElems=str2double(tokens{1});
                        index=1;
                        for ii=1:numElems
                            index=index+1;
                            key=tokens{index};
                            index=index+1;
                            value=tokens{index};
                            keyValueMap(key)=value;
                        end
                    end
                end
                if keyValueMap.isKey('NativeDeclaration')
                    attribValue=keyValueMap('NativeDeclaration');
                else


                    if isa(m3iType,'Simulink.metamodel.types.FloatingPoint')
                        if(m3iType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double)
                            attribValue='double';
                        else
                            attribValue='float';
                        end
                    elseif isa(m3iType,'Simulink.metamodel.types.Boolean')
                        attribValue='bool';
                    elseif isa(m3iType,'Simulink.metamodel.types.Integer')||...
                        isa(m3iType,'Simulink.metamodel.types.FixedPoint')||...
                        isa(m3iType,'Simulink.metamodel.types.Enumeration')


                        attribValue=autosar.mm.mm2ara.TypeWriter.getAraSupportedTypeNameForNumericType(m3iType);
                    else
                        attribValue=m3iSwBaseType.Name;
                    end
                end
            else
                if isa(m3iType,'Simulink.metamodel.types.Boolean')
                    attribValue='bool';
                elseif isa(m3iType,'Simulink.metamodel.types.Integer')||...
                    isa(m3iType,'Simulink.metamodel.types.FixedPoint')||...
                    isa(m3iType,'Simulink.metamodel.types.Enumeration')
                    attribValue=autosar.mm.mm2ara.TypeWriter.getAraSupportedTypeNameForNumericType(m3iType);
                elseif isa(m3iType,'Simulink.metamodel.types.FloatingPoint')
                    if(m3iType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double)
                        attribValue='double';
                    else
                        attribValue='float';
                    end

                end
            end
        end

        function writeHeaderInclusionGuard(codeWriter,nsCellArray,prependStr,m3iType)

            str=prependStr;
            appendStr=['IMPL_TYPE_',upper(m3iType.Name),'_H_'];
            for ii=1:numel(nsCellArray)
                str=[str,upper(nsCellArray{ii})];%#ok<AGROW>
                str=[str,'_'];%#ok<AGROW>
            end
            str=[str,appendStr];
            codeWriter.wLine(str);
        end

        function[enumTypeName,baseTypeName,enumMemberValues,enumMemberNames]=...
            getEnumInfo(m3iType)
            baseTypeName=autosar.mm.mm2ara.TypeWriter.getSwBaseTypeNativeDeclaration(m3iType);
            enumTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(m3iType);
            [enumMemberValues,enumMemberNames]=enumeration(m3iType.Name);
        end

        function writeScopedEnum(codeWriter,m3iType)
            [enumTypeName,baseTypeName,enumMemberValues,enumMemberNames]=...
            autosar.mm.mm2ara.TypeWriter.getEnumInfo(m3iType);
            codeWriter.wLine(['enum class ',enumTypeName,' : ',baseTypeName,'{']);
            for ii=1:numel(enumMemberValues)
                enumLiteralName=enumMemberNames{ii};

                str=sprintf('\t%s = %s',enumLiteralName,...
                int2str(enumMemberValues(ii)));
                if ii~=numel(enumMemberValues)

                    str=strcat(str,',');
                end
                codeWriter.wLine(str);
            end

            codeWriter.wLine('};');
        end

        function writeCStyleEnum(codeWriter,m3iType)
            [enumTypeName,baseTypeName,enumMemberValues,enumMemberNames]=...
            autosar.mm.mm2ara.TypeWriter.getEnumInfo(m3iType);
            codeWriter.wLine(['using ',enumTypeName,' = ',baseTypeName,';']);

            for ii=1:numel(enumMemberValues)
                if ismethod(enumMemberValues,'addClassNameToEnumNames')&&...
                    enumMemberValues.addClassNameToEnumNames
                    enumLiteralName=[m3iType.Name,'_',enumMemberNames{ii}];
                else
                    enumLiteralName=enumMemberNames{ii};
                end

                str=sprintf('const %s %s{ %s };',m3iType.Name,enumLiteralName,...
                int2str(enumMemberValues(ii)));
                codeWriter.wLine(str);
            end
        end

        function openNamespacesFor(m3iType,codeWriter)

            [~,nsCellArray]=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
            m3iType);
            autosar.mm.mm2ara.NamespaceHelper.writeBegNamespaces(codeWriter,nsCellArray);
        end

        function closeNamespacesFor(m3iType,codeWriter)
            [~,nsCellArray]=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
            m3iType);
            autosar.mm.mm2ara.NamespaceHelper.writeEndNamespaces(codeWriter,nsCellArray);
        end
    end

    methods(Access=private)

        function addPrimitiveType(this,m3iType,nsCellArray,filePath)
            mprops=Simulink.getMetaClassIfValidEnumDataType(m3iType.Name);
            if isempty(mprops)

                this.WrittenFiles=[this.WrittenFiles,filePath];
                codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
                true,'filename',filePath,'append',false);
                this.writeFileDescription(codeWriter,'ara::com');
                this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',m3iType);
                this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',m3iType);
                codeWriter.wLine('#include <cstdint>');
                this.openNamespacesFor(m3iType,codeWriter);
                value=this.getSwBaseTypeNativeDeclaration(m3iType);
                usingTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(m3iType);
                codeWriter.wLine(['using ',usingTypeName,' = ',value,';']);
                this.closeNamespacesFor(m3iType,codeWriter);
                this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif //',m3iType);
                codeWriter.close();
            else
                this.addEnumerationType(m3iType,nsCellArray,filePath);
            end
        end

        function addEnumerationType(this,m3iType,nsCellArray,filePath)

            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',m3iType);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',m3iType);
            codeWriter.wLine('#include <cstdint>');
            this.openNamespacesFor(m3iType,codeWriter);
            if this.shouldEmitScopedEnumClass()
                this.writeScopedEnum(codeWriter,m3iType);
            else
                this.writeCStyleEnum(codeWriter,m3iType);
            end
            this.closeNamespacesFor(m3iType,codeWriter);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif //',m3iType);
            codeWriter.close();
        end

        function shouldEmitScopedEnumClass=shouldEmitScopedEnumClass(this)


            modelName=this.ARABuilder.getModelName();
            langStandard=get_param(modelName,'TargetLangStandard');
            shouldEmitScopedEnumClass=...
            matlab.internal.feature("Cpp11ScopedEnumClass")&&...
            strcmp(langStandard,'C++11 (ISO)');
        end

        function addStructureType(this,m3iType,nsCellArray,filePath)

            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',m3iType);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',m3iType);
            uniqueTypes=containers.Map;
            for kk=1:m3iType.Elements.size
                m3iElement=m3iType.Elements.at(kk);
                if m3iElement.Type.isvalid()
                    m3iElementType=m3iElement.Type;
                elseif m3iElement.InlineType.isvalid()
                    m3iElementType=m3iElement.InlineType;
                else
                    m3iElementType=[];
                    assert(false,'struct type element is empty!');
                end
                if~any(strcmp(autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes(),m3iElementType.Name))
                    str=lower(m3iElementType.Name);
                    nsStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(m3iElementType,namespaceSeparator='/');
                    uniqueTypes(str)=[nsStr,'impl_type_',str,'.h'];
                end
            end
            vals=uniqueTypes.values;
            for kk=1:numel(vals)
                codeWriter.wLine(['#include "',vals{kk},'"']);
            end

            this.openNamespacesFor(m3iType,codeWriter);

            usingTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(m3iType);
            codeWriter.wLine(['struct ',usingTypeName,'{']);

            for jj=1:m3iType.Elements.size
                m3iElement=m3iType.Elements.at(jj);
                if m3iElement.Type.isvalid()
                    m3iElementType=m3iElement.Type;
                elseif m3iElement.InlineType.isvalid()
                    m3iElementType=m3iElement.InlineType;
                else
                    m3iElementType=[];
                    assert(false,'struct type element is empty!');
                end

                usingTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(m3iElementType);
                namespaceStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(m3iElementType);
                codeWriter.wLine([namespaceStr,usingTypeName,' ',m3iElement.Name,';']);
            end
            codeWriter.wLine('};');
            this.closeNamespacesFor(m3iType,codeWriter);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif //',m3iType);
            codeWriter.close();
        end

        function addMatrixType(this,m3iType,nsCellArray,filePath)

            this.WrittenFiles=[this.WrittenFiles,filePath];
            codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
            true,'filename',filePath,'append',false);
            this.writeFileDescription(codeWriter,'ara::com');
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#ifndef ',m3iType);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#define ',m3iType);
            codeWriter.wLine('#include "ara/core/array.h"');
            m3iDim=1;
            for jj=1:m3iType.Dimensions.size
                m3iDim=m3iDim*m3iType.Dimensions.at(jj);
            end
            if~any(strcmp(autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes(),m3iType.BaseType.Name))
                fileName=lower(m3iType.BaseType.Name);
                fileName=['impl_type_',fileName,'.h'];
                nsStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(m3iType.BaseType,namespaceSeparator='/');
                codeWriter.wLine(['#include "',nsStr,fileName,'"']);
                typeName=...
                autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iType.BaseType);
            else
                typeName=this.getSwBaseTypeNativeDeclaration(m3iType.BaseType);
            end
            this.openNamespacesFor(m3iType,codeWriter);
            usingTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(m3iType);

            codeWriter.wLine([' using ',usingTypeName,' = ara::core::Array<',typeName,...
            ',',num2str(m3iDim),'>;']);
            this.closeNamespacesFor(m3iType,codeWriter);
            this.writeHeaderInclusionGuard(codeWriter,nsCellArray,'#endif //',m3iType);
            codeWriter.close();
        end

    end

end


