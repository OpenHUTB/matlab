classdef Mapping<handle




    methods(Static,Access=public)
        function portMapping=getPortMapping(modelName,functionSignature,isClient)


            import autosar.simulink.functionPorts.Mapping;
            portMapping=[];
            [portName,methodName]=...
            Mapping.getPortAndMethodFromSignature(functionSignature);
            fcnPortH=Mapping.getFunctionPort(modelName,portName,methodName);

            if isempty(fcnPortH)

                return;
            else
                fcnPortH=fcnPortH{1};
            end

            modelMapping=autosar.api.Utils.modelMapping(modelName);
            if isClient
                mappedBlocks='ClientPorts';
            else
                mappedBlocks='ServerPorts';
            end
            portMapping=modelMapping.(mappedBlocks).findobj('Block',getfullname(fcnPortH));
        end
    end

    methods(Static,Access=private)
        function fcnPortH=getFunctionPort(modelName,portName,methodName)

            fcnPortH=find_system(modelName,'SearchDepth',1,...
            'IsComposite','on',...
            'IsClientServer','on','PortName',portName,...
            'Element',methodName);
        end

        function[portName,methodName]=getPortAndMethodFromSignature(functionSignature)


            pat='(?<PortName>\w+)\.(?<MethodName>\w+)';
            names=regexp(functionSignature,pat,'names');
            if~isempty(names)
                portName=names.PortName;
                methodName=names.MethodName;
            else
                DAStudio.error('autosarstandard:api:InvalidCSPortSignature',functionSignature);
            end
        end
    end
end


