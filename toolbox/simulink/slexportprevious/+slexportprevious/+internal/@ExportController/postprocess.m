function postprocess(obj,dynamicRulesStruct,progressFcn)




    if~bdIsLoaded(obj.sourceModelName)
        DAStudio.error('Simulink:ExportPrevious:ModelNotLoaded',obj.sourceModelName);
    end

    p=Simulink.loadsave.ExportRuleProcessor(char(obj.targetModelFile),...
    char(obj.targetModelFile),obj.targetVersion.release);

    if isfield(dynamicRulesStruct,'Harnesses')
        harnessIDs=fieldnames(dynamicRulesStruct.Harnesses);
    else
        harnessIDs={};
    end


    rulesFolders=slexportprevious.internal.CallbackDispatcher.getDatabasePaths;

    progress_increment=1/(numel(harnessIDs)+numel(rulesFolders)+4);
    progress=0;
    progressFcn(0);

    function incrementProgress
        progress=progress+progress_increment;
        progressFcn(progress);
    end



    if isstruct(dynamicRulesStruct)
        if~isempty(harnessIDs)


            p.setPartsFilter(@i_is_system_bd_part);
        end

        if isa(dynamicRulesStruct.SystemBlockDiagram,'slexportprevious.RuleSet')
            try
                p.applyRules(dynamicRulesStruct.SystemBlockDiagram.getRules);
            catch E
                obj.reportAsWarning(E);
            end
        end
        incrementProgress();


        for i=1:numel(harnessIDs)
            rs=dynamicRulesStruct.Harnesses.(harnessIDs{i});
            if isa(rs,'slexportprevious.RuleSet')
                prefix=['/simulink/',harnessIDs{i},'/'];
                partsFilter=@(partdef)strncmp(partdef.name,prefix,numel(prefix));
                p.setPartsFilter(partsFilter);
                try
                    p.applyRules(rs.getRules);
                catch E
                    obj.reportAsWarning(E);
                end
            end
        end

        if isfield(dynamicRulesStruct,'PartSpecific')
            rulesTable=dynamicRulesStruct.PartSpecific;
            assert(isa(rulesTable,'table'));
            s=size(rulesTable);
            assert(s(2)==2);
            rows=s(1);
            for i=1:rows
                currentPart=table2cell(rulesTable(i,1));
                currentPart=currentPart{1};
                rules=table2cell(rulesTable(i,2));
                p.setPartsFilter(@(partdef)strcmp(partdef.name,currentPart));
                p.applyRules(rules);
            end
        end

        p.setPartsFilter([]);
    end


    for i=1:numel(rulesFolders)
        rf=slexportprevious.RulesFile.forFolder(rulesFolders{i});
        try
            p.applyRulesFile(rf.mFileName);
        catch E
            obj.reportAsWarning(E);
        end
        incrementProgress()
    end

    if~obj.isSLX

        container=get_param(obj.sourceModelName,'BlockDiagramType');
        container(1)=upper(container(1));
        verRule=slexportprevious.rulefactory.replaceParameterValue(...
        'Version','WILDCARD',obj.targetVersion.version_str);
        verRule=['<',container,verRule,'>'];

        p.applyRule(verRule);
    end

    p.close(true);

    incrementProgress();

    if obj.targetVersion.isMDL&&obj.targetVersion.isR2011bOrEarlier

        Simulink.data.revertSignalObjectsInModelFile(obj.targetModelFile);
    end

    assert(progress<1);
    progressFcn(1);

end

function x=i_is_system_bd_part(partdef)


    partname=partdef.name;
    x=true;
    slashes=find(partname=='/');
    if numel(slashes)<3
        return;
    end
    if slashes(2)~=10
        return;
    end
    if slashes(3)<14
        return;
    end
    if~strcmp(partname(2:9),'simulink')
        return;
    end
    f=partname(11:slashes(3)-1);
    s=find(f=='_');
    if isempty(s)
        return;
    end
    suffix=f(s(end)+1:end);
    if strcmp(suffix,'bd')||all(suffix>'0'&suffix<'9')
        x=false;
    end
end
