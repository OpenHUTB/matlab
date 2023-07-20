function loc=generateReportForDCE(name,location,type,projectPath,artifactScope,launchReport)





    resource=metric.internal.algorithms.DesignCostDataServiceResource.EstimationData;


    resource.updateArtifacts(projectPath);



    if(resource.isEmpty())
        error(message('SimulinkFixedPoint:designCostEstimation:runInCurrentSession'));
    end


    reportGenService=designcostestimation.internal.services.ReportGeneration(resource.getUpdatedData(projectPath,artifactScope),name,type,location);
    reportGenService.runService(launchReport);
    loc=reportGenService.ReportFullFile;
end
