



classdef Event<handle
    properties(SetAccess=private)
        Name;
        EventType;
        TriggerPort;
        RunnableName;
        ReceiverCellValues={DAStudio.message('RTW:autosar:selectERstr')};
        Activation=DAStudio.message('RTW:autosar:selectERstr');
        ActivationCellValues={DAStudio.message('RTW:autosar:selectERstr')};
        ModeReceiverPort=DAStudio.message('RTW:autosar:selectERstr');
        ModeReceiverPortCellValues={DAStudio.message('RTW:autosar:selectERstr')};
        ModeDeclaration1=DAStudio.message('RTW:autosar:selectERstr');
        ModeDeclarationCellValues1={DAStudio.message('RTW:autosar:selectERstr')};
        ModeDeclaration2=DAStudio.message('RTW:autosar:selectERstr');
        ModeDeclarationCellValues2={DAStudio.message('RTW:autosar:selectERstr')};
    end

    methods
        function obj=Event(name,type,port,runnable)
            obj.Name=name;
            obj.EventType=type;
            obj.TriggerPort=port;
            obj.RunnableName=runnable;
        end

        function setName(obj,name)
            obj.Name=name;
        end

        function setTriggerPort(obj,port)
            obj.TriggerPort=port;
        end

        function setType(obj,type)
            obj.EventType=type;
        end

        function setRunnableName(obj,runnable)
            obj.RunnableName=runnable;
        end

        function setReceiverCellValues(obj,receiverCellValues)
            obj.ReceiverCellValues=receiverCellValues;
        end

        function setActivationCellValues(obj,activationCellValues)
            obj.ActivationCellValues=activationCellValues;
        end

        function setActivation(obj,activation)
            obj.Activation=activation;
        end

        function setModeReceiverPort(obj,modeReceiverPort)
            obj.ModeReceiverPort=modeReceiverPort;
        end

        function setModeReceiverPortCellValues(obj,modeReceiverPortCellValues)
            obj.ModeReceiverPortCellValues=modeReceiverPortCellValues;
        end

        function setModeDeclaration1(obj,modeDeclaration1)
            obj.ModeDeclaration1=modeDeclaration1;
        end

        function setModeDeclarationCellValues1(obj,modeDeclarationCellValues1)
            obj.ModeDeclarationCellValues1=modeDeclarationCellValues1;
        end

        function setModeDeclaration2(obj,modeDeclaration2)
            obj.ModeDeclaration2=modeDeclaration2;
        end

        function setModeDeclarationCellValues2(obj,modeDeclarationCellValues2)
            obj.ModeDeclarationCellValues2=modeDeclarationCellValues2;
        end
    end
end
