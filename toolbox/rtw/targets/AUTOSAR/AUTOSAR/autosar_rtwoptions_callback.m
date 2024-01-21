function varargout=autosar_rtwoptions_callback(action,varargin)

    switch action
    case 'GetOptions'
        rtwoptions=varargin{1};
        rtwoptions(end+1).prompt=DAStudio.message('RTW:autosar:autosarCodeGenOptions');
        rtwoptions(end).type='Category';
        rtwoptions(end).enable='on';
        rtwoptions(end).default=2;
        rtwoptions(end+1).prompt=DAStudio.message('RTW:autosar:generateXMLForSchema');
        rtwoptions(end).type='Popup';
        rtwoptions(end).enable='on';
        rtwoptions(end).default=autosarcore.rtwOptions('GetDefaultSchema');
        rtwoptions(end).popupstrings=autosarcore.rtwOptions('GetSupportedSchemaStrs');
        rtwoptions(end).tlcvariable='AutosarSchemaVersion';
        rtwoptions(end).tooltip=DAStudio.message('RTW:autosar:generateXMLForSchemaTooltip');
        rtwoptions(end).makevariable='';
        rtwoptions(end+1).prompt=DAStudio.message('RTW:autosar:maxShortNameLength');
        rtwoptions(end).type='Edit';
        rtwoptions(end).enable='on';
        rtwoptions(end).default='128';
        rtwoptions(end).tlcvariable='AutosarMaxShortNameLength';
        rtwoptions(end).tooltip=DAStudio.message('RTW:autosar:maxShortNameLengthTooltip');
        rtwoptions(end).callback='';
        rtwoptions(end).makevariable='';
        rtwoptions(end+1).prompt=DAStudio.message('RTW:autosar:compilerAbstractionMacros');
        rtwoptions(end).type='Checkbox';
        rtwoptions(end).enable='on';
        rtwoptions(end).default='off';
        rtwoptions(end).tlcvariable='AutosarCompilerAbstraction';
        rtwoptions(end).tooltip=DAStudio.message('RTW:autosar:compilerAbstractionMacrosTooltip');
        rtwoptions(end).callback='';
        rtwoptions(end).makevariable='';

        rtwoptions(end+1).prompt=DAStudio.message('RTW:autosar:matrixIOUsing1DArrays');
        rtwoptions(end).type='Checkbox';
        rtwoptions(end).enable='on';
        rtwoptions(end).default='off';
        rtwoptions(end).tooltip=DAStudio.message('RTW:autosar:matrixIOUsing1DArraysTooltip');
        rtwoptions(end).tlcvariable='AutosarMatrixIOAsArray';
        rtwoptions(end).callback='';
        rtwoptions(end).makevariable='';

        rtwoptions(end+1).type='NonUI';
        rtwoptions(end).enable='on';
        rtwoptions(end).default='off';
        rtwoptions(end).tlcvariable='DisableAUTOSARRoutinesHostLibrary';
        rtwoptions(end).callback='';
        rtwoptions(end).makevariable='';

        varargout{1}=rtwoptions;

    case 'ActivateCallBack'
        hSrc=varargin{1};
        hDlg=varargin{2};
        hParent=hSrc;
        while~isempty(hParent.getParent)&&isa(hParent.getParent,'Simulink.BaseConfig')
            hParent=hParent.getParent;
        end
        if(~hParent.getPropEnabled('SupportAbsoluteTime'))
            slConfigUISetEnabled(hDlg,hSrc,'SupportAbsoluteTime',1);
            slConfigUISetVal(hDlg,hSrc,'SupportAbsoluteTime','on');
        end
        slConfigUISetEnabled(hDlg,hSrc,'MultiInstanceERTCode',1);
        slConfigUISetEnabled(hDlg,hSrc,'RootIOFormat',1);
        slConfigUISetVal(hDlg,hSrc,'RootIOFormat','Individual arguments');
        slConfigUISetEnabled(hDlg,hSrc,'RootIOFormat',0);
        if(~hParent.getPropEnabled('ZeroInternalMemoryAtStartup'))
            slConfigUISetEnabled(hDlg,hSrc,'ZeroInternalMemoryAtStartup',1);
        end
        if(~hParent.getPropEnabled('InitFltsAndDblsToZero'))
            slConfigUISetEnabled(hDlg,hSrc,'InitFltsAndDblsToZero',1);
        end
        slConfigUISetEnabled(hDlg,hSrc,'TargetLang',0);
        slConfigUISetVal(hDlg,hSrc,'GenerateAllocFcn','off');
        slConfigUISetEnabled(hDlg,hSrc,'GenerateAllocFcn',0);
        slConfigUISetVal(hDlg,hSrc,'MultiInstanceErrorCode','Error');
        slConfigUISetEnabled(hDlg,hSrc,'MultiInstanceErrorCode',0);
        slConfigUISetEnabled(hDlg,hSrc,'IncludeMdlTerminateFcn',1);
        setProp(hSrc,'UseToolchainInfoCompliant','on');
        setProp(hSrc,'LookupTableObjectStructAxisOrder','2,1,3,4,...');
        slConfigUISetEnabled(hDlg,hSrc,'SupportVariableSizeSignals',1);
        slConfigUISetEnabled(hDlg,hSrc,'SupportNonFinite',1);
        slConfigUISetEnabled(hDlg,hSrc,'SupportComplex',1);
        slConfigUISetVal(hDlg,hSrc,'BooleansAsBitfields','off');
        slConfigUISetEnabled(hDlg,hSrc,'BooleansAsBitfields',0);

    case 'SelectCallBack'
        hSrc=varargin{1};
        hDlg=varargin{2};
        slConfigUISetVal(hDlg,hSrc,'ZeroExternalMemoryAtStartup','off');
        slConfigUISetEnabled(hDlg,hSrc,'ZeroExternalMemoryAtStartup',0);
        slConfigUISetVal(hDlg,hSrc,'ZeroInternalMemoryAtStartup','off');
        slConfigUISetVal(hDlg,hSrc,'CombineOutputUpdateFcns','on');
        slConfigUISetEnabled(hDlg,hSrc,'CombineOutputUpdateFcns',0);
        slConfigUISetVal(hDlg,hSrc,'SupportContinuousTime','off');
        slConfigUISetEnabled(hDlg,hSrc,'SupportContinuousTime',0);
        slConfigUISetVal(hDlg,hSrc,'SupportVariableSizeSignals','off');
        slConfigUISetEnabled(hDlg,hSrc,'SupportVariableSizeSignals',1);
        slConfigUISetVal(hDlg,hSrc,'SupportAbsoluteTime','on');
        slConfigUISetEnabled(hDlg,hSrc,'SupportAbsoluteTime',1);
        slConfigUISetVal(hDlg,hSrc,'SupportNonFinite','off');
        slConfigUISetEnabled(hDlg,hSrc,'SupportNonFinite',1);
        slConfigUISetVal(hDlg,hSrc,'IncludeMdlTerminateFcn','off');
        slConfigUISetEnabled(hDlg,hSrc,'IncludeMdlTerminateFcn',1);
        slConfigUISetVal(hDlg,hSrc,'GenerateSampleERTMain','off');
        slConfigUISetEnabled(hDlg,hSrc,'GenerateSampleERTMain',0);
        slConfigUISetVal(hDlg,hSrc,'TargetOS','BareBoardExample');
        slConfigUISetEnabled(hDlg,hSrc,'TargetOS',0);
        slConfigUISetVal(hDlg,hSrc,'MatFileLogging','off');
        slConfigUISetEnabled(hDlg,hSrc,'MatFileLogging',0);
        slConfigUISetVal(hDlg,hSrc,'GRTInterface','off');
        slConfigUISetEnabled(hDlg,hSrc,'GRTInterface',0);
        slConfigUISetVal(hDlg,hSrc,'SupportNonInlinedSFcns','off');
        slConfigUISetEnabled(hDlg,hSrc,'SupportNonInlinedSFcns',0);
        slConfigUISetVal(hDlg,hSrc,'SuppressErrorStatus','on');
        slConfigUISetEnabled(hDlg,hSrc,'SuppressErrorStatus',0);
        slConfigUISetVal(hDlg,hSrc,'GenCodeOnly','on');
        slConfigUISetVal(hDlg,hSrc,'ModelReferenceCompliant','on');
        slConfigUISetVal(hDlg,hSrc,'CreateSILPILBlock','None');
        slConfigUISetVal(hDlg,hSrc,'RootIOFormat','Individual arguments')
        slConfigUISetEnabled(hDlg,hSrc,'RootIOFormat',0);
        slConfigUISetVal(hDlg,hSrc,'EmbeddedCoderDictionary','')
        slConfigUISetEnabled(hDlg,hSrc,'EmbeddedCoderDictionary',0);
        slConfigUISetVal(hDlg,hSrc,'TargetLang','C')
        slConfigUISetEnabled(hDlg,hSrc,'TargetLang',0);
        slConfigUISetVal(hDlg,hSrc,'SupportComplex','off');
        slConfigUISetEnabled(hDlg,hSrc,'SupportComplex',1);
        slConfigUISetVal(hDlg,hSrc,'CodeInterfacePackaging','Nonreusable function');
        slConfigUISetEnabled(hDlg,hSrc,'MultiInstanceERTCode',1);
        slConfigUISetVal(hDlg,hSrc,'GenerateAllocFcn','off');
        slConfigUISetEnabled(hDlg,hSrc,'GenerateAllocFcn',0);
        slConfigUISetVal(hDlg,hSrc,'MultiInstanceErrorCode','Error');
        slConfigUISetEnabled(hDlg,hSrc,'MultiInstanceErrorCode',0);
        slConfigUISetVal(hDlg,hSrc,'AutosarCompliant',true)
        slConfigUISetEnabled(hDlg,hSrc,'AutosarCompliant',0);
        slConfigUISetVal(hDlg,hSrc,'ModelStepFunctionPrototypeControlCompliant',false)
        slConfigUISetEnabled(hDlg,hSrc,'ModelStepFunctionPrototypeControlCompliant',0);
        slConfigUISetVal(hDlg,hSrc,'CompOptLevelCompliant',true)
        slConfigUISetEnabled(hDlg,hSrc,'CompOptLevelCompliant',0);
        slConfigUISetVal(hDlg,hSrc,'ParMdlRefBuildCompliant',true)
        slConfigUISetEnabled(hDlg,hSrc,'ParMdlRefBuildCompliant',0);
        slConfigUISetVal(hDlg,hSrc,'ERTFirstTimeCompliant',true)
        slConfigUISetEnabled(hDlg,hSrc,'ERTFirstTimeCompliant',0);
        slConfigUISetVal(hDlg,hSrc,'IncludeERTFirstTime',false)
        setProp(hSrc,'UseToolchainInfoCompliant','on');
        setProp(hSrc,'LookupTableObjectStructAxisOrder','2,1,3,4,...');
        slConfigUISetVal(hDlg,hSrc,'LUTObjectStructOrderExplicitValues','Size,Breakpoints,Table');
        slConfigUISetEnabled(hDlg,hSrc,'LUTObjectStructOrderExplicitValues',0);
        slConfigUISetVal(hDlg,hSrc,'LUTObjectStructOrderEvenSpacing','Size,Table,Breakpoints');
        slConfigUISetEnabled(hDlg,hSrc,'LUTObjectStructOrderEvenSpacing',0);
        slConfigUISetVal(hDlg,hSrc,'BooleansAsBitfields','off');
        slConfigUISetEnabled(hDlg,hSrc,'BooleansAsBitfields',0);

    otherwise

    end






