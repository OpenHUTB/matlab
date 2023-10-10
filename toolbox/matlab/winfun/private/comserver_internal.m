function MLPath=comserver_internal(action,nv)

    identity=System.Security.Principal.WindowsIdentity.GetCurrent();
    principal=System.Security.Principal.WindowsPrincipal(identity);
    isadmin=principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);


    if(action=="register")&&isfield(nv,'User')&&(nv.User=="all")&&(~isadmin)
        err=MException('MATLAB:COM:AdminRegisterError',getString(message('MATLAB:COM:AdminRegisterError')));
        err.throwAsCaller;
    elseif(action=="unregister")&&isfield(nv,'User')&&(nv.User=="all")&&(~isadmin)
        err=MException('MATLAB:COM:AdminUnregisterError',getString(message('MATLAB:COM:AdminUnregisterError')));
        err.throwAsCaller;
    end


    userroot='HKEY_CURRENT_USER\Software\Classes\';
    adminroot='HKEY_LOCAL_MACHINE\Software\Classes\';


    if(action=="register")&&(~isfield(nv,'User')||nv.User=="current")
        addRegistryKeys(userroot);
    elseif(action=="unregister")&&(~isfield(nv,'User')||nv.User=="current")
        removeRegistryKeys(userroot);
    elseif(action=="register")&&(nv.User=="all")&&(isadmin)
        addRegistryKeys(adminroot);
    elseif(action=="unregister")&&(nv.User=="all")&&(isadmin)
        removeRegistryKeys(adminroot);
    elseif(action=="query")
        pathStruct=RegisteredMATLABCOMServer();

        if(nargout==0)
            disp(pathStruct);
        else
            MLPath=pathStruct;
        end
    end
end


function addRegistryKeys(root)


    try
        clsids=GetCOMClassIds();
    catch e
        if(e.identifier=="MATLAB:UndefinedFunction")

            clsids=GetOlderVersionClassIds();
        end
    end


    clsidML=clsids.CLSID;
    clsidSingle=clsids.CLSIDSingle;
    clsidDesktop=clsids.CLSIDDesktop;


    typeLib=clsids.TypeLib;
    iEngine=clsids.IEngine;
    dIMLApp=clsids.DIMLApp;
    typeLibMarshaler=clsids.TypeLibMarshaler;


    v=sscanf(version,'%d.%d');


    ProgID='Matlab.AutoServer.Single';
    ProgIDName='Matlab.AutoServer.Single';
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidSingle);
    addKey([root,ProgID,'\NotInsertable\'],'');
    addKey([root,ProgID,'\CurVer\'],sprintf('Matlab.AutoServer.Single.%d.%d',v));


    ProgID=sprintf('Matlab.AutoServer.Single.%d.%d',v);
    ProgIDName=sprintf('Matlab.AutoServer.Single (Version %d.%d)',v);
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidSingle);
    addKey([root,ProgID,'\NotInsertable\'],'');



    ProgID='Matlab.Application';
    ProgIDName='Matlab.Application';
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidML);
    addKey([root,ProgID,'\NotInsertable\'],'');
    addKey([root,ProgID,'\CurVer\'],sprintf('Matlab.Application.%d.%d',v));


    ProgID='Matlab.AutoServer';
    ProgIDName='Matlab.AutoServer';
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidML);
    addKey([root,ProgID,'\NotInsertable\'],'');
    addKey([root,ProgID,'\CurVer\'],sprintf('Matlab.AutoServer.%d.%d',v));


    ProgID='Matlab.Application.Single';
    ProgIDName='Matlab.Application.Single';
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidSingle);
    addKey([root,ProgID,'\NotInsertable\'],'');
    addKey([root,ProgID,'\CurVer\'],sprintf('Matlab.Application.Single.%d.%d',v));


    ProgID='Matlab.Desktop.Application';
    ProgIDName='Matlab.Desktop.Application';
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidDesktop);
    addKey([root,ProgID,'\NotInsertable\'],'');
    addKey([root,ProgID,'\CurVer\'],sprintf('Matlab.Desktop.Application.%d.%d',v));



    ProgID=sprintf('Matlab.Application.%d.%d',v);
    ProgIDName=sprintf('Matlab.Application (Version %d.%d)',v);
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidML);
    addKey([root,ProgID,'\NotInsertable\'],'');

    addKeys(clsidML,'Matlab.Application','/MLAutomation');


    ProgID=sprintf('Matlab.AutoServer.%d.%d',v);
    ProgIDName=sprintf('Matlab.AutoServer (Version %d.%d)',v);
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidML);
    addKey([root,ProgID,'\NotInsertable\'],'');


    ProgID=sprintf('Matlab.Application.Single.%d.%d',v);
    ProgIDName=sprintf('Matlab.Application.Single (Version %d.%d)',v);
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidSingle);
    addKey([root,ProgID,'\NotInsertable\'],'');

    addKeys(clsidSingle,'Matlab.Application.Single','/MLAutomation');


    ProgID=sprintf('Matlab.Desktop.Application.%d.%d',v);
    ProgIDName=sprintf('Matlab.Desktop.Application (Version %d.%d)',v);
    addKey([root,ProgID,'\'],ProgIDName)
    addKey([root,ProgID,'\CLSID\'],clsidDesktop);
    addKey([root,ProgID,'\NotInsertable\'],'');

    addKeys(clsidDesktop,'Matlab.Desktop.Application','-desktop -MLAutomation')


    addKey([root,'AppID\',clsidML,'\'],sprintf('Matlab.Application (Version %d.%d)',v));

    addKey([root,'TypeLib\',typeLib,'\'],'Matlab Application Type Library');
    addKey([root,'TypeLib\',typeLib,'\1.0\'],sprintf('Matlab Application (Version %d.%d) Type Library',v));
    addKey([root,'TypeLib\',typeLib,'\1.0\0\'],'');
    addKey([root,'TypeLib\',typeLib,'\1.0\0\win32\'],fullfile(matlabroot,'bin',computer('arch'),'mlapp.tlb'));
    addKey([root,'CLSID\',clsidML,'\AppId'],clsidML);
    addKey([root,'CLSID\',clsidDesktop,'\AppId'],clsidML);


    addKey([root,'Interface\',iEngine,'\'],'IEngine');
    addKey([root,'Interface\',iEngine,'\ProxyStubClsid32\'],iEngine);
    addKey([root,'Interface\',iEngine,'\NumMethods\'],'10');
    addKey([root,'Interface\',iEngine,'\BaseInterface\'],'{00000000-0000-0000-C000-000000000046}');
    addKey([root,'CLSID\',iEngine,'\'],'IEngine_PSFactory');
    addKey([root,'CLSID\',iEngine,'\InprocServer32\'],fullfile(matlabroot,'bin',computer('arch'),'mwoles05.dll'));


    addKey([root,'Interface\',dIMLApp,'\'],'DIMLApp');
    addKey([root,'Interface\',dIMLApp,'\NumMethods\'],'22');
    addKey([root,'Interface\',dIMLApp,'\ProxyStubClsid32\'],typeLibMarshaler);
    addKey([root,'Interface\',dIMLApp,'\TypeLib\'],typeLib);
    addKey([root,'Interface\',dIMLApp,'\TypeLib\Version\'],'1.0');

    function addKeys(clsid,indepid,startupOption)
        addKey([root,'CLSID\',clsid,'\'],ProgIDName);
        addKey([root,'CLSID\',clsid,'\LocalServer32\'],[fullfile(matlabroot,'bin',computer('arch'),'matlab.exe'),' ',startupOption]);
        addKey([root,'CLSID\',clsid,'\NotInsertable\'],'');
        addKey([root,'CLSID\',clsid,'\ProgID\'],ProgID);
        addKey([root,'CLSID\',clsid,'\Programmable\'],'');
        addKey([root,'CLSID\',clsid,'\TypeLib\'],typeLib);
        addKey([root,'CLSID\',clsid,'\VersionIndependentProgID\'],indepid);
    end

    function addKey(key,value)
        persistent reg
        if isempty(reg)
            reg=actxserver('WScript.Shell');
        end
        reg.RegWrite(key,value);
    end
end


function removeRegistryKeys(root)


    try
        clsids=GetCOMClassIds();
    catch e
        if(e.identifier=="MATLAB:UndefinedFunction")

            clsids=GetOlderVersionClassIds();
        end
    end

    clsidML=clsids.CLSID;
    clsidSingle=clsids.CLSIDSingle;
    clsidDesktop=clsids.CLSIDDesktop;

    typeLib=clsids.TypeLib;
    iEngine=clsids.IEngine;
    dIMLApp=clsids.DIMLApp;


    v=sscanf(version,'%d.%d');



    ProgID='Matlab.Application';
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\CurVer\']);
    removeKey([root,ProgID,'\'])


    ProgID='Matlab.AutoServer';
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\CurVer\']);
    removeKey([root,ProgID,'\'])


    ProgID='Matlab.Application.Single';
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\CurVer\']);
    removeKey([root,ProgID,'\'])


    ProgID='Matlab.AutoServer.Single';
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\CurVer\']);
    removeKey([root,ProgID,'\'])


    ProgID='Matlab.Desktop.Application';
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\CurVer\']);
    removeKey([root,ProgID,'\'])



    ProgID=sprintf('Matlab.Application.%d.%d',v);
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\'])

    removeKeys(clsidML);


    ProgID=sprintf('Matlab.AutoServer.%d.%d',v);
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\'])


    ProgID=sprintf('Matlab.Application.Single.%d.%d',v);
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\'])

    removeKeys(clsidSingle);


    ProgID=sprintf('Matlab.AutoServer.Single.%d.%d',v);
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\'])


    ProgID=sprintf('Matlab.Desktop.Application.%d.%d',v);
    removeKey([root,ProgID,'\CLSID\']);
    removeKey([root,ProgID,'\NotInsertable\']);
    removeKey([root,ProgID,'\'])

    removeKeys(clsidDesktop);



    removeKey([root,'AppID\',clsidML,'\']);

    removeKey([root,'TypeLib\',typeLib,'\1.0\0\win32\']);
    removeKey([root,'TypeLib\',typeLib,'\1.0\0\']);
    removeKey([root,'TypeLib\',typeLib,'\1.0\']);
    removeKey([root,'TypeLib\',typeLib,'\']);


    removeKey([root,'Interface\',iEngine,'\ProxyStubClsid32\']);
    removeKey([root,'Interface\',iEngine,'\NumMethods\']);
    removeKey([root,'Interface\',iEngine,'\BaseInterface\']);
    removeKey([root,'Interface\',iEngine,'\']);
    removeKey([root,'CLSID\',iEngine,'\InprocServer32\']);
    removeKey([root,'CLSID\',iEngine,'\']);


    removeKey([root,'Interface\',dIMLApp,'\NumMethods\']);
    removeKey([root,'Interface\',dIMLApp,'\ProxyStubClsid32\']);
    removeKey([root,'Interface\',dIMLApp,'\TypeLib\Version\']);
    removeKey([root,'Interface\',dIMLApp,'\TypeLib\']);
    removeKey([root,'Interface\',dIMLApp,'\']);

    function removeKeys(clsid)
        removeKey([root,'CLSID\',clsid,'\LocalServer32\']);
        removeKey([root,'CLSID\',clsid,'\NotInsertable\']);
        removeKey([root,'CLSID\',clsid,'\ProgID\']);
        removeKey([root,'CLSID\',clsid,'\Programmable\']);
        removeKey([root,'CLSID\',clsid,'\TypeLib\']);
        removeKey([root,'CLSID\',clsid,'\VersionIndependentProgID\']);
        removeKey([root,'CLSID\',clsid,'\']);
    end

    function removeKey(key)
        persistent reg
        if isempty(reg)
            reg=actxserver('WScript.Shell');
        end
        try
            reg.RegDelete(key);
        catch
        end
    end
end


function pathStruct=RegisteredMATLABCOMServer()

    pathStruct.User=getmlpath(Microsoft.Win32.Registry.CurrentUser);
    pathStruct.User=erase(pathStruct.User," /MLAutomation");

    pathStruct.Administrator=getmlpath(Microsoft.Win32.Registry.LocalMachine);
    pathStruct.Administrator=erase(pathStruct.Administrator," /MLAutomation");

    function mlpath=getmlpath(curroot)
        try
            clsid=curroot.OpenSubKey('Software\\Classes\\Matlab.Application\\CLSID').GetValue('');
            mlpath=['',char(curroot.OpenSubKey('Software\\Classes\\CLSID').OpenSubKey(clsid).OpenSubKey('LocalServer32').GetValue(''))];
            curroot.Close;
        catch
            mlpath='';
        end
    end
end


function clsids=GetOlderVersionClassIds()

    config=getConfig;


    clsids.CLSID=config.(['R',version('-release')]).CLSID;
    clsids.CLSIDSingle=config.(['R',version('-release')]).Single.CLSID;
    clsids.CLSIDDesktop=config.(['R',version('-release')]).Desktop.CLSID;


    clsids.TypeLib='{C36E46AB-6A81-457B-9F91-A7719A06287F}';
    clsids.IEngine='{3D272B00-B576-11cf-A50F-00A024583C19}';
    clsids.DIMLApp='{669CEC93-6E22-11cf-A4D6-00A024583C19}';


    function config=getConfig

        config.R2019b.CLSID='{0818548B-86E8-4451-87C2-AB70D68C490A}';
        config.R2019b.Single.CLSID='{DEF76351-87F3-4083-8F41-ACF527BAA0B3}';
        config.R2019b.Desktop.CLSID='{DEB7BBCB-0AA0-41C2-BEE8-5CA637E729AA}';


        config.R2020a.CLSID='{368C18D2-53D8-433A-AD3B-FCF8F16CBE3F}';
        config.R2020a.Single.CLSID='{8CBC0AC2-6B34-4EC7-BC2D-0C21ED05BA35}';
        config.R2020a.Desktop.CLSID='{969B2C55-EFEF-43FB-A81F-62AB8C1228D8}';
    end
end




