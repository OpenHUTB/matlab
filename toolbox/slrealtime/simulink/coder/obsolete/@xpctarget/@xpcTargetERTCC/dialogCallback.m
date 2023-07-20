function dialogCallback(hObj,hDlg,tag,action)




    hSrc=hObj;

    switch tag
    case 'preApplyErrorCheck'
        return
    case 'Tag_ConfigSet_XPC_xPCisDefaultEnv'
        val=hDlg.getWidgetValue(tag);
        if val
            set(hSrc,'ExtMode','off');
        end

    case 'Tag_ConfigSet_XPC_xPCTargetPCEnvName'
        val=hDlg.getWidgetValue('Tag_ConfigSet_XPC_xPCisDefaultEnv');
        if~val
            tgs=xpctarget.targets;
            idx=strmatch(get(hSrc,'xPCTargetPCEnvName'),tgs.getTargetNames,'exact');
            if isempty(idx)
                disp(['Warning: Target PC ','''',get(hSrc,'xPCTargetPCEnvName'),'''','is not defined']);
            end
        end

    case 'Tag_ConfigSet_XPC_xPCisDownloadable'
        val=hDlg.getWidgetValue('Tag_ConfigSet_XPC_xPCisDefaultEnv');
        if~val
            tgs=xpctarget.targets;
            idx=strmatch(get(hSrc,'xPCTargetPCEnvName'),tgs.getTargetNames,'exact');
            if isempty(idx)
                disp(['Warning: Target PC ','''',get(hSrc,'xPCTargetPCEnvName'),'''','is not defined']);
            end
        end












    case{'Tag_ConfigSet_XPC_xPCisModelTimeout',...
        'Tag_ConfigSet_XPC_xPCLoadParamSetFile'}


    case 'Tag_ConfigSet_RTW_ERT_DataExchangeInterface'
        val=getWidgetValue(hDlg,tag);
        set(hSrc,'RTWCAPIParams','off');
        set(hSrc,'RTWCAPISignals','off');
        set(hSrc,'ExtMode','off');
        set(hSrc,'GenerateASAP2','off');
        switch val
        case 1
            set(hSrc,'RTWCAPIParams','on');
            set(hSrc,'RTWCAPISignals','on');
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_RTWCAPIParams',true);
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_RTWCAPISignals',true);
        case 2
            set(hSrc,'ExtMode','on');
        case 3
            set(hSrc,'GenerateASAP2','on');
        end
    case 'Tag_ConfigSet_RTW_ERT_SupportFloat'
        val=getWidgetValue(hDlg,tag);
        if~logical(val)
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportNonFinite',0);
            set(hSrc,'SupportNonFinite','off');
            set(hSrc,'PurelyIntegerCode','on');
        else
            set(hSrc,'PurelyIntegerCode','off');
        end

    case 'Tag_ConfigSet_RTW_ERT_GRTInterface'
        val=getWidgetValue(hDlg,tag);
        if logical(val)
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportFloat',true);
            set(hSrc,'PurelyIntegerCode','off');
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_CombineOutputUpdateFcns',false);
            set(hSrc,'CombineOutputUpdateFcns','off');
        end
    case 'Tag_ConfigSet_RTW_ERT_SuppressErrorStatus'
        val=getWidgetValue(hDlg,tag);
        if logical(val)
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportContinuousTime',false);
            set(hSrc,'SupportContinuousTime','off');
        end
    case 'Tag_ConfigSet_RTW_ERT_MatFileLogging'
        val=getWidgetValue(hDlg,tag);
        if logical(val)
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportFloat',true);
            set(hSrc,'PurelyIntegerCode','off');
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_IncludeMdlTerminateFcn',true);
            set(hSrc,'IncludeMdlTerminateFcn','on');
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SuppressErrorStatus',false);
            set(hSrc,'SuppressErrorStatus','off');
        end
    case 'Tag_ConfigSet_RTW_ERT_SupportNonInlinedSFcns'
        val=getWidgetValue(hDlg,tag);
        if logical(val)
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportFloat',true);
            set(hSrc,'PurelyIntegerCode','off');
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_SupportNonFinite',true);
            set(hSrc,'SupportNonFinite','on');
        end
    case{'Tag_ConfigSet_RTW_ERT_RTWCAPIParams',...
        'Tag_ConfigSet_RTW_ERT_RTWCAPISignals'}
        val1=strcmp(get(hSrc,'RTWCAPIParams'),'on');
        val2=strcmp(get(hSrc,'RTWCAPISignals'),'on');
        if~val1&&~val2
            disp(['Warning: C-API will not be generated.  To generate C-API, either'...
            ,' Signals or Parameters or both should be checked.']);
            setWidgetValue(hDlg,'Tag_ConfigSet_RTW_ERT_DataExchangeInterface',0);
        end

    case 'Tag_ConfigSet_RTW_Templates_ERTSrcFileBannerTemplate_Browse'
        val=getWidgetValue(hDlg,'Tag_ConfigSet_RTW_Templates_ERTSrcFileBannerTemplate');
        currFile='';
        if~isempty(val)
            currFile=which(val);
            if strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                currFile='';
            end
        end

        [filename,pathname]=uigetfile(...
        {'*.tlc','*.tlc';...
        '*.cgt','*.cgt'},...
        action,currFile);
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(hSrc,'ERTSrcFileBannerTemplate',filename);


        end

    case 'Tag_ConfigSet_RTW_Templates_ERTSrcFileBannerTemplate_Edit'
        if~isempty(hSrc.ERTSrcFileBannerTemplate)
            edit(hSrc.ERTSrcFileBannerTemplate);
        end


    case 'Tag_ConfigSet_RTW_Templates_ERTHdrFileBannerTemplate_Browse'
        val=getWidgetValue(hDlg,'Tag_ConfigSet_RTW_Templates_ERTHdrFileBannerTemplate');
        currFile='';
        if~isempty(val)
            currFile=which(val);
            if strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                currFile='';
            end
        end

        [filename,pathname]=uigetfile(...
        {'*.tlc','*.tlc';...
        '*.cgt','*.cgt'},...
        action,currFile);
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(hSrc,'ERTHdrFileBannerTemplate',filename);


        end

    case 'Tag_ConfigSet_RTW_Templates_ERTHdrFileBannerTemplate_Edit'
        if~isempty(hSrc.ERTHdrFileBannerTemplate)
            edit(hSrc.ERTHdrFileBannerTemplate);
        end


    case 'Tag_ConfigSet_RTW_Templates_ERTDataSrcFileTemplate_Browse'
        val=getWidgetValue(hDlg,'Tag_ConfigSet_RTW_Templates_ERTDataSrcFileTemplate');
        currFile='';
        if~isempty(val)
            currFile=which(val);
            if strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                currFile='';
            end
        end

        [filename,pathname]=uigetfile(...
        {'*.tlc','*.tlc';...
        '*.cgt','*.cgt'},...
        action,currFile);
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(hSrc,'ERTDataSrcFileTemplate',filename);


        end

    case 'Tag_ConfigSet_RTW_Templates_ERTDataSrcFileTemplate_Edit'
        if~isempty(hSrc.ERTDataSrcFileTemplate)
            edit(hSrc.ERTDataSrcFileTemplate);
        end


    case 'Tag_ConfigSet_RTW_Templates_ERTDataHdrFileTemplate_Browse'
        val=getWidgetValue(hDlg,'Tag_ConfigSet_RTW_Templates_ERTDataHdrFileTemplate');
        currFile='';
        if~isempty(val)
            currFile=which(val);
            if strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                currFile='';
            end
        end

        [filename,pathname]=uigetfile(...
        {'*.tlc','*.tlc';...
        '*.cgt','*.cgt'},...
        action,currFile);
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(hSrc,'ERTDataHdrFileTemplate',filename);


        end

    case 'Tag_ConfigSet_RTW_Templates_ERTDataHdrFileTemplate_Edit'
        if~isempty(hSrc.ERTDataHdrFileTemplate)
            edit(hSrc.ERTDataHdrFileTemplate);
        end


    case 'Tag_ConfigSet_RTW_Templates_ERTCustomFileTemplate_Browse'
        val=getWidgetValue(hDlg,'Tag_ConfigSet_RTW_Templates_ERTCustomFileTemplate');
        currFile='';
        if~isempty(val)
            currFile=which(val);
            if strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                currFile='';
            end
        end

        [filename,pathname]=uigetfile(...
        {'*.tlc','*.tlc';'*.cgt','*.cgt'},...
        action,currFile);
        if~isequal(filename,0)&&~isequal(pathname,0)
            set(hSrc,'ERTCustomFileTemplate',filename);


        end

    case 'Tag_ConfigSet_RTW_Templates_ERTCustomFileTemplate_Edit'
        if~isempty(hSrc.ERTCustomFileTemplate)
            edit(hSrc.ERTCustomFileTemplate);
        end


    case{'Tag_ConfigSet_RTW_DataPlacement_DataDefinitionFile',...
        'Tag_ConfigSet_RTW_DataPlacement_DataReferenceFile',...
        'Tag_ConfigSet_RTW_DataPlacement_ModuleName'}
        switch tag
        case 'Tag_ConfigSet_RTW_DataPlacement_DataDefinitionFile'
            param='DataDefinitionFile';
        case 'Tag_ConfigSet_RTW_DataPlacement_DataReferenceFile'
            param='DataReferenceFile';
        case 'Tag_ConfigSet_RTW_DataPlacement_ModuleName'
            param='ModuleName';
        end
        val=getWidgetValue(hDlg,tag);
        [errtxt,newval]=ec_check_user_entered_fields(param,val);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        set(hSrc,param,newval);
        setWidgetValue(hDlg,tag,newval);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_double'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.double=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_single'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.single=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int32'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.int32=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int16'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.int16=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int8'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.int8=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint32'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.uint32=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint16'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.uint16=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint8'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.uint8=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_boolean'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.boolean=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements,tag(end-2:end));
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.int=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements,tag(end-3:end));
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.uint=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_char'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements,tag(end-2:end));
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.char=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint64'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.uint64=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int64'
        val=getWidgetValue(hDlg,tag);
        replacements=get_param(hSrc,'ReplacementTypes');
        [errtxt,val]=ec_check_user_entered_fields('ReplacementTypes',val,replacements);
        if~isempty(errtxt)
            error('slrealtime:obsolete:xpcTargetERTCC:dialogCallback:dlgValue',errtxt);
        end
        replacements.int64=val;
        set_param(hSrc,'ReplacementTypes',replacements);

    case 'Tag_ConfigSet_RTW_Templates_GenerateSampleERTMain'
        val=getWidgetValue(hDlg,tag);
        if val==1
            setWidgetValue(hDlg,tag,0);
            set_param(hSrc,'GenerateSampleERTMain',0);
            error(message('slrealtime:obsolete:xpcTargetERTCC:xpcTargetERTCC:NoAlternateMain'));
        end

    otherwise
        error(message('slrealtime:obsolete:xpcTargetERTCC:xpcTargetERTCC:invalidDlgCb'));
    end

    hDlg.enableApplyButton(true,false);


    return


