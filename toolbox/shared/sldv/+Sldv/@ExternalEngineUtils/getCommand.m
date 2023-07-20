function[cmd,args,followUp,dvo,encryptDvo,extResults,validate,extKill]=getCommand(name)




    tc=Sldv.Token.get.getTestComponent;

    try
        [p,cmd,args,followUp,dvo,encryptDvo,extResults,validate,extKill]=findstrategy(name,tc);
    catch MEx %#ok<NASGU>
        cmd={};
        args='';
        followUp=0;
        dvo=false;
        encryptDvo=false;
        extResults=false;
        validate=false;
        extKill='';
        return;
    end



    if(2==slavteng('feature','MockingDvoAnalyzer'))
        args{2}=sldvprivate('sldvGetActiveSession',get_param(tc.analysisInfo.designModelH,'Name')).getMockLogPath();
    end

    if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        if(slfeature('RAOldPSBackend'))
            args=strcat(args,' -ps-old-be');
        end
        return;
    end

    originalargs=expandArguments(tc,args);
    originalargs=updateSkipPolyspaceDeadLogicArg(tc,originalargs);
    if tc.recordDvirSim
        args={};
        args{1}=strrep(originalargs{1},'dvoanalyzer','dvotool');
        args{2}='-dvirsim';

        cmd=strrep(cmd,'dvoanalyzer','dvotool');
    elseif~dvo

        cmd=strrep(cmd,'dvoanalyzer','dvotool');
        args=originalargs;
    else
        args=originalargs;
    end

    if~isempty(p)
        cmd=[p,filesep,cmd];
    end
end
function updatedArgs=updateSkipPolyspaceDeadLogicArg(tc,existingArgs)
    updatedArgs=existingArgs;
    if(tc.isPolyspaceDeadLogicSkipped()==true)
        updatedArgs{end+1}='-skip_psdeadlogic';
        updatedArgs{end+1}='-ps-quick';
    end
end

function args=expandArguments(tc,args)
    if isempty(tc)

    else
        opts=tc.activeSettings;
        for i=1:length(args)
            if strcmp(args{i},'$STEP_MAX$')
                max=opts.MaxViolationSteps;
                args{i}=num2str(max);
            end
        end
        if strcmp(opts.ExtendExistingTests,'on')
            args{end+1}='-extend';
        end


        args{end+1}='-t';
        if(opts.MaxProcessTime<34560000)
            args{end+1}=num2str(opts.MaxProcessTime);
        else
            args{end+1}='34560000';
        end

        args{end+1}='-l';
        assert(round(opts.AnalysisLevel)==opts.AnalysisLevel&&...
        0<=opts.AnalysisLevel&&opts.AnalysisLevel<=5);
        args{end+1}=num2str(opts.AnalysisLevel);





        if strcmp(opts.RandomizeNoEffectData,'on')
            args{end+1}='-randomize';
        end


        if(strcmp(opts.mode,'TestGeneration'))
            args{end+1}='-depth';
            args{end+1}=num2str(opts.MaxTestCaseSteps);

            args{end+1}='-mticks';
            args{end+1}=num2str(tc.slowestTaskTicks);
        end




        if(slavteng('feature','CoverageExtensionEnhancements')==1&&...
            (strcmp(opts.ModelCoverageObjectives,'None')||...
            (~strcmp(opts.CoverageDataFile,'')&&~strcmp(opts.ExtendExistingTests,'on'))))
            args{end+1}='-cov-extend';
        end


    end
end

function[p,cmd,args,followUp,dvo,encryptDvo,extResults,validate,extKill]=findstrategy(name,tc)
    engines=Sldv.ExternalEngineUtils.getAll;
    tc.analysisInfo.actualCommandForAnalysis=name;
    if(2==slavteng('feature','MockingDvoAnalyzer'))
        name='MockingDVOEngine';
    else
        name=translateInternalName(name);
    end
    for i=1:length(engines)
        try
            eng=eval(engines{i}.Name);
            if strcmp(eng.Name,name)
                p=eng.CommandPath;
                cmd=eng.Command;
                args=[eng.Command,eng.CommandArguments];
                followUp=eng.FollowUpStrategy;
                dvo=eng.UsesDVO;
                encryptDvo=eng.UsesEncryptedDVO;
                extResults=eng.AcceptExternalResults;
                validate=eng.ValidateSatisfiedResults;
                extKill=eng.ExternalKillCommand;
                return;
            end
        catch MEx %#ok<NASGU>

        end
    end
    error(message('Sldv:shared:DataUtils:InvalidExternalEngine'))

end

function name=translateInternalName(name)
    switch(lower(name))
    case 'combinedobjectives'
        name='(Experimental) Combined';
    case 'individualobjectives'
        name='(Experimental) Individual';
    case 'findviolation'
        name='Find Violation with Stubbing';
    case 'prove'
        name='Prove with Stubbing';
    case 'provewithviolationdetection'
        name='Prove with Violation Detection and Stubbing';
    case 'largemodel'
        name='(Experimental) Large Model';
    case 'longtestcases'
        name='(Experimental) Long Test Cases';
    end
end


