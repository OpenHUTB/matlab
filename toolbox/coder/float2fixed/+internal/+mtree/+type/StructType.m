classdef StructType<internal.mtree.Type





    properties(Access=public)
        busName(1,:)char;
    end

    properties(GetAccess=public,SetAccess=immutable)
        fields(1,1)struct;
    end

    methods(Access=public)

        function this=StructType(propNames,propValues,dimensions)
            this=this@internal.mtree.Type(dimensions);

            assert(numel(propNames)==numel(propValues));

            this.busName='';
            this.fields=this.nameValToStruct(propNames,propValues);
        end

        function name=getMLName(~)
            name='struct';
        end

        function type=toSlName(~)
            type='struct';
        end

        function doesit=supportsExampleValues(this)
            doesit=true;
            fieldTypes=this.getFieldTypes;

            for i=1:numel(fieldTypes)
                if~fieldTypes(i).supportsExampleValues
                    doesit=false;
                    return;
                end
            end
        end

        function subtypes=getFieldTypes(this)
            names=fieldnames(this.fields);
            numFields=numel(names);

            subtypes=repmat(internal.mtree.type.UnknownType,1,numFields);

            for i=1:numFields
                subtypes(i)=this.fields.(names{i});
            end
        end

        function names=getFieldNames(this)
            names=fieldnames(this.fields);
        end

    end

    methods(Access=protected)

        function exVal=getExampleValueScalar(this)

            fieldNames=this.getFieldNames;
            fieldTypes=this.getFieldTypes;

            numFields=numel(fieldNames);
            fieldVals=cell(1,numFields);

            for i=1:numFields
                fieldVals{i}=fieldTypes(i).getExampleValue;
            end

            exVal=this.nameValToStruct(fieldNames,fieldVals);
        end

        function exStr=getExampleValueStringScalar(this)



            fieldNames=this.getFieldNames;
            fieldTypes=this.getFieldTypes;

            numFields=numel(fieldNames);
            structArgStrs=cell(1,numFields*2);

            for i=1:numFields
                structArgStrs{i*2-1}=['''',fieldNames{i},''''];
                structArgStrs{i*2}=fieldTypes(i).getExampleValueString();
            end

            exStr=sprintf('struct(%s)',strjoin(structArgStrs,', '));
        end

        function res=isTypeEqualScalar(this,other)


            res=false;

            if isa(other,'internal.mtree.type.StructType')
                namesThis=fieldnames(this.fields);
                namesOther=fieldnames(other.fields);

                if isequal(namesThis,namesOther)

                    res=true;

                    for i=1:numel(namesThis)
                        currName=namesThis{i};
                        thisField=this.fields.(currName);
                        otherField=other.fields.(currName);

                        if~thisField.isTypeEqual(otherField)
                            res=false;
                            return;
                        end
                    end
                end
            end
        end

        function type=toScalarPIRType(this)

            recordFactory=pir_rec_factory_tc;
            recordFactory.setRecordName(this.busName);

            names=fieldnames(this.fields);
            numFields=numel(names);

            for i=1:numFields
                fieldType=this.fields.(names{i});
                recordFactory.addMember(names{i},fieldType.toPIRType);
            end

            type=pir_record_t(recordFactory);
        end

    end

    methods(Static,Access=public)
        function s=nameValToStruct(names,values)


            interleavedArgs=reshape(...
            [reshape(names,1,[]);reshape(values,1,[])],...
            1,[]);

            s=struct(interleavedArgs{:});
        end
    end

    methods(Static,Access=public)





        function type=fromStructInfo(functionInfoRegistry,mxInferredTypeInfo)
            assert(strcmp(mxInferredTypeInfo.Class,'struct'));

            structFields=mxInferredTypeInfo.StructFields;
            nProps=numel(structFields);
            propNames=cell(1,nProps);
            propValues=cell(1,nProps);

            for i=1:nProps
                propNames{i}=structFields(i).FieldName;
                propInfoID=structFields(i).MxInfoID;
                propMxInferredTypeInfo=functionInfoRegistry.mxInfos{propInfoID};


                if strcmp(propMxInferredTypeInfo.Class,'struct')
                    propValues{i}=internal.mtree.type.StructType.fromStructInfo(...
                    functionInfoRegistry,propMxInferredTypeInfo);
                else


                    typeInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(...
                    propMxInferredTypeInfo,functionInfoRegistry.mxArrays);

                    propValues{i}=internal.mtree.Type.fromTypeInfo(typeInfo);
                end
            end

            dimensions=mxInferredTypeInfo.Size;

            dimensions(mxInferredTypeInfo.SizeDynamic)=-1;

            type=internal.mtree.type.StructType(propNames,propValues,dimensions);
        end

        function type=fromStructVarTypeInfo(varTypeInfo)
            assert(varTypeInfo.isStruct);

            dimensions=varTypeInfo.inferred_Type.Size;

            dimensions(varTypeInfo.inferred_Type.SizeDynamic)=-1;

            symbolName=varTypeInfo.SymbolName;
            lenSymbolName=numel(symbolName);

            numFields=numel(varTypeInfo.getNonNestedLoggedFields)+...
            numel(varTypeInfo.getImmediateNestedFields);
            propNames=cell(1,numFields);
            propValues=cell(1,numFields);
            propIdx=1;




            for i=1:numel(varTypeInfo.loggedFields)
                fullField=varTypeInfo.loggedFields{i};
                trailingField=fullField(lenSymbolName+1:end);

                dotsPos=find(trailingField=='.');
                numDots=numel(dotsPos);



                assert(numDots>0);


                if numDots==1
                    endFieldName=numel(trailingField);
                else
                    endFieldName=dotsPos(2)-1;
                end
                fieldName=trailingField(dotsPos(1)+1:endFieldName);



                if propIdx>1&&strcmp(fieldName,propNames{propIdx-1})
                    continue;
                end

                fieldVTI=varTypeInfo.getStructPropVarInfo([symbolName,'.',fieldName]);
                propNames{propIdx}=fieldName;
                propValues{propIdx}=internal.mtree.Type.fromVarTypeInfo(fieldVTI);
                propIdx=propIdx+1;
            end

            assert(propIdx==numFields+1);

            type=internal.mtree.type.StructType(propNames,propValues,dimensions);
        end
    end
end


