classdef PortInterface<handle





    methods(Static)
        function valueExpr=getIsService(obj)
            valueExpr=systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.getPropertyValue(obj,'IsService');
        end

        function valueExpr=getPackage(obj)
            valueExpr=systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.getPropertyValue(obj,'Package');
        end

        function valueExpr=getInterfaceKind(obj)
            valueExpr=systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.getPropertyValue(obj,'InterfaceKind');
        end

        function setIsService(obj,valueExpr,~)
            systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.setPropertyValue(obj,'IsService',valueExpr);
        end

        function setPackage(obj,valueExpr,~)
            systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.setPropertyValue(obj,'Package',valueExpr);
        end

        function setInterfaceKind(obj,valueExpr,~)
            systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface.setPropertyValue(obj,'InterfaceKind',valueExpr);
        end
    end

    methods(Static,Access=private)
        function valueStr=getPropertyValue(obj,propName)
            import systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface
            [platformMapping,interfaceObj]=PortInterface.getPlatformMapping(obj);
            value=platformMapping.getInterfacePlatformPropValue(interfaceObj,propName);
            valueStr=Simulink.interface.dictionary.internal.PlatformMapping.convertValueToExpression(value);
        end

        function setPropertyValue(obj,propName,valueExpr)
            import systemcomposer.internal.derivedprops.AUTOSARClassic.PortInterface
            [platformMapping,interfaceObj]=PortInterface.getPlatformMapping(obj);
            platformMapping.syncPlatformProperty(interfaceObj,{propName},{eval(valueExpr)});
        end

        function[platformMapping,interfaceObj]=getPlatformMapping(obj)
            idictImplMF0Model=mf.zero.getModel(obj);
            idictImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(idictImplMF0Model);
            assert(idictImpl.getStorageContext()==systemcomposer.architecture.model.interface.Context.DICTIONARY,...
            'AUTOSAR platform mapping can only existing in dictionary context!');
            dictName=idictImpl.getStorageSource();
            if~endsWith(dictName,'.sldd')
                dictName=[dictName,'.sldd'];
            end
            dictAPI=Simulink.interface.dictionary.open(dictName);
            interfaceObj=dictAPI.getInterface(obj.getName);
            platformMapping=dictAPI.getPlatformMapping('AUTOSARClassic');
        end
    end

end


