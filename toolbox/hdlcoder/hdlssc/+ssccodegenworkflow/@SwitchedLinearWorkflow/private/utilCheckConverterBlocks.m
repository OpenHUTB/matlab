function[linkedSubsystems,atomicSubsystems,referencedSubsystems,spsFilters,pssUnitConversion]=...
    utilCheckConverterBlocks(spsBlks,pssBlks,solverType)




    linkedSubsystems={};
    atomicSubsystems={};
    referencedSubsystems={};

    for block=[spsBlks,pssBlks]
        subsystemName=get_param(block{1},'parent');




        while get_param(subsystemName,'parent')




            if strcmpi(get_param(subsystemName,'LinkStatus'),'resolved')



                if isempty(linkedSubsystems)||~any(ismember(linkedSubsystems,{subsystemName}))
                    linkedSubsystems=[linkedSubsystems;{subsystemName}];%#ok<AGROW>
                end
            end



            if strcmpi(get_param(subsystemName,'TreatAsAtomicUnit'),'on')
                if isempty(atomicSubsystems)||~any(ismember(atomicSubsystems,{subsystemName}))
                    atomicSubsystems=[atomicSubsystems;{subsystemName}];%#ok<AGROW>
                end
            end
            if~isempty(get_param(subsystemName,'ReferencedSubsystem'))
                if isempty(referencedSubsystems)||~any(ismember(referencedSubsystems,{subsystemName}))
                    referencedSubsystems=[referencedSubsystems;{subsystemName}];%#ok<AGROW>
                end
            end


            subsystemName=get_param(subsystemName,'parent');
        end

    end



    spsFilters={};
    if(solverType)
        for block=spsBlks
            if~strcmp(get_param(block,'FilteringAndDerivatives'),'zero')
                if~strcmp(get_param(block,'FilteringAndDerivatives'),'provide')
                    spsFilters=[spsFilters,block];%#ok<AGROW>
                elseif~strcmp(get_param(block,'UdotUserProvided'),'0')
                    spsFilters=[spsFilters,block];%#ok<AGROW>
                end
            end
        end
    else
        for block=spsBlks
            if strcmp(get_param(block,'FilteringAndDerivatives'),'provide')
                if(~strcmp(get_param(block,'UdotUserProvided'),'0'))
                    spsFilters=[spsFilters,block];%#ok<AGROW>
                end
            end
        end
    end


    pssUnitConversion={};

    unitList={'1','V','A','inherit'};
    for block=pssBlks
        if~any(ismember(unitList,get_param(block,'Unit')))
            pssUnitConversion=[pssUnitConversion,block];%#ok<AGROW>
        end

    end

end

