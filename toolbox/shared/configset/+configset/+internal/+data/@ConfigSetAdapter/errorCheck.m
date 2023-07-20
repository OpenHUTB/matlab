function newValue=errorCheck(~,cs,pdata,value)















    controller=cs.getDialogController;
    tag=pdata.getTag(cs);
    param=pdata.Name;
    newValue=value;
    switch tag
    case{'Tag_ConfigSet_CodeApp_DefineNamingFcn',...
        'Tag_ConfigSet_CodeApp_ParamNamingFcn',...
        'Tag_ConfigSet_CodeApp_SignalNamingFcn',...
        'Tag_ConfigSet_CodeApp_CustomCommentsFcn'}

        [errtxt,newValue]=ec_check_user_entered_fields(param,value);
        if~isempty(errtxt)
            me=MException('Simulink:SL_InvalidFcnName',errtxt);
            throw(me);
        end

    case{'Tag_ConfigSet_RTW_DataPlacement_DataDefinitionFile',...
        'Tag_ConfigSet_RTW_DataPlacement_DataReferenceFile',...
        'Tag_ConfigSet_RTW_DataPlacement_ModuleName'}

        [errtxt,newValue]=ec_check_user_entered_fields(param,value);
        if~isempty(errtxt)
            me=MException('Simulink:SL_InvalidFileModuleName',errtxt);
            throw(me);
        end

    case{'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_double',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_single',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int32',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int16',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int8',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint32',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint16',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint8',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_boolean',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_char',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_uint64',...
        'Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_int64'}

        changedField=tag(length('Tag_ConfigSet_RTW_ERT_Replacement_ReplacementTypes_')+1:end);
        fieldValue=value.(changedField);
        paramName=pdata.getParamName;
        [errtxt,newFieldVal]=ec_check_user_entered_fields(paramName,fieldValue,cs.get_param(paramName),changedField);
        newValue=value;
        newValue.(changedField)=newFieldVal;
        if~isempty(errtxt)
            me=MException('Simulink:SL_InvalidReplacementTypes',errtxt);
            throw(me);
        end

    case 'Tag_ConfigSet_RTW_CustomCode_RTWUseSimCustomCode'
        if strcmp(value,'on')
            if~CheckCustomCodeSettingsConsistency(cs)
                controller.ErrorDialog=...
                warndlg(getString(message('Simulink:dialog:EnableRTWUseSimCustomCodeWarning')));
            end
        end

    case 'Tag_ConfigSet_CodeApp_UseSimReservedNames'
        if strcmp(value,'on')
            if strcmp(cs.get_param('UseSimReservedNames'),'off')
                rtwval=cs.get_param('ReservedNameArray');
                if~isempty(rtwval)&&~isequal(rtwval,cs.get_param('SimReservedNameArray'))
                    controller.ErrorDialog=...
                    warndlg(getString(message('Simulink:dialog:EnableUseSimReservedNamesWarning')));
                end
            end
        end

    case '_pslink_PSPrjConfigFile_tag'
        if~isempty(value)
            pslink.verifier.ConfigFile.checkValidProjectFile(value);
        end

    case 'ConfigSet_HDLCoder_TestBenchPanel_FPToleranceValue'
        if value<0||isnan(value)
            error(message('HDLShared:CLI:missingparametervalue',message('HDLShared:hdldialog:hdlglblsettingsTBFloatToleranceValue').getString));
        end
    end

    function consistency=CheckCustomCodeSettingsConsistency(hConfigSet)
        model=get_param(hConfigSet.getModel,'Object');

        if isempty(model)
            isLib=false;
        else
            isLib=model.isLibrary;
        end


        if isLib&&~isequal(get_param(hConfigSet,'SimUseLocalCustomCode'),...
            get_param(hConfigSet,'RTWUseLocalCustomCode'))
            consistency=false;
            return;
        end

        rtwCustomSourceCode=get_param(hConfigSet,'CustomSourceCode');
        rtwCustomHeaderCode=get_param(hConfigSet,'CustomHeaderCode');
        rtwCustomInclude=get_param(hConfigSet,'CustomInclude');
        rtwCustomSource=get_param(hConfigSet,'CustomSource');
        rtwCustomLibrary=get_param(hConfigSet,'CustomLibrary');
        rtwCustomInitializer=get_param(hConfigSet,'CustomInitializer');
        rtwCustomTerminator=get_param(hConfigSet,'CustomTerminator');


        if isempty(rtwCustomSourceCode)&&...
            isempty(rtwCustomHeaderCode)&&...
            isempty(rtwCustomInclude)&&...
            isempty(rtwCustomSource)&&...
            isempty(rtwCustomLibrary)&&...
            isempty(rtwCustomInitializer)&&...
            isempty(rtwCustomTerminator)
            consistency=true;
            return;
        end

        consistency=isequal(rtwCustomSourceCode,get_param(hConfigSet,'SimCustomSourceCode'))&&...
        isequal(rtwCustomHeaderCode,get_param(hConfigSet,'SimCustomHeaderCode'))&&...
        isequal(rtwCustomInclude,get_param(hConfigSet,'SimUserIncludeDirs'))&&...
        isequal(rtwCustomSource,get_param(hConfigSet,'SimUserSources'))&&...
        isequal(rtwCustomLibrary,get_param(hConfigSet,'SimUserLibraries'))&&...
        isequal(rtwCustomInitializer,get_param(hConfigSet,'SimCustomInitializer'))&&...
        isequal(rtwCustomTerminator,get_param(hConfigSet,'SimCustomTerminator'));

