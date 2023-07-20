classdef slidProxy<handle




    properties(Access=private)
        mSlidObj;
        mParentObj;
        mSrcObj;
        mSlidDAObj;
    end

    properties(Access=public)
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=slidProxy(slidObj,srcObj,parentObj)
            thisObj.init(slidObj,srcObj);
            thisObj.mParentObj=parentObj;
        end

        function init(thisObj,slidObj,srcObj)
            thisObj.mSlidObj=slidObj;
            thisObj.mSlidDAObj=Simulink.SlidDAProxy(thisObj.mSlidObj);
            thisObj.mSrcObj=srcObj;
        end

        function hasActions=hasPropertyActions(thisObj,propName)
            hasActions=isequal(propName,'Value');
        end

        function label=getDisplayLabel(thisObj)
            label=thisObj.mSlidObj.Name;
        end

        function icon=getDisplayIcon(thisObj)
            icon=thisObj.getDefaultIcon();
            if thisObj.mParentObj.isValueOverridden(thisObj.mSlidObj)
                iconsep='/';
                delims=strfind(icon,iconsep);
                pos=delims(length(delims));
                icon=insertBefore(icon,pos,[iconsep,'override']);
            end
        end

        function icon=getDefaultIcon(thisObj)
            if isobject(thisObj.mSrcObj)
                try
                    icon=thisObj.mSrcObj.getDisplayIcon();
                catch ME
                    icon='';
                end
            else
                icon='toolbox/shared/dastudio/resources/MatlabArray.png';
            end
        end

        function valid=isValidProperty(thisObj,propName)
            if isobject(thisObj.mSrcObj)
                props=properties(thisObj.mSrcObj);
            else
                props=properties(thisObj.mSlidObj);
            end
            valid=any(ismember(props,propName));
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            readonly=true;
        end

        function datatype=getPropDataType(thisObj,propName)
            datatype='string';
        end

        function prop=getPropValue(thisObj,propName)
            preErrorCheckingFlag=thisObj.mParentObj.getValueSrcErrorChecking();




            try
                if isequal(propName,'Value')
                    thisObj.mParentObj.setValueSrcErrorChecking(false);
                    prop=thisObj.mSlidDAObj.getPropValue(propName);
                    thisObj.mParentObj.setValueSrcErrorChecking(preErrorCheckingFlag);
                elseif isobject(thisObj.mSrcObj)
                    prop=thisObj.mSrcObj.(propName);
                    if~ischar(prop)
                        prop=DAStudio.MxStringConversion.convertToString(prop);
                    end
                else
                    prop=thisObj.getMxPropValue(propName);
                end
            catch
                thisObj.mParentObj.setValueSrcErrorChecking(preErrorCheckingFlag);
                prop='';
            end
        end

        function getPropertyStyle(thisObj,propName,objStyle)
            if thisObj.mParentObj.isValueOverridden(thisObj.mSlidObj)
                objStyle.Tooltip=thisObj.mParentObj.getOverriddenTooltip(thisObj,thisObj.mSlidObj,propName);
                if isequal(propName,'Value')
                    objStyle.Italic=true;
                end
            end

        end

        function prop=getValue(thisObj)
            try
                if isobject(thisObj.mSrcObj)
                    prop=thisObj.mSrcObj.Value;
                else
                    prop=thisObj.getMxPropValue('_Value');
                end
            catch
                prop=[];
            end
        end

        function setValue(thisObj,value)
            if isobject(thisObj.mSrcObj)
                thisObj.mSrcObj.Value=value;
            else
                thisObj.mSrcObj=value;
            end
        end

        function varObj=getVariable(thisObj)
            varObj=thisObj.mSrcObj;
        end

        function setPropValue(thisObj,propName,value)
            try
                if isobject(thisObj.mSrcObj)
                    thisObj.mSrcObj.(propName)=eval(value);
                elseif isequal(propName,'Value')
                    thisObj.mSrcObj=eval(value);
                end
                thisObj.mParentObj.applyChanges(thisObj.mSlidObj.Name,thisObj.mSrcObj);
            catch
            end
        end

        function uuid=getUUID(thisObj)
            uuid=thisObj.mSlidObj.UUID;
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            objectLevel=Simulink.data.getScalarObjectLevel(thisObj.mSrcObj);
            if(objectLevel==0)
                dlgStruct=da_mxarray_get_schema(thisObj);
                for i=1:numel(dlgStruct.Items)
                    if isfield(dlgStruct.Items{i},'ObjectProperty')&&...
                        isequal(dlgStruct.Items{i}.ObjectProperty,'Value')
                        dlgStruct.Items{i}.Source=thisObj;
                        break;
                    end
                end
            else
                dlgStruct=sl_get_dialog_schema(thisObj.mSrcObj,thisObj.mSlidObj.Name);
            end
            dlgStruct.DisableDialog=true;
            dlgStruct.EmbeddedButtonSet={'Apply','Revert','Help'};
        end

        function slidProxy=getSlidViewProxy(thisObj)
            slidProxy=thisObj;
        end

        function postApply(thisObj)
            thisObj.mParentObj.applyChanges(thisObj.mSlidObj.Name,thisObj.mSrcObj);
        end
    end


    methods(Access=private)
        function propValue=getMxPropValue(thisObj,propName)
            switch propName
            case 'DataType'
                propValue=class(thisObj.mSrcObj);
            case 'Value'
                propValue=DAStudio.MxStringConversion.convertToString(thisObj.mSrcObj);
            case '_Value'
                propValue=thisObj.mSrcObj;
            case 'Dimensions'
                tempVal=size(thisObj.mSrcObj);
                propValue=strcat('[',strcat(num2str(tempVal),']'));
            case 'Complexity'
                if(isnumeric(thisObj.mSrcObj))
                    if(isreal(thisObj.mSrcObj))
                        propValue='real';
                    else
                        propValue='complex';
                    end
                else
                    propValue='N/A';
                end
            otherwise
                propValue=DAStudio.MxStringConversion.convertToString(thisObj.mSlidObj.(propName));
            end
        end

    end

end