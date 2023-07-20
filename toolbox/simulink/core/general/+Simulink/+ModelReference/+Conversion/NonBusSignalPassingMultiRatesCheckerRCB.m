classdef NonBusSignalPassingMultiRatesCheckerRCB<Simulink.ModelReference.Conversion.NonBusSignalPassingMultiRatesChecker



    methods(Access=protected)
        function checkImpl(this)
            ph=get_param(this.currentSubsystem,'PortHandles');
            ports=[ph.Inport,ph.Outport];
            for idx=1:numel(ports)
                port=ports(idx);
                isInport=strcmp(get_param(port,'PortType'),'inport');
                msg='';
                if isInport
                    bus=get_param(port,'CompiledBusStruct');
                    if isempty(bus)&&coder.internal.SampleTimeChecks.LocalHasMixedSampleTimeSrc(port)
                        msg=message('RTW:buildProcess:InputPortMixedSampleTime',...
                        idx,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(this.currentSubsystem),this.currentSubsystem));
                    end
                else
                    outPortH=coder.internal.slBus('LocalGetBlockForPortPrm',port,'PortHandles');
                    bus=get_param(outPortH.Inport,'CompiledBusStruct');
                    if isempty(bus)&&coder.internal.SampleTimeChecks.LocalHasMixedSampleTimeSrc(outPortH.Inport)
                        msg=message('RTW:buildProcess:OutputPortMixedSampleTime',...
                        idx,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(this.currentSubsystem),this.currentSubsystem));
                    end
                end
                if~isempty(msg)
                    this.handleDiagnostic(msg);
                end
            end
        end
    end

    methods(Access=public)
        function this=NonBusSignalPassingMultiRatesCheckerRCB(ConversionData,currentSubsystem)
            this@Simulink.ModelReference.Conversion.NonBusSignalPassingMultiRatesChecker(ConversionData,currentSubsystem);
        end
    end
end
