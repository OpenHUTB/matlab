


classdef VarDimsUtils<handle
    properties(Access=public)
        HasVarDimsOutport=false
        HasVarDimsInport=false
    end


    properties(Access=private)
Writer
DataTypeUtils


        IsBusOrStruct=false;
        BusElementIndex=-1;

ModelInterface
CodeInfo
    end



    methods
        function this=VarDimsUtils(writer)
            this.Writer=writer;
            this.DataTypeUtils=coder.internal.modelreference.DataTypeUtils;
        end
    end



    methods
        function writeDeclarationForVarDims(this,dataInterface)
            varName=dataInterface.Implementation.Identifier;
            dataType=dataInterface.Implementation.Type;
            baseType=this.DataTypeUtils.getBaseType(dataType).Identifier;
            if(dataType.isScalar||dataType.isStructure||dataType.isVoid)
                this.Writer.writeLine('%s %s;',baseType,varName);
            elseif dataType.isMatrix
                this.Writer.writeLine('%s %s[%d];',baseType,varName,dataType.getWidth);
            else
                assert(false,'Unsupported data type');
            end
        end



        function writeInitializationForVarDims(this,dataType,varNamePrefix,varIdx,functionCallString)
            baseType=this.DataTypeUtils.getBaseType(dataType).Identifier;
            if dataType.isScalar
                this.Writer.writeLine('%s = (%s) %s(S, %d, %d);',varNamePrefix,baseType,functionCallString,varIdx,...
                this.getDataSetIndex(0));
            elseif dataType.isMatrix
                numOfElements=dataType.getWidth;
                for eIdx=1:numOfElements
                    this.Writer.writeLine('%s[%d] = (%s) %s(S, %d, %d);',varNamePrefix,eIdx-1,baseType,functionCallString,varIdx,...
                    this.getDataSetIndex(eIdx-1));
                end
            elseif dataType.isStructure
                this.IsBusOrStruct=true;
                numberOfElements=length(dataType.Elements);
                for eIdx=1:numberOfElements
                    if isempty(regexp(dataType.Elements(eIdx).Identifier,'^sl_padding','once'))
                        this.writeInitializationForVarDims(dataType.Elements(eIdx).Type,...
                        sprintf('%s.%s',varNamePrefix,dataType.Elements(eIdx).Identifier),...
                        varIdx,functionCallString)
                    end
                end
            else
                assert(false,'Unsupported data type');
            end
        end



        function writeUpdateForVarDims(this,dataType,varNamePrefix,varIdx,functionCallString)
            if dataType.isScalar
                this.Writer.writeLine('%s(S, %d, %d, (int)%s);',functionCallString,varIdx,this.getDataSetIndex(0),varNamePrefix);
            elseif dataType.isMatrix
                numOfElements=dataType.getWidth;
                for eIdx=1:numOfElements
                    this.Writer.writeLine('%s(S, %d, %d, (int)%s[%d]);',functionCallString,varIdx,this.getDataSetIndex(eIdx-1),varNamePrefix,eIdx-1);
                end
            elseif dataType.isStructure
                this.IsBusOrStruct=true;
                numberOfElements=length(dataType.Elements);
                for eIdx=1:numberOfElements
                    if isempty(regexp(dataType.Elements(eIdx).Identifier,'^sl_padding','once'))
                        this.writeUpdateForVarDims(dataType.Elements(eIdx).Type,...
                        sprintf('%s.%s',varNamePrefix,dataType.Elements(eIdx).Identifier),...
                        varIdx,functionCallString)
                    end
                end
            else
                assert(false,'Unsupported data type');
            end
        end


        function val=getDataSetIndex(this,dIdx)
            if(this.IsBusOrStruct)
                this.BusElementIndex=this.BusElementIndex+1;
                val=this.BusElementIndex;
            else
                val=dIdx;
            end
        end


        function resetBusElementIndex(this)
            this.BusElementIndex=-1;
            this.IsBusOrStruct=false;
        end


        function status=hasVarDimsPort(this,functionInterfaces,regExpression)
            status=false;
            numOfFunctions=length(functionInterfaces);
            for funcIdx=1:numOfFunctions
                functionInterface=functionInterfaces(funcIdx);

                if coder.internal.modelreference.FunctionInterfaceUtils.hasAsyncSampleTime(functionInterface)
                    break;
                end

                dataInterfaces=functionInterface.ActualArgs;
                numberOfDataInterfaces=length(dataInterfaces);
                for idx=1:numberOfDataInterfaces
                    if this.isVarDimsPort(dataInterfaces(idx),regExpression)
                        status=true;
                        return;
                    end
                end
            end
        end


        function hasVarDim=hasVarDimsInport(this,functionInterfaces)
            hasVarDim=this.hasVarDimsPort(functionInterfaces,'^InVarDims(\d+)$');
        end


        function hasVarDim=hasVarDimsOutport(this,functionInterfaces)
            hasVarDim=this.hasVarDimsPort(functionInterfaces,'^OutVarDims(\d+)$');
        end
    end



    methods(Static)
        function isVardim=isVarDimsPort(dataInterface,regExpression)
            rtwVariable=dataInterface.Implementation;
            if~isa(rtwVariable,'RTW.Literal')
                isVardim=~isempty(regexp(rtwVariable.Identifier,regExpression,'once'));
            else
                isVardim=false;
            end
        end
    end
end
