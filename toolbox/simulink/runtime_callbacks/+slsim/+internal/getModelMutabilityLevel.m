function modelMutability=getModelMutabilityLevel(simStatus,isDeployed)






    if(isenum(simStatus))
        switch(simStatus)
        case slsim.SimulationStatus.Inactive
            if(isDeployed)

                modelMutability='runtorun';
            else

                modelMutability='any';
            end
        case{slsim.SimulationStatus.Initializing,...
            slsim.SimulationStatus.Initialized}
            modelMutability='runtorun';
        case slsim.SimulationStatus.Terminating
            modelMutability='none';
        otherwise
            modelMutability='runtime';
        end
    else
        switch(simStatus)
        case{'stopped','initializing'}
            modelMutability='any';
        case 'compiled'
            modelMutability='runtorun';
        case 'terminating'
            modelMutability='none';
        otherwise
            modelMutability='runtime';
        end
    end
end