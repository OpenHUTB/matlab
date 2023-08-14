classdef ValueEntry<handle







    properties(Access=protected)
        mSrcObj;
        mDefinitionsObj;
        mControllerObj;
        mParentObj;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ValueEntry(srcObj,defObj,controllerObj,parentObj)
            thisObj.mSrcObj=srcObj;
            thisObj.mDefinitionsObj=defObj;
            thisObj.mControllerObj=controllerObj;
            thisObj.mParentObj=parentObj;
        end

        function label=getDisplayLabel(thisObj)
            label=thisObj.mSrcObj.getName();
        end

        function icon=getDisplayIcon(thisObj)
            obj=thisObj.mDefinitionsObj.getDefinitionObj(thisObj.mSrcObj.getName());
            icon=obj.getDefaultIcon();

        end

        function valid=isValidProperty(thisObj,propName)
            valid=thisObj.mControllerObj.isValidProperty(propName);
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=true;
        end

        function datatype=getPropDataType(thisObj,propName)
            datatype='string';
        end

        function propVal=getPropValue(thisObj,propName)
            switch propName
            case 'Name'
                propVal=thisObj.mSrcObj.getName();
            otherwise
                propVal='';
            end
        end

        function getPropertyStyle(thisObj,propName,propertyStyle)
            try
                if isequal(propName,'Overlay')
                    overlay=thisObj.mSrcObj.getEffectiveOverlayThrowError();
                    if~isempty(overlay)
                        filename=overlay.getSource();
                        [path,name,ext]=fileparts(filename);
                        filedisp=['(',name,ext,')'];
                        propertyStyle.WidgetInfo=struct('Type','label','Text',filedisp,'Location','right');
                    end
                end
                if isequal(propName,'Overlay')||isequal(propName,'Effective Value')
                    if~isempty(thisObj.mParentObj)&&~(thisObj.mParentObj.getActive())
                        propertyStyle.ForegroundColor=[.5,.5,.5];
                    end
                end
            catch
            end
        end

        function setPropValue(thisObj,propName,value)
            if isequal(propName,'Default Value')
                thisObj.mSrcObj.setValue(value);
            end
        end


        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct=[];
            obj=thisObj.mControllerObj.getForwardedObject(thisObj.mSrcObj);
            if~isempty(obj)
                try
                    dlgStruct=obj.getDialogSchema(arg1);
                catch ME

                end
            end
        end

    end


    methods(Access=private)

        function propVal=getDefaultValue(thisObj)
            obj=thisObj.mDefinitionsObj.getDefinitionObj(thisObj.mSrcObj.getName());
            propVal=obj.getValue();

            if~ischar(propVal)
                propVal=DAStudio.MxStringConversion.convertToString(propVal);
            end
        end

    end

end