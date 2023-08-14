classdef CompFunctionTypeParser





    methods
        function dataStruct=convert(this,compFunctionArgs)
            assert(isa(compFunctionArgs,'Simulink.ModelReference.internal.compileInfo.CompFunctionArgs'),'Expected CompFunctionArgs object');

            import autosar.bsw.rte.CompFunctionTypeParser.getTypeStr

            dataStruct=this.getTypeStruct();

            [inputs,outputs]=autosar.bsw.rte.CompFunctionTypeParser.getSLArginNames(compFunctionArgs);


            for ii=1:compFunctionArgs.inArgs.Size
                argInfo=compFunctionArgs.inArgs.at(ii);


                dataStruct.inputNameToTypeStringMap(inputs{ii})=getTypeStr(argInfo.dataType);


                dimsStruct=argInfo.dims;
                numDims=dimsStruct.Size;
                dimsArr=zeros(numDims,1);
                for jj=1:numDims
                    dimsArr(jj)=dimsStruct(jj);
                end
                dataStruct.inputNameToDimensionStringMap(inputs{ii})=mat2str(dimsArr);
            end


            for ii=1:compFunctionArgs.outArgs.Size
                argInfo=compFunctionArgs.outArgs.at(ii);


                dataStruct.outputNameToTypeStringMap(outputs{ii})=getTypeStr(argInfo.dataType);


                dimsStruct=argInfo.dims;
                numDims=dimsStruct.Size;
                dimsArr=zeros(numDims,1);
                for jj=1:numDims
                    dimsArr(jj)=dimsStruct(jj);
                end
                dataStruct.outputNameToDimensionStringMap(outputs{ii})=mat2str(dimsArr);
            end
        end
    end

    methods(Static,Access=private)
        function typeStr=getTypeStr(argDataType)
            assert(isa(argDataType,'Simulink.ModelReference.internal.compileInfo.CompDataType'),...
            'Expected CompDataType object');
            if strcmp(argDataType.dataClass,'Enum')
                prefix='Enum: ';
            elseif strcmp(argDataType.dataClass,'Bus')
                prefix='Bus: ';
            else
                prefix='';
            end
            typeStr=[prefix,argDataType.dataTypeName];
        end

        function dataStr=getTypeStruct()
            dataStr=struct();
            dataStr.inputNameToTypeStringMap=containers.Map('KeyType','char','ValueType','char');
            dataStr.inputNameToDimensionStringMap=containers.Map('KeyType','char','ValueType','char');

            dataStr.outputNameToTypeStringMap=containers.Map('KeyType','char','ValueType','char');
            dataStr.outputNameToDimensionStringMap=containers.Map('KeyType','char','ValueType','char');
        end

        function indexByPos=getArgIndices(compFunctionArgs)
            indexByPos=cell(compFunctionArgs.argIndexMap.Size,1);
            compFunctionArgsArr=compFunctionArgs.argIndexMap.toArray();
            for ii=1:compFunctionArgs.argIndexMap.Size
                indexByPos{compFunctionArgsArr(ii).position+1}=compFunctionArgsArr(ii).index;
            end
        end

        function[inputs,outputs]=getSLArginNames(compFunctionArgs)
            argNamesOrdered=cell(compFunctionArgs.argIndexMap.Size,1);
            indexByPos=autosar.bsw.rte.CompFunctionTypeParser.getArgIndices(compFunctionArgs);
            compFunctionArgsArr=compFunctionArgs.argNameMap.toArray();
            argNames=compFunctionArgs.argNameMap.keys;
            for ii=1:compFunctionArgs.argNameMap.Size
                argNamesOrdered{compFunctionArgsArr(ii).position+1}=argNames{ii};
            end

            inputs={};
            outputs={};
            for ii=1:numel(indexByPos)
                indexStr=indexByPos{ii};
                if startsWith(indexStr,'I')
                    inputs{str2double(indexStr(2:end))+1}=argNamesOrdered{ii};%#ok<AGROW>
                else
                    outputs{str2double(indexStr(2:end))+1}=argNamesOrdered{ii};%#ok<AGROW>
                end
            end
        end
    end
end
