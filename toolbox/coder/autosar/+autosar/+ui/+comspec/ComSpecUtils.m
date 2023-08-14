classdef ComSpecUtils<handle




    methods(Static,Access=public)

        function m3iPort=findM3IPortByName(m3iComp,ARPortName)
            m3iPort=autosar.mm.Model.findM3IPortByName(m3iComp,ARPortName);
        end

        function m3iInfoObj=findM3IPortInfoForDataElement(m3iPort,ARDataName,isInport)


            m3iInfoObj=[];
            if m3iPort.has('info')
                m3iInfoSeq=m3iPort.info;
            elseif m3iPort.has('Info')
                m3iInfoSeq=m3iPort.Info;
            else
                return
            end

            if isInport
                infoType={'Simulink.metamodel.arplatform.port.DataReceiverPortInfo',...
                'Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo'};
            else
                infoType={'Simulink.metamodel.arplatform.port.DataSenderPortInfo',...
                'Simulink.metamodel.arplatform.port.NvDataSenderPortInfo'};
            end

            for jj=1:m3iInfoSeq.size()
                if m3iInfoSeq.at(jj).DataElements.isvalid()&&...
                    strcmp(m3iInfoSeq.at(jj).DataElements.Name,ARDataName)&&...
                    any(strcmp(m3iInfoSeq.at(jj).MetaClass.qualifiedName,infoType))
                    m3iInfoObj=m3iInfoSeq.at(jj);
                    break;
                end
            end
        end

        function m3iComSpec=getM3IComSpec(m3iComp,ARPortName,ARDataName,isInport)


            m3iComSpec=[];

            m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(...
            m3iComp,ARPortName);

            if isempty(m3iPort)
                return;
            end

            m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(...
            m3iPort,ARDataName,isInport);

            if isempty(m3iInfo)
                return;
            else
                if autosar.api.Utils.isNvPort(m3iPort)
                    m3iComSpec=m3iInfo.ComSpec;
                else
                    m3iComSpec=m3iInfo.comSpec;
                end
            end
        end

    end
end



