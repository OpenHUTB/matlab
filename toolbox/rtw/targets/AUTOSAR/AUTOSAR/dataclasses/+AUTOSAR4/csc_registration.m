function defs=csc_registration(action)



















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','Global');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'CSCType','Unstructured');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',true);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','Unstructured.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

        h=Simulink.MemorySectionRefDefn;
        set(h,'Name','VAR');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'RefPackageName','AUTOSAR');
        set(h,'RefDefnName','SwAddrMethod');
        defs=[defs;h];

        h=Simulink.MemorySectionRefDefn;
        set(h,'Name','CAL');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'RefPackageName','AUTOSAR');
        set(h,'RefDefnName','SwAddrMethod');
        defs=[defs;h];

        h=Simulink.MemorySectionRefDefn;
        set(h,'Name','CONST');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'RefPackageName','AUTOSAR');
        set(h,'RefDefnName','SwAddrMethod_Const');
        defs=[defs;h];

        h=Simulink.MemorySectionRefDefn;
        set(h,'Name','VOLATILE');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'RefPackageName','AUTOSAR');
        set(h,'RefDefnName','SwAddrMethod_Volatile');
        defs=[defs;h];

        h=Simulink.MemorySectionRefDefn;
        set(h,'Name','CONST_VOLATILE');
        set(h,'OwnerPackage','AUTOSAR4');
        set(h,'RefPackageName','AUTOSAR');
        set(h,'RefDefnName','SwAddrMethod_Const_Volatile');
        defs=[defs;h];


        if exist('additionalAUTOSAR4MemorySections','file')==2
            try


                defs=[defs;additionalAUTOSAR4MemorySections()];
            catch ME
                warning('Could not load additional memory sections due to the following error %s',...
                ME.message);%#ok<MEXCEP>
            end
        end


    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end





