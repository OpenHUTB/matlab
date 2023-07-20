function report=sscScalableAdvisorImpl(modelName,blockPaths)






    if~(iscellstr(blockPaths)||isstring(blockPaths))
        pm_error('physmod:simscape:simscape:sb_advisor:InvalidPathsType');
    end


    statsSetting=simscape.internal.systemBundleStatistics('enabled',true);
    cacheSetting=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);


    sbSetting=simscape.internal.scalableBuild(false);


    c1=onCleanup(@()simscape.internal.systemBundleStatistics('enabled',statsSetting));
    c2=onCleanup(@()simscape.internal.cacheMethod(cacheSetting));
    c3=onCleanup(@()simscape.internal.scalableBuild(sbSetting));

    warnId='physmod:simscape:compiler:core:sf_xform:SourceNodeInReusableComponent';
    warnState=warning('query',warnId);
    c4=onCleanup(@()warning(warnState.state,warnId));
    warning('off',warnId);

    c5=onCleanup(@()builtin('_simscape_engine_sli_scalable_compile_set_reusable','reset'));

    wasLoaded=bdIsLoaded(modelName);
    if~wasLoaded
        load_system(modelName);
    else


        scalableSetting=get_param(modelName,'SimscapeCompileComponentReuse');
        c6=onCleanup(@()set_param(modelName,'SimscapeCompileComponentReuse',scalableSetting));
    end


    set_param(modelName,'SimscapeCompileComponentReuse','off');

    try
        for i=1:numel(blockPaths)
            blockPaths{i}=getfullname(blockPaths{i});
            if~strcmp(get_param(blockPaths{i},'BlockType'),'SubSystem')
                pm_error('physmod:simscape:simscape:sb_advisor:NonSubsystem',blockPaths{i});
            end
        end

        globalDisableFlags={};




        solverBlocks=find_system(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'ReferenceBlock',...
        'nesl_utility/Solver Configuration');
        for i=1:numel(solverBlocks)
            useLocalSolver=get_param(solverBlocks{i},'UseLocalSolver');
            if strcmp(useLocalSolver,'on')
                localSolverChoice=get_param(solverBlocks{i},'LocalSolverChoice');
                if strcmp(localSolverChoice,'NE_PARTITIONING_ADVANCER')
                    globalDisableFlags{end+1}='PartitioningSolver';
                end
            end
        end



        simscape.performance.timing.reset;
        simscape.performance.timing.setup({});


        simscape.internal.scalableBuildPatternReport('reset');


        ticStart=tic;
        set_param(modelName,'SimulationCommand','update');
        modelCompileTime=toc(ticStart);

        patternFlags=simscape.internal.scalableBuildPatternReport('report');
        if patternFlags.lti||patternFlags.swl
            globalDisableFlags{end+1}='LtiSwl';
        end
        if patternFlags.indexredux
            globalDisableFlags{end+1}='NonlinearHighIndex';
        end


        processNetworks=simscape.performance.timing.query('SimscapeProcessNetworks');
        setupSim=simscape.performance.timing.query('ExtensibleCompiler.SetupSimulation');

        ct.normalCompileTime=processNetworks.wall-sum([setupSim.wall]);
        ct.normalCompileMemory=compute_memory_usage(simscape.performance.timing.query(''));

        ct.totalCompilationTime=modelCompileTime;

        simscape.internal.scalableBuildPatternReport('reset');


        set_param(modelName,'SimscapeCompileComponentReuse','on');


        simscape.internal.systemBundleStatistics('clear');


        simscape.internal.scalableBuildPatternReport('reset');


        simscape.performance.timing.reset();
        simscape.performance.timing.setup({});


        builtin('_simscape_engine_sli_scalable_compile_set_reusable','set',modelName,blockPaths);
        set_param(modelName,'SimulationCommand','update');

        scalableCompile=simscape.performance.timing.query('SimscapeProcessNetworks');
        scalableSetupSim=simscape.performance.timing.query('ExtensibleCompiler.SetupSimulation');
        ct.scalableCompileTime=scalableCompile.wall-sum([scalableSetupSim.wall]);
        ct.scalableCompileMemory=compute_memory_usage(simscape.performance.timing.query(''));


        patternData=simscape.internal.scalableBuildPatternReport('report');

        data=simscape.internal.systemBundleStatistics('report');

        [sstable,ctable]=make_report(data,patternData);

    catch e

        if~wasLoaded
            close_system(modelName,0);
        end

        throwAsCaller(e);
    end

















    speedupAbsThresh=5;
    speedup=ct.normalCompileTime-ct.scalableCompileTime;

    recommend='';
    if~isempty(globalDisableFlags)
        recommend=char(txt('RecommendedDisable',modelName));
        for i=1:numel(globalDisableFlags)
            recommend=[recommend,newline,'  - ',char(txt(globalDisableFlags{i}))];
        end
    elseif(height(sstable)+height(ctable))>0&&speedup>speedupAbsThresh
        recommend=char(txt('RecommendedEnable',modelName));
    end

    report=simscape.ScalableReport(...
    'Model',modelName,...
    'Subsystems',sstable,...
    'Components',ctable,...
    'TotalModelCompilationTime',ct.totalCompilationTime,...
    'SimscapeCompilationTime',ct.normalCompileTime,...
    'PeakMemory',sprintf('%.0f MB',ct.normalCompileMemory/1e6),...
    'ScalableSimscapeCompilationTime',ct.scalableCompileTime,...
    'ScalablePeakMemory',sprintf('%.0f MB',ct.scalableCompileMemory/1e6),...
    'Recommendation',recommend);

    if~wasLoaded
        close_system(modelName,0);
    end
end


function mem=compute_memory_usage(perfLogData)
    memoryData=[perfLogData.memory];
    mem=max(memoryData)-min(memoryData);
end


function[ssreport,creport]=make_report(data,patternData)



    fcns=struct;
    fcns.getClassName=@(s)referencePath(s.block);
    fcns.getInstanceName=@(s)s.block;
    fcns.getComponents=@(data)data.subsystems;
    fcns.variableNames=...
    [txt('CompiledBlock')
    txt('InternalVariables')
    txt('InterfaceVariables')
    txt('ReusedBlocks')
    txt('Note')];
    subsysDetails=buildDetails(data,patternData.subsystemNotes,fcns);
    ssreport=buildTopTable(subsysDetails);


    fcns.getClassName=@(c)packagePath(c.file);
    fcns.getInstanceName=@(c)c.path;
    fcns.getComponents=@(data)data.components;
    fcns.variableNames=...
    [txt('CompiledComponent')
    txt('InternalVariables')
    txt('InterfaceVariables')
    txt('ReusedComponents')
    txt('Note')];
    componentDetails=buildDetails(data,patternData.componentNotes,fcns);
    creport=buildTopTable(componentDetails);
end


function topTable=buildTopTable(details)

    refs=keys(details);
    vals=values(details);

    N=numel(refs);

    totInst=zeros(N,1);
    compInst=zeros(N,1);
    reuse=strings(N,1);
    for i=1:N
        compInst(i)=height(vals{i});


        reusecnt=sum(cellfun(@(x)numel(x),vals{i}{:,4}));
        totInst(i)=compInst(i)+reusecnt;

        if totInst(i)==1
            reuse(i)="0%";
        else
            reuseNum=(totInst(i)-compInst(i))/(totInst(i)-1);
            reuse(i)=sprintf("%0.f%%",100*reuseNum);
        end
    end

    topTable=table(totInst,compInst,reuse,vals',...
    'VariableNames',...
    [txt('TotalInstances')
    txt('CompiledInstances')
    txt('Reuse')
    txt('Details')],'RowNames',refs);
end

function details=buildDetails(data,notes,fcns)

    details=containers.Map('KeyType','char','ValueType','any');

    for i=1:numel(data)
        details=process_bundle(details,fcns.getComponents(data{i}),fcns);
    end

    for i=1:numel(notes)
        details=add_note(details,notes(i),fcns);
    end
end

function details=process_bundle(details,subsystems,fcns)

    otherNetworkDetails=copymap(details);
    for i=1:numel(subsystems)
        details=process_subsystem(details,subsystems(i),otherNetworkDetails,fcns);
    end
end

function details=process_subsystem(details,subsystem,otherNetworkDetails,fcns)
    if isempty(subsystem.name)

        return
    end

    refPath=fcns.getClassName(subsystem);

    subsysDetails=compiled_details(subsystem,fcns);
    if details.isKey(refPath)
        if otherNetworkDetails.isKey(refPath)
            otherTable=otherNetworkDetails(refPath);
            if any(otherTable{:,1}==subsysDetails{1,1})

                note=strjoin([subsysDetails{1,txt('Note')},txt('MultipleNetworkInside')],newline);
                subsysDetails{1,txt('Note')}=strtrim(note);
            else

                note=strjoin([subsysDetails{1,txt('Note')},txt('MultipleNetworkUse')],newline);
                subsysDetails{1,txt('Note')}=strtrim(note);
            end
        end
        details(refPath)=[details(refPath);subsysDetails];
    else
        details(refPath)=subsysDetails;
    end

end

function t=compiled_details(subsystem,fcns)

    infVars=double(subsystem.mf.iflat_states);


    intVars=double(subsystem.mf.flat_states-infVars);


    reused=setdiff(subsystem.instances,fcns.getInstanceName(subsystem));

    t=table(string(fcns.getInstanceName(subsystem)),intVars,infVars,{string(reused)},"",...
    'VariableNames',fcns.variableNames);
end

function details=add_note(details,note,fcns)
    refPath=fcns.getClassName(note);

    if details.isKey(refPath)
        refDetails=details(refPath);
        lv=strcmp([refDetails{:,1}],fcns.getInstanceName(note));
        if any(lv)

            lv=lv&~contains(refDetails{:,end},note.msg);
            refDetails{lv,end}=strtrim(strcat(refDetails{lv,end},[newline,note.msg]));
        else

            refDetails=[refDetails;note2table(note,fcns)];
        end
        details(refPath)=refDetails;
    else

        details(refPath)=note2table(note,fcns);
    end
end

function t=note2table(note,fcns)
    t=table(string(fcns.getInstanceName(note)),NaN,NaN,{string.empty(1,0)},string(note.msg),...
    'VariableNames',fcns.variableNames);
end


function refPath=referencePath(blockPath)
    refSs=get_param(blockPath,'ReferencedSubsystem');
    refBlk=get_param(blockPath,'ReferenceBlock');


    if~strcmp(refSs,'')

        refPath=refSs;
    elseif~strcmp(refBlk,'')

        refPath=refBlk;
    else

        refPath=blockPath;
    end
end

function pkgPath=packagePath(filePath)
    getName=ne_private('ne_filetopackagefunction');
    pkgPath=getName(filePath);
end

function out=copymap(map)

    out=containers.Map('KeyType',map.KeyType,'ValueType',map.ValueType);
    if~isempty(map)
        out=containers.Map(keys(map),values(map));
    end
end

function str=txt(id,varargin)
    m=message(['physmod:simscape:simscape:sb_advisor:',id],varargin{:});
    str=m.string;
end
