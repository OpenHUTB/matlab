function dryNodes=finddryhydraulicnodes(model,updateModel)















    domain='foundation.hydraulic.hydraulic';
    acrossvar='p';


    narginchk(1,2);

    if nargin<2
        updateModel=true;
    end




    solverBlocks=find_system(model,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'SubClassName','solver');
    for i=1:numel(solverBlocks)
        if strcmp(get_param(solverBlocks{i},'FrequencyDomain'),'on')
            error('physmod:simscape:compiler:sli:BadSolver','');
        end
    end


    [sf,ins,outs]=simscape.compiler.sli.componentModel(model,updateModel);


    if isempty(sf)

        dryNodes=[];
        return;
    elseif iscell(sf)

        compliant=cellfun(@getCompliantVars,sf,ins,outs,...
        'UniformOutput',false);


        compliant=vertcat(compliant{:});
    else
        compliant=getCompliantVars(sf,ins,outs);
    end



    gl=simscape.internal.lastTranslationResult(model);


    nodes=builtin('_ssc_get_simscape_nodes',gl,model);


    hydnodes=nodes(strcmp({nodes.domain},domain));


    dry=true(size(hydnodes));

    for i=1:numel(hydnodes)
        terminalNames=strcat({hydnodes(i).terminals.name},['.',acrossvar]);


        if numel(intersect(compliant,terminalNames))==numel(terminalNames)
            dry(i)=false;
        end
    end

    dryNodes=hydnodes(dry);


end

function compliant=getCompliantVars(sf,ins,outs)


    sf=simscape.xform(sf,containers.Map,ins);
    mf=simscape.sf2mf(sf,'FilteredInputs',ins,'FilteredOutputs',outs);
    compliant=builtin('_ssc_get_compliant_observables',mf);


end
