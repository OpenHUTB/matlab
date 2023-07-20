classdef InstantiationDataDefProps<handle




    methods(Static)

        function m3iInstanceRef=getInstanceRef(instantiationDataDefProps,m3iPort,m3iData)


            m3iInstanceRef=[];
            for ii=1:instantiationDataDefProps.size()
                if~isempty(m3iPort)
                    if isa(instantiationDataDefProps.at(ii),'Simulink.metamodel.arplatform.instance.ParameterDataPortInstanceRef')&&...
                        m3iPort==instantiationDataDefProps.at(ii).Port&&...
                        m3iData==instantiationDataDefProps.at(ii).DataElements
                        m3iInstanceRef=instantiationDataDefProps.at(ii);
                        break
                    end
                else
                    if isa(instantiationDataDefProps.at(ii),'Simulink.metamodel.arplatform.instance.ParameterDataCompInstanceRef')&&...
                        m3iData==instantiationDataDefProps.at(ii).DataElements
                        m3iInstanceRef=instantiationDataDefProps.at(ii);
                        break
                    end
                end
            end
        end

    end
end


