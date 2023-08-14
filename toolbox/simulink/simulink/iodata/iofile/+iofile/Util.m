classdef Util




    properties
    end

    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
        Version=1.0;
    end

    methods(Static=true)

        function isValid=isValidSignal(myArg,varargin)


            isValid=isSimulinkSignalFormat(myArg,varargin{:});
        end

        function isValid=isValidSignalDataArray(sigDataArray)






            isValid=isDataArray(sigDataArray);
        end

        function isValid=isValidTimeExpression(tExpression)

            isValid=isTimeExpression(tExpression);

        end


        function isValid=isValidFunctionCallInput(fcnInput)

            isValid=isFunctionCallSignal(fcnInput);
        end


        function isValid=isValidBusStruct(Signal)


            isValid=isBusSignal(Signal);
        end


        function isValid=isFcnCallTableData(Signal)
            isValid=is2dDataArray(Signal);
        end


        function isValid=isGroundSignal(Signal)

            isValid=isGroundSignal(Signal);

        end
    end

end