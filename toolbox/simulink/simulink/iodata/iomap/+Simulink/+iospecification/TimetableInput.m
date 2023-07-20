classdef TimetableInput<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=isSLTimeTable(varIn);
        end

    end


    properties(Hidden)
        SupportedVarType='timetable'
    end


    methods

        function outDataType=getDataType(obj)
            outDataType=class(obj.Value.(obj.Value.Properties.VariableNames{1}));
            if strcmp(outDataType,'embedded.fi')
                numType=obj.Value.Data.numerictype;
                outDataType=obj.checkDataForFixedPoint(outDataType,numType);
            end
        end


        function outDims=getDimensions(obj)
            outDims=obj.getDimension(size(obj.Value.(obj.Value.Properties.VariableNames{1})));
        end


        function outSignalType=getSignalType(obj)
            outSignalType=obj.getComplexString(~isreal(obj.Value.(obj.Value.Properties.VariableNames{1}))&&...
            ~isstring(obj.Value.(obj.Value.Properties.VariableNames{1})));
        end


        function dim=getDimension(~,dataSize)
            dim=dataSize(2:end);
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.TimetableInput.isa(varIn);
        end

    end
end
