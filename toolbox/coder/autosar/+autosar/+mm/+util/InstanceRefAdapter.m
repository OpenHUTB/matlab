





classdef InstanceRefAdapter<handle

    methods(Static)
        function validShortIds=getValidShortIds(m3iComp,metaClassName)



            switch metaClassName
            case 'FlowDataPortInstanceRef'
                m3iPorts=M3I.SequenceOfClassObject.make(m3iComp.rootModel);
                m3iPorts.addAll(m3iComp.ReceiverPorts);
            case 'ModeDeclarationInstanceRef'
                m3iPorts=M3I.SequenceOfClassObject.make(m3iComp.rootModel);
                m3iPorts.addAll(m3iComp.ModeReceiverPorts);
                for ii=1:m3iComp.ReceiverPorts.size()
                    if~m3iComp.ReceiverPorts.at(ii).Interface.ModeGroup.isEmpty()
                        m3iPorts.append(m3iComp.ReceiverPorts.at(ii));
                    end
                end
            case 'OperationPortInstanceRef'
                m3iPorts=M3I.SequenceOfClassObject.make(m3iComp.rootModel);
                m3iPorts.addAll(m3iComp.ServerPorts);
            case 'TriggerInstanceRef'
                m3iPorts=M3I.SequenceOfClassObject.make(m3iComp.rootModel);
                m3iPorts.addAll(m3iComp.TriggerReceiverPorts);
            otherwise
                assert(false,'Do not know how to form a short id for %s',metaClassName);
            end

            validShortIds=m3i.mapcell(@(x)autosar.mm.util.InstanceRefAdapter.getValidPortInstanceRefShortIds(x),m3iPorts);
            validShortIds=[validShortIds{:}];
        end

    end

    methods(Static,Access=private)

        function validShortIds=getValidPortInstanceRefShortIds(m3iPort)



            arg1=m3iPort.Name;

            switch m3iPort.Interface.MetaClass
            case Simulink.metamodel.arplatform.interface.ModeSwitchInterface.MetaClass
                if isempty(m3iPort.Interface.ModeGroup)||~m3iPort.Interface.ModeGroup.isvalid()
                    DAStudio.error('autosarstandard:api:mmInvalidModeGroup',...
                    autosar.api.Utils.getQualifiedName(m3iPort.Interface));
                end
                if isempty(m3iPort.Interface.ModeGroup.ModeGroup)||~m3iPort.Interface.ModeGroup.ModeGroup.isvalid()
                    DAStudio.error('autosarstandard:api:mmInvalidModeDeclarationGroup',...
                    autosar.api.Utils.getQualifiedName(m3iPort.Interface.ModeGroup));
                end
                m3iObjSeq=m3iPort.Interface.ModeGroup.ModeGroup.Mode;
            case Simulink.metamodel.arplatform.interface.SenderReceiverInterface.MetaClass
                if~m3iPort.Interface.ModeGroup.isEmpty()
                    m3iObjSeq=m3iPort.Interface.ModeGroup;
                else
                    m3iObjSeq=m3iPort.Interface.DataElements;
                end
            case Simulink.metamodel.arplatform.interface.ClientServerInterface.MetaClass
                m3iObjSeq=m3iPort.Interface.Operations;
            case Simulink.metamodel.arplatform.interface.TriggerInterface.MetaClass
                m3iObjSeq=m3iPort.Interface.Triggers;
            otherwise
                assert(false,'Do not know how to form short id for %s',m3iPort.Interface.MetaClass.name);
            end

            validShortIds=cellfun(@(arg2)[arg1,'.',arg2],m3i.mapcell(@(m3iObj)m3iObj.Name,m3iObjSeq),'UniformOutput',false);
        end

    end
end


