classdef OperatorsWeight2d<handle







    properties(SetAccess=private)
SupportedOperators
SupportedDatatypes
OperatorWeightTable
    end

    properties(Access=private)
OperatorWeightArray
    end

    methods

        function obj=OperatorsWeight2d()
            obj.SupportedDatatypes={'single','double','int8','uint8','int16','uint16','int32','int64','uint32','uint64'};
            obj.SupportedOperators={'ADD(+)',...
            'DIV(/)',...
            'MUL(*)',...
            'MINUS(-)',...
            'UMINUS(-u)',...
            'GT(>)',...
            'GE(>=)',...
            'LT(<)',...
            'LE(<=)',...
            'EQ(==)',...
            'NE(!=)',...
            'SHIFT_LEFT(<<)',...
            'SHIFT_RIGHT(>>)',...
            'SHIFT_RIGHT_LOG(>>l)',...
            'SHIFT_RIGHT_ARITH(>>a)',...
            'LOG_COND(conditional)',...
            'BIT_AND(&)',...
            'BIT_OR(|)',...
            'LOG_OR(||)',...
            'LOG_NOT(!)',...
            'ASSIGN(=)',...
            'LOG_AND(&&)',...
            'CAST((typecast))'};

            numRows=numel(obj.SupportedOperators);
            numCols=numel(obj.SupportedDatatypes);

            obj.OperatorWeightArray=ones(numRows,numCols);
            obj.OperatorWeightTable=array2table(obj.OperatorWeightArray,'VariableNames',obj.SupportedDatatypes,...
            'RowNames',obj.SupportedOperators);
        end


        function weight=getWeight(obj,Operator,DataType)


            if any(strcmp(obj.SupportedOperators,Operator))&&any(strcmp(obj.SupportedDatatypes,DataType))
                weight=obj.OperatorWeightTable{Operator,DataType};
            else
                weight=0;
            end
        end


        function setWeight(obj,Operator,DataType,Weight)

            OperatorIdx=find(strcmp(obj.SupportedOperators,Operator));
            DataTypeIdx=find(strcmp(obj.SupportedDatatypes,DataType));
            if(isempty(OperatorIdx))

                DAStudio.error('SimulinkFixedPoint:designCostEstimation:unsupportedOperator',Operator);
            end
            if(isempty(DataTypeIdx))

                DAStudio.error('SimulinkFixedPoint:designCostEstimation:unsupportedDatatype',DataType);
            end
            obj.OperatorWeightArray(OperatorIdx,DataTypeIdx)=Weight;
            obj.OperatorWeightTable=array2table(obj.OperatorWeightArray,'VariableNames',obj.SupportedDatatypes,...
            'RowNames',obj.SupportedOperators);
        end
    end
end


