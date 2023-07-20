function schema()













mlock


    hCreateInPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hCreateInPackage,'BaseMSDefn');


    hThisClass=schema.class(hCreateInPackage,'MemorySectionRefDefn',hDeriveFromClass);



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


    hMSDefnClass=findclass(hCreateInPackage,'MemorySectionDefn');
    hThisProp=schema.prop(hThisClass,'RefDefnObj','Simulink.BaseMSDefn');

    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';



    props=hMSDefnClass.Properties;
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
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getTabs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMSPropDetails');
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

            currentName=hThis.RefDefnName;
            namesList=processcsc('GetMemorySectionNames',newName);


            if(~any(ismember(namesList,currentName)))
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
            MSLDiagnostic('Simulink:dialog:MSRefDefnSetDefnNameError2Warning',...
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



