


function[blockH,names]=getAllOwnerBlocksForStateAccess(subsysH)



    blockH={};
    names={};
    if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')


        all_blks=find_system(subsysH,'LookUnderMasks','all','FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IsStateOwnerBlock','on');
    else
        all_blks=find_system(subsysH,'LookUnderMasks','all','FollowLinks','on',...
        'MatchFilter',@Simulink.match.allVariants,'IsStateOwnerBlock','on');
    end
    for idx=1:length(all_blks)
        blk=all_blks(idx);

        switch get_param(blk,'BlockType')
        case{'Delay','UnitDelay'}

            stateName=get_param(blk,'StateName');
            if isvarname(stateName)
                blockH{end+1}=blk;
                names{end+1}=stateName;
            end
        case{'DiscreteIntegrator','DiscreteStateSpace',...
            'DiscreteZeroPole','DiscreteFilter','DiscreteFir',...
            'DiscreteTransferFcn'}

            stateName=get_param(blk,'StateIdentifier');
            if isvarname(stateName)
                blockH{end+1}=blk;
                names{end+1}=stateName;
            end
        case{'Integrator','StateSpace'}

            stateName=get_param(blk,'ContinuousStateAttributes');
            if~isvarname(stateName)

                subName=stateName(2:end-1);
                if isvarname(subName)
                    blockH{end+1}=blk;
                    names{end+1}=subName;
                end
            end
        case{'SecondOrderIntegrator'}
            xname=get_param(blk,'StateNameX');
            if~isvarname(xname)

                subName=xname(2:end-1);
                if isvarname(subName)
                    blockH{end+1}=blk;
                    names{end+1}=subName;
                end
            end
            dxname=get_param(blk,'StateNameDXDT');
            if~isvarname(dxname)

                subName=dxname(2:end-1);
                if isvarname(subName)
                    blockH{end+1}=blk;
                    names{end+1}=subName;
                end
            end
        case{'S-Function'}

            stateNames=Simulink.internal.getSFunctionStateNames(blk);
            for k=1:numel(stateNames)
                stateName=stateNames{k};
                if isvarname(stateName)
                    blockH{end+1}=blk;
                    names{end+1}=stateName;
                end
            end
        otherwise

        end

    end
