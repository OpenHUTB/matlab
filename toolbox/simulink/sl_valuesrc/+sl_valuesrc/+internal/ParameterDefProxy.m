classdef ParameterDefProxy<handle



    properties(Access=private)
        mPrmDefObj;
        mValGrpObj;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ParameterDefProxy(prmDefObj,valGrpObj)
            thisObj.mPrmDefObj=prmDefObj;
            thisObj.mValGrpObj=valGrpObj;
        end

        function label=getDisplayLabel(thisObj)
            label=thisObj.mPrmDefObj.getDisplayLabel();
        end

        function icon=getDisplayIcon(thisObj)
            if thisObj.mValGrpObj.isParameterInGroup(thisObj.mPrmDefObj.getUUID())
                icon='toolbox/simulink/sl_valuesrc/+sl_valuesrc/valuesrcPlugin/resources/icons/Grouped_16.png';
            else
                icon=thisObj.mPrmDefObj.getDisplayIcon();
            end
        end

        function getPropertyStyle(thisObj,propName,propertyStyle)
            if isempty(propName)||isequal(propName,'Name')&&...
                thisObj.mValGrpObj.isParameterInGroup(thisObj.mPrmDefObj.getUUID())
                propertyStyle.Italic=true;
                propertyStyle.ForegroundColor=[.5,.5,.5];
            end
        end

        function valid=isValidProperty(thisObj,propName)
            valid=thisObj.mPrmDefObj.isValidProperty(propName);
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=thisObj.mPrmDefObj.isReadonlyProperty(propName);
        end

        function datatype=getPropDataType(thisObj,propName)
            datatype=thisObj.mPrmDefObj.getPropDataType(propName);
        end

        function prop=getPropValue(thisObj,propName)
            prop=thisObj.mPrmDefObj.getPropValue(propName);
        end

        function setPropValue(thisObj,propName,value)
            thisObj.mPrmDefObj.setPropValue(propName,value);
        end

        function uuid=getUUID(thisObj)
            uuid=thisObj.mPrmDefObj.getUUID();
        end

    end


    methods(Access=private)
    end

end