classdef M3IConnectedPortFinder<handle




    properties(Access=private)
        M3iAssemblyConnectorSeq;
        M3iRToPPortDict=dictionary(...
        Simulink.metamodel.arplatform.port.ParameterReceiverPort.empty,...
        cell.empty);
    end

    methods
        function this=M3IConnectedPortFinder(m3iModel)
            this.M3iAssemblyConnectorSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
            m3iModel,Simulink.metamodel.arplatform.composition.AssemblyConnector.MetaClass,true);
        end

        function m3iPPort=findParameterPPort(this,m3iRPort)
            assert(isa(m3iRPort,'Simulink.metamodel.arplatform.port.ParameterReceiverPort'),...
            'Expect only ParameterReceiverPort');

            if isKey(this.M3iRToPPortDict,m3iRPort)
                m3iPPortCell=this.M3iRToPPortDict(m3iRPort);
                m3iPPort=m3iPPortCell{1};
            else
                matchedM3iAssemblyConnectors=m3i.filter(@(x)x.Requester.RequiredPort==m3iRPort,...
                this.M3iAssemblyConnectorSeq);
                if numel(matchedM3iAssemblyConnectors)==1


                    m3iPPort=matchedM3iAssemblyConnectors{1}.Provider.ProvidedPort;
                else
                    m3iPPort=Simulink.metamodel.arplatform.port.ParameterSenderPort.empty;
                end
                this.M3iRToPPortDict(m3iRPort)={m3iPPort};
            end
        end
    end
end


