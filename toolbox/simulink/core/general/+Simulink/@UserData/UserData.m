classdef(Abstract)UserData<Simulink.data.HasPropertyType&matlab.mixin.Copyable&matlab.io.savevars.internal.Serializable




    methods
        function propValue=getPropValue(thisObj,propName)
            propValue=DAStudio.Protocol.getPropValue(thisObj,propName);
        end
        function setPropValue(thisObj,propName,propValue)
            DAStudio.Protocol.setPropValue(thisObj,propName,propValue);
        end
        function dlgstruct=getDialogSchema(thisObj,name)
            dlgstruct=get_object_default_ddg(thisObj,name,thisObj);
        end
    end
end
