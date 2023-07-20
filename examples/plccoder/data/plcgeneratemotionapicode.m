function plcgeneratemotionapicode(subsystem)

    if(nargin<1)
        subsystem=gcb;
    end


    [driveNames,dummyStateNames,motionApiNames,globalDataNames]=getDriveTemplateNames();


    blockH=get_param(subsystem,'handle');
    [modelH,portInfo,error_occ,ss2mdlExc]=coder.internal.ss2mdl(blockH,'SS2mdlForPLC',true);%#ok<ASGLU>

    newMdlName=get_param(modelH,'name');
    disp(['Created temporary model for code generation :',newMdlName]);


    rt=sfroot;
    machine=rt.find('-isa','Stateflow.Machine','Name',get_param(modelH,'Name'));

    for ii=1:length(driveNames)
        driveH=machine.find('-isa','Stateflow.AtomicSubchart','Name',driveNames{ii});
        for jj=1:length(driveH)
            delete(driveH(jj));
        end
    end
    for ii=1:length(dummyStateNames)
        dummyH=machine.find('-isa','Stateflow.State','Name',dummyStateNames{ii});
        for jj=1:length(dummyH)
            delete(dummyH(jj));
        end
    end

    for ii=1:length(motionApiNames)
        motionFnH=machine.find('-isa','Stateflow.Function','Name',motionApiNames{ii});
        for jj=1:length(motionFnH)
            delete(motionFnH(jj));
        end
    end

    chartName='';
    axisDataH=machine.find('-isa','Stateflow.Data','DataType','Bus: AXIS_SERVO_DRIVE','Scope','Local');
    for jj=1:length(axisDataH)
        if(isa(axisDataH(jj).up,'Stateflow.Chart'))
            axisDataH(jj).Scope='Input';
            chartName=axisDataH(jj).up.Name;
        end
    end


    modelName=get_param(modelH,'Name');
    load_system('MotionApiStubs');
    close_system_MotionApiStubs=onCleanup(@()close_system('MotionApiStubs'));
    add_block('MotionApiStubs/MotionApiStubs',[modelName,'/',get_param(subsystem,'Name'),'/MotionApiStubs'],'makeNameUnique','on');

    for jj=1:length(axisDataH)
        if(isa(axisDataH(jj).up,'Stateflow.Chart'))
            portName=axisDataH(jj).Name;
            add_block('MotionApiStubs/Axis',[modelName,'/',get_param(subsystem,'Name'),'/',portName]);
            add_line([modelName,'/',get_param(subsystem,'Name')],[portName,'/1'],[chartName,'/',num2str(jj)]);
        end
    end



    [srcCS,~]=plc_mdl_get_configset(modelH);
    plcConfig=srcCS.getComponent('PLC Coder');
    plcConfig.set_param('PLC_TargetIDE','studio5000');
    existingdefNames=plcConfig.get_param('PLC_ExternalDefinedNames');

    existingdefNamescell=strsplit(existingdefNames,'\n');

    newDefNames=existingdefNamescell;
    for iii=1:length(motionApiNames)
        if isempty(find(ismember(existingdefNamescell,motionApiNames{iii}),1))
            newDefNames{end+1}=motionApiNames{iii};%#ok<AGROW>
        end
    end

    for iii=1:length(globalDataNames)
        if isempty(find(ismember(existingdefNamescell,globalDataNames{iii}),1))
            newDefNames{end+1}=globalDataNames{iii};%#ok<AGROW>
        end
    end

    for iii=1:length(axisDataH)
        if isempty(find(ismember(existingdefNamescell,axisDataH(iii).Name),1))
            newDefNames{end+1}=axisDataH(iii).Name;%#ok<AGROW>
        end
    end

    newDefNames=strjoin(newDefNames,'\n');
    plcConfig.set_param('PLC_ExternalDefinedNames',newDefNames);




    plcConfig.set_param('PLC_GenerateReport','off');
    plcConfig.set_param('PLC_LaunchReport','off');


    open_system(modelH);
    close_system_modelH=onCleanup(@()bdclose(modelH));

    chart=machine.find('-isa','Stateflow.Chart','Name',chartName);


    cactionLanguage=1;
    if cactionLanguage==0
        error(['C action language is not supported '...
        ,'for generating structured text for motion api calls.'...
        ,'Please use matlab action language in your chart:',chartName]);
    else
        statesall=chart.find('-isa','Stateflow.State');
        for ii=1:length(statesall)

            if isempty(sf('SubstatesOf',statesall(ii).Id))
                removeMotionAPILHS(statesall(ii));
            end
        end
    end

    set_param(modelH,'UnconnectedInputMsg','none');
    set_param(modelH,'UnconnectedOutputMsg','none');
    set_param(modelH,'SolverType','fixed');
    set_param(modelH,'SimulationCommand','update');
    plcgeneratecode([modelName,'/',get_param(subsystem,'Name')]);

end

function[srcCS,origCS]=plc_mdl_get_configset(modelH)



    modelObj=get_param(modelH,'Object');
    origCS=modelObj.getActiveConfigSet();
    srcCS=origCS;
    while(isa(srcCS,'Simulink.ConfigSetRef'))
        srcCS=srcCS.getRefConfigSet();
    end
end

function removeMotionAPILHS(states)






    for iii=1:length(states)
        state=states(iii);
        sectionSnippetsMap=getStateSectionSnippets(state);

        out='';
        for sectionIndex=1:size(sectionSnippetsMap,1)
            section=sectionSnippetsMap{sectionIndex,1};
            sectionSnippet=sectionSnippetsMap{sectionIndex,2};
            if isempty(sectionSnippet)
                continue;
            else

                motionCommandNoLHS=stripMotionInstrLHS(sectionSnippet);
            end

            switch class(section)
            case 'Stateflow.Ast.EntrySection'
                out=[out,'entry:',motionCommandNoLHS];%#ok<AGROW>
            case 'Stateflow.Ast.DuringSection'
                out=[out,'during:',motionCommandNoLHS];%#ok<AGROW>
            case 'Stateflow.Ast.ExitSection'
                out=[out,'exit:',motionCommandNoLHS];%#ok<AGROW>
            case 'Stateflow.Ast.BindSection'
                out=[out,'bind:',motionCommandNoLHS];%#ok<AGROW>
            case 'Stateflow.Ast.OnEventSection'
                out=[out,'on ',section.condition{1}.sourceSnippet,':',motionCommandNoLHS];%#ok<AGROW>
            end
        end
        stateName=state.name;
        updatedStateLabelString=[stateName,newline,out];

        sf('set',state.id,'.labelString',updatedStateLabelString);
    end
end

function sectionSnippetsMap=getStateSectionSnippets(state)






    sNode=Stateflow.Ast.getContainer(state);


    sections=sNode.sections;


    sectionSnippetsMap=cell(length(sections),2);

    for secIndex=1:length(sections)
        section=sections{secIndex};



        roots=section.roots;
        sourceSnippet='';
        for rootIndex=1:length(roots)

            sourceSnippet=[sourceSnippet,roots{rootIndex}.sourceSnippet];%#ok<AGROW>
        end

        sectionSnippetsMap{secIndex,1}=section;
        sectionSnippetsMap{secIndex,2}=sourceSnippet;
    end
end

function motionCommandNoLHS=stripMotionInstrLHS(actions)




    m=mtree(actions);
    [~,~,motionCommands,~]=getDriveTemplateNames();

    calls=m.mtfind('Kind','CALL','Left.Fun',motionCommands,'Parent.Kind','EQUALS');





    if calls.isempty
        motionCommandNoLHS=actions;
        return;
    end

    replacements={};
    indices=calls.indices;
    for ii=1:length(indices)
        n=m.select(indices(ii));

        replacements=[replacements,{n.Parent,n.tree2str}];%#ok<AGROW>
    end

    updatedActions=m.tree2str(0,1,replacements);
    motionCommandNoLHS=updatedActions;
end
