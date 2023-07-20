function out=fitDataStepHandler(action,varargin)

    switch(action)
    case 'getFitDataStep'
        out=getFitDataStep(varargin{:});
    end

end

function dataStep=getFitDataStep(node,externalDataInfo)


    externalDataNames={};
    if~isempty(externalDataInfo.data)
        externalDataNames={externalDataInfo.data.name};
    end


    dataStep=struct;


    detailsNode=getField(node,'DataSettings');

    dataStep.dataMATFile=externalDataInfo.matfile;
    dataStep.dataMATFileVariableName=getAttribute(detailsNode,'DataSet');
    dataStep.dataName=getAttribute(detailsNode,'DataSet');
    dataStep.enabled=true;
    dataStep.name='DataFit';
    dataStep.type='DataFit';
    dataStep.version=1;
    dataStep.dataUnits={};



    if~any(ismember(externalDataNames,getAttribute(detailsNode,'DataSet')))
        dataStep.dataMATFileVariableName='';
        dataStep.dataName='';
    end


    for i=1:numel(externalDataInfo.data)
        if strcmp(externalDataInfo.data(i).name,dataStep.dataName)
            dataStep.dataUnits={externalDataInfo.data(i).dataInfo.columnInfo.units};
            break;
        end
    end


    dataStep.internal=getInternalStructTemplate();
    dataStep.internal.argtype='data';
    dataStep.internal.id=1;
    dataStep.internal.isSetup=true;

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
