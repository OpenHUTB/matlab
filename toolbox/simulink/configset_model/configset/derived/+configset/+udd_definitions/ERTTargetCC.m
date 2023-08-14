function cls=ERTTargetCC(cls)




    prop=Simulink.TargetCCProperty(cls,'GenerateASAP2','slbool');
    prop.FactoryValue='off';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'DSAsUniqueAccess','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ExtMode','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ExtModeTransport','slint');
    prop.FactoryValue=0;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setExtModeTransport;

    prop=Simulink.TargetCCProperty(cls,'ExtModeStaticAlloc','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.getFunction=@configset.ert.getExtModeStaticAlloc;
    prop.setFunction=@configset.ert.setExtModeStaticAlloc;

    prop=Simulink.TargetCCProperty(cls,'ExtModeAutomaticAllocSize','slbool');
    prop.FactoryValue='on';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ExtModeMaxTrigDuration','slint');
    prop.FactoryValue=10;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setExtModeMaxTrigDuration;

    prop=Simulink.TargetCCProperty(cls,'ExtModeStaticAllocSize','slint');
    prop.FactoryValue=1000000;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setExtModeStaticAllocSize;

    prop=Simulink.TargetCCProperty(cls,'ExtModeTesting','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    prop=Simulink.TargetCCProperty(cls,'ExtModeMexFile','ustring');
    prop.FactoryValue='ext_comm';
    prop.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    prop=Simulink.TargetCCProperty(cls,'ExtModeMexArgs','ustring');
    prop.FactoryValue='';
    prop.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    prop=Simulink.TargetCCProperty(cls,'UserDataClassName','MATLAB array');
    prop.FactoryValue=[];
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'CSCSource','ustring');
    prop.FactoryValue='';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'ExtModeIntrfLevel','ustring');
    prop.FactoryValue='Level1';
    prop.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_INLINEDPARAMETERPLACEMENT_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_INLINEDPARAMETERPLACEMENT_ENUM',{'Hierarchical','NonHierarchical'},0:1);
    end
    prop=Simulink.TargetCCProperty(cls,'InlinedParameterPlacement','CONFIG_TARGET_ERTTARGETCC_INLINEDPARAMETERPLACEMENT_ENUM');
    prop.FactoryValue='NonHierarchical';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getInlinedParameterPlacement;

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_TARGETOS_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_TARGETOS_ENUM',{'BareBoardExample','VxWorksExample','NativeThreadsExample'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'TargetOS','CONFIG_TARGET_ERTTARGETCC_TARGETOS_ENUM');
    prop.FactoryValue='BareBoardExample';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_MULTIINSTANCEERRORCODE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_MULTIINSTANCEERRORCODE_ENUM',{'None','Warning','Error'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'MultiInstanceErrorCode','CONFIG_TARGET_ERTTARGETCC_MULTIINSTANCEERRORCODE_ENUM');
    prop.FactoryValue='Error';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_ROOTIOFORMAT_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_ROOTIOFORMAT_ENUM',{'Individual arguments','Structure reference','Part of model data structure'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'RootIOFormat','CONFIG_TARGET_ERTTARGETCC_ROOTIOFORMAT_ENUM');
    prop.FactoryValue='Individual arguments';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'RTWCAPISignals','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'RTWCAPIParams','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'RTWCAPIStates','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'RTWCAPIRootIO','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'TargetID','MATLAB array');
    prop.FactoryValue=[];
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';

    prop=Simulink.TargetCCProperty(cls,'ERTSrcFileBannerTemplate','ustring');
    prop.FactoryValue='ert_code_template.cgt';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ERTHdrFileBannerTemplate','ustring');
    prop.FactoryValue='ert_code_template.cgt';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ERTDataSrcFileTemplate','ustring');
    prop.FactoryValue='ert_code_template.cgt';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ERTDataHdrFileTemplate','ustring');
    prop.FactoryValue='ert_code_template.cgt';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ERTCustomFileTemplate','ustring');
    prop.FactoryValue='example_file_process.tlc';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setERTCustomFileTemplate;

    prop=Simulink.TargetCCProperty(cls,'RateGroupingCode','slbool');
    prop.FactoryValue='on';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_INITIALVALUESOURCE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_INITIALVALUESOURCE_ENUM',{'Model','DataObject'},0:1);
    end
    prop=Simulink.TargetCCProperty(cls,'InitialValueSource','CONFIG_TARGET_ERTTARGETCC_INITIALVALUESOURCE_ENUM');
    prop.FactoryValue='Model';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');
    prop.setFunction=@configset.ert.setInitialValueSource;

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_MODULENAMINGRULE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_MODULENAMINGRULE_ENUM',{'Unspecified','SameAsModel','UserSpecified'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'ModuleNamingRule','CONFIG_TARGET_ERTTARGETCC_MODULENAMINGRULE_ENUM');
    prop.FactoryValue='Unspecified';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');
    prop.setFunction=@configset.ert.setModuleNamingRule;

    prop=Simulink.TargetCCProperty(cls,'ModuleName','ustring');
    prop.FactoryValue='';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');

    prop=Simulink.TargetCCProperty(cls,'EnableDataOwnership','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.getFunction=@configset.ert.getEnableDataOwnership;
    prop.setFunction=@configset.ert.setEnableDataOwnership;

    prop=Simulink.TargetCCProperty(cls,'SignalDisplayLevel','slint');
    prop.FactoryValue=10;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ParamTuneLevel','slint');
    prop.FactoryValue=10;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_GLOBALDATADEFINITION_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_GLOBALDATADEFINITION_ENUM',{'Auto','InSourceFile','InSeparateSourceFile'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'GlobalDataDefinition','CONFIG_TARGET_ERTTARGETCC_GLOBALDATADEFINITION_ENUM');
    prop.FactoryValue='Auto';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'DataDefinitionFile','ustring');
    prop.FactoryValue='global.c';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_GLOBALDATAREFERENCE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_GLOBALDATAREFERENCE_ENUM',{'Auto','InSourceFile','InSeparateHeaderFile'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'GlobalDataReference','CONFIG_TARGET_ERTTARGETCC_GLOBALDATAREFERENCE_ENUM');
    prop.FactoryValue='Auto';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_ERTFILEPACKAGINGFORMAT_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_ERTFILEPACKAGINGFORMAT_ENUM',{'Modular','CompactWithDataFile','Compact'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'ERTFilePackagingFormat','CONFIG_TARGET_ERTTARGETCC_ERTFILEPACKAGINGFORMAT_ENUM');
    prop.FactoryValue='Modular';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_RATETRANSITIONBLOCKCODE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_RATETRANSITIONBLOCKCODE_ENUM',{'Inline','Function'},0:1);
    end
    prop=Simulink.TargetCCProperty(cls,'RateTransitionBlockCode','CONFIG_TARGET_ERTTARGETCC_RATETRANSITIONBLOCKCODE_ENUM');
    prop.FactoryValue='Inline';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setRateTransitionBlockCode;

    prop=Simulink.TargetCCProperty(cls,'DataReferenceFile','ustring');
    prop.FactoryValue='global.h';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'PreserveExpressionOrder','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'PreserveIfCondition','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ConvertIfToSwitch','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'PreserveExternInFcnDecls','slbool');
    prop.FactoryValue='on';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'PreserveStaticInFcnDecls','slbool');
    prop.FactoryValue='on';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'GenerateDefaultCase','slbool');
    prop.FactoryValue='off';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');

    prop=Simulink.TargetCCProperty(cls,'SuppressUnreachableDefaultCases','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'EnableSignedLeftShifts','slbool');
    prop.FactoryValue='on';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'EnableSignedRightShifts','slbool');
    prop.FactoryValue='on';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ImplementImageWithCVMat','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'HoistShortCircuitFcnCalls','slbool');
    prop.FactoryValue='off';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');

    prop=Simulink.TargetCCProperty(cls,'MisraCompliance','slbool');
    prop.FactoryValue='off';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_INDENTSTYLE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_INDENTSTYLE_ENUM',{'K&R','Allman'},0:1);
    end
    prop=Simulink.TargetCCProperty(cls,'IndentStyle','CONFIG_TARGET_ERTTARGETCC_INDENTSTYLE_ENUM');
    prop.FactoryValue='K&R';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_INDENTSIZE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_INDENTSIZE_ENUM',{'2','3','4','5','6','7','8'},0:6);
    end
    prop=Simulink.TargetCCProperty(cls,'IndentSize','CONFIG_TARGET_ERTTARGETCC_INDENTSIZE_ENUM');
    prop.FactoryValue='2';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_NEWLINESTYLE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_NEWLINESTYLE_ENUM',{'Default','LF','CR+LF'},0:2);
    end
    prop=Simulink.TargetCCProperty(cls,'NewlineStyle','CONFIG_TARGET_ERTTARGETCC_NEWLINESTYLE_ENUM');
    prop.FactoryValue='Default';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'MaxLineWidth','slint');
    prop.FactoryValue=80;
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxLineWidth;

    prop=Simulink.TargetCCProperty(cls,'EnableUserReplacementTypes','slbool');
    prop.FactoryValue='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'ReplacementTypes','MATLAB array');
    prop.FactoryValue=struct('double','','single','','int32','','int16','','int8','','uint32','','uint16','','uint8','','boolean','','int','','uint','','char','','uint64','','int64','');
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setReplacementTypes;

    prop=Simulink.TargetCCProperty(cls,'MaxIdInt64','ustring');
    prop.FactoryValue='MAX_int64_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdInt64;

    prop=Simulink.TargetCCProperty(cls,'MinIdInt64','ustring');
    prop.FactoryValue='MIN_int64_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMinIdInt64;

    prop=Simulink.TargetCCProperty(cls,'MaxIdUint64','ustring');
    prop.FactoryValue='MAX_uint64_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdUint64;

    prop=Simulink.TargetCCProperty(cls,'MaxIdInt32','ustring');
    prop.FactoryValue='MAX_int32_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdInt32;

    prop=Simulink.TargetCCProperty(cls,'MinIdInt32','ustring');
    prop.FactoryValue='MIN_int32_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMinIdInt32;

    prop=Simulink.TargetCCProperty(cls,'MaxIdUint32','ustring');
    prop.FactoryValue='MAX_uint32_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdUint32;

    prop=Simulink.TargetCCProperty(cls,'MaxIdInt16','ustring');
    prop.FactoryValue='MAX_int16_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdInt16;

    prop=Simulink.TargetCCProperty(cls,'MinIdInt16','ustring');
    prop.FactoryValue='MIN_int16_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMinIdInt16;

    prop=Simulink.TargetCCProperty(cls,'MaxIdUint16','ustring');
    prop.FactoryValue='MAX_uint16_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdUint16;

    prop=Simulink.TargetCCProperty(cls,'MaxIdInt8','ustring');
    prop.FactoryValue='MAX_int8_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdInt8;

    prop=Simulink.TargetCCProperty(cls,'MinIdInt8','ustring');
    prop.FactoryValue='MIN_int8_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMinIdInt8;

    prop=Simulink.TargetCCProperty(cls,'MaxIdUint8','ustring');
    prop.FactoryValue='MAX_uint8_T';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMaxIdUint8;

    prop=Simulink.TargetCCProperty(cls,'BooleanTrueId','ustring');
    prop.FactoryValue='true';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setBooleanTrueId;

    prop=Simulink.TargetCCProperty(cls,'BooleanFalseId','ustring');
    prop.FactoryValue='false';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setBooleanFalseId;

    prop=Simulink.TargetCCProperty(cls,'TypeLimitIdReplacementHeaderFile','ustring');
    prop.FactoryValue='';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'MemSecPackage','ustring');
    prop.FactoryValue='--- None ---';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'MemSecDataConstants','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'MemSecDataIO','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'MemSecDataInternal','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'MemSecDataParameters','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'MemSecFuncInitTerm','ustring');
    prop.FactoryValue='Default';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'MemSecFuncExecute','ustring');
    prop.FactoryValue='Default';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setMemSecFuncExecute;

    prop=Simulink.TargetCCProperty(cls,'MemSecFuncSharedUtil','ustring');
    prop.FactoryValue='Default';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

    prop=Simulink.TargetCCProperty(cls,'MemSecFuncSharedUtilSetByExecute','slbool');
    prop.FactoryValue='off';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.AccessFlags.PublicSet='off';

    prop=Simulink.TargetCCProperty(cls,'ErrorDialog','MATLAB array');
    prop.FactoryValue=[];
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.AccessFlags.Copy='off';

    prop=Simulink.TargetCCProperty(cls,'GroupConstants','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';

    prop=Simulink.TargetCCProperty(cls,'GroupRootIO','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.AccessFlags.Serialize='off';
    prop.TargetCCPropertyAttributes.set_prop_attrib('GRANDFATHERED');
    prop.getFunction=@configset.ert.getGroupRootIO;

    prop=Simulink.TargetCCProperty(cls,'GroupRootInputs','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupRootInputs;

    prop=Simulink.TargetCCProperty(cls,'GroupRootOutputs','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupRootOutputs;

    prop=Simulink.TargetCCProperty(cls,'GroupInternal','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupInternal;

    prop=Simulink.TargetCCProperty(cls,'GroupParameters','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupParameters;

    prop=Simulink.TargetCCProperty(cls,'GroupDataTransfer','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupDataTransfer;

    prop=Simulink.TargetCCProperty(cls,'GroupSharedLocalDataStores','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupSharedLocalDataStores;

    prop=Simulink.TargetCCProperty(cls,'GroupInstanceSpecificParameters','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupInstanceSpecificParameters;

    prop=Simulink.TargetCCProperty(cls,'GroupModelData','ustring');
    prop.FactoryValue='Default';
    prop.Visible='off';
    prop.getFunction=@configset.ert.getGroupModelData;

    if isempty(findtype('CONFIG_TARGET_ERTTARGETCC_ARRAYCONTAINERTYPE_ENUM'))
        schema.EnumType('CONFIG_TARGET_ERTTARGETCC_ARRAYCONTAINERTYPE_ENUM',{'C-style array','std::array'},0:1);
    end
    prop=Simulink.TargetCCProperty(cls,'ArrayContainerType','CONFIG_TARGET_ERTTARGETCC_ARRAYCONTAINERTYPE_ENUM');
    prop.FactoryValue='C-style array';
    prop.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
    prop.setFunction=@configset.ert.setArrayContainerType;

    Simulink.TargetCCPropertyAttributes.regPropPresetListener(cls);

    m=schema.method(cls,'setPrivate_MemSecFuncByExecute');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','slbool'};
    s.OutputTypes={};

    m=schema.method(cls,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(cls,'getMdlRefComplianceTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','Sl_MdlRefTarget_EnumType'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(cls,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(cls,'okToAttach');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool'};

    m=schema.method(cls,'okToDetach');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

end
