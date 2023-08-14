classdef StringSetUtility<handle

    methods(Static)
        function stringSetObj=getStrSetObjFortheSysObjectParam(blockHandle,paramName)
            stringSetObj=[];
            className=get_param(blockHandle,'System');
            metaClassData=meta.class.fromName(className);
            metaClassProperties=metaClassData.PropertyList;
            allPropertyNames={metaClassProperties.Name};
            metaCLassPropData=metaClassProperties(strcmp(allPropertyNames,paramName));
            isSystemMetaProp=isa(metaCLassPropData,'matlab.system.CustomMetaProp');
            if isSystemMetaProp&&~isempty(metaCLassPropData)&&metaCLassPropData.ConstrainedSet
                metaPairedSet=metaClassProperties(strcmp(allPropertyNames,[paramName,'Set']));
                stringSetObj=metaPairedSet.DefaultValue;
            end
        end

        function errorIfTypeOptionsDoNotMatch(paramName,typeOpts,defaultStrSetVals)
            for i=1:length(typeOpts)
                matchFound=~isempty(find(strcmpi(defaultStrSetVals,typeOpts{i})));
                if~matchFound
                    validValueStr=char(join(strcat('"',defaultStrSetVals(:),'"'),' | '));
                    errMsg=DAStudio.message('MATLAB:system:StringSet:InvalidTypeOption',typeOpts{i},...
                    paramName,validValueStr);
                    error(errMsg);
                end
            end
        end

        function defaultStrSetVals=getDefaultTypeOptionsFromStrSetObj(typeOptsStrSetObj)
            defaultStrSetVals=getAllowedValues(typeOptsStrSetObj);
            if isstring(defaultStrSetVals)


                defaultStrSetVals=defaultStrSetVals.cellstr;
            end



            if isa(typeOptsStrSetObj,'matlab.system.internal.MessageCatalogSet')
                defaultMsgIDStrSet=cell(1,length(defaultStrSetVals));
                for strInd=1:length(defaultStrSetVals)
                    defaultMsgIDStrSet{strInd}=getMessageIdentiferFromIndex(typeOptsStrSetObj,strInd);
                end
                defaultStrSetVals=defaultMsgIDStrSet;
            end
        end

        function flag=isTypeOptionsDefault(blockHandle,paramName,typeOpts)
            flag=true;
            typeOptsStrSetObj=...
            matlab.system.internal.StringSetUtility.getStrSetObjFortheSysObjectParam(blockHandle,char(paramName));
            if~isempty(typeOptsStrSetObj)&&isa(typeOptsStrSetObj,'matlab.system.StringSet')
                defaultStrSetVals=...
                matlab.system.internal.StringSetUtility.getDefaultTypeOptionsFromStrSetObj(typeOptsStrSetObj);
                flag=isempty(setdiff(defaultStrSetVals,typeOpts));
            end
        end
    end
end