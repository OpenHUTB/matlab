function schema()






mlock


    hCreateInPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hCreateInPackage,'BaseCSCDefn');


    hThisClass=schema.class(hCreateInPackage,'CSCDefn',hDeriveFromClass);




    cscdefn_enumtypes;




    hThisProp=schema.prop(hThisClass,'CSCType','CSC_Enum_CSCType');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Unstructured';

    hPostSetListener=handle.listener(hThisClass,hThisProp,...
    'PropertyPostSet',...
    @postSetFcn_CSCType);
    schema.prop(hThisProp,'PostSetListener','handle');
    hThisProp.PostSetListener=hPostSetListener;

    hThisProp=schema.prop(hThisClass,'MemorySection','string');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Default';

    hThisProp=schema.prop(hThisClass,'IsMemorySectionInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsGrouped','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hPostSetListener=handle.listener(hThisClass,hThisProp,...
    'PropertyPostSet',...
    @postSetFcn_IsGrouped);
    schema.prop(hThisProp,'PostSetListener','handle');
    hThisProp.PostSetListener=hPostSetListener;

    hThisProp=schema.prop(hThisClass,'DataUsage','handle');
    hThisProp.GetFunction=@getFcn_DataUsage;
    hThisProp.AccessFlags.AbortSet='off';


    hThisProp=schema.prop(hThisClass,'DataScope','CSC_Enum_DataScope');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Auto';

    hThisProp=schema.prop(hThisClass,'IsDataScopeInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsAutosarPerInstanceMemory','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsAutosarPostBuild','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'SupportSILPIL','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'DataInit','CSC_Enum_DataInit');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Auto';

    hThisProp=schema.prop(hThisClass,'IsDataInitInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'DataAccess','CSC_Enum_DataAccess');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Direct';

    hThisProp=schema.prop(hThisClass,'IsDataAccessInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'HeaderFile','ustring');
    hThisProp.SetFunction=@setFcn_HeaderFile;

    hThisProp=schema.prop(hThisClass,'IsHeaderFileInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'DefinitionFile','ustring');
    hThisProp.SetFunction=@setFcn_DefinitionFile;

    hThisProp=schema.prop(hThisClass,'IsDefinitionFileInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'Owner','ustring');
    hThisProp.setFunction=@setFcn_Owner;
    hThisProp=schema.prop(hThisClass,'IsOwnerInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'PreserveDimensions','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;
    hThisProp.GetFunction=@getFcn_PreserveDimensions;

    hThisProp=schema.prop(hThisClass,'PreserveDimensionsInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;
    hThisProp.GetFunction=@getFcn_PreserveDimensionsInstanceSpecific;

    hThisProp=schema.prop(hThisClass,'IsReusable','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsReusableInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;


    assert((slfeature('LatchingViaCSCs')==0)||...
    ((slfeature('LatchingViaCSCs')>0)&&...
    (slfeature('LatchingForDataObjects')>0)));

    if(slfeature('LatchingViaCSCs')<3)

        hThisProp=schema.prop(hThisClass,'Latching','CSC_Enum_Latching1');
    else

        hThisProp=schema.prop(hThisClass,'Latching','CSC_Enum_Latching');
    end
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='None';
    hThisProp.GetFunction=@getFcn_Latching;
    if(slfeature('LatchingViaCSCs')==0)
        hThisProp.AccessFlags.Serialize='off';
        hThisProp.AccessFlags.Copy='off';
        hThisProp.Visible='off';
    end

    hThisProp=schema.prop(hThisClass,'IsLatchingInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;
    hThisProp.GetFunction=@getFcn_IsLatchingInstanceSpecific;
    if(slfeature('LatchingViaCSCs')==0)
        hThisProp.AccessFlags.Serialize='off';
        hThisProp.AccessFlags.Copy='off';
        hThisProp.Visible='off';
    end

    hThisProp=schema.prop(hThisClass,'CriticalSection','ustring');
    hThisProp.GetFunction=@getFcn_CriticalSection;
    hThisProp.SetFunction=@setFcn_CriticalSection;
    if(slfeature('LatchingViaCSCs')<4)
        hThisProp.AccessFlags.Serialize='off';
        hThisProp.AccessFlags.Copy='off';
        hThisProp.Visible='off';
    end

    hThisProp=schema.prop(hThisClass,'CommentSource','CSC_Enum_CommentSource');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='Default';

    hThisProp=schema.prop(hThisClass,'TypeComment','ustring');
    hThisProp.SetFunction=@setFcn_StringTrim;

    hThisProp=schema.prop(hThisClass,'DeclareComment','ustring');
    hThisProp.SetFunction=@setFcn_StringTrim;

    hThisProp=schema.prop(hThisClass,'DefineComment','ustring');
    hThisProp.SetFunction=@setFcn_StringTrim;


    hThisProp=schema.prop(hThisClass,'TypeCommentForUI','ustring');
    hThisProp.SetFunction=@setFcn_TypeCommentForUI;
    hThisProp.GetFunction=@getFcn_TypeCommentForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'DeclareCommentForUI','ustring');
    hThisProp.SetFunction=@setFcn_DeclareCommentForUI;
    hThisProp.GetFunction=@getFcn_DeclareCommentForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'DefineCommentForUI','ustring');
    hThisProp.SetFunction=@setFcn_DefineCommentForUI;
    hThisProp.GetFunction=@getFcn_DefineCommentForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'CSCTypeAttributesClassName','string');
    hThisProp.SetFunction=@setFcn_StringTrim;



    hPostSetListener=handle.listener(hThisClass,hThisProp,...
    'PropertyPostSet',...
    @postSetFcn_CSCTypeAttributesClassName);
    schema.prop(hThisProp,'PostSetListener','handle');
    hThisProp.PostSetListener=hPostSetListener;

    hThisProp=schema.prop(hThisClass,'CSCTypeAttributes','mxArray');
    hThisProp.AccessFlags.AbortSet='off';
    hThisProp.SetFunction=@setFcn_CSCTypeAttributes;

    hThisProp=schema.prop(hThisClass,'TLCFileName','string');
    hThisProp.AccessFlags.Init='on';
    hThisProp.AccessFlags.AbortSet='off';
    hThisProp.FactoryValue='Unstructured.tlc';


    hThisProp.SetFunction=@setFcn_StringTrim;


    hPostSetListener=handle.listener(hThisClass,hThisProp,...
    'PropertyPostSet',...
    @postSetFcn_TLCFileName);
    schema.prop(hThisProp,'PostSetListener','handle');
    hThisProp.PostSetListener=hPostSetListener;


    hThisProp=schema.prop(hThisClass,'ConcurrentAccess','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';
    if(slfeature('LatchingViaCSCs')>0)
        hThisProp.GetFunction=@l_GetConcurrentAccess;
        hThisProp.SetFunction=@l_SetConcurrentAccess;
    end

    hThisProp=schema.prop(hThisClass,'IsConcurrentAccessInstanceSpecific','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=true;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';






    m=schema.method(hThisClass,'getProp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'createCustomAttribClass');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'updateRefObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    findclass(hCreateInPackage,'BuiltinCSCAttributes');

    m=schema.method(hThisClass,'createCustomAttribObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={'Simulink.BuiltinCSCAttributes'};

    m=schema.method(hThisClass,'convert2struct');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','string'};
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

    m=schema.method(hThisClass,'hasInstanceSpecificProperties');
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

    m=schema.method(hThisClass,'getCSCDefnForPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

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








    function actVal=getFcn_DataUsage(hObj,actVal)

        if isempty(actVal)
            actVal=Simulink.DataUsage;
            hObj.DataUsage=actVal;
        end



        function actVal=setFcn_StringTrim(hObj,newVal)%#ok
            actVal=strtrim(newVal);



            function newVal=setFcn_TypeCommentForUI(hObj,newVal)
                hObj.TypeComment=Simulink.CSCUI.prepareUIStringForCode(newVal);



                function actVal=getFcn_TypeCommentForUI(hObj,origVal)%#ok
                    actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.TypeComment);



                    function newVal=setFcn_DeclareCommentForUI(hObj,newVal)
                        hObj.DeclareComment=Simulink.CSCUI.prepareUIStringForCode(newVal);



                        function actVal=getFcn_DeclareCommentForUI(hObj,origVal)%#ok
                            actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.DeclareComment);



                            function newVal=setFcn_DefineCommentForUI(hObj,newVal)
                                hObj.DefineComment=Simulink.CSCUI.prepareUIStringForCode(newVal);



                                function actVal=getFcn_DefineCommentForUI(hObj,origVal)%#ok
                                    actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.DefineComment);



                                    function actVal=setFcn_HeaderFile(hObj,newVal)%#ok





                                        if any(newVal>127)
                                            DAStudio.error('Simulink:Data:UDDData_ErrNonAsciiPropertyValue',newVal,'HeaderFile');
                                        end
                                        slprivate('check_headerfile_string',newVal);
                                        actVal=strtrim(newVal);




                                        function actVal=setFcn_DefinitionFile(~,newVal)



                                            try
                                                newVal=strtrim(newVal);

                                                if any(newVal>127)
                                                    DAStudio.error('Simulink:Data:UDDData_ErrNonAsciiPropertyValue',newVal,'DefinitionFile');
                                                end
                                                [errTxt,hasDelimiters]=slprivate('check_generated_filename',newVal,'.c');
                                                if hasDelimiters
                                                    errTxt=[DAStudio.message('Simulink:mpt:MPTDelimiterUnAllowed'),errTxt];
                                                end
                                                if~isempty(errTxt)&&~isequal(errTxt,'File name empty.')
                                                    DAStudio.error('Simulink:mpt:MPTSLGenMsg',errTxt);
                                                end
                                            catch ME
                                                rethrow(ME);
                                            end

                                            actVal=newVal;





                                            function actVal=setFcn_Owner(~,newVal)


                                                if(isempty(newVal)||isvarname(newVal))
                                                    actVal=newVal;
                                                else
                                                    DAStudio.error('Simulink:Data:UDDData_PropertyValueMustBeVariableName',newVal,'Owner');
                                                end





                                                function actVal=getFcn_Latching(hObj,actVal)


                                                    if strcmp(actVal,'None')
                                                        return;
                                                    end

                                                    if((~strcmp(hObj.DataAccess,'Direct'))||...
                                                        (hObj.IsDataAccessInstanceSpecific)||...
                                                        (slfeature('LatchingViaCSCs')==0)||...
                                                        (~isAccessMethod(hObj)&&(slfeature('LatchingViaCSCs')<2))||...
                                                        (hObj.DataUsage.IsParameter&&(slfeature('LatchingForDataObjects')<2)))
                                                        actVal='None';
                                                    end





                                                    function actVal=getFcn_IsLatchingInstanceSpecific(hObj,actVal)


                                                        if(actVal==false)
                                                            return;
                                                        end

                                                        if((~strcmp(hObj.DataAccess,'Direct'))||...
                                                            (hObj.IsDataAccessInstanceSpecific)||...
                                                            (slfeature('LatchingViaCSCs')==0)||...
                                                            (~isAccessMethod(hObj)&&(slfeature('LatchingViaCSCs')<2)))
                                                            actVal=false;
                                                        end





                                                        function actVal=getFcn_CriticalSection(hObj,actVal)


                                                            if~strcmp(hObj.Latching,'Task edge')
                                                                actVal='';
                                                            end





                                                            function actVal=getFcn_PreserveDimensions(hObj,actVal)



                                                                if(actVal==false)
                                                                    return;
                                                                end

                                                                if~strcmp(hObj.DataAccess,'Direct')||...
                                                                    hObj.IsDataAccessInstanceSpecific||...
                                                                    isAccessMethod(hObj)
                                                                    actVal=false;
                                                                end





                                                                function actVal=getFcn_PreserveDimensionsInstanceSpecific(hObj,actVal)



                                                                    if(actVal==false)
                                                                        return;
                                                                    end
                                                                    ownerPackage=hObj.OwnerPackage;
                                                                    isSimulinkOrMptGetSet=(strcmp(ownerPackage,'Simulink')||strcmp(ownerPackage,'mpt'))&&strcmp(hObj.Name,'GetSet');

                                                                    if(~strcmp(hObj.DataAccess,'Direct')||...
                                                                        hObj.IsDataAccessInstanceSpecific||...
                                                                        isAccessMethod(hObj)||strcmp(hObj.CSCType,'FlatStructure'))&&~isSimulinkOrMptGetSet
                                                                        actVal=false;
                                                                    end





                                                                    function actVal=setFcn_CriticalSection(~,newVal)


                                                                        if(isempty(newVal)||isvarname(newVal))
                                                                            actVal=newVal;
                                                                        else
                                                                            DAStudio.error('Simulink:Data:UDDData_PropertyValueMustBeVariableName',newVal,'CriticalSection');
                                                                        end





                                                                        function postSetFcn_CSCType(hProp,eventData)%#ok



                                                                            hObj=eventData.AffectedObject;
                                                                            newVal=eventData.NewVal;

                                                                            switch newVal
                                                                            case 'Unstructured'
                                                                                hObj.IsGrouped=false;
                                                                                hObj.CSCTypeAttributesClassName='';
                                                                                hObj.TLCFileName='Unstructured.tlc';

                                                                            case 'FlatStructure'
                                                                                hObj.IsGrouped=true;
                                                                                hObj.CSCTypeAttributesClassName='Simulink.CSCTypeAttributes_FlatStructure';
                                                                                hObj.TLCFileName='FlatStructure.tlc';

                                                                            case 'AccessFunction'
                                                                                hObj.MemorySection='Default';
                                                                                hObj.IsMemorySectionInstanceSpecific=false;
                                                                                hObj.IsGrouped=false;

                                                                                hObj.DataScope='Imported';
                                                                                hObj.IsDataScopeInstanceSpecific=false;
                                                                                if strcmp(hObj.DataInit,'Static')
                                                                                    hObj.DataInit='Auto';
                                                                                end


                                                                                hObj.IsHeaderFileInstanceSpecific=true;
                                                                                hObj.Owner='';
                                                                                hObj.IsOwnerInstanceSpecific=false;
                                                                                hObj.DefinitionFile='';
                                                                                hObj.IsDefinitionFileInstanceSpecific=false;




                                                                                hObj.CommentSource='Default';



                                                                                hObj.CSCTypeAttributesClassName='Simulink.CSCTypeAttributes_GetSet';
                                                                                hObj.TLCFileName='GetSet.tlc';

                                                                            case 'Other'
                                                                                hObj.CSCTypeAttributesClassName='';
                                                                                hObj.TLCFileName='';
                                                                            end





                                                                            function postSetFcn_IsGrouped(hProp,eventData)%#ok



                                                                                hObj=eventData.AffectedObject;
                                                                                newVal=eventData.NewVal;

                                                                                if newVal
                                                                                    hObj.IsMemorySectionInstanceSpecific=false;
                                                                                    hObj.IsDataScopeInstanceSpecific=false;
                                                                                    hObj.IsDataInitInstanceSpecific=false;
                                                                                    hObj.IsDataAccessInstanceSpecific=false;
                                                                                    hObj.IsHeaderFileInstanceSpecific=false;



                                                                                end





                                                                                function postSetFcn_CSCTypeAttributesClassName(hProp,eventData)%#ok



                                                                                    hObj=eventData.AffectedObject;
                                                                                    newVal=strtrim(eventData.NewVal);

                                                                                    hObj.CSCTypeAttributes=[];

                                                                                    if~isempty(newVal)


                                                                                        try
                                                                                            hCSCTypeAttributes=eval(newVal);
                                                                                            hObj.CSCTypeAttributes=hCSCTypeAttributes;
                                                                                        catch err
                                                                                            DAStudio.error('Simulink:dialog:CSCDefnPostSetFcnCSCTypeAttrbUseClass',newVal,err.message);
                                                                                        end
                                                                                    end





                                                                                    function actVal=setFcn_CSCTypeAttributes(hObj,newVal)%#ok



                                                                                        if~isempty(newVal)&&...
                                                                                            ~isa(newVal,'Simulink.CustomStorageClassAttributes')
                                                                                            DAStudio.error('Simulink:dialog:CSCDefnPostSetFcnCSCTypeAttrbExpObject',...
                                                                                            'Simulink.CustomStorageClassAttributes');
                                                                                        end

                                                                                        actVal=newVal;




                                                                                        function postSetFcn_TLCFileName(hProp,eventData)%#ok


                                                                                            hObj=eventData.AffectedObject;

                                                                                            if~isempty(hObj)&&strcmp(hObj.CSCType,'Other')&&~isempty(hObj.CSCTypeAttributes)











                                                                                                if strcmp(hObj.OwnerPackage,'mpt')
                                                                                                    return;
                                                                                                end

                                                                                                if isa(hObj.CSCTypeAttributes,'mpt.CSCTypeAttributes_Unstructed')
                                                                                                    Case=1;
                                                                                                else
                                                                                                    Case=2;
                                                                                                end

                                                                                                instanceCSCTypeAttrProps=hObj.CSCTypeAttributes.getInstanceSpecificProps;
                                                                                                instanceCSCTypeAttrPropNames={};
                                                                                                for k=1:length(instanceCSCTypeAttrProps)
                                                                                                    instanceCSCTypeAttrPropNames{end+1}=instanceCSCTypeAttrProps(k).Name;%#ok
                                                                                                end

                                                                                                if Case==1
                                                                                                    if hObj.CSCTypeAttributes.IssueWarning

                                                                                                        l_CopyOverOwnerOrDefinitionFile(hObj,'Owner',instanceCSCTypeAttrPropNames);
                                                                                                        l_CopyOverOwnerOrDefinitionFile(hObj,'DefinitionFile',instanceCSCTypeAttrPropNames);


                                                                                                        MSLDiagnostic('Simulink:dialog:CSCTypeAttrPromotedOwnerDefinitionFileWarning',...
                                                                                                        hObj.OwnerPackage,hObj.Name).reportAsWarning;
                                                                                                    end
                                                                                                else


                                                                                                    props=Simulink.data.getPropList(hObj.CSCTypeAttributes);
                                                                                                    propnames={};
                                                                                                    for k=1:length(props)
                                                                                                        propnames{end+1}=props(k).Name;%#ok
                                                                                                    end

                                                                                                    hasOwnerDefinitionFile=false;
                                                                                                    if ismember('Owner',propnames)
                                                                                                        hasOwnerDefinitionFile=true;
                                                                                                        l_CopyOverOwnerOrDefinitionFile(hObj,'Owner',instanceCSCTypeAttrPropNames);
                                                                                                    end
                                                                                                    if ismember('DefinitionFile',propnames)
                                                                                                        hasOwnerDefinitionFile=true;
                                                                                                        l_CopyOverOwnerOrDefinitionFile(hObj,'DefinitionFile',instanceCSCTypeAttrPropNames);
                                                                                                    end

                                                                                                    if hasOwnerDefinitionFile
                                                                                                        MSLDiagnostic('Simulink:dialog:CSCTypeAttrUserOwnerDefinitionFileWarning',...
                                                                                                        hObj.CSCTypeAttributesClassName,...
                                                                                                        hObj.Name,hObj.OwnerPackage).reportAsWarning;
                                                                                                    end
                                                                                                end
                                                                                            end




                                                                                            function l_CopyOverOwnerOrDefinitionFile(hObj,propname,instanceCSCTypeAttrPropNames)

                                                                                                set(hObj,propname,hObj.CSCTypeAttributes.(propname));

                                                                                                instancespecificname=['Is',propname,'InstanceSpecific'];
                                                                                                if ismember(propname,instanceCSCTypeAttrPropNames)
                                                                                                    set(hObj,instancespecificname,true);
                                                                                                else
                                                                                                    set(hObj,instancespecificname,false);
                                                                                                end



                                                                                                function result=l_GetConcurrentAccess(hObj,~)

                                                                                                    result=~strcmp(hObj.Latching,'None');



                                                                                                    function newValue=l_SetConcurrentAccess(hObj,newValue)

                                                                                                        if strcmp(hObj.Latching,'None')
                                                                                                            if(newValue)
                                                                                                                assert(false,'Enabling ConcurrentAccess is not allowed');
                                                                                                                hObj.Latching='Minimum latency';
                                                                                                            end
                                                                                                        else
                                                                                                            assert(false,'Setting ConcurrentAccess after latching has already been set');
                                                                                                        end





