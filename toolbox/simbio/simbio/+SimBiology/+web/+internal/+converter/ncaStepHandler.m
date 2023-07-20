function out=ncaStepHandler(action,varargin)

    switch(action)
    case 'getNCAStep'
        out=getNCAStep(varargin{:});
    case 'getNCADataStep'
        out=getNCADataStep(varargin{:});
    end

end

function step=getNCAStep(externalDataNode,projectVersion)

    step=getNCAStepTemplate;
    step.internal=getInternalStructTemplate;


    definitionTable=struct('ID',-1,'classification','','column','','message',[]);
    definitionTable=repmat(definitionTable,6,1);

    classification={'Group','ID','Time','Concentration','IV Bolus Dose','Extravascular Dose'};
    switch projectVersion
    case{'5','5.1','5.2','5.3','5.4','5.5','5.6'}
        attribute={'Group','','Independent','DependentVariables0','DoseLabels0','DoseLabels1'};
    otherwise
        attribute={'NCAGroupColumn','NCAIDColumn','NCATimeColumn','NCAConcentrationColumn','NCAIVBolusDoseColumn','NCAExtravascularDoseColumn'};
    end

    for i=1:numel(definitionTable)
        definitionTable(i).classification=classification{i};
        definitionTable(i).column=getAttribute(externalDataNode,attribute{i});

        if isempty(definitionTable(i).column)
            definitionTable(i).column=' ';
        end
    end



    switch projectVersion
    case{'5','5.1','5.2','5.3','5.4','5.5','5.6'}


        if isempty(getAttribute(externalDataNode,'DoseLabels1'))&&~isempty(getAttribute(externalDataNode,'DoseLabels0'))
            doseType=getAttribute(externalDataNode,'TypeOfDose');
            if strcmpi(doseType,'ExtraVascular')
                definitionTable(end).column=getAttribute(externalDataNode,'DoseLabels0');
                definitionTable(end-1).column=' ';
            end
        end
    end

    step.definition=definitionTable;


    props={'cmaxTimeRange','lambdaTimeRange','loq','partialAUC','sparseSampling'};
    switch projectVersion
    case{'5','5.1','5.2','5.3','5.4','5.5','5.6'}
        attribute={'NCACmaxTimeRange','NCALamdaTimeRange','LOQ','NCAPartialAUC','SparseSampling'};
    otherwise
        attribute={'NCACmaxTimeRange','NCALamdaTimeRange','NCALOQ','NCAPartialAUC','SparseSampling'};
    end

    for i=1:numel(props)
        step.(props{i})=getAttribute(externalDataNode,attribute{i});
    end


    cmaxMessage=SimBiology.web.ncahandler('verifyRange',struct('value',step.cmaxTimeRange,'supportsMultiple',true));
    if cmaxMessage{2}.error
        cmaxMessage=struct('type','error','id','NCA_INVALID_RANGE','message','The value for CMax Time Range is invalid. Specify as list of [min max] values, e.g. [1 4], [6 8]');
    else
        cmaxMessage={};
    end

    lambdaTimeRangeMessage=SimBiology.web.ncahandler('verifyRange',struct('value',step.lambdaTimeRange,'supportsMultiple',false));
    if lambdaTimeRangeMessage{2}.error
        lambdaTimeRangeMessage=struct('type','error','id','NCA_INVALID_RANGE','message','The value for Lambda Time Range is invalid. Specify as [min max], e.g. [1 8]');
    else
        lambdaTimeRangeMessage={};
    end

    partialAUCMessage=SimBiology.web.ncahandler('verifyRange',struct('value',step.partialAUC,'supportsMultiple',true));
    if partialAUCMessage{2}.error
        partialAUCMessage=struct('type','error','id','NCA_INVALID_RANGE','message','The value for Partial AUC is invalid. Specify as list of [min max] values, e.g. [1 4], [6 8]');
    else
        partialAUCMessage={};
    end

    step.internal.cmaxTimeRangeMessage=cmaxMessage;
    step.internal.lambdaTimeRangeMessage=lambdaTimeRangeMessage;
    step.internal.partialAUCMessage=partialAUCMessage;
    step.internal.id=2;

end

function dataStep=getNCADataStep(externalDataInfo)


    dataStep=struct;
    dataStep.dataMATFile=externalDataInfo.matfileName;
    dataStep.dataMATFileVariableName=externalDataInfo.matfileVariableName;
    dataStep.matfileDerivedVariableName=externalDataInfo.matfileDerivedVariableName;
    dataStep.dataName=externalDataInfo.name;
    dataStep.enabled=true;
    dataStep.name='DataNCA';
    dataStep.type='DataNCA';
    dataStep.version=1;
    dataStep.dataUnits={externalDataInfo.dataInfo.columnInfo.units};


    dataStep.internal=getInternalStructTemplate;
    dataStep.internal.argtype='data';
    dataStep.internal.id=1;
    dataStep.internal.isSetup=true;

end

function out=getNCAStepTemplate

    out=struct;
    out.cmaxTimeRange='';
    out.definition='';
    out.description='';
    out.enabled=true;
    out.internal='';
    out.lambdaTimeRange='';
    out.loq=0;
    out.name='NCA';
    out.partialAUC='';
    out.sparseSampling=false;
    out.type='NCA';
    out.version=1;

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');
end
