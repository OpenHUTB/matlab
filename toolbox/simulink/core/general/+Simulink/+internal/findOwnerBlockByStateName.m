function blockH=findOwnerBlockByStateName(subsysH,name)






    blockH=[];
    all_blks=find_system(subsysH,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'IsStateOwnerBlock','on');
    for idx=1:length(all_blks)
        blk=all_blks(idx);

        switch get_param(blk,'BlockType')
        case{'Delay','UnitDelay'}

            stateName=get_param(blk,'StateName');
            if strcmp(stateName,name)
                blockH=blk;
            end
        case{'DiscreteIntegrator','DiscreteStateSpace',...
            'DiscreteZeroPole','DiscreteFilter','DiscreteFir',...
            'DiscreteTransferFcn'}

            stateName=get_param(blk,'StateIdentifier');
            if strcmp(stateName,name)
                blockH=blk;
            end
        case{'Integrator','StateSpace'}

            stateName=get_param(blk,'ContinuousStateAttributes');
            if strcmp(stateName,char("'"+name+"'"))
                blockH=blk;
            end
        case{'SecondOrderIntegrator'}
            xname=get_param(blk,'StateNameX');
            if strcmp(xname,char("'"+name+"'"))
                blockH=blk;
            end
            dxname=get_param(blk,'StateNameDXDT');
            if strcmp(dxname,char("'"+name+"'"))
                blockH=blk;
            end
        case{'S-Function'}

            stateNames=Simulink.internal.getSFunctionStateNames(blk);
            for k=1:numel(stateNames)
                stateName=stateNames{k};
                if strcmp(stateName,name)
                    blockH=blk;
                end
            end
        otherwise

        end

    end
