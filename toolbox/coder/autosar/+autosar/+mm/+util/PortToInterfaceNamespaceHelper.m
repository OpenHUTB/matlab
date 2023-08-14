classdef PortToInterfaceNamespaceHelper<handle





    methods(Static,Access=public)
        function portNameVec=getMappedARServicePortNames(modelH)
            modelMapping=autosar.api.Utils.modelMapping(modelH);
            assert(isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping'),...
            'Expected adaptive mapping');
            mappedPorts=[modelMapping.Inports.MappedTo,modelMapping.Outports.MappedTo];

            portNameVec=arrayfun(@(x)x.Port,mappedPorts,'UniformOutput',false);

            fcnPorts=find_system(modelH,'SearchDepth',1,...
            'IsComposite','on',...
            'IsClientServer','on');
            fcnPortNames=get_param(fcnPorts,'PortName');
            if~iscell(fcnPortNames)
                fcnPortNames={fcnPortNames};
            end
            portNameVec=[portNameVec,fcnPortNames'];

            portNameVec=unique(portNameVec);
        end

        function[interfaceNameVec,namespaceVec]=getInterfaceNamesAndNamespacesForPortNames(modelH,portNameVec)

            interfaceNameVec=cell(length(portNameVec),1);
            namespaceVec=cell(length(portNameVec),1);
            delim='::';
            compObj=autosar.api.Utils.m3iMappedComponent(modelH);
            modelName=get_param(modelH,'Name');
            componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelName);
            for portIdx=1:length(portNameVec)

                curPortName=portNameVec{portIdx};
                m3iPort=autosar.mm.Model.findChildByName(compObj,curPortName);
                if isempty(m3iPort)



                    busPortBlockH=find_system(modelName,'SearchDepth',1,...
                    'IsComposite','on','PortName',curPortName);
                    assert(length(busPortBlockH)>=1,'Expected to find bus port')
                    interfaceNameVec{portIdx}=...
                    componentAdapter.getAutosarInterfaceName(busPortBlockH{1});
                    namespaceVec{portIdx}='';
                    continue;
                end

                m3iInterface=m3iPort.Interface;
                interfaceNameVec{portIdx}=m3iInterface.Name;

                if~m3iInterface.Namespaces.isEmpty()

                    for jj=m3iInterface.Namespaces.size:-1:1
                        namespace{jj}=m3iInterface.Namespaces.at(jj).Symbol;
                    end
                    namespaceVec{portIdx}=strjoin(namespace,delim);
                else
                    namespaceVec{portIdx}='';
                end
            end
        end
    end
end


