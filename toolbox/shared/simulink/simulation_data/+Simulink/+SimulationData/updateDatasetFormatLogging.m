function updateDatasetFormatLogging(top_mdl,variants,commented,saveFormat)























    narginchk(1,4);


    if nargin>0
        top_mdl=convertStringsToChars(top_mdl);
    end
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        variants='';
    end
    if nargin>1
        variants=convertStringsToChars(variants);
    end

    if nargin>2
        commented=convertStringsToChars(commented);
    end

    if nargin>3
        saveFormat=convertStringsToChars(saveFormat);
    end


    closeMdlObj=Simulink.SimulationData.ModelCloseUtil(true);%#ok<NASGU>


    if Simulink.internal.useFindSystemVariantsMatchFilter()
        args={};
        if strcmpi(variants,'ActiveVariants')||isempty(variants)
            args{end+1}='MatchFilter';
            args{end+1}=@Simulink.match.activeVariants;
        elseif strcmpi(variants,'ActivePlusCodeVariants')
            args{end+1}='MatchFilter';
            args{end+1}=@Simulink.match.codeCompileVariants;
        end
        if nargin>2
            args{end+1}='IncludeCommented';
            args{end+1}=commented;
        end
    else
        if nargin>2
            args={'Variants',variants,'IncludeCommented',commented};
        elseif nargin>1
            args={'Variants',variants};
        else
            args={};
        end
    end
    try
        mdls=find_mdlrefs(top_mdl,args{:});
    catch me
        throwAsCaller(me);
    end

    if nargin<4
        saveFormat='SignalLogging';
    else
        if~(strcmpi(saveFormat,'OutputAndState')||strcmpi(saveFormat,'SignalLogging'))
            DAStudio.error('Simulink:Logging:SigLogSaveFormatOption',saveFormat);
        end
    end



    anyChange=false;
    for idx=1:length(mdls)

        load_system(mdls{idx});


        wasDirty=strcmpi(get_param(mdls{idx},'Dirty'),'on');


        [changedThisMdl,changedCSRefs]=locCheckAndSetMdlSigLogSaveFormat(...
        mdls{idx},saveFormat);
        if~changedThisMdl&&isempty(changedCSRefs)

            continue;
        else
            anyChange=true;
        end


        SaveMdlAndReportMessages(mdls{idx},wasDirty,changedThisMdl,changedCSRefs);
    end


    if~anyChange
        str=DAStudio.message('Simulink:Logging:SigLogFormatUpdateNotNeed');
        fprintf('%s\n',str);
    end

end



function[isMdlChanged,changedCsRefs]=locCheckAndSetMdlSigLogSaveFormat(...
    mdl,saveFormat)



    isMdlChanged=false;
    changedCsRefs='';


    csNames=getConfigSets(mdl);
    for idx=1:length(csNames)
        csName=csNames{idx};


        cfgRefWSVarName='';


        cs=getConfigSet(mdl,csName);

        isCsRef=isa(cs,'Simulink.ConfigSetRef');
        if isCsRef
            try

                cfgRefWSVarName=cs.WSVarName;
                cs=cs.getRefConfigSet;
            catch %#ok<CTCH>

                continue;
            end
        end




        paramChanged=false;
        if strcmpi(saveFormat,'OutputAndState')
            fmt=get_param(cs,'SaveFormat');
            if~strcmpi(fmt,'Dataset')
                set_param(cs,'SaveFormat','Dataset')
                paramChanged=true;
            end
        else
            fmt=get_param(cs,'SignalLoggingSaveFormat');
            if strcmpi(fmt,'ModelDataLogs')
                set_param(cs,'SignalLoggingSaveFormat','Dataset')
                paramChanged=true;
            end
        end

        if paramChanged

            if isCsRef
                assert(~isempty(cfgRefWSVarName));
                if isempty(changedCsRefs)
                    changedCsRefs=cfgRefWSVarName;
                else
                    changedCsRefs=[changedCsRefs,', ',cfgRefWSVarName];%#ok
                end
            else
                isMdlChanged=true;
            end
        end
    end
end


function SaveMdlAndReportMessages(mdl,wasDirty,mdlChanged,changedCsRefs)


    if mdlChanged
        if~wasDirty
            try
                save_system(mdl);
                str=DAStudio.message('Simulink:Logging:SigLogFormatUpdateMsg',mdl);
            catch me
                disp(me.message);
                str=DAStudio.message('Simulink:Logging:SigLogFormatUpdateNoSaveMsg',mdl);
            end
        else
            str=DAStudio.message('Simulink:Logging:SigLogFormatUpdateNoSaveMsg',mdl);
        end
        fprintf('%s\n',str);
    end


    if~isempty(changedCsRefs)
        str=DAStudio.message('Simulink:Logging:SigLogFormatUpdateConfigSet',changedCsRefs);
        fprintf('%s\n',str);
    end
end

