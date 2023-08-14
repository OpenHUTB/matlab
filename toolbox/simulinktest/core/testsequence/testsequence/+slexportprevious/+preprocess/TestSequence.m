function TestSequence(obj)




    if isR2016bOrEarlier(obj.ver)

        sfr=sfroot;
        machine=sfr.find('-isa','Stateflow.Machine','Name',obj.modelName);

        if isempty(machine)

            return;
        end

        tsBlks=machine.find('-isa','Stateflow.ReactiveTestingTableChart');
        if isempty(tsBlks)

            return;
        end

        if isR2014bOrEarlier(obj.ver)

            for tsBlk=tsBlks'
                obj.replaceWithEmptySubsystem(tsBlk.Path);
            end
        else
            if isR2015bOrEarlier(obj.ver)



                states=tsBlks.find('-isa','Stateflow.State');
                for state=states'
                    state.Description='';

                    try

                        if rmidata.isExternal(obj.modelName)
                            rmidata.RmiSlData.getInstance.set(state.Id,[]);
                        else
                            sf('set',state.Id,'.requirementInfo','');
                        end
                    catch ME

                        warning([message('Stateflow:reactive:UnableToClearRequirements').getString(),ME.message]);
                    end
                end
                arrayfun(@delete,tsBlks.find('-isa','Stateflow.Message','-or','-isa','Stateflow.FunctionCall'));
            end


            for tsBlk=tsBlks'
                set_param(tsBlk.Path,'SFBlockType','State Transition Table');
            end
        end
    end
end
