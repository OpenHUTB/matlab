function updateCSOptionsForCoderTarget(hSrc,action,varargin)






    hCS=hSrc.getConfigSet;
    curCmd=get_param(hCS,'PostCodeGenCommand');
    coderTargetCommand='codertarget.postCodeGenHookCommand(h)';
    if isequal(action,'entry')


        isPrevConfiguredForSoC=false;
        if nargin==3
            isPrevConfiguredForSoC=varargin{1};
        end

        if isempty(curCmd)
            set_param(hCS,'PostCodeGenCommand',coderTargetCommand);
        elseif~contains(curCmd,coderTargetCommand)
            if~isequal(curCmd(end),';')
                curCmd(end+1)=';';
            end
            set_param(hCS,'PostCodeGenCommand',[curCmd,coderTargetCommand]);
        end
        updateTLCOptions(hCS,action);
        set_param(hCS,'ERTCustomFileTemplate','codertarget_file_process.tlc');
        if codertarget.utils.isMdlConfiguredForSoC(hCS)||...
isPrevConfiguredForSoC

        else
            set_param(hCS,'SolverType','Fixed-step');
        end
        set_param(hCS,'RTWCompilerOptimization','off');
        set_param(hCS,'GenerateMakefile','on');
        set_param(hCS,'GenerateSampleERTMain','off');
        set_param(hCS,'TemplateMakefile','ert_default_tmf');
        set_param(hCS,'MakeCommand','make_rtw');



        dlTarget=get_param(hCS,'DLTargetLibrary');
        if strcmpi(dlTarget,'mkl-dnn')
            set_param(hCS,'DLTargetLibrary','None');
        end
        set_param(hCS,'TargetLangStandard','C89/C90 (ANSI)');
        hCS.setPropEnabled('MaxStackSize',true);
        set_param(hCS,'MaxStackSize','64');
        coder.coverage.BuildHook.addHook(hCS,'codertarget.tools.BuildHook',...
        'argsAllComponents',{});
        codertarget.utils.setESBPluginAttached(hCS,...
        codertarget.utils.shouldESBPluginBeAttached(hCS));
    elseif isequal(action,'exit')
        newCommand=strrep(curCmd,coderTargetCommand,'');
        if isequal(newCommand,';')
            newCommand='';
        end
        set_param(hCS,'PostCodeGenCommand',newCommand);
        updateTLCOptions(hCS,action);
        if hCS.isValidParam('ERTCustomFileTemplate')
            set_param(hCS,'ERTCustomFileTemplate','example_file_process.tlc');
        end
        coder.coverage.BuildHook.removeHook(hCS,'codertarget.tools.BuildHook');
        codertarget.utils.setESBPluginAttached(hCS,...
        codertarget.utils.shouldESBPluginBeAttached(hCS));
    end
end


function updateTLCOptions(hCS,action)






    os=codertarget.targethardware.getTargetRTOS(hCS);
    tlcOptionsStr=get_param(hCS,'TLCOptions');
    tlcOptions=...
    {'-aInlineSetEventsForThisBaseRateFcn=TLC_FALSE';
    '-aSuppressMultiTaskScheduler=TLC_FALSE';...
    '-aRateBasedStepFcn=1';...
'-aRateBasedStepFcn=0'
    };
    if isequal(action,'entry')

        for i=1:numel(tlcOptions)
            if isempty(strfind(tlcOptionsStr,tlcOptions{i}))
                tlcOptionsStr=[tlcOptionsStr,char(32),tlcOptions{i}];%#ok<AGROW>
            end
        end

        if isequal(os,'Baremetal')
            tlcOptionsStr=strrep(tlcOptionsStr,tlcOptions{4},'');
            if isempty(strfind(tlcOptionsStr,tlcOptions{3}))
                tlcOptionsStr=[tlcOptionsStr,char(32),tlcOptions{3}];
            end
        else
            tlcOptionsStr=strrep(tlcOptionsStr,tlcOptions{3},'');
            if isempty(strfind(tlcOptionsStr,tlcOptions{4}))
                tlcOptionsStr=[tlcOptionsStr,char(32),tlcOptions{4}];
            end
        end
    else

        for i=1:numel(tlcOptions)
            if~isempty(strfind(tlcOptionsStr,tlcOptions{i}))
                tlcOptionsStr=strrep(tlcOptionsStr,tlcOptions{i},'');
            end
        end
    end
    set_param(hCS,'TLCOptions',strtrim(tlcOptionsStr));
end
