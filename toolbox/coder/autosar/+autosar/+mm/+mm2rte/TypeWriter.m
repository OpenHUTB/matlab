classdef TypeWriter<autosar.mm.mm2rte.RTEWriter




    properties(Constant,Access='public')
        RTETypeFileNameH='Rte_Type.h';
    end

    properties(Constant,Access='private')
        StaticallyDefinedAutosarTypes=...
        autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames(isAdaptive=false);
    end

    properties(Access='private')
        BaseToRTWTypesMap;
        WrittenTypeDefs;
        WrittenEnumLiteralsDefs;
        AutosarMaxShortNameLength;
    end

    methods(Access='public')
        function this=TypeWriter(typeBuilder,maxShortNameLength)
            this=this@autosar.mm.mm2rte.RTEWriter(typeBuilder);
            rteFilesLocation=typeBuilder.RTEGenerator.RTEFilesLocation;
            this.File_h_name=fullfile(rteFilesLocation,...
            autosar.mm.mm2rte.TypeWriter.RTETypeFileNameH);
            this.AutosarMaxShortNameLength=maxShortNameLength;


            this.WriterHFile=rtw.connectivity.CodeWriter.create('callCBeautifier',true,...
            'filename',this.File_h_name,...
            'append',false);
            this.BaseToRTWTypesMap=containers.Map(...
            {'uint8','sint8','uint16','sint16','uint32','sint32','boolean','float32','float64','uint64','sint64'},...
            {'uint8_T','int8_T','uint16_T','int16_T','uint32_T','int32_T','boolean_T','real32_T','real_T','uint64_T','int64_T'});
            this.WrittenTypeDefs=[];
            this.WrittenEnumLiteralsDefs=[];
        end

        function write(this)
            this.writeFileDescription(this.WriterHFile);

            autosar.mm.mm2rte.RTEWriter.writeFileGuardStart(...
            this.WriterHFile,this.RTETypeFileNameH);

            this.WriterHFile.writeLine('#include "rtwtypes.h"');
            this.WriterHFile.writeLine('#include "Std_Types.h"');
            if this.RTEBuilder.needsSystemConstantDefs()
                this.WriterHFile.writeLine('#include "Rte_Cfg.h"');
            end


            rteStatusType={'RTE_E_OK','RTE_E_LOST_DATA','RTE_E_LIMIT','E2E_E_OK','E2EPW_STATUS_OK',...
            'E2EPW_STATUS_OKSOMELOST'};
            rteStatusValues={'0x00','0x40','0x82','0x00','0x00','0x20'};
            this.WriterHFile.wComment('AUTOSAR RTE Status Types');
            for ii=1:length(rteStatusType)
                this.WriterHFile.wLine('#ifndef %s',rteStatusType{ii});
                this.WriterHFile.wLine('#define %s (%s)',...
                rteStatusType{ii},rteStatusValues{ii});
                this.WriterHFile.wLine('#endif');
            end


            this.WriterHFile.wComment('AUTOSAR Implementation data types, specific to software component');
            rteData=this.RTEBuilder.RTEData;
            voidPtrDataItems=rteData.DataItems('VoidPointer').Items;
            if~isempty(voidPtrDataItems)
                this.WriterHFile.wComment('AUTOSAR Void Pointer Types');
                arrayfun(@this.writeDataItem,voidPtrDataItems);
            end

            primDataItems=rteData.DataItems('Primitive').Items;
            if~isempty(primDataItems)
                arrayfun(@this.writeDataItem,primDataItems);
            end

            enumDataItems=rteData.DataItems('Enumeration').Items;
            if~isempty(enumDataItems)
                this.WriterHFile.wComment('AUTOSAR Enumeration Types');
                arrayfun(@this.writeDataItem,enumDataItems);
            end


            structDataItems=rteData.DataItems('Structure').Items;
            if~isempty(structDataItems)
                this.WriterHFile.wComment('AUTOSAR Structure Types');
                arrayfun(@this.writeDataItem,structDataItems);
            end

            arrayDataItems=rteData.DataItems('Array').Items;
            if~isempty(arrayDataItems)
                this.WriterHFile.wComment('AUTOSAR Array Types');
                arrayfun(@this.writeDataItem,arrayDataItems);
            end


            this.writeTypedef(this.WriterHFile,'void*','Rte_Instance');


            this.WriterHFile.writeLine('#endif');
        end

        function fileNames=getWrittenFiles(this)
            fileNames=getWrittenFiles@autosar.mm.mm2rte.RTEWriter(this);
        end
    end

    methods(Access='private')
        function writeDataItem(this,dataItem)
            Kind=dataItem.Kind;
            switch Kind
            case 'Primitive'
                left=dataItem.BaseTypeName;
                right=dataItem.ImpTypeName;
                this.writeTypedef(this.WriterHFile,left,right);
            case 'Enumeration'
                left=dataItem.BaseTypeName;
                right=dataItem.ImpTypeName;
                this.writeEnumTypedef(this.WriterHFile,left,right,dataItem.NameValuePairs,...
                dataItem.OnTransitionName,dataItem.OnTransitionValue);
            case 'Array'
                left=dataItem.ImpTypeName;
                right=sprintf('%s%s',dataItem.ArrayTypeName,this.getDimensionCDeclaration(dataItem.Dimensions));
                this.writeTypedef(this.WriterHFile,left,right);

            case 'Structure'
                this.writeStructTypedef(this.WriterHFile,dataItem.name,dataItem.Elements);
            case 'VoidPointer'
                left=[dataItem.BaseTypeName,'*'];
                right=dataItem.ImpTypeName;
                this.writeTypedef(this.WriterHFile,left,right);
            otherwise
                assert(false,'Unsupported type Kind "%s".',Kind);
            end
        end
    end

    methods(Access='private')
        function writeTypedef(this,writer,leftType,rightType)
            if any(strcmp(this.WrittenTypeDefs,rightType))

                return
            end

            if any(strcmp(rightType,autosar.mm.mm2rte.TypeWriter.StaticallyDefinedAutosarTypes))


                return
            end

            if strcmp(leftType,rightType)

                return
            end

            writer.wLine('typedef %s %s;',leftType,rightType);


            this.WrittenTypeDefs{end+1}=rightType;
        end

        function writeEnumTypedef(this,writer,leftType,rightType,...
            nameValuePairs,onTransitionName,onTransitionValue)

            this.writeTypedef(writer,leftType,rightType);


            for ii=1:2:length(nameValuePairs)
                enumLiternalName=nameValuePairs{ii};
                enumLiteralValue=nameValuePairs{ii+1};

                if any(strcmp(this.WrittenEnumLiteralsDefs,enumLiternalName))

                    continue
                end

                writer.wLine('#ifndef %s',enumLiternalName);
                writer.wLine('#define %s (%d)',enumLiternalName,...
                double(enumLiteralValue));
                writer.wLine('#endif');

                this.WrittenEnumLiteralsDefs{end+1}=enumLiternalName;
            end


            if~isempty(onTransitionValue)&&...
                ~any(strcmp(this.WrittenEnumLiteralsDefs,onTransitionName))

                writer.wLine('#ifndef %s',onTransitionName);
                writer.wLine('#define %s (%d)',onTransitionName,...
                double(onTransitionValue));
                writer.wLine('#endif');

                this.WrittenEnumLiteralsDefs{end+1}=onTransitionName;
            end
        end

        function writeStructTypedef(this,writer,type,elements)

            if any(strcmp(this.WrittenTypeDefs,type))

                return
            else

                this.WrittenTypeDefs{end+1}=type;
            end



            writer.wLine('#ifndef DEFINED_TYPEDEF_FOR_%s_',type);
            writer.wLine('#define DEFINED_TYPEDEF_FOR_%s_',type);

            writer.wLine('typedef struct {');
            writer.incIndent;
            for ii=1:length(elements)
                elem=elements(ii);
                if elem.IsArray
                    writer.wLine('%s %s%s;',elem.Type,elem.Name,this.getDimensionCDeclaration(elem.Dimensions));
                else
                    writer.wLine('%s %s;',elem.Type,elem.Name);
                end
            end
            writer.decIndent;
            writer.wLine('} %s;',type);
            writer.wLine('#endif');
        end

        function writeMultipleTypedefs(this,writer,leftTypes,rightTypes)
            cellfun(@(x,y)this.writeTypedef(writer,x,y),leftTypes,rightTypes);
        end

    end

    methods(Static,Access=private)

        function dimStr=getDimensionCDeclaration(dimensionCellArray)

            dimStr=sprintf('[%s]',strjoin(dimensionCellArray,']['));
        end

        function dimid=getDimensionId(dimensionCellArray)

            dimid=strjoin(dimensionCellArray,'x');
        end
    end
end



