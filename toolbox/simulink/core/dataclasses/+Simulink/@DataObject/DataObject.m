classdef(Abstract)DataObject<dynamicprops&hgsetget&JavaVisible&matlab.mixin.Copyable&Simulink.data.DDGInterface&Simulink.data.HasPropertyType&matlab.io.savevars.internal.Serializable&handle














    methods(Access=protected)

        function retVal=copyElement(obj)


            retVal=copyElement@matlab.mixin.Copyable(obj);






            retVal.Description=obj.Description;
            retVal.Min=obj.Min;
            retVal.Max=obj.Max;
            retVal.DocUnits=obj.DocUnits;


            if slfeature('SLDataDictionarySetUserData')>0&&...
                isprop(obj,'TargetUserData')&&...
                ~isempty(obj.TargetUserData)
                cpTUD=copy(obj.TargetUserData);
                Simulink.dd.private.setTargetUserData(retVal,cpTUD);
            end

        end
    end


    methods
        function retVal=set(obj,varargin)





            if(nargin>2)

                set@hgsetget(obj,varargin{:});
                if(nargout>0)
                    DAStudio.error('MATLAB:unassignedOutputsTextSimple','set');
                end
            else
                retVal=set@hgsetget(obj,varargin{:});
            end

            switch nargin
            case 2


                propName=varargin{1};
                allowedValues=getPropAllowedValues(obj,propName);
                if~isempty(allowedValues)
                    retVal=allowedValues;
                end
            case 1


                fields=fieldnames(retVal);
                for idx=1:length(fields)
                    propName=fields{idx};
                    retVal.(propName)=set(obj,propName);
                end
            otherwise


            end
        end

        function clone(obj,cloneName)
            assert(isscalar(obj));

            origObj=[];
            try
                origObj=evalin('caller',cloneName);
            catch
            end

            if obj.CoderInfo.HasContext
                objCopy=slprivate('copyHelper',obj);
                assignin('caller',cloneName,objCopy);
                copyValue=evalin('caller',cloneName);
                if obj.CoderInfo.isContextEqual(copyValue.CoderInfo)
                    obj.CoderInfo.copyCodeMappingProperties(cloneName);
                else

                    if isempty(origObj)
                        evalin('caller',['clear ',cloneName]);
                    else
                        assignin('caller',cloneName,origObj);
                    end
                    DAStudio.error('Simulink:Data:InvalidCloneOfMWSObject');
                end
            else
                copyObj=copy(obj);
                assignin('caller',cloneName,copyObj);
            end
        end
    end

    methods(Hidden)

        function retVal=getPossibleProperties(obj)
            retVal=getPossibleProperties@Simulink.data.HasPropertyType(obj);

            retVal(strcmp(retVal,'CoderInfo'))=[];
        end


        function retVal=isValidProperty(obj,propName,varargin)
            if l_isStoredIntProperty(propName)
                if isempty(l_getDataTypeObjIfFixpt(obj,varargin{:}))
                    retVal=false;
                else
                    retVal=true;
                end
            elseif(strcmp(propName,'CoderInfo'))
                retVal=false;
            else
                retVal=isValidProperty@Simulink.data.HasPropertyType(obj,propName);
            end
        end


        function retVal=isReadonlyProperty(obj,propName)
            if l_isStoredIntProperty(propName)
                retVal=false;
            else
                retVal=isReadonlyProperty@Simulink.data.HasPropertyType(obj,propName);
            end
        end


        function retVal=hasPropertyActions(obj,propName,contextObj)
            retVal=hasPropertyActions@Simulink.data.HasPropertyType(obj,propName,contextObj);
        end


        function retVal=getPropertyActions(obj,propName,propVal)
            retVal=getPropertyActions@Simulink.data.HasPropertyType(obj,propName,propVal);
        end


        function retVal=getPropValue(obj,propName,varargin)
            if l_isStoredIntProperty(propName)
                retVal=l_convertRealWorldToStoredIntegerValue(obj,propName,varargin{:});
            else

                retVal=getPropValue@Simulink.data.DDGInterface(obj,propName);
            end
        end


        function setPropValue(obj,propName,propVal,varargin)



            propName=handleHeaderFileProperty(obj,propName);

            if l_isStoredIntProperty(propName)
                propVal=l_convertStoredIntegerToRealWorldValue(obj,propVal,varargin{:});
                propName=extractAfter(propName,'StoredInt');
            end


            if(strncmp(propName,'CoderInfo.',10))
                setPropValue(obj.CoderInfo,propName(11:end),propVal);
            elseif(strncmp(propName,'RTWInfo.',8))
                setPropValue(obj.RTWInfo,propName(9:end),propVal);
            elseif(strncmp(propName,'LoggingInfo.',12))
                setPropValue(obj.LoggingInfo,propName(13:end),propVal);
            else

                setPropValue@Simulink.data.HasPropertyType(obj,propName,propVal,varargin{:});
            end
        end


        function retVal=getPropDataType(obj,propName)
            if l_isStoredIntProperty(propName)
                retVal='int64';
            else
                retVal=getPropDataType@Simulink.data.HasPropertyType(obj,propName);
            end
        end


        function retVal=getPropAllowedValues(obj,propName)
            retVal=getPropAllowedValues@Simulink.data.HasPropertyType(obj,propName);
        end



        function retVal=convertFrom(obj,oldObj)

















            retVal=obj;
            Simulink.data.copyProps(oldObj,retVal);
        end

    end


    methods(Hidden,Access=protected)

        function checkCSCPackageName(obj,pkgName)



            hClass=metaclass(obj);


            if(hClass<=?Simulink.Parameter)
                hDataClass=?Simulink.Parameter;
            elseif(hClass<=?Simulink.Signal)
                hDataClass=?Simulink.Signal;
            else
                DAStudio.error('Simulink:Data:InputIsNotADataObject');
            end
            if~l_isDerivedFromDataClassInPackage(hClass,hDataClass,pkgName)
                DAStudio.error('Simulink:Data:InvalidCSCPackageName',pkgName,class(obj));
            end
        end

    end


    methods(Hidden,Access=private)

        function propName=handleHeaderFileProperty(obj,propName)

            if(strcmp(propName,'HeaderFile')&&isempty(findprop(obj,'HeaderFile')))


                propName='CoderInfo.CustomAttributes.HeaderFile';
                assert(isValidProperty(obj,propName));
            end
        end
    end


    methods(Static,Hidden)

        function writeContentsForSaveVars(obj,vs)



            if slfeature('AutoMigrationIM')==0||obj.HasCoderInfo
                vs.writePropertyContents('CoderInfo',obj.CoderInfo);
            else
                vs.writeProperty('HasCoderInfo',obj.HasCoderInfo);
            end
            vs.writeProperty('Description',obj.Description);
            vs.writeProperty('DataType',obj.DataType);
            vs.writeProperty('Min',obj.Min);
            vs.writeProperty('Max',obj.Max);
            vs.writeProperty('DocUnits',obj.DocUnits);



            if slfeature('SLDataDictionarySetUserData')>0&&...
                isprop(obj,'TargetUserData')&&...
                ~isempty(obj.TargetUserData)
                vs.writeProperty('TargetUserData',obj.TargetUserData);
            end
        end

    end


    methods(Sealed)

        function retVal=isequal(obj1,obj2)

            retVal=builtin('isequal',obj1,obj2);
        end

        function retVal=isequaln(obj1,obj2)

            retVal=builtin('isequaln',obj1,obj2);
        end
    end


    methods(Sealed,Hidden)

        function clearTargetUserData(obj)



            Simulink.dd.private.setTargetUserData(obj,[]);
        end


        function retVal=getAutoCompleteData(source,tag,partialText)
            retVal={};
            if contains(tag,'Unit')
                retVal=Simulink.UnitPrmWidget.getUnitSuggestions(partialText);
            end
        end

    end

end




function retVal=l_isDerivedFromDataClassInPackage(hClass,hDataClass,pkgName)

    retVal=false;



    if(hClass<=hDataClass)
        if strcmp(pkgName,hClass.ContainingPackage.Name)

            retVal=true;
            return;
        else

            for idx=1:length(hClass.SuperclassList)
                hSuperClass=hClass.SuperclassList(idx);
                if l_isDerivedFromDataClassInPackage(hSuperClass,hDataClass,pkgName)
                    retVal=true;
                    return;
                end
            end
        end
    end
end


function result=l_isStoredIntProperty(propName)
    result=((slfeature('EnableStoredIntMinMax')>0)&&...
    (strcmp(propName,'StoredIntMin')||strcmp(propName,'StoredIntMax')));
end


function retVal=l_evaluateExpressionInContext(expr,context)

    retVal=[];
    try
        if isempty(context)
            retVal=evalin('base',string(expr));
        elseif isa(context,'Simulink.ModelWorkspace')
            retVal=slResolve(expr,context.ownerName);
        elseif isa(context,'Simulink.data.dictionary.Section')
            retVal=context.evalin(expr);
        end
    catch ME
        return;
    end
end


function dtObj=l_getDataTypeObjIfFixpt(obj,varargin)
    narginchk(1,2);
    if(nargin==1)
        context=[];
    else
        context=varargin{1};
    end

    dtObj=l_evaluateDataTypeInContext(obj.DataType,context);

    if isa(dtObj,'Simulink.AliasType')
        dtObj=l_evaluateDataTypeInContext(dtObj.BaseType,context);
    end
    if((isa(dtObj,'Simulink.NumericType')||isnumerictype(dtObj))&&dtObj.isfixed&&~dtObj.isscalingunspecified)
        return;
    else
        dtObj=[];
    end
end


function dtObj=l_evaluateDataTypeInContext(dt,context)



    dtObj=[];
    if(sl('sldtype_is_builtin',dt)||...
        strncmp(dt,'Enum:',4)||...
        strncmp(dt,'Bus:',3)||...
        strcmp(dt,'struct')||...
        strcmp(dt,'auto')||...
        strcmp(dt,'string'))
        return;
    end
    dtObj=l_evaluateExpressionInContext(dt,context);
end


function retVal=l_convertStoredIntegerToRealWorldValue(obj,propVal,varargin)


    if(nargin==2)
        context=[];
    else
        context=varargin{1};
    end
    dtObj=l_getDataTypeObjIfFixpt(obj,varargin{:});
    SIValue=num2str(l_evaluateExpressionInContext(propVal,context));



    fiObj=fi(0,dtObj);


    fiObjNoScaling=stripscaling(fiObj);


    fiObjNoScaling.Value=SIValue;
    fiObjWithRWValue=reinterpretcast(fiObjNoScaling,fiObj.numerictype);
    retVal=fiObjWithRWValue.Value;
end


function retVal=l_convertRealWorldToStoredIntegerValue(obj,propName,varargin)


    dtObj=l_getDataTypeObjIfFixpt(obj,varargin{:});
    if isempty(dtObj)
        retVal='';
    else

        assert(l_isStoredIntProperty(propName));

        propName=extractAfter(propName,'StoredInt');
        propValue=obj.(propName);
        if isempty(propValue)
            retVal=getPropValue(obj,propName);
        else
            fiObjWithRWValue=fi(obj.(propName),dtObj);
            fiObjNoScaling=stripscaling(fiObjWithRWValue);
            retVal=fiObjNoScaling.Value;
        end
    end
end

