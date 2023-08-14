function[covData,runtestError,simOut]=getCoverageFromTestCases(obj,simData)



    numTestCases=numel(simData);
    covData=cell(1,numTestCases);
    simOut=cell(1,numTestCases);%#ok<PREALL>
    runtestError=false;

    try
        if~isa(simData,'Simulink.Simulation.Future')
            runtestError=all(arrayfun(@(eachData)eachData,simData)==-1);
        end

        if runtestError
            simOut=repmat({-1},1,numTestCases);



        else
            [simOut,covData]=obj.runTestObj.getSimulationResults(simData);
        end
    catch Mex %#ok<NASGU>
        runtestError=true;
        simOut=repmat({-1},1,numTestCases);
    end

    if~runtestError
        for idx=1:length(simOut)
            if~isempty(simOut{idx}.ErrorMessage)
                simOut{idx}=-1;
            end
        end
    end
end
