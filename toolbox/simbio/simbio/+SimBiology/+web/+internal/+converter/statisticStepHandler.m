function out=statisticStepHandler(action,varargin)

    switch(action)
    case 'getStatisticsStep'
        out=getStatisticsStep(varargin{:});
    end

end

function statisticsStep=getStatisticsStep(taskNode)

    statisticsStep=getStatisticStepStruct;
    internalStruct=getInternalStructTemplate;
    internalStruct.argType='calculateStatistics';
    internalStruct.isSetup=true;


    statsRows={};
    simViewerNode=getField(taskNode,'SimulationViewer');

    if isempty(simViewerNode)
        statisticsStep.statistics=statsRows;
        return;
    end

    statisticsNodes=getField(simViewerNode,'Measurement');

    if~isempty(statisticsNodes)
        statsRows=getStatisticsTemplate;
        statsRows=repmat(statsRows,numel(statisticsNodes),1);

        for i=1:numel(statisticsNodes)
            statsRows(i).name=getAttribute(statisticsNodes(i),'Name');
            statsRows(i).value=getAttribute(statisticsNodes(i),'Expression');
            statsRows(i).message={};
        end


        statisticsStep.enabled=true;
    end

    statisticsStep.statistics=statsRows;

end

function out=getStatisticStepStruct

    out=struct;
    out.enabled=false;
    out.name='Calculate Statistics';
    out.type='Calculate Statistics';
    out.internal='';
    out.version=1;

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');

end

function out=getStatisticsTemplate

    out.ID='';
    out.use=true;
    out.name='';
    out.equal='=';
    out.value='';
    out.matlabError='';
    out.message='';
    out.type='';
end
