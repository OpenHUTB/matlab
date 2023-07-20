




classdef DataVariant<handle

    properties(SetAccess=private)
m_ddFilespec
m_baseKeyStr
m_scope
m_variantCondition
m_variantProps
    end

    properties(SetAccess=private,Transient=true)
m_upToDate
m_baseEntryInfo
m_entryValueIsMxArray
m_baseEntryID
    end

    properties(SetAccess=public,Transient=true)
m_modifyingInDialog
    end

    methods
        function thisObj=DataVariant(ddFilespec,baseEntryNameOrID,variantCondition)
            thisObj.m_ddFilespec=ddFilespec;
            ddConn=Simulink.dd.open(ddFilespec);

            if ischar(baseEntryNameOrID)

                thisObj.m_baseEntryID=ddConn.getEntryID(baseEntryNameOrID);
            else
                thisObj.m_baseEntryID=baseEntryNameOrID;
            end

            assert(isnumeric(thisObj.m_baseEntryID));
            thisObj.m_baseEntryInfo=ddConn.getEntryInfo(...
            thisObj.m_baseEntryID);
            thisObj.m_scope=ddConn.getEntryParentName(thisObj.m_baseEntryID);
            thisObj.m_upToDate=false;
            thisObj.m_variantCondition=variantCondition;
            thisObj.m_modifyingInDialog=false;
            dPathString=[thisObj.m_scope,'.',thisObj.m_baseEntryInfo.Name];
            key=ddConn.getEntryKey(dPathString);
            thisObj.m_baseKeyStr=key.toString;
        end

        function displayLabel=getDisplayLabel(thisObj)
            displayLabel='';
            thisObj.validate;
            if thisObj.m_upToDate
                displayLabel=thisObj.m_baseEntryInfo.Name;
            end
        end

        function filepath=getDisplayIcon(thisObj)
            filepath='';
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    baseicon=['toolbox',filesep,'shared',filesep,'dastudio',filesep,'resources',filesep];
                    if isstruct(thisObj.m_baseEntryInfo.Value)
                        baseicon=[baseicon,'variable_struct.png'];
                    elseif iscell(thisObj.m_baseEntryInfo.Value)
                        baseicon=[baseicon,'variable_cell.png'];
                    elseif islogical(thisObj.m_baseEntryInfo.Value)
                        baseicon=[baseicon,'variable_logic.png'];
                    else
                        baseicon=[baseicon,'MatlabArray.png'];
                    end
                else
                    baseicon=thisObj.m_baseEntryInfo.Value.getDisplayIcon;
                end
                filepath=baseicon;
            end
        end

        function getPropertyStyle(thisObj,name,retVal)
            thisObj.validate;
            if thisObj.m_upToDate
                if isequal(name,'Name')

                    retVal.ForegroundColor=[.63,.63,.63];
                elseif~isfield(thisObj.m_variantProps,name)||isequal(name,'Variant')
                    retVal.Italic=true;
                    if~isReadonlyProperty(thisObj,name)
                        retVal.ForegroundColor=[.22,.36,.49];

                    end
                end
            end
        end

        function entryValue=getForwardedObject(thisObj)
            entryValue=[];
            if isempty(thisObj.m_modifyingInDialog)||~thisObj.m_modifyingInDialog
                thisObj.validate;

                if thisObj.m_upToDate
                    entryValue=Simulink.dd.DataVariant.constructVarFromVariantVars(...
                    thisObj.m_baseEntryInfo.Value,thisObj);
                end
            else
                entryValue=thisObj.m_baseEntryInfo.Value;
            end
        end

        function isValid=isValidProperty(thisObj,propName)
            isValid=false;
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    isValid=strcmp(propName,'Value');
                else
                    try
                        isValid=thisObj.m_baseEntryInfo.Value.isValidProperty(propName);
                    catch
                        isValid=strcmp(propName,'Value');
                    end
                end
            end
        end

        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    isReadonly=strcmp(propName,'DataType');
                else
                    isReadonly=thisObj.m_baseEntryInfo.Value.isReadonlyProperty(propName);
                end
            end
        end

        function propDataType=getPropDataType(thisObj,propName)
            propDataType='';
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    propDataType='string';
                else
                    try
                        propDataType=getPropDataType(thisObj.m_baseEntryInfo.Value,propName);
                    catch
                        propDataType='mxArray';
                    end
                end
            end
        end

        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues=cell(0,1);
            thisObj.validate;
            if thisObj.m_upToDate&&~thisObj.m_entryValueIsMxArray
                allowedValues=getPropAllowedValues(thisObj.m_baseEntryInfo.Value,propName);
            end
        end

        function setPropValue(thisObj,propName,propValue)

            thisObj.validate;
            if thisObj.m_upToDate



                currentVar=Simulink.dd.DataVariant.constructVarFromVariantVars(...
                thisObj.m_baseEntryInfo.Value,thisObj);
                if thisObj.m_entryValueIsMxArray
                    assert(strcmp(propName,'Value'));
                    valueAssignExpr='currentVar = eval(propValue);';
                    try
                        eval(valueAssignExpr);
                    catch e %#ok
                        return;
                    end
                else
                    switch getPropDataType(thisObj,propName)
                    case{'ustring','string','enum','asciiString'}

                    case 'bool'
                        switch propValue
                        case '1'
                            propValue=true;%#ok
                        case '0'
                            propValue=false;%#ok
                        otherwise
                            assert(false,'Unexpected property value for boolean property');
                        end
                    otherwise

                        try
                            propValue=eval(propValue);%#ok
                        catch e %#ok
                            return;
                        end
                    end
                    try

                        eval(['currentVar.',propName,' = propValue;']);
                    catch e %#ok
                        return;
                    end
                end
                thisObj.updateVariantProps(thisObj.m_baseEntryInfo.Value,currentVar);
            end
        end

        function propValue=getPropValue(thisObj,propName)

            propValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                if isfield(thisObj.m_variantProps,propName)
                    variantPropValuePair=thisObj.m_variantProps.(propName);
                    propValue=variantPropValuePair{2};
                else
                    propValue=l_getPropertyValue(thisObj.m_baseEntryInfo.Value,propName);
                end
            end
        end

        function dlgstruct=getDialogSchema(thisObj,~)
            if isempty(thisObj.m_modifyingInDialog)||~thisObj.m_modifyingInDialog
                thisObj.validate;
                if thisObj.m_upToDate
                    if thisObj.m_entryValueIsMxArray
                        dlgstruct=da_mxarray_get_schema(thisObj);
                    else
                        forwardObj=getForwardedObject(thisObj);
                        dlgstruct=forwardObj.getDialogSchema(thisObj.m_baseEntryInfo.Name);
                    end
                else
                    messageText.Name=DAStudio.message(...
                    'Simulink:dialog:DataDictEntryNotFound',thisObj.m_basentryInfo.Name);
                    messageText.Type='text';
                    messageText.Alignment=6;

                    dlgstruct.DialogTitle=thisObj.m_baseEntryInfo.Name;
                    dlgstruct.Items={messageText};
                    dlgstruct.HelpMethod='helpview';
                    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
                end
                thisObj.m_modifyingInDialog=true;
            else
                try
                    if thisObj.m_entryValueIsMxArray
                        dlgstruct=da_mxarray_get_schema(thisObj);
                    else
                        forwardObj=getForwardedObject(thisObj);
                        dlgstruct=forwardObj.getDialogSchema(thisObj.m_baseEntryInfo.Name);
                    end
                catch me %#ok
                    messageText.Name=DAStudio.message(...
                    'Simulink:dialog:DataDictEntryNotFound',thisObj.m_basentryInfo.Name);
                    messageText.Type='text';
                    messageText.Alignment=6;

                    dlgstruct.DialogTitle=thisObj.m_baseEntryInfo.Name;
                    dlgstruct.Items={messageText};
                    dlgstruct.HelpMethod='helpview';
                    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
                end
            end
        end

        function updateVariantProps(thisObj,baseVar,currentVar)
            diffPropNames=Simulink.dd.DataVariant.getDiffPropNames(...
            baseVar,currentVar);
            if isempty(diffPropNames)
                thisObj.m_variantProps=[];
            else
                if~isempty(thisObj.m_variantProps)
                    currVariedPropNames=fieldnames(thisObj.m_variantProps);
                    for k=1:numel(currVariedPropNames)
                        currVariedPropName=currVariedPropNames{k};
                        if~ismember(currVariedPropName,diffPropNames)
                            thisObj.m_variantProps=...
                            rmfield(thisObj.m_variantProps,currVariedPropName);
                        end
                    end
                end

                for i=1:numel(diffPropNames)
                    propName=diffPropNames{i};
                    if thisObj.m_entryValueIsMxArray
                        assert(strcmp(propName,'Value'));
                        variantPropVal=currentVar;
                        variantPropValStr=DAStudio.MxStringConversion.convertToString(variantPropVal);
                        thisObj.m_variantProps.(propName)={variantPropVal,variantPropValStr};
                    else
                        variantPropVal=currentVar.(propName);
                        variantPropValStr=getPropValue(currentVar,propName);
                        thisObj.m_variantProps.(propName)={variantPropVal,variantPropValStr};
                    end
                end
            end
        end

        function revertToBaseVar(thisObj)
            thisObj.m_variantProps=[];
        end

    end

    methods(Access=public,Static)
        function retArray=constructVarFromVariant(ddFilespec,basebaseEntryNameOrID,variantEntryIDs)
            retArray=[];
            ddConn=Simulink.dd.open(ddFilespec);
            aVariant=Simulink.dd.DataVariant(ddFilespec,basebaseEntryNameOrID,'');
            aVariant.validate;
            if aVariant.m_upToDate
                for i=1:numel(variantEntryIDs)
                    currVariantEntryID=variantEntryIDs(i);
                    currVariantEntryInfo=ddConn.getEntryInfo(...
                    currVariantEntryID);
                    assert(isa(currVariantEntryInfo.Value,'Simulink.dd.DataVariant'));
                    currVariedProps=currVariantEntryInfo.Value.m_variantProps;
                    if~isempty(currVariedProps)
                        currVariedPropNames=fieldnames(currVariedProps);
                        for k=1:numel(currVariedPropNames)
                            variedPropName=currVariedPropNames{k};
                            variedPropValuePair=currVariedProps.(variedPropName);
                            variedPropVal=variedPropValuePair{1};
                            if aVariant.m_entryValueIsMxArray
                                assert(strcmp(variedPropName,'Value'));
                                aVariant.m_baseEntryInfo.Value=variedPropVal;
                            else

                                try
                                    aVariant.m_baseEntryInfo.Value.(variedPropName)=variedPropVal;
                                catch e %#ok
                                    continue;
                                end

                            end
                        end
                    end

                end
                retArray=aVariant.m_baseEntryInfo.Value;
                invalidate(aVariant);
            end
        end

        function retArray=constructVarFromVariantVars(baseVar,variantVars)

            if Simulink.data.isSupportedEnumObject(baseVar)
                objectLevel=0;
            else
                objectLevel=Simulink.data.getScalarObjectLevel(baseVar);
            end
            if objectLevel==0
                retArray=baseVar;
            else
                retArray=copy(baseVar);
            end

            function l_SetProp(Obj,propName,propVal)
                Obj.(propName)=propVal;
            end


            currVariant=variantVars;
            assert(isa(currVariant,'Simulink.dd.DataVariant'));
            currVariedProps=currVariant.m_variantProps;
            if~isempty(currVariedProps)
                dimsToSet=[];
                isValueEmpty=false;
                currVariedPropNames=fieldnames(currVariedProps);
                for k=1:numel(currVariedPropNames)
                    variedPropName=currVariedPropNames{k};
                    variedPropValuePair=currVariedProps.(variedPropName);
                    variedPropVal=variedPropValuePair{1};
                    if objectLevel==0
                        assert(strcmp(variedPropName,'Value'));
                        retArray=variedPropVal;
                    else
                        if isequal(variedPropName,'Value')&&...
                            ~isempty(variedPropVal)
                            isValueEmpty=true;
                        elseif isequal(variedPropName,'Dimensions')
                            dimsToSet=variedPropVal;
                            continue;
                        end

                        try
                            l_SetProp(retArray,variedPropName,variedPropVal);
                        catch e %#ok
                            continue;
                        end
                    end
                end


                canHaveUserDefinedDims=(isValueEmpty&&...
                slfeature('ModelArgumentValueInterface')>0);
                canHaveSymbDims=ischar(dimsToSet);
                if~isempty(dimsToSet)&&...
                    (canHaveUserDefinedDims||canHaveSymbDims)
                    try
                        l_SetProp(retArray,'Dimensions',dimsToSet);
                    catch e %#ok
                    end
                end
            end

        end

        function diffPropNames=getDiffPropNames(a,b)
            diffPropNames={};
            if Simulink.data.isSupportedEnumObject(a)
                objectLevel=0;
            else
                objectLevel=Simulink.data.getScalarObjectLevel(a);
            end

            if objectLevel==0
                isequalStr=comparisons_private(...
                'comparevars',a,b);
                if~strcmp(isequalStr,'yes')
                    diffPropNames{end+1}='Value';
                end
            else
                assert(strcmp(class(a),class(b)));
                propsOfInterests=Simulink.data.getPropList(...
                a,'GetAccess','public','SetAccess','public');
                propsNamesOfInterests={propsOfInterests.Name};

                assignin('base','a',a);
                assignin('base','b',b);
                exp_a='evalin(''base'',''a'')';
                exp_b='evalin(''base'',''b'')';
                cleanup=onCleanup(@()evalin('base','clear a;clear b'));

                diffs=comparisons_private('vardiff',exp_a,exp_b);
                fields=diffs.getFields;

                for i=1:numel(fields)
                    if fields(i).getDiff
                        propName=char(fields(i).getName);
                        if ismember(propName,propsNamesOfInterests)
                            diffPropNames{end+1}=char(fields(i).getName);
                        end
                    end
                end
                delete(cleanup);
            end
        end

    end

    methods(Access=private)

        function validate(thisObj)
            if isempty(thisObj.m_upToDate)
                thisObj.m_upToDate=false;
            end
            if~thisObj.m_upToDate

                try
                    ddConn=Simulink.dd.open(thisObj.m_ddFilespec);


                    if isempty(thisObj.m_baseEntryID)
                        ddKey=Simulink.dd.DataSourceEntryKey.fromString(thisObj.m_baseKeyStr);
                        baseEntryPath=ddConn.getEntryPath(ddKey);
                        thisObj.m_baseEntryID=ddConn.getEntryID(baseEntryPath);
                    end

                    thisObj.m_baseEntryInfo=ddConn.getEntryInfo(...
                    thisObj.m_baseEntryID);
                    entryValue=thisObj.m_baseEntryInfo.Value;

                    if Simulink.data.isSupportedEnumObject(entryValue)
                        objectLevel=0;
                    else
                        objectLevel=Simulink.data.getScalarObjectLevel(entryValue);
                    end

                    thisObj.m_baseEntryInfo.Value=entryValue;
                    thisObj.m_entryValueIsMxArray=objectLevel==0;
                    thisObj.m_upToDate=true;
                catch me
                    thisObj.m_entryValueIsMxArray=false;
                end
            end
        end

        function invalidate(thisObj)
            if thisObj.m_upToDate
                thisObj.m_baseEntryInfo.Value=[];
                thisObj.m_upToDate=false;
            end
        end
    end


end


function propValue=l_getPropertyValue(entryValue,propName)
    if Simulink.data.isSupportedEnumObject(entryValue)
        objectLevel=0;
    else
        objectLevel=Simulink.data.getScalarObjectLevel(entryValue);
    end

    if objectLevel==0
        switch(propName)
        case 'DataType'
            propValue=class(entryValue);
        case 'Value'
            propValue=DAStudio.MxStringConversion.convertToString(...
            entryValue);
        otherwise
            assert(false);
        end
    else
        try
            propValue=entryValue.getPropValue(propName);
        catch
            switch(propName)
            case 'DataType'
                propValue=class(entryValue.Value);
            case 'Value'
                propValue=DAStudio.MxStringConversion.convertToString(...
                entryValue);
            otherwise
                assert(false);
            end
        end
        if islogical(propValue)
            if propValue
                propValue='on';
            else
                propValue='off';
            end
        end
    end

end




