classdef RtpsSerializerWriterUtils





    methods(Access=public,Static)

        function[idlType,dataType,idlStructType]=getRTPSMetaDataFromType(eventDataBaseType)


            switch(class(eventDataBaseType))
            case 'Simulink.metamodel.types.Boolean'
                idlType='bool';
                idlStructType='boolean';
                dataType='bool';
            case{'Simulink.metamodel.types.Integer','Simulink.metamodel.types.FixedPoint',...
                'Simulink.metamodel.types.Enumeration'}
                nrBits=eventDataBaseType.Length.value;
                assert(eventDataBaseType.Length.unit==Simulink.metamodel.types.DataSizeUnitKind.Bit,...
                'Support for other units is not added yet.');

                if(nrBits<=8)
                    if eventDataBaseType.IsSigned
                        idlType='int8';
                        idlStructType='char';
                        dataType='int8_t';
                    else
                        idlType='uint8';
                        idlStructType='octet';
                        dataType='uint8_t';
                    end
                elseif(nrBits<=16)
                    if eventDataBaseType.IsSigned
                        idlType='int16';
                        idlStructType='short';
                        dataType='int16_t';
                    else
                        idlType='uint16';
                        idlStructType='unsigned short';
                        dataType='uint16_t';
                    end
                elseif(nrBits<=32)
                    if eventDataBaseType.IsSigned
                        idlType='int32';
                        idlStructType='long';
                        dataType='int32_t';
                    else
                        idlType='uint32';
                        idlStructType='unsigned long';
                        dataType='uint32_t';
                    end
                elseif(nrBits<=64)
                    if eventDataBaseType.IsSigned
                        idlType='int64';
                        idlStructType='long long';
                        dataType='int64_t';
                    else
                        idlType='uint64';
                        idlStructType='unsigned long long';
                        dataType='uint64_t';
                    end
                end
            case 'Simulink.metamodel.types.FloatingPoint'
                if(eventDataBaseType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double)
                    idlType='float64';
                    idlStructType='double';
                    dataType='double';
                else
                    idlType='float32';
                    idlStructType='float';
                    dataType='float';
                end
            otherwise
                assert(false,'Event Data Type "%s" not handled by Fast RTPS idl generator.',...
                class(eventDataBaseType));
            end
        end

        function lambdaName=getLambdaName(lambdaNum)

            lambdaName=['tLambda',num2str(lambdaNum)];
        end

        function retObjName=getRetObjName(objNum)
            retObjName=['retObj',num2str(objNum)];
        end

        function arrSizeName=getArrSizeName(arrSizeNum)
            arrSizeName=['arrSize',num2str(arrSizeNum)];
        end

        function sizeCode=cleanAppendSizeCode(initSizeCode,appndSign,appSizeCode)

            if isempty(initSizeCode)
                sizeCode=appSizeCode;
            elseif isempty(appSizeCode)
                sizeCode=initSizeCode;
            else
                sizeCode=[initSizeCode,appndSign,appSizeCode];
            end
        end

        function matDim=getMatrixSize(matrixDataType)


            matDim=1;
            for ii=1:matrixDataType.Dimensions.size
                matDim=matDim*matrixDataType.Dimensions.at(ii);
            end
        end

        function arrayType=getRecursiveArrayType(matrixDataType)




            arrayType='';
            if~isa(matrixDataType,'Simulink.metamodel.types.Matrix')
                return;
            end

            arrayType=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(matrixDataType);
        end

        function[sizeCode,lambdaNum]=generateSerializationLambda(codeWriter,lambdaNum,type,ismethod)



            if nargin<4
                ismethod=false;
            end

            sizeCode='';
            if isa(type,'Simulink.metamodel.types.Structure')

                structTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(type);

                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] (',structTypeName,' ob0) -> std::string {']);
                codeWriter.wLine('std::string sStr1 = "";');
                for ii=1:type.Elements.size()
                    curTypElem=type.Elements.at(ii);


                    if curTypElem.Type.isvalid()
                        curTypElemType=curTypElem.Type;
                    else
                        curTypElemType=curTypElem.ReferencedType;
                    end

                    if isa(curTypElemType,'Simulink.metamodel.types.Structure')


                        lambdaNum=lambdaNum+1;
                        tSizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationLambda(codeWriter,lambdaNum,curTypElemType);
                        codeWriter.wLine(['sStr1 = sStr1 + ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(ob0.',curTypElem.Name,');']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',tSizeCode);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Matrix')
                        [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationArrayTypeLambda(codeWriter,lambdaNum,'sStr1',['ob0.',curTypElem.Name],curTypElemType);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',tSizeCode);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Integer')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FixedPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FloatingPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.Boolean')
                        [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(curTypElemType);
                        codeWriter.wLine(['sStr1 = sStr1 + ara::com::_RtpsSerialize<',dataType,'>{}(ob0.',curTypElem.Name,');']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',['(2 * sizeof(',dataType,') + 1)']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Enumeration')
                        qualifiedEnumTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(curTypElemType);
                        codeWriter.wLine(['sStr1 = sStr1 + ara::com::_RtpsSerialize<',qualifiedEnumTypeName,'>{}(ob0.',curTypElem.Name,');']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',['(2 * sizeof(',qualifiedEnumTypeName,') + 1)']);
                    else
                    end
                end
            else

                if ismethod
                    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(type);
                else
                    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(type);
                end

                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] (',arrayType,' ob0) -> std::string {']);
                codeWriter.wLine('std::string sStr1 = "";');
                [sizeCode,~]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationArrayTypeLambda(codeWriter,lambdaNum,'sStr1','ob0',type);
            end
            codeWriter.wLine('return sStr1;');
            codeWriter.wLine('};');
        end

        function[sizeCode,retLambdaNum]=generateSerializationArrayTypeLambda(codeWriter,lambdaNum,strName,objName,type)


            matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(type));
            retLambdaNum=lambdaNum;
            if isa(type.BaseType,'Simulink.metamodel.types.Structure')||...
                isa(type.BaseType,'Simulink.metamodel.types.Matrix')



                lambdaNum=lambdaNum+1;
                retLambdaNum=lambdaNum;
                tSizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationLambda(codeWriter,lambdaNum,type.BaseType);
                codeWriter.wBlockStart(['for (int i = 0; i < ',matDim,'; ++i)']);
                codeWriter.wLine([strName,'=',strName,' + ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(',objName,'[i]);']);
                codeWriter.wBlockEnd();
                sizeCode=[matDim,' * (',tSizeCode,')'];
            elseif isa(type.BaseType,'Simulink.metamodel.types.Integer')||...
                isa(type.BaseType,'Simulink.metamodel.types.FixedPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.FloatingPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.Boolean')

                [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(type.BaseType);
                codeWriter.wLine([strName,'=',strName,' + ara::com::_RtpsSerialize<ara::core::Array<',dataType,', ',matDim,'>>{}(',objName,');']);
                sizeCode=['(2 * ',matDim,' * sizeof(',dataType,') + 1)'];
            elseif isa(type.BaseType,'Simulink.metamodel.types.Enumeration')
                codeWriter.wLine([strName,'=',strName,' + ara::com::_RtpsSerialize<ara::core::Array<',type.BaseType.Name,', ',matDim,'>>{}(',objName,');']);
                sizeCode=['(2 * ',matDim,' * sizeof(',type.BaseType.Name,') + 1)'];
            else
            end
        end

        function retArrSizeNum=generateImplToIdlConversionLambda(codeWriter,lambdaNum,type,arrSizeNum)



            namespace='eprosima_dds::';
            retObjNum=0;

            if isa(type,'Simulink.metamodel.types.Structure')

                structTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(type);
                dataTypeNameSpace=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(type);
                qualifiedStructTypeName=[dataTypeNameSpace,structTypeName];
                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] ( const ',qualifiedStructTypeName,' ob0) -> ',namespace,structTypeName,' {']);
                codeWriter.wLine([namespace,structTypeName,' retObj;']);
                for ii=1:type.Elements.size()
                    curTypElem=type.Elements.at(ii);


                    if curTypElem.Type.isvalid()
                        curTypElemType=curTypElem.Type;
                    else
                        curTypElemType=curTypElem.ReferencedType;
                    end

                    if isa(curTypElemType,'Simulink.metamodel.types.Structure')


                        lambdaNum=lambdaNum+1;
                        autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateImplToIdlConversionLambda(codeWriter,lambdaNum,curTypElemType,arrSizeNum);
                        codeWriter.wLine(['retObj.',curTypElem.Name,'(',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(ob0.',curTypElem.Name,'));']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Matrix')
                        retObjNum=retObjNum+1;
                        matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(curTypElemType));
                        codeWriter.wLine(['const std::int32_t ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),' = ',num2str(matDim),';']);
                        [lambdaNum,arrSizeNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateImplToIdlConversionArrayTypeLambda(codeWriter,lambdaNum,retObjNum,['ob0.',curTypElem.Name],curTypElem.Name,curTypElemType,arrSizeNum);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Integer')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FixedPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FloatingPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.Boolean')
                        codeWriter.wLine(['retObj.',curTypElem.Name,'(ob0.',curTypElem.Name,');']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Enumeration')

                        [~,platformType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(curTypElemType);
                        codeWriter.wLine(['retObj.',curTypElem.Name,'(static_cast<',platformType,'>(ob0.',curTypElem.Name,'));']);
                    else
                    end
                end
            else

                arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(type);
                matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(type));
                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] ( const ',arrayType,' ob0) -> std::array<',namespace,type.BaseType.Name,',',matDim,'> {']);
                codeWriter.wLine(['const std::int32_t ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),' = ',num2str(matDim),';']);
                codeWriter.wLine(['std::array<',namespace,type.BaseType.Name,', ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> retObj;']);
                retObjNum=retObjNum+1;
                autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateImplToIdlConversionArrayTypeLambda(codeWriter,lambdaNum,retObjNum,'ob0','',type,arrSizeNum);
            end
            codeWriter.wLine('return retObj;');
            codeWriter.wLine('};');
            retArrSizeNum=arrSizeNum;
        end

        function[retLambdaNum,retArrSizeNum]=generateImplToIdlConversionArrayTypeLambda(codeWriter,lambdaNum,objNum,objName,elemName,type,arrSizeNum)


            namespace='eprosima_dds::';

            retLambdaNum=lambdaNum;
            retArrSizeNum=arrSizeNum+1;
            if isa(type.BaseType,'Simulink.metamodel.types.Structure')||...
                isa(type.BaseType,'Simulink.metamodel.types.Matrix')



                lambdaNum=lambdaNum+1;
                retLambdaNum=lambdaNum;
                retArrSizeNum=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateImplToIdlConversionLambda(codeWriter,lambdaNum,type.BaseType,retArrSizeNum);
                codeWriter.wLine(['std::array<',namespace,type.BaseType.Name,', ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),';']);
                codeWriter.wBlockStart(['for (std::int32_t i = 0; i < ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'; ++i)']);
                codeWriter.wLine([autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),'[i] = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(',objName,'[i]);']);
                codeWriter.wBlockEnd();
                if isempty(elemName)
                    codeWriter.wLine(['retObj = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),';']);
                else
                    codeWriter.wLine(['retObj.',elemName,'(',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),');']);
                end
            elseif isa(type.BaseType,'Simulink.metamodel.types.Integer')||...
                isa(type.BaseType,'Simulink.metamodel.types.FixedPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.FloatingPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.Boolean')

                [~,~,idlStructType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(type.BaseType);
                if(isequal(idlStructType,'char'))
                    codeWriter.wLine(['std::array<char, ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> idlVal;']);
                    codeWriter.wBlockStart(['for(std::int32_t i=0;i< ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'; i++)']);
                    codeWriter.wLine(['idlVal[i] = static_cast<char>(',objName,'[i]);'])
                    codeWriter.wBlockEnd();
                    codeWriter.wLine(['retObj.',elemName,'(idlVal);']);
                else
                    codeWriter.wLine(['retObj.',elemName,'(',objName,');']);
                end
            elseif isa(type.BaseType,'Simulink.metamodel.types.Enumeration')

                [~,platformType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(type.BaseType);
                codeWriter.wLine(['retObj.',elemName,'(static_cast<',platformType,'>(',objName,'));']);
            else
            end
        end

        function[sizeCode,lambdaNum]=generateDeserializationLambda(codeWriter,lambdaNum,type,ismethod)



            if nargin<4
                ismethod=false;
            end

            sizeCode='';
            if isa(type,'Simulink.metamodel.types.Structure')

                structTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(type);
                codeWriter.wLine(['auto tLambda',num2str(lambdaNum),' = [&] (size_t& st, std::string& ob0) -> ',structTypeName,' {']);
                codeWriter.wLine([structTypeName,' retObj;']);
                for ii=1:type.Elements.size()
                    curTypElem=type.Elements.at(ii);


                    if curTypElem.Type.isvalid()
                        curTypElemType=curTypElem.Type;
                    else
                        curTypElemType=curTypElem.ReferencedType;
                    end

                    if isa(curTypElemType,'Simulink.metamodel.types.Structure')


                        lambdaNum=lambdaNum+1;
                        [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationLambda(codeWriter,lambdaNum,curTypElemType);
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(st, ob0);']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',tSizeCode);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Matrix')
                        [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationArrayTypeLambda(codeWriter,lambdaNum,'ob0',['retObj.',curTypElem.Name],curTypElemType);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',tSizeCode);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Integer')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FixedPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FloatingPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.Boolean')
                        [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(curTypElemType);
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = ara::com::_RtpsDeserialize<',dataType,'>{}(st, ob0);']);
                        codeWriter.wLine(['st += (2 * sizeof(',dataType,') + 1);']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',['(2 * sizeof(',dataType,') + 1)']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Enumeration')

                        qualifiedEnumTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(curTypElemType);
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = ara::com::_RtpsDeserialize<',qualifiedEnumTypeName,'>{}(st, ob0);']);
                        codeWriter.wLine(['st += (2 * sizeof(',qualifiedEnumTypeName,') + 1);']);
                        sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',['(2 * sizeof(',qualifiedEnumTypeName,') + 1)']);
                    else
                    end

                end
            else

                if ismethod
                    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(type);
                else
                    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(type);
                end
                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] (size_t& st, std::string& ob0) -> ',arrayType,' {']);
                codeWriter.wLine([arrayType,' retObj;']);
                [sizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationArrayTypeLambda(codeWriter,lambdaNum,'ob0','retObj',type);
            end
            codeWriter.wLine('return retObj;');
            codeWriter.wLine('};');
        end

        function[sizeCode,retLambdaNum]=generateDeserializationArrayTypeLambda(codeWriter,lambdaNum,strName,objName,type)


            matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(type));
            retLambdaNum=lambdaNum;
            if isa(type.BaseType,'Simulink.metamodel.types.Structure')||...
                isa(type.BaseType,'Simulink.metamodel.types.Matrix')



                lambdaNum=lambdaNum+1;
                retLambdaNum=lambdaNum;
                [tSizeCode,~]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationLambda(codeWriter,lambdaNum,type.BaseType);
                codeWriter.wBlockStart(['for (int i = 0; i < ',matDim,'; ++i)']);
                codeWriter.wLine([objName,'[i] = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(st, ',strName,');']);
                codeWriter.wBlockEnd();
                sizeCode=[matDim,' * (',tSizeCode,')'];
            elseif isa(type.BaseType,'Simulink.metamodel.types.Integer')||...
                isa(type.BaseType,'Simulink.metamodel.types.FixedPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.FloatingPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.Boolean')

                [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(type.BaseType);
                codeWriter.wLine([objName,'= ara::com::_RtpsDeserialize<ara::core::Array<',dataType,', ',matDim,'>>{}(st, ',strName,');']);
                codeWriter.wLine(['st += (2 * sizeof(',dataType,') * ',matDim,' + 1);']);
                sizeCode=['(2 * ',matDim,' * sizeof(',dataType,') + 1)'];
            elseif isa(type.BaseType,'Simulink.metamodel.types.Enumeration')

                codeWriter.wLine([objName,'= ara::com::_RtpsDeserialize<ara::core::Array<',type.BaseType.Name,', ',matDim,'>>{}(st, ',strName,');']);
                codeWriter.wLine(['st += (2 * sizeof(',type.BaseType.Name,') * ',matDim,' + 1);']);
                sizeCode=['(2 * ',matDim,' * sizeof(',type.BaseType.Name,') + 1)'];
            else
            end
        end

        function retArrSizeNum=generateIdlToImplConversionLambda(codeWriter,lambdaNum,type,arrSizeNum)



            namespace='eprosima_dds::';
            retObjNum=0;

            if isa(type,'Simulink.metamodel.types.Structure')

                structTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(type);
                qualifiedStructTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(type);
                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] (',namespace,structTypeName,' ob0) -> ',qualifiedStructTypeName,' {']);
                codeWriter.wLine([qualifiedStructTypeName,' retObj;']);
                for ii=1:type.Elements.size()
                    curTypElem=type.Elements.at(ii);


                    if curTypElem.Type.isvalid()
                        curTypElemType=curTypElem.Type;
                    else
                        curTypElemType=curTypElem.ReferencedType;
                    end

                    if isa(curTypElemType,'Simulink.metamodel.types.Structure')


                        lambdaNum=lambdaNum+1;
                        autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateIdlToImplConversionLambda(codeWriter,lambdaNum,curTypElemType,arrSizeNum);
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(ob0.',curTypElem.Name,'());']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Matrix')
                        retObjNum=retObjNum+1;
                        matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(curTypElemType));
                        codeWriter.wLine(['const std::int32_t ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),' = ',num2str(matDim),';']);
                        [lambdaNum,arrSizeNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateIdlToImplConversionArrayTypeLambda(codeWriter,lambdaNum,retObjNum,['ob0.',curTypElem.Name],curTypElem.Name,curTypElemType,arrSizeNum);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Integer')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FixedPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.FloatingPoint')||...
                        isa(curTypElemType,'Simulink.metamodel.types.Boolean')
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = ob0.',curTypElem.Name,'();']);
                    elseif isa(curTypElemType,'Simulink.metamodel.types.Enumeration')

                        qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(curTypElemType);
                        codeWriter.wLine(['retObj.',curTypElem.Name,' = static_cast<',qualifiedTypeName,'>(ob0.',curTypElem.Name,'());']);
                    else
                    end
                end
            else

                arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(type);
                matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(type));
                codeWriter.wLine(['auto ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),' = [&] ( std::array<',namespace,type.BaseType.Name,',',matDim,'>  ob0) -> ',arrayType,' {']);
                codeWriter.wLine([arrayType,' retObj;']);
                codeWriter.wLine(['const std::int32_t ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),' = ',num2str(matDim),';']);
                retObjNum=retObjNum+1;
                autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateIdlToImplConversionArrayTypeLambda(codeWriter,lambdaNum,retObjNum,'ob0','',type,arrSizeNum);
            end
            codeWriter.wLine('return retObj;');
            codeWriter.wLine('};');
            retArrSizeNum=arrSizeNum;
        end

        function[retLambdaNum,retArrSizeNum]=generateIdlToImplConversionArrayTypeLambda(codeWriter,lambdaNum,objNum,objName,elemName,type,arrSizeNum)


            namespace='eprosima_dds::';
            retLambdaNum=lambdaNum;
            retArrSizeNum=arrSizeNum+1;
            if isa(type.BaseType,'Simulink.metamodel.types.Structure')||...
                isa(type.BaseType,'Simulink.metamodel.types.Matrix')



                lambdaNum=lambdaNum+1;
                retLambdaNum=lambdaNum;
                retArrSizeNum=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateIdlToImplConversionLambda(codeWriter,lambdaNum,type.BaseType,retArrSizeNum);
                if isempty(elemName)
                    codeWriter.wBlockStart(['for (std::int32_t i = 0; i < ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'; ++i)']);
                    codeWriter.wLine(['retObj[i] = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(',objName,'[i]);']);
                    codeWriter.wBlockEnd();
                else
                    codeWriter.wLine(['std::array<',namespace,type.BaseType.Name,', ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),' = ',objName,'();']);
                    codeWriter.wBlockStart(['for (std::int32_t i = 0; i < ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'; ++i)']);
                    codeWriter.wLine(['retObj.',elemName,'[i] = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRetObjName(objNum),'[i]);']);
                    codeWriter.wBlockEnd();
                end
            elseif isa(type.BaseType,'Simulink.metamodel.types.Integer')||...
                isa(type.BaseType,'Simulink.metamodel.types.FixedPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.FloatingPoint')||...
                isa(type.BaseType,'Simulink.metamodel.types.Boolean')

                [~,~,idlStructType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(type.BaseType);
                if(isequal(idlStructType,'char'))
                    codeWriter.wLine(['std::array<char, ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> idlVal =',objName,'();']);
                    codeWriter.wLine(['std::array<int8_t, ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'> implVal;']);
                    codeWriter.wBlockStart(['for(std::int32_t i=0;i< ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getArrSizeName(arrSizeNum),'; i++)']);
                    codeWriter.wLine('implVal[i] = static_cast<int8_t>(idlVal[i]);');
                    codeWriter.wBlockEnd();
                    codeWriter.wLine(['retObj.',elemName,' = implVal;']);
                else
                    codeWriter.wLine(['retObj.',elemName,' = ',objName,'();']);
                end
            elseif isa(type.BaseType,'Simulink.metamodel.types.Enumeration')

                codeWriter.wLine(['retObj.',elemName,' = static_cast<',type.BaseType.Name,'>(',objName,'());']);
            else
            end
        end

        function[sizeCode,lambdaNum]=GenerateArgDeserializationRoutine(codeWriter,m3iType,argName,stPosVarName,methodArgVarName,ismethod,lambdaNum)



            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                eventDataBaseType=m3iType.BaseType;
            else
                eventDataBaseType=m3iType;
            end


            if isa(eventDataBaseType,'Simulink.metamodel.types.Structure')||...
                isa(eventDataBaseType,'Simulink.metamodel.types.Matrix')
                lambdaName=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum);
                [sizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationLambda(codeWriter,lambdaNum,m3iType,ismethod);

                if isa(m3iType,'Simulink.metamodel.types.Structure')
                    qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iType);
                    codeWriter.wLine([qualifiedTypeName,' ',argName,' = ',lambdaName,'(',stPosVarName,', ',methodArgVarName,');']);
                else
                    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(m3iType);
                    codeWriter.wLine([arrayType,' ',argName,' = ',lambdaName,'(',stPosVarName,', ',methodArgVarName,');']);
                end

                codeWriter.wLine([stPosVarName,' += ',sizeCode,';']);
                return;
            end


            [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataBaseType);
            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(m3iType));
                codeWriter.wLine(['ara::core::Array<',dataType,',',matDim,'> ',argName,' = ara::com::_RtpsDeserialize<ara::core::Array<',dataType,',',matDim,'>>{}(',stPosVarName,', ',methodArgVarName,');']);
                codeWriter.wLine([stPosVarName,' += 2 * ',matDim,' * sizeof(',dataType,') + 1;']);
                sizeCode=['(2 * ',matDim,' * sizeof(',dataType,') + 1)'];
            elseif isa(m3iType,'Simulink.metamodel.types.Enumeration')
                qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iType);
                codeWriter.wLine([qualifiedTypeName,' ',argName,' = ara::com::_RtpsDeserialize<',qualifiedTypeName,'>{}(',stPosVarName,', ',methodArgVarName,');']);
                codeWriter.wLine([stPosVarName,' += 2 * sizeof(',qualifiedTypeName,') + 1;']);
                sizeCode=['(2 * sizeof(',qualifiedTypeName,') + 1)'];
            else
                codeWriter.wLine([dataType,' ',argName,' = ara::com::_RtpsDeserialize<',dataType,'>{}(',stPosVarName,', ',methodArgVarName,');']);
                codeWriter.wLine([stPosVarName,' += 2 * sizeof(',dataType,') + 1;']);
                sizeCode=['(2 * sizeof(',dataType,') + 1)'];
            end
        end

        function[sizeCode,lambdaNum]=GenerateArgSerializationRoutine(codeWriter,m3iType,argName,serArgName,ismethod,lambdaNum)




            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                eventDataBaseType=m3iType.BaseType;
            else
                eventDataBaseType=m3iType;
            end


            if isa(eventDataBaseType,'Simulink.metamodel.types.Structure')||...
                isa(eventDataBaseType,'Simulink.metamodel.types.Matrix')

                lambdaName=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum);
                [sizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationLambda(codeWriter,lambdaNum,m3iType,ismethod);

                codeWriter.wLine(['std::string ',serArgName,' = ',lambdaName,'(',argName,');']);
                return;
            end


            [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataBaseType);
            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                matDim=num2str(autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(m3iType));
                codeWriter.wLine(['std::string ',serArgName,' = ara::com::_RtpsSerialize<ara::core::Array<',dataType,',',matDim,'>>{}(',argName,');']);
                sizeCode=['(2 * ',matDim,' * sizeof(',dataType,') + 1)'];
            elseif isa(m3iType,'Simulink.metamodel.types.Enumeration')

                qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iType);
                codeWriter.wLine(['std::string ',serArgName,' = ara::com::_RtpsSerialize<',qualifiedTypeName,'>{}(',argName,');']);
                sizeCode=['(2 * sizeof(',qualifiedTypeName,') + 1)'];
            else
                codeWriter.wLine(['std::string ',serArgName,' = ara::com::_RtpsSerialize<',dataType,'>{}(',argName,');']);
                sizeCode=['(2 * sizeof(',dataType,') + 1)'];
            end
        end

        function codeDataType=getGenCodeDataType(m3iType)


            if isa(m3iType,'Simulink.metamodel.types.Structure')||...
                isa(m3iType,'Simulink.metamodel.types.Enumeration')

                codeDataType=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iType);
            elseif isa(m3iType,'Simulink.metamodel.types.Matrix')

                codeDataType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(m3iType);
            elseif isa(m3iType,'Simulink.metamodel.types.Boolean')||...
                isa(m3iType,'Simulink.metamodel.types.Integer')||...
                isa(m3iType,'Simulink.metamodel.types.FixedPoint')||...
                isa(m3iType,'Simulink.metamodel.types.FloatingPoint')

                [~,dataType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(m3iType);
                codeDataType=dataType;
            else

                codeDataType=m3iType.Name;
            end
        end

        function cArrayType=getCArrayTypeName(m3iType,isOutDirection)


            if nargin<2


                isOutDirection=false;
            end
            cArrayType='';
            if~isa(m3iType,'Simulink.metamodel.types.Matrix')
                return;
            end

            ptr='*';

            bType=m3iType.BaseType;
            while isa(bType,'Simulink.metamodel.types.Matrix')
                ptr=[ptr,'*'];%#ok<AGROW>
                bType=bType.BaseType;
            end
            qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(bType);
            if(isOutDirection)
                cArrayType=[qualifiedTypeName,ptr];
            else
                cArrayType=['const ',qualifiedTypeName,ptr];
            end
        end

    end
end


