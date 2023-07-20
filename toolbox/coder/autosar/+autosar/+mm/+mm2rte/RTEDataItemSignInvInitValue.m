classdef RTEDataItemSignInvInitValue<handle





    properties(Access='private')
        RunnableName;
        PortName;
        DataElementName;
        PortInfo;
        TypeInfo;
    end

    methods(Access='public')
        function this=RTEDataItemSignInvInitValue(runnableName,portName,...
            dataElementName,portInfo,typeInfo)

            this.RunnableName=runnableName;
            this.PortName=portName;
            this.DataElementName=dataElementName;
            this.PortInfo=portInfo;
            this.TypeInfo=typeInfo;
        end

        function initValVarName=getInitValVarName(this)
            initValVarName=sprintf('Rte_IC_%s_%s',this.PortName,this.DataElementName);
        end

        function writeForSource(this,writerCFile)
            initValVar=sprintf('Rte_IC_%s_%s',this.PortName,this.DataElementName);
            if~isempty(this.PortInfo)&&...
                ~isempty(this.PortInfo.comSpec)
                if this.PortInfo.comSpec.InitialValue.isvalid()
                    initVal=this.PortInfo.comSpec.InitialValue;
                else
                    initVal=this.PortInfo.comSpec.InitValue;
                end


                value=this.getValueFromInitValueType(initVal);
                varType=this.TypeInfo.RteType;

                arrSize={};
                arrSize=this.getArraySizeFromInitValue(initVal,arrSize);

                initString=this.getVarInitializingString(value);

                if~isempty(arrSize)
                    varDeclare=[varType,' ',initValVar];
                    for k=1:length(arrSize)
                        varDeclare=[varDeclare,'[',num2str(arrSize{k}),']'];%#ok<AGROW>
                    end
                    writerCFile.wLine('%s = %s;',varDeclare,initString);
                else
                    writerCFile.wLine('%s %s = %s;',varType,initValVar,initString);
                end
            end
        end

        function writeForHeader(this,writerHFile)
            initValVar=sprintf('Rte_IC_%s_%s',this.PortName,this.DataElementName);
            policyVar=sprintf('Rte_Replace_%s_%s',this.PortName,this.DataElementName);

            if~isempty(this.PortInfo)&&...
                ~isempty(this.PortInfo.comSpec)
                if this.PortInfo.comSpec.InitialValue.isvalid()
                    initVal=this.PortInfo.comSpec.InitialValue;
                else
                    initVal=this.PortInfo.comSpec.InitValue;
                end



                if this.PortInfo.DataElements.InvalidationPolicy==Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Replace
                    writerHFile.wLine('#define %s %s',policyVar,'1');
                end

                varType=this.TypeInfo.RteType;

                arrSize={};
                arrSize=this.getArraySizeFromInitValue(initVal,arrSize);

                if~isempty(arrSize)
                    varDeclare=['extern ',varType,' ',initValVar];
                    for k=1:length(arrSize)
                        varDeclare=[varDeclare,'[',num2str(arrSize{k}),']'];%#ok<AGROW>
                    end
                    writerHFile.wLine('%s;',varDeclare);
                else
                    writerHFile.wLine('extern %s %s;',varType,initValVar);
                end
            end
        end

        function value=getValueFromInitValueType(this,initVal)

            if isa(initVal,'Simulink.metamodel.types.ConstantReference')
                value=this.getValueFromInitValueType(initVal.Value.ConstantValue);
            elseif isa(initVal,'Simulink.metamodel.types.LiteralReal')||...
                isa(initVal,'Simulink.metamodel.types.EnumerationLiteral')
                if isa(initVal.Type,'Simulink.metamodel.types.Boolean')
                    value=logical(initVal.Value);
                else
                    value=initVal.Value;
                end
            elseif isa(initVal,'Simulink.metamodel.types.EnumerationLiteralReference')
                value=initVal.Value.Value;
            elseif isa(initVal,'Simulink.metamodel.types.MatrixValueSpecification')
                value=cell(1,initVal.ownedCell.size);
                for l=1:initVal.ownedCell.size
                    value{l}=this.getValueFromInitValueType(initVal.ownedCell.at(l).Value);
                end
            elseif isa(initVal,'Simulink.metamodel.types.StructureValueSpecification')
                value=cell(1,initVal.OwnedSlot.size);
                for c=1:initVal.OwnedSlot.size
                    value{c}=this.getValueFromInitValueType(initVal.OwnedSlot.at(c).Value);
                end
            end
        end

        function arraySize=getArraySizeFromInitValue(this,initVal,arraySize)
            if isa(initVal,'Simulink.metamodel.types.MatrixValueSpecification')
                size=initVal.ownedCell.size();
                arraySize=[arraySize,size];
                arraySize=this.getArraySizeFromInitValue(initVal.ownedCell.at(1).Value,arraySize);
            elseif isa(initVal,'Simulink.metamodel.types.ConstantReference')
                constantValue=initVal.Value.ConstantValue;
                arraySize=this.getArraySizeFromInitValue(constantValue,arraySize);
            end
        end

        function outputString=getVarInitializingString(this,inputCellArray)
            if iscell(inputCellArray)
                outputString=this.getArrayStr(inputCellArray);
            else
                outputString=num2str(inputCellArray);
            end

        end

        function outStr=getArrayStr(this,inputCellArray)
            len=length(inputCellArray);
            inputString='{';
            for idx=1:len
                if iscell(inputCellArray{idx})
                    inputString=[inputString,this.getArrayStr(inputCellArray{idx}),','];%#ok<AGROW>
                else
                    inputString=[inputString,num2str(inputCellArray{idx}),','];%#ok<AGROW>
                end
            end
            inputString=inputString(1:end-1);
            outStr=[inputString,'}'];
        end
    end
end


