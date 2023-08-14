function schema()













mlock


    hCreateInPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hCreateInPackage,'BaseCSCDefn');


    hThisClass=schema.class(hCreateInPackage,'CSCRefDefn',hDeriveFromClass);



    cscdefn_enumtypes;







    hThisProp=schema.prop(hThisClass,'RefPackageName','string');
    hThisProp.GetFunction=@getRefPackage;
    hThisProp.SetFunction=@setRefPackage;

    hThisProp=schema.prop(hThisClass,'StoredRefPackageName','string');

    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'RefDefnName','string');
    hThisProp.SetFunction=@setRefDefnName;


    hCSCDefnClass=findclass(hCreateInPackage,'CSCDefn');
    hThisProp=schema.prop(hThisClass,'RefDefnObj','Simulink.BaseCSCDefn');

    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';



    props=hCSCDefnClass.Properties;
    propsToExclude={'Name',...
    'OwnerPackage',...
    'DataUsage'};
    for idx=1:length(props)
        if ismember(props(idx).Name,propsToExclude)
            continue;
        end

        l_createDummyProp(hThisClass,props(idx).Name,props(idx).DataType);
    end






    m=schema.method(hThisClass,'getProp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'updateRefObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'updateRefObjWithName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getRefDefnObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'convert2struct');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'checkCircularReference');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'deepCopy');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createCustomAttribClass');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={'string'};


    findclass(hCreateInPackage,'BuiltinCSCAttributes');

    m=schema.method(hThisClass,'createCustomAttribObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={'Simulink.BuiltinCSCAttributes'};


    m=schema.method(hThisClass,'getIdentifiersForInstance');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string','ustring'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'getIdentifiersForGroup');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'isAddressable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isImported');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isMacro');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isAutosarNVRAM');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isAutosarPerInstanceMemory');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getBitPackBoolean');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getCommentSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDataAccess');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDataInit');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDataScope');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getTypeComment');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDeclareComment');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDefineComment');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDefinitionFile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getHeaderFile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getIsParameter');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getIsSignal');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getStructName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getStructTypeDef');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getStructTypeTag');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getStructTypeToken');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getStructTypeName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getQualifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getIsConst');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getIsVolatile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getIsReusable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getLatching');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getCriticalSection');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'hasInstanceSpecificProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'isAccessMethod');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getGetFunctionName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getSetFunctionName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getGetElementFunctionName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getSetElementFunctionName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getStructValueViaReturnArgument');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'supportsArrayAccess');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'isConcurrentAccess');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'getTabs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getCSCPropDetails');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMemorySectionDefnForPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getDefnsForValidation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle','handle'};

    m=schema.method(hThisClass,'isequal');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getCSCDefnForPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

end

function retVal=getRefPackage(hThis,currVal)%#ok
    retVal=hThis.StoredRefPackageName;
end

function newName=setRefPackage(hThis,newName)
    if~isequal(newName,hThis.StoredRefPackageName)
        myPackage=hThis.OwnerPackage;
        oldName=hThis.StoredRefPackageName;

        if isempty(myPackage)
            DAStudio.error('Simulink:dialog:CSCRefDefnSetRefPkgBeforeOwnerPkg');
        end

        try

            processcsc('CheckCircularReference',myPackage,newName);
        catch err
            DAStudio.error('Simulink:dialog:CSCRefDefnCannotSetRefPkg',...
            newName,myPackage,hThis.Name,err.message);
        end


        hThis.StoredRefPackageName=newName;

        try

            currentCSCName=hThis.RefDefnName;
            namesList=processcsc('GetCSCNames',newName);


            if(~any(ismember(namesList,currentCSCName)))
                hThis.RefDefnName=namesList{1};
            end


            hThis.updateRefObj;
        catch err
            hThis.StoredRefPackageName=oldName;
            rethrow(err);
        end

    end
end

function newName=setRefDefnName(hThis,newName)

    if~isequal(newName,hThis.RefDefnName)
        try
            hThis.updateRefObjWithName(newName);
        catch err
            warnState=warning('off','backtrace');
            MSLDiagnostic('Simulink:dialog:CSCRefDefnSetDefnNameError2Warning',...
            err.message,hThis.RefDefnName).reportAsWarning;
            warning(warnState);
            newName=hThis.RefDefnName;
        end
    end
end

function hThisProp=l_createDummyProp(hThisClass,propName,propType)
    hThisProp=schema.prop(hThisClass,propName,propType);
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PrivateSet='off';
    hThisProp.GetFunction=@(hObj,currVal)getDummyPropertyValue(hObj,propName,currVal);


    hThisProp.AccessFlags.AbortSet='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.AccessFlags.Init='off';
    hThisProp.AccessFlags.Reset='off';
    hThisProp.AccessFlags.Serialize='off';
end


function retVal=getDummyPropertyValue(hThis,propName,currVal)%#ok
    actualDefnObj=hThis.getRefDefnObj;
    retVal=actualDefnObj.getProp(propName);
end



