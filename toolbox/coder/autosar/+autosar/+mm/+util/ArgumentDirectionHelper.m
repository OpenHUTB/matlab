classdef ArgumentDirectionHelper<handle





    methods(Static,Access=public)
        function validDirections=getValidDirectionsFor(m3iInterface)
            validDirections={...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In.toString,...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out.toString};
            if isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ServiceInterface')

                if slfeature('AdaptiveMethodsCommErrorHandling')

                    validDirections{end+1}=...
                    Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.CommunicationError.toString;
                end
                if slfeature('AdaptiveMethodsTimeoutErrorHandling')
                    validDirections{end+1}=...
                    Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.TimeoutError.toString;
                end
            else

                validDirections{end+1}=...
                Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut.toString;

                validDirections{end+1}=...
                Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error.toString;
            end
        end
    end
end


