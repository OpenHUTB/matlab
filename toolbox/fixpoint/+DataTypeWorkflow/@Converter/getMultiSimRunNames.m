function multiSimRunNames=getMultiSimRunNames(this,varargin)







    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=dataLayer.getWorkflowTopologyFacade(this.TopModel);

    if nargin==1


        allMultiSimIDs=facade.query(this.TopModel,'type','MultipleScenario');
    else


        mergedRunName=varargin{1};
        [~,mergedRunID]=dataLayer.getIdFromRunName(this.TopModel,mergedRunName);


        allMultiSimIDs=facade.query(num2str(mergedRunID),'search','parents','type','Collection');
    end




    if numel(allMultiSimIDs)==1&&isempty(allMultiSimIDs{1})
        numRuns=0;
    else
        numRuns=numel(allMultiSimIDs);
    end


    multiSimRunNames=cell(numRuns,1);


    for idx=1:numRuns
        fptID=str2double(allMultiSimIDs{idx});
        multiSimRunNames{idx}=dataLayer.getRunNameFromID(this.TopModel,fptID);
    end

end

