function configData=RunTimeModule_config















    persistent fConfigData

    if isempty(fConfigData)

        msgPrfx='physmod:pm_sli:RTM:SimscapeCC:property:EditingMode:';





        EditingMode.PropertyName='EditingMode';
        EditingMode.Label_msgid=[msgPrfx,'items:label'];
        EditingMode.DataType='PmSli_RTM_EditingModeType';
        EditingMode.Group_msgid=[msgPrfx,'items:group'];
        EditingMode.GroupDesc='';
        EditingMode.ValueLabel_msgidprfx=[msgPrfx,'value:'];
        EditingMode.Visible=true;

        EditingMode.MenuTag='PmSli_EditingMode';
        EditingMode.MenuStatusTip_msgid=[msgPrfx,'items:menustatustip'];
        EditingMode.MenuOptionTag_prfx='Platform:EditingMode:';
        EditingMode.MenuOptionStatusTip_templ_msgid=[msgPrfx,'optionstatustip'];
        EditingMode.MenuOptionStatusTip_param_msgidprfx=EditingMode.ValueLabel_msgidprfx;

        EditingMode.BlockParameterName='ParameterEditingModes';

        ProductsUsed.PropertyName='PhysicalModelingProducts';
        ProductsUsed.DataType='mxArray';
        ProductsUsed.Visible=false;


        ModelTopologyChecksum.PropertyName='PhysicalModelingChecksum';
        ModelTopologyChecksum.DataType='double';
        ModelTopologyChecksum.Visible=false;

        ModelParameterChecksum.PropertyName='PhysicalModelingParameterChecksum';
        ModelParameterChecksum.DataType='double';
        ModelParameterChecksum.Visible=false;

        ConfigSet.CloneSuffix='physmod:pm_sli:RTM:SimscapeCC:ConfigSet:CloneNameSuffix';


        errPrfx='physmod:pm_sli:RTM:RunTimeModule:error:';

        internalErrPrfx=[errPrfx,'internal:'];
        Error.CannotGetParameterMode_msgid=[internalErrPrfx,'CannotGetParameterMode'];
        Error.CannotFindLibraryBlock_msgid=[internalErrPrfx,'CannotFindLibraryBlock'];
        Error.IncorrectCode_msgid=[internalErrPrfx,'IncorrectCode'];
        Error.UnknownBlockCallback_msgid=[internalErrPrfx,'UnknownBlockCallbackx'];
        Error.UnknownParamTypeRequest_msgid=[internalErrPrfx,'UnknownParameterTypeRequest'];
        Error.BlockNotConverted_templ_msgid=[internalErrPrfx,'BlockNotConverted'];
        Error.CannotSnapshotBlocks_templ_msgid=[internalErrPrfx,'CannotSnapshotBlocks'];
        Error.CannotGetEditingModeNoSource_msgid=[internalErrPrfx,'CannotGetEditingModeSourceObjectEmpty'];
        Error.RtmNotInitialized_msgid=[internalErrPrfx,'RtmNotInitialized'];
        Error.BlockProductUnregistered_templ_msgid=[internalErrPrfx,'RestrictedLoadFoundBlockProductNotRegistered'];
        Error.UnexpectedCallback_templ_msgid=[internalErrPrfx,'UnexpectedCallback'];
        Error.CannotSetParamProperty_templ_msgid=[internalErrPrfx,'CannotSetParamProperty'];

        userErrPrfx=[errPrfx,'user:'];
        Error.NoPlatformProductLicense_msgid=[userErrPrfx,'NoPlatformProductLicense'];
        Error.CannotRestoreParams_templ_msgid=[userErrPrfx,'CannotRestoreParams'];
        Error.CannotChangeLockedMode_templ_msgid=[userErrPrfx,'CannotChangeLockedModelMode'];
        Error.IllegallyChangedDlgParams_templ_msgid=[userErrPrfx,'BlockParamsChangedInRestrictedMode'];
        Error.CannotAddInUsingMode_msgid=[userErrPrfx,'CannotAddBlockInRestrictedMode'];
        Error.CannotRemoveInUsingMode_msgid=[userErrPrfx,'CannotRemoveBlockInRestrictedMode'];
        Error.UnlicensedProducts_templ_msgid=[userErrPrfx,'UnlicensedProducts'];
        Error.NoLicenseToAddBlock_templ_msgid=[userErrPrfx,'NoLicenseToAddBlock'];
        Error.NoLicenseToRemoveBlock_templ_msgid=[userErrPrfx,'NoLicenseToRemoveBlock'];

        Error.NoLicenseToModifyLibraryBlock_templ_msgid=[userErrPrfx,'NoLicenseToModifyLibraryBlock'];
        Error.NoLicenseToRemoveLibraryBlock_templ_msgid=[userErrPrfx,'NoLicenseToRemoveLibraryBlock'];
        Error.NoLicenseToAddLibraryBlock_templ_msgid=[userErrPrfx,'NoLicenseToAddLibraryBlock'];
        Error.NoLicenseToSaveLibraryBlock_templ_msgid=[userErrPrfx,'NoLicenseToSaveLibraryBlock'];
        Error.NoLicenseToCompileOrSaveInAuthoringMode=[userErrPrfx,'NoLicenseToCompileOrSaveInAuthoringMode'];
        Error.NoLicenseToModifyBlock_templ_msgid=[userErrPrfx,'NoLicenseToModifyBlock'];

        Error.IllegalUsingModeOperation_templ_msgid=[userErrPrfx,'CannotPerformRestrictedModelOperation'];
        Error.IllegallyChangedTopology_msgid=[userErrPrfx,'IllegallyChangedTopology'];
        Error.IllegallyChangedBlockParameters_templ_msgid=[userErrPrfx,'IllegallyChangedBlockParameters'];
        Error.InconsistentLibraryBlock_templ_msgid=[userErrPrfx,'InconsistentLibraryBlock'];
        Error.UnresolvedBlockLink_templ_msgid=[userErrPrfx,'UnresolvedBlockLink'];
        Error.UnresolvedLibraryLinks_templ_msgid=[userErrPrfx,'UnresolvedLibraryLinks'];

        Error.UnappliedDialogChanges_templ_msgid=[userErrPrfx,'UnappliedDialogChanges'];

        lblPrfx='physmod:pm_sli:RTM:RunTimeModule:label:';

        Label.ErrorDlgTitle_msgid=[lblPrfx,'ErrorDlgTitle'];



        BlockId.Relevant.Exist={EditingMode.BlockParameterName};

        BlockId.Unmodified.Match(1).Param='StaticLinkStatus';
        BlockId.Unmodified.Match(1).Value='resolved';
        BlockId.Unmodified.Match(2).Param='StaticLinkStatus';
        BlockId.Unmodified.Match(2).Value='implicit';

        BlockId.Recurse(1)={'Simulink.SubSystem'};


        warningPrfx='physmod:pm_sli:RTM:RunTimeModule:warning:';
        Warning.ModelLoadedInRestrictedMode_templ_msgid=[warningPrfx,'ModelLoadedInRestrictedMode'];
        Warning.CouldNotObtainLicenses_msgid=[warningPrfx,'CouldNotObtainLicenses'];
        Warning.PreferencesRequestRestrictedLoadAlways_msgid=[warningPrfx,'PreferencesRequestRestrictedLoadAlways'];
        Warning.UnresolvedBlockLinkWhenSaving_templ_msgid=[warningPrfx,'UnresolvedBlockLinkWhenSaving'];

        ONESEC=datenum([1,1,1,1,1,2])-datenum([1,1,1,1,1,1]);
        ModelOp.WindowWidth=1*ONESEC;


        ModelOp.Label.presave=[lblPrfx,'SaveOperation'];
        ModelOp.Label.compile=[lblPrfx,'CompileOperation'];

        fConfigData.EditingMode=EditingMode;
        fConfigData.ProductsUsed=ProductsUsed;
        fConfigData.ModelTopologyChecksum=ModelTopologyChecksum;
        fConfigData.Error=Error;
        fConfigData.Label=Label;
        fConfigData.BlockId=BlockId;
        fConfigData.Warning=Warning;
        fConfigData.ConfigSet=ConfigSet;
        fConfigData.ModelOp=ModelOp;
        fConfigData.ModelParameterChecksum=ModelParameterChecksum;
        fConfigData.ProductSeparator='|';
        fConfigData.AddParamErrorId='Simulink:Commands:ParamExists';
    end

    configData=fConfigData;





