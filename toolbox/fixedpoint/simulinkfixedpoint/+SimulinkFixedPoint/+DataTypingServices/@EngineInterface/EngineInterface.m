classdef(Sealed)EngineInterface<handle








    methods(Access=private)

        function this=EngineInterface
        end
    end
    methods(Static)

        function singleObject=getInterface()
            persistent localObject;
            if isempty(localObject)||~isvalid(localObject)
                localObject=SimulinkFixedPoint.DataTypingServices.EngineInterface;

            end


            singleObject=localObject;
        end

    end

    methods(Access=public)
        run(this,context)
    end

end