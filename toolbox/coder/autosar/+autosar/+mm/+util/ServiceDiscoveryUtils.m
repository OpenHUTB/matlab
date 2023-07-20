classdef ServiceDiscoveryUtils



    properties(Constant,Access=private)
        AllowedValues={autosar.mm.util.ServiceDiscoveryEnum.OneTime.char();...
        autosar.mm.util.ServiceDiscoveryEnum.DynamicDiscovery.char()};
    end

    methods(Static,Access=public)
        function setServiceDiscoveryModeForUI(mdlName,m3iPort,dlg,widgetTag)

            idx=dlg.getWidgetValue(widgetTag);
            serviceDiscoveryMode=autosar.mm.util.ServiceDiscoveryUtils.AllowedValues{idx+1};
            apiObj=autosar.api.getAUTOSARProperties(mdlName);
            apiObj.set(autosar.api.Utils.getQualifiedName(m3iPort),'ServiceDiscoveryMode',serviceDiscoveryMode);
            dlg.clearWidgetDirtyFlag(widgetTag);
        end

        function validateServiceDiscoveryMode(propValue)


            import autosar.mm.util.ServiceDiscoveryUtils;
            if~any(strcmp(propValue,ServiceDiscoveryUtils.AllowedValues))
                allowedValueStr=ServiceDiscoveryUtils.cell2str(...
                ServiceDiscoveryUtils.AllowedValues);
                DAStudio.error('RTW:autosar:apiInvalidPropertyValue',...
                propValue,'ServiceDiscoveryMode',...
                allowedValueStr);
            end
        end

        function modeVec=getServiceDiscoveryModeForPortVec(modelH,portNameVec)


            modeVec=cell(length(portNameVec),1);
            apiObj=autosar.api.getAUTOSARProperties(modelH);
            for portIdx=1:length(portNameVec)
                m3iModel=autosar.api.Utils.m3iModel(modelH);
                portPath=apiObj.find([],'Port','Name',portNameVec{portIdx});
                if isempty(portPath)


                    modeVec{portIdx}=autosar.mm.util.ServiceDiscoveryUtils.AllowedValues{1};
                else
                    m3iPort=autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath(m3iModel,portPath{1});
                    if isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceRequiredPort')
                        modeVec{portIdx}=apiObj.get(portPath{1},...
                        'ServiceDiscoveryMode');
                    else

                        modeVec{portIdx}='';
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function str=cell2str(cellArray)

            str='';
            sep='';
            for ii=1:length(cellArray)
                str=sprintf('%s%s''%s''',str,sep,cellArray{ii});
                sep=', ';
            end
            str=sprintf('%s',str);
        end

    end
end


