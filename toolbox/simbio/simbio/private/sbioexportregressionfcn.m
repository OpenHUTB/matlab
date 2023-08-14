function[y,t,simdata]=sbioexportregressionfcn(phi,timeVec,groupId,exportedModel,numGroups)





















    values=phi;
    if~all(isfinite(values))
        error(message('SimBiology:sbiofit:INVALID_ESTIMATED_PARAMETER'));
    end






    exportedModel.SimulationOptions.OutputTimes=timeVec;

    doses=exportedModel.Doses;
    if isempty(doses)
        groupDoseObjects=[];
    else
        doses=reshape(exportedModel.Doses,numGroups,[]);
        groupDoseObjects=doses(groupId,:);
    end



    if nargout<=2
        [t,y]=privatesimulate(exportedModel,phi,groupDoseObjects);
    else
        simdata=privatesimulate(exportedModel,phi,groupDoseObjects);
        t=simdata.Time;
        y=simdata.Data;
    end

end
