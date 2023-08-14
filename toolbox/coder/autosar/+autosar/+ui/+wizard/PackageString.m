




classdef PackageString
    properties(Constant)
        Title=DAStudio.message('autosarstandard:ui:uiWizardTitle');
        InterfacesTitle=DAStudio.message('autosarstandard:ui:uiWizardInterfaces');
        PortsTitle=DAStudio.message('autosarstandard:ui:uiWizardPortsTitle');
        DefaultComponentType='Application';
        DefaultInterfaceFormatCtl='Interface$M';
        DefaultDataElementFormatCtl='DataElement$M';
        DefaultPortFormatCtl='Port$M';
        DefaultPort1='sr_Port';
        DefaultPort2='sr_Port1';
        DefaultPort3='cs_Port';
        DefaultPort4='sr_Port2';
        DefaultInterface='sr_Interface';
        DefaultCSInterface='cs_Interface';
        DefaultNVInterface='nv_Interface';
        DefaultTriggerInterface='trigger_Interface';
        InterfaceTypes={'Application software','Basic software'};
        ComponentTypes=[autosar.composition.Utils.getSupportedComponentKinds(),{'Adaptive'}];
        PortTypes={'Sender','Receiver','ModeReceiver','Server',...
        'SenderReceiver','Client','NvReceiver',...
        'NvSender','NvSenderReceiver',...
        'ParameterReceiverPort','ModeSender',...
        'TriggerReceiver','Provided','Required',...
        'PersistencyProvidedPort','PersistencyRequiredPort',...
        'PersistencyProvidedRequiredPort'};
        InterfaceMulDeleteError=DAStudio.message('autosarstandard:ui:uiWizardInterfaceMulDeleteErr');
        PortMulDeleteError=DAStudio.message('autosarstandard:ui:uiWizardPortMulDeleteErr');
        InvalidIndexError=DAStudio.message('autosarstandard:ui:uiWizardInvalidIndexErr');
        DefaultDataAccessInport='ImplicitReceive';
        DefaultDataAccessOutport='ImplicitSend';
        DefaultDataAccessMSInport='ModeReceive';
        DefaultDataAccessMSOutport='ModeSend';
        DefaultQueuedDataAccessInport='QueuedExplicitReceive';
        DefaultQueuedDataAccessOutport='QueuedExplicitSend';
        DefaultSignalInvalidationDataAccess='ExplicitSend';
        DefaultAllocateMemory='false';
        SenderPorts='SenderPorts';
        ReceiverPorts='ReceiverPorts';
        SenderReceiverPorts='SenderReceiverPorts';
        ModeReceiverPorts='ModeReceiverPorts';
        ModeSenderPorts='ModeSenderPorts';
        ServerPorts='ServerPorts';
        ClientPorts='ClientPorts';
        NvSenderPorts='NvSenderPorts';
        NvReceiverPorts='NvReceiverPorts';
        NvSenderReceiverPorts='NvSenderReceiverPorts';
        ParameterReceiverPorts='ParameterReceiverPorts';
        TriggerReceiverPorts='TriggerReceiverPorts';
        DataElements='DataElements';
        Triggers='Triggers';
        NewName='New';
        DataElementNewName='DataElement';
        NvDataNewName='NvData';
        OperationNewName='Operation';
        MethodNewName='Method';
        TriggersNewName='Trigger';
        FieldNewName='Field';
        EventNewName='Event';
        RemoveInterfaceError=DAStudio.message('autosarstandard:ui:uiWizardRemoveInterfaceErr');
        RemoveInterfaceDlgTitle=DAStudio.message('autosarstandard:ui:uiWizardRemoveInterfaceTitle');
        InterfaceToolTip=' Interface';
        PortToolTip=' Port';
        DefaultMetamodelName='AUTOSAR';
        EventPrefix='Event_';
        DefaultIRVName='IRV';
        DefaultEventName='Event';
        EventTypes={'TimingEvent','DataReceivedEvent',...
        'ModeSwitchEvent','OperationInvokedEvent',...
        'InitEvent','DataReceiveErrorEvent',...
        'ExternalTriggerOccurredEvent'};
        TransitionTypes={'OnEntry','OnExit','OnTransition'};
        EventTableTitle='Events';
        FcnCallSuffix='_client';

        ReceiverPortsStr='Receiver Ports';
        SenderPortsStr='Sender Ports';
        SenderReceiverPortsStr='Sender Receiver Ports';
        NvReceiverPortsStr='Nonvolatile Receiver Ports';
        NvSenderPortsStr='Nonvolatile Sender Ports';
        NvSenderReceiverPortsStr='Nonvolatile Sender Receiver Ports';
        ClientPortsStr='Client Ports';
        ServerPortsStr='Server Ports';
        DefaultServiceInterface='service_interface';
        DefaultPersistencyKeyValueInterface='persistency_key_value_interface';
        DefaultServicePort1='service_port';
        DefaultServicePort2='service_port1';
        DefaultPersistencyPort1='persistency_port';
        DefaultPersistencyPort2='persistency_port1';
        DefaultPersistencyPort3='persistency_port2';
    end
end


