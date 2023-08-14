classdef IRModifier<handle



    properties(SetAccess=protected,GetAccess=protected)

        modifier;
    end

    properties(SetAccess=public,GetAccess=public)

        DataType Simulink.NumericType=fixdt(1,32,0);

        RoundingMethod char='Floor';

        OverflowAction char='Wrap';

        Active logical=true;
    end

    properties(SetAccess=private,GetAccess=public)

        ID char='';
    end

    methods(Access={?IRInstrumentation.IRModifierManager,...
        ?IRInstrumentation.IRModifier})
        function obj=IRModifier(ID)


            obj.modifier=IRInstrumentation.Modifier(ID);
            obj.ID=ID;
        end

        function deregisterModifier(obj)



            obj.modifier.clear();
            obj.modifier.delete();
        end
    end

    methods
        function set.RoundingMethod(obj,value)
            roundigModes={'Floor','Ceil','Convergent',...
            'Nearest','Round','Zero'};

            if ismember(value,roundigModes)
                obj.RoundingMethod=value;
            else
                warning('IRModifier:InvalidRoundingMethod',...
                'Rounding mode method not accepted');
            end
        end

        function set.OverflowAction(obj,value)
            overflow={'Wrap','Saturate'};

            if ismember(value,overflow)
                obj.OverflowAction=value;
            else
                warning('IRModifier:InvalidOverflowAction',...
                'Overflow action mode not accepted');
            end
        end
    end

    methods(Hidden=true,Access=protected)
        function obj=setDataType(obj)

            wordLength=obj.DataType.WordLength;
            if slfeature('ModifiersReducedWordLengthSupport')&&wordLength>64
                error('IRModifierManager:ReducedWordLength',...
                'Maximum WordLength is 64');
            end
            obj.modifier.WordLength=wordLength;
            obj.modifier.FractionLength=obj.DataType.FractionLength;
            obj.modifier.Activation=1;
            obj.modifier.Sign=obj.DataType.getSpecifiedSign;
        end

        function obj=setRoundingMethod(obj)

            if strcmp(obj.RoundingMethod,'Floor')
                obj.modifier.RoundingMode=2;
            elseif strcmp(obj.RoundingMethod,'Ceil')
                obj.modifier.RoundingMode=0;
            elseif strcmp(obj.RoundingMethod,'Convergent')
                obj.modifier.RoundingMode=1;
            elseif strcmp(obj.RoundingMethod,'Nearest')
                obj.modifier.RoundingMode=3;
            elseif strcmp(obj.RoundingMethod,'Round')
                obj.modifier.RoundingMode=4;
            elseif strcmp(obj.RoundingMethod,'Zero')
                obj.modifier.RoundingMode=5;
            end
        end

        function obj=setOverflowAction(obj)

            if strcmp(obj.OverflowAction,'Wrap')
                obj.modifier.OverflowHandling=0;
            elseif strcmp(obj.OverflowAction,'Saturate')
                obj.modifier.OverflowHandling=1;
            end
        end

        function obj=setActivation(obj)

            if obj.Active
                obj.modifier.Activation=1;
            else
                obj.modifier.Activation=0;
            end
        end

    end

    methods
        function obj=upload(obj)


            obj.setDataType();
            obj.setRoundingMethod();
            obj.setOverflowAction();
            obj.setActivation();
            obj.modifier.upload();
        end

    end
end
