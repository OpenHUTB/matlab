function updateOwnerBlockStateName(subsysH,oldName,validNewName)

    ownerBlk=Simulink.internal.findOwnerBlockByStateName(subsysH,oldName);
    if~isempty(ownerBlk)
        switch get_param(ownerBlk,'BlockType')
        case{'Delay','UnitDelay'}

            set_param(ownerBlk,'StateName',validNewName);
        case{'DiscreteIntegrator','DiscreteStateSpace',...
            'DiscreteZeroPole','DiscreteFilter',...
            'DiscreteFir',...
            'DiscreteTransferFcn'}

            set_param(ownerBlk,'StateIdentifier',validNewName);
        case{'Integrator','StateSpace'}

            set_param(ownerBlk,'ContinuousStateAttributes',string(char("'"+validNewName+"'")));
        case{'SecondOrderIntegrator'}
            xname=get_param(ownerBlk,'StateNameX');
            if strcmp(xname,oldName)
                set_param(ownerBlk,'StateNameX',string(char("'"+validNewName+"'")));
            end
            dxname=get_param(ownerBlk,'StateNameDXDT');
            if strcmp(dxname,oldName)
                set_param(ownerBlk,'StateNameDXDT',string(char("'"+validNewName+"'")));
            end
        case{'S-Function'}

            stateNames=Simulink.internal.getSFunctionStateNames(ownerBlk);
            newVal='';
            for k=1:numel(stateNames)
                stateName=stateNames{k};
                if strcmp(stateName,oldName)
                    newVal=newVal+newName;
                else
                    newVal=newVal+stateName;
                end
                if k<numel(stateNames)
                    newVal=newVal+',';
                end
            end
            set_param(ownerBlk,'SFcnStateName',newVal);
        otherwise

            assert(false);
        end

    end
