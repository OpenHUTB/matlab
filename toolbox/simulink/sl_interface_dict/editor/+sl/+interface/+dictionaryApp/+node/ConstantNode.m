classdef ConstantNode<sl.interface.dictionaryApp.node.DesignNode




    properties(Constant,Access=protected)

        PropertiesToHide cell={};
        GenericPropertyNames cell=...
        {sl.interface.dictionaryApp.node.PackageString.NameProp};
        TypePropName='';
    end

    methods(Access=protected)

        function propertyNames=getPlatformProperties(~)

            propertyNames={};
        end
    end

    methods(Access=public)
        function dataType=getPropDataType(~,propName)
            if strcmp(propName,...
                sl.interface.dictionaryApp.node.PackageString.DataTypeProp)
                dataType='enum';
            else
                dataType='string';
            end
        end

        function entries=getPropAllowedValues(this,propName)
            if strcmp(propName,...
                sl.interface.dictionaryApp.node.PackageString.DataTypeProp)

                dtaItems=[];
                dtaItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
                dtaItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
                dtaItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('Parameter');
                dtaItems.supportsEnumType=true;
                dtaItems.supportsBusType=true;
                entries=Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dtaItems,this.InterfaceDictElement);
            else
                entries=getPropAllowedValues@sl.interface.dictionaryApp.node.DesignNode(this,propName);
            end
        end

        function propVal=getPropValue(this,propName)
            propVal=this.InterfaceDictElement.get(propName);
            if strcmp(propName,'Value')

                propVal=num2str(propVal);
            end
        end

        function setPropValue(this,propName,propVal)
            if strcmp(propName,'Value')

                propVal=eval(propVal);
            end
            this.InterfaceDictElement.set(propName,propVal);
        end

        function nodeType=getNodeType(this)%#ok
            nodeType='Constant';
        end

        function isValid=isValid(this)

            isValid=this.InterfaceDictElement.isvalid;
        end
    end

    methods(Access=protected)
        function customizeDialogSchema(~,~)

        end
    end
end


