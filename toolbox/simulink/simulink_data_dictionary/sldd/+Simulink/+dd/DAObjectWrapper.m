classdef DAObjectWrapper<handle



    properties(SetAccess=private)
m_objectToWrap
    end
    methods
        function thisObj=DAObjectWrapper(objectToWrap)
            thisObj.m_objectToWrap=objectToWrap;
        end
        function delete(thisObj)

        end
        function displayLabel=getDisplayLabel(thisObj)
            displayLabel='Default display label';
        end
        function forwardedObject=getForwardedObject(thisObj)
            forwardedObject=thisObj.m_objectToWrap;
        end
        function isValid=isValidProperty(thisObj,propName)
            isValid=DAStudio.Protocol.isValidProperty(thisObj.m_objectToWrap,propName);
        end
        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=DAStudio.Protocol.isReadonlyProperty(thisObj.m_objectToWrap,propName);
        end
        function propDataType=getPropDataType(thisObj,propName)
            propDataType=DAStudio.Protocol.getPropDataType(thisObj.m_objectToWrap,propName);
        end
        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues=DAStudio.Protocol.getPropAllowedValues(thisObj.m_objectToWrap,propName);
        end
        function setPropValue(thisObj,propName,propValue)
            DAStudio.Protocol.setPropValue(thisObj.m_objectToWrap,propName,propValue);
        end
        function propValue=getPropValue(thisObj,propName)

            propValue=DAStudio.Protocol.getPropValue(thisObj.m_objectToWrap,propName);
        end
        function propertyNames=getPossibleProperties(thisObj)
            props=Simulink.data.getPropList(thisObj.m_objectToWrap,...
            'GetAccess','public');
            propertyNames=cell(length(props),1);
            outIndex=1;
            for i=1:length(props)
                if sldialogs('ddg_is_property_visible',thisObj.m_objectToWrap,props(i))
                    propertyNames{i}=props(outIndex).Name;
                    outIndex=outIndex+1;
                else
                    propertyNames(outIndex)=[];
                end
            end
        end
        function dlgstruct=getDialogSchema(thisObj,name)
            dlgstruct=get_object_default_ddg(...
            thisObj.m_objectToWrap,name,thisObj.m_objectToWrap);
        end

    end

end
