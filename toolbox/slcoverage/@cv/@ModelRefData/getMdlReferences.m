function[supportedrefs,supportedrefblocks]=getMdlReferences(mdl,allLevel,closeunopenedmodels,supportedSimModes)






    if nargin<2
        allLevel=false;
    end
    if nargin<3
        closeunopenedmodels=false;
    end
    if nargin<4
        supportedSimModes={'normal'};
    end


    open_diagrams=find_system('type','block_diagram');


    if~any(strcmp(mdl,open_diagrams))
        load_system(mdl);
    end





    supportedrefs={};
    supportedrefblocks={};
    toclose={};


    NestedFindMdlBlks(get_param(mdl,'Name'))

    function NestedFindMdlBlks(mdl)






















        if~isSupported(get_param(mdl,'SimulationMode'),supportedSimModes)
            return;
        end
        mdlblks=find_system(mdl,'FollowLinks','on',...
        'LookUnderMasks','all','MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
        'BlockType','ModelReference');

        if isempty(mdlblks)
            mdl_supportedlblks={};
            mdl_supportedrefs={};
        else
            ind_supported=isSupported(get_param(mdlblks,'SimulationMode'),supportedSimModes);
            ind_protected=strcmpi(get_param(mdlblks,'ProtectedModel'),'on');
            mdl_supportedlblks=mdlblks(ind_supported&~ind_protected);
            mdl_supportedrefs=get_param(mdl_supportedlblks,'ModelName');
        end



        if SlCov.CoverageAPI.supportObserverCoverage


            obsblks=find_system(mdl,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all',...
            'BlockType','ObserverReference');
        else
            obsblks=[];
        end
        if isempty(obsblks)
            obs_supportedlblks={};
            obs_supportedrefs={};
        else



            obs_supportedlblks=obsblks;
            obs_supportedrefs=get_param(obs_supportedlblks,'ObserverModelName');
        end

        supportedrefblocks=[supportedrefblocks;mdl_supportedlblks;obs_supportedlblks];
        locAllSupportedRefs=[mdl_supportedrefs;obs_supportedrefs];
        supportedrefs=unique([supportedrefs;locAllSupportedRefs]);

        if allLevel
            for ct=1:numel(locAllSupportedRefs)
                mn=locAllSupportedRefs{ct};
                if~any(strcmp(mn,open_diagrams))
                    load_system(mn);
                    toclose{end+1}=mn;%#ok<AGROW>
                end
                NestedFindMdlBlks(mn);
            end
        end
    end

    function match=matchFilterAllVariants(blk)%#ok<INUSD>
        match=true;
    end



    if closeunopenedmodels
        for ct_outer=1:length(toclose)
            close_system(toclose{ct_outer});
        end
    end
end

function ind_supported=isSupported(modes,supportedSimModes)
    ind_supported=ismember(lower(modes),lower(supportedSimModes));
end
