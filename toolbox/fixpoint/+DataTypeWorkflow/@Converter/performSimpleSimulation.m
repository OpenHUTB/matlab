function simOut=performSimpleSimulation(this,args)







    multiSimRuns=this.getMultiSimRunNames();
    isNotPreviousMultiSim=~ismember(this.CurrentRunName,multiSimRuns);
    assert(isNotPreviousMultiSim,message('FixedPointTool:fixedPointTool:msgRunNameExists',this.CurrentRunName));

    simOut=sim(this.TopModel,args{:});

    if~isa(simOut,'Simulink.SimulationOutput')



        warning(message('SimulinkFixedPoint:autoscaling:SIMBackwardsCompatibleSyntax'));
    else




        newRunID=DataTypeWorkflow.SigLogServices.getSDIRunID(this.TopModel,this.CurrentRunName,[]);
        sigLogStruct=struct('modelName',this.TopModel,'runID',newRunID);
        DataTypeWorkflow.SigLogServices.updateFromEventData(sigLogStruct);

    end







    SimulinkFixedPoint.ApplicationData.mergeModelReferenceData(get_param(this.TopModel,'Object'),this.CurrentRunName);


    this.createSettingsMapFromSystem(this.CurrentRunName);

end
