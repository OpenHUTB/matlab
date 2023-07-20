function FailingObjs=SingleEMLBlockCallBack(system,hObjectFcn)




















    FailingObjs={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{2}.Value,inputParams{3}.Value);
    fcnObjs=mdladvObj.filterResultWithExclusion(fcnObjs);


    s=size(fcnObjs);
    if s(1)~=length(fcnObjs)

        fcnObjs=fcnObjs';
    end
    if inputParams{1}.Value
        fcnObjs=Advisor.Utils.Eml.getReferencedMFiles(system,fcnObjs);
    end


    for i=1:length(fcnObjs)
        FailingObjs=[FailingObjs;hObjectFcn(fcnObjs{i})];%#ok<AGROW>
    end

end