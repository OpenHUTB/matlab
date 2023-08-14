classdef OutportExporter<Simulink.sdi.internal.export.SignalExporter




    methods

        function ret=getDomainType(~)
            ret='outport';
        end


        function ret=exportElement(this,ret,dataStruct)
            ret=exportElement@Simulink.sdi.internal.export.SignalExporter(...
            this,ret,dataStruct);
            ret.PortType='inport';
        end

    end

end
