function out=modelStepHandler(action,varargin)

    switch(action)
    case 'getModelStep'
        out=getModelStep(varargin{:});
    end

end

function modelStep=getModelStep(node,modelSessionID,projectVersion)


    model=getModelFromSessionID(modelSessionID);


    modelStep=getModelSection(node,modelSessionID);
    modelStep.enabled=true;


    [doses,doseTableData]=getDoseSection(node,model,projectVersion);
    modelStep.doses=doses;
    modelStep.internal.dosesRawTableData=doseTableData;


    explorerSection=getExplorerSection(node,model);
    dosesToAdjust=getDosesToAdjustInfo(node,model,projectVersion,doses);
    explorerSection.sliders=vertcat(explorerSection.sliders,dosesToAdjust);
    modelStep.explorer=explorerSection;


    modelStep.statesToLog=getStatesToLogSection(node,model);


    modelStep.statesToLogAll=false;
    modelStep.statesToLogUseConfigset=true;
    statesToLog=getField(node,'StatesToLog');
    if~isempty(statesToLog)
        modelStep.statesToLogUseConfigset=~getAttribute(statesToLog,'TaskSpecific');
    end


    modelStep.variants=getVariantSection(node,model,projectVersion);

end

function modelSection=getModelSection(node,modelSessionID)

    modelSection=getModelStepTemplate;
    modelSection.model=modelSessionID;
    modelSection.accelerate=getAttribute(node,'Accelerate',false);


    modelSection.internal.argType='model';
    modelSection.internal.id=1;
    modelSection.internal.isSetup=true;


    modelSection.internal.args.supportDose=true;
    modelSection.internal.args.supportStatesToLog=true;
    modelSection.internal.args.supportVariant=true;
    modelSection.internal.args.supportsAccelerate=true;

end

function[doses,doseRawTableData]=getDoseSection(node,model,projectVersion)

    switch projectVersion
    case{'4.1'}
        [doses,doseRawTableData]=getDoseSectionR2012a(node,model);
    case{'4.2','4.3','4.3.1'}
        [doses,doseRawTableData]=getDoseSectionPre2014b(node,model);
    otherwise
        [doses,doseRawTableData]=getDoseSectionPost2014b(node,model);
    end

end

function[doses,doseRawTableData]=getDoseSectionPost2014b(node,model)

    dosesToApply=getField(node,'DosesToApply');
    if isempty(dosesToApply)
        doses=[];
        doseRawTableData=populateDoseTableData(doses);
        return;
    end

    doseNodes=getField(dosesToApply,'DoseRowObject');

    if isempty(doseNodes)
        doses=[];
        doseRawTableData=populateDoseTableData(doses);
        return;
    end


    if~isempty(model)
        doseObjs=model.getdose;
        doseObjNames={doseObjs.name};
    else
        doseObjs=[];
        doseObjNames={};
    end


    template=getDoseTemplate;
    doses=repmat(template,numel(doseNodes),1);

    for i=1:numel(doseNodes)
        doses(i).name=getAttribute(doseNodes(i),'Name');
        doses(i).use=getAttribute(doseNodes(i),'Selected');

        obj=doseObjs(ismember(doseObjNames,doses(i).name));
        if~isempty(obj)
            doses(i).sessionID=obj.sessionID;
            doses(i).UUID=obj.UUID;
            doses(i).type=obj.Type;
        end
    end


    doseRawTableData=populateDoseTableData(doses);

end

function[doses,doseRawTableData]=getDoseSectionPre2014b(node,model)

    doseNodes=getField(node,'Doses');

    if isempty(doseNodes)
        doses=[];
    else
        numDoses=getAttribute(doseNodes,'SelectedDosesCount');

        if isempty(numDoses)||isnan(numDoses)
            doses=[];
        else

            if~isempty(model)
                doseObjs=model.getdose;
                doseObjNames={doseObjs.name};
            else
                doseObjs=[];
                doseObjNames={};
            end


            doses=getDoseTemplate;
            doses=repmat(doses,numDoses,1);


            for i=1:numDoses
                doses(i).name=getAttribute(doseNodes,sprintf('SelectedDoses%d',i-1));

                obj=doseObjs(ismember(doseObjNames,doses(i).name));
                if~isempty(obj)
                    doses(i).sessionID=obj.sessionID;
                    doses(i).UUID=obj.UUID;
                    doses(i).type=obj.Type;
                end
            end
        end
    end


    doseRawTableData=populateDoseTableData(doses);

end

function[doses,doseRawTableData]=getDoseSectionR2012a(node,model)

    doseNodes=getField(node,'Doses');

    if isempty(doseNodes)
        doses=[];
    else

        if~isempty(model)
            doseObjs=model.getdose;
            doseObjNames={doseObjs.name};
        else
            doseObjs=[];
            doseObjNames={};
        end


        doseNames=getAttribute(doseNodes,'SelectedDoses');
        if~isempty(doseNames)
            doseNames=textscan(doseNames(2:end-1),'%s','Delimiter',',');
            doseNames=doseNames{1};
        end

        numDoses=numel(doseNames);
        doses=getDoseTemplate;
        doses=repmat(doses,numDoses,1);


        for i=1:numDoses
            doses(i).name=doseNames{i};
            obj=doseObjs(ismember(doseObjNames,doses(i).name));
            if~isempty(obj)
                doses(i).sessionID=obj.sessionID;
                doses(i).UUID=obj.UUID;
                doses(i).type=obj.Type;
            end
        end
    end


    doseRawTableData=populateDoseTableData(doses);

end

function tableData=populateDoseTableData(doses)

    tableData=getDoseInternalTemplate;
    tableData=repmat(tableData,numel(doses),1);

    for i=1:numel(doses)
        tableData(i).use=doses(i).use;
        tableData(i).name=doses(i).name;
        tableData(i).sessionID=doses(i).sessionID;
        tableData(i).UUID=doses(i).UUID;
    end

end

function explorerSection=getExplorerSection(taskNode,model)

    simViewer=getField(taskNode,'SimulationViewer');
    if isempty(simViewer)
        explorerSection=getExplorerSectionTemplate;
        explorerSection.type='Model Explorer';
        explorerSection.sliders=[];
        return;
    end

    sliderNodes=getField(simViewer,'TunableParameter');
    if isempty(sliderNodes)||isempty(model)
        sliders=[];
    else
        template=struct('maxValue',0,'minValue',0,'pqn','',...
        'sessionID',-1,'UUID',-1,'type','','use',true,...
        'value','','property','');

        sliders=repmat(template,length(sliderNodes),1);

        for i=1:numel(sliderNodes)
            sliders(i).pqn=getAttribute(sliderNodes(i),'PQN');
            sliders(i).minValue=getAttribute(sliderNodes(i),'MinValue');
            sliders(i).maxValue=getAttribute(sliderNodes(i),'MaxValue');
            sliders(i).value=getAttribute(sliderNodes(i),'Value');



            if isnan(sliders(i).value)
                sliders(i).value=sliders(i).minValue;
            end
        end


        for i=1:numel(sliders)
            obj=getObject(model,sliders(i).pqn);
            if~isempty(obj)
                sliders(i).sessionID=obj.sessionID;
                sliders(i).UUID=obj.UUID;
                sliders(i).type=obj.Type;
                sliders(i).pqn=obj.PartiallyQualifiedNameReally;
            end
        end
    end


    explorerSection=getExplorerSectionTemplate;
    explorerSection.type='Model Explorer';
    explorerSection.sliders=sliders;

end

function sliderInfo=getDosesToAdjustInfo(taskNode,model,projectVersion,doses)

    sliderInfo=[];
    simViewer=getField(taskNode,'SimulationViewer');
    if isempty(simViewer)
        return;
    end

    dosesToExplore=getField(simViewer,'DosesToExplore');
    if isempty(dosesToExplore)
        return;
    end




    maxPercent=getAttribute(simViewer,'TunableParameterMaxValue');
    minPercent=getAttribute(simViewer,'TunableParameterMinValue');

    maxPercent=(1+maxPercent/100);
    minPercent=(1-minPercent/100);

    template=struct('maxValue',0,'minValue',0,'pqn','',...
    'sessionID',-1,'UUID',-1,'type','','use',true,'value',0);

    sliderAmount=repmat(template,1,numel(dosesToExplore));
    sliderTime=repmat(template,1,numel(dosesToExplore));
    sliderRate=repmat(template,1,numel(dosesToExplore));

    for i=1:numel(sliderAmount)
        sliderAmount(i).property='Amount';
        sliderAmount(i).pqn=getAttribute(dosesToExplore(i),'Name');
        sliderAmount(i).value=getAttribute(dosesToExplore(i),'Amount0');



        switch projectVersion
        case{'5','5.1','5.2'}
            amountCount=getAttribute(dosesToExplore(i),'AmountCount');
            if amountCount>0
                maxAmount=getAttribute(dosesToExplore(i),sprintf('Amount%d',(amountCount-1)));
                minAmount=getAttribute(dosesToExplore(i),'Amount0');
            else
                maxAmount=0;
                minAmount=0;
            end

            sliderAmount(i).minValue=round(minAmount*minPercent,4);
            sliderAmount(i).maxValue=round(maxAmount*maxPercent,4);
        otherwise
            sliderAmount(i).minValue=roundValue(getAttribute(dosesToExplore(i),'MinAmount'),4);
            sliderAmount(i).maxValue=roundValue(getAttribute(dosesToExplore(i),'MaxAmount'),4);
        end
    end

    for i=1:numel(sliderTime)
        sliderTime(i).property='StartTime';
        sliderTime(i).pqn=getAttribute(dosesToExplore(i),'Name');
        sliderTime(i).value=getAttribute(dosesToExplore(i),'Time0');



        switch projectVersion
        case{'5','5.1','5.2'}
            timeCount=getAttribute(dosesToExplore(i),'TimeCount');
            if timeCount>0
                maxTime=getAttribute(dosesToExplore(i),sprintf('Time%d',(timeCount-1)));
                minTime=getAttribute(dosesToExplore(i),'Time0');
            else
                maxTime=0;
                minTime=0;
            end

            sliderTime(i).minValue=round(minTime*minPercent,4);
            sliderTime(i).maxValue=round(maxTime*maxPercent,4);
        otherwise
            sliderTime(i).minValue=roundValue(getAttribute(dosesToExplore(i),'MinTime'),4);
            sliderTime(i).maxValue=roundValue(getAttribute(dosesToExplore(i),'MaxTime'),4);
        end
    end

    for i=1:numel(sliderRate)
        sliderRate(i).property='Rate';
        sliderRate(i).pqn=getAttribute(dosesToExplore(i),'Name');
        sliderRate(i).value=getAttribute(dosesToExplore(i),'Rate0');



        switch projectVersion
        case{'5','5.1','5.2'}
            rateCount=getAttribute(dosesToExplore(i),'RateCount');
            if rateCount>0
                maxRate=getAttribute(dosesToExplore(i),sprintf('Rate%d',(rateCount-1)));
                minRate=getAttribute(dosesToExplore(i),'Rate0');
            else
                maxRate=0;
                minRate=0;
            end

            sliderRate(i).minValue=round(minRate*minPercent,4);
            sliderRate(i).maxValue=round(maxRate*maxPercent,4);

        otherwise
            sliderRate(i).minValue=roundValue(getAttribute(dosesToExplore(i),'MinRate'),4);
            sliderRate(i).maxValue=roundValue(getAttribute(dosesToExplore(i),'MaxRate'),4);
        end
    end


    sliders=[sliderAmount,sliderTime,sliderRate];
    sliders=reshape(sliders',1,numel(sliders));



    for i=1:numel(sliders)
        if isempty(sliders(i).value)||isnan(sliders(i).value)
            sliders(i).value=sliders(i).minValue;
        end
    end


    for i=1:numel(sliders)
        obj=getObject(model,sliders(i).pqn);

        if~isempty(obj)&&strcmp(obj.Type,'repeatdose')&&isDoseInTask(doses,sliders(i).pqn)
            sliders(i).sessionID=obj.sessionID;
            sliders(i).UUID=obj.UUID;
            sliders(i).type=obj.Type;
            sliders(i).use=isDoseUsedInTask(doses,sliders(i).pqn);


            sliderInfo=vertcat(sliderInfo,sliders(i));%#ok<AGROW>
        end
    end

end

function statesToLog=getStatesToLogSection(taskNode,model)

    statesToLogNode=getField(taskNode,'StatesToLog');
    taskSpecific=false;

    if~isempty(statesToLogNode)
        taskSpecific=getAttribute(statesToLogNode,'TaskSpecific');
    end



    if taskSpecific
        statesToLogNodes=getField(statesToLogNode,'TaskStatesToLog');

        if isempty(statesToLogNodes)
            statesToLog=[];
        else
            template=getStatesToLogTemplate;
            statesToLog=repmat(template,numel(statesToLogNodes),1);

            for i=1:numel(statesToLog)
                statesToLog(i).name=getAttribute(statesToLogNodes(i),'Name');
                statesToLog(i).use=getAttribute(statesToLogNodes(i),'Log');

                state=getObject(model,statesToLog(i).name);
                if~isempty(state)
                    statesToLog(i).name=state(1).PartiallyQualifiedNameReally;
                    statesToLog(i).sessionID=state(1).SessionID;
                    statesToLog(i).UUID=state(1).UUID;
                    statesToLog(i).type=state(1).Type;
                    statesToLog(i).isUndefined=false;
                else
                    statesToLog(i).sessionID=-1;
                    statesToLog(i).UUID=-1;
                    statesToLog(i).isUndefined=false;
                end
            end
        end
    else


        if~isempty(model)
            cs=model.getconfigset('default');
            states=cs.RuntimeOptions.StatesToLog;


            statesToLog=getStatesToLogTemplate;
            statesToLog=repmat(statesToLog,numel(states),1);

            for i=1:numel(states)
                statesToLog(i).name=states(i).name;
                statesToLog(i).sessionID=states(i).sessionID;
                statesToLog(i).UUID=states(i).UUID;
                statesToLog(i).type=states(i).Type;
                statesToLog(i).isUndefined=false;
            end
        else
            statesToLog=[];
        end
    end

end

function variants=getVariantSection(taskNode,model,projectVersion)

    switch projectVersion
    case{'4.1'}
        variants=getVariantSectionPre2012a(taskNode,model);
    case{'4.2','4.3','4.3.1'}
        variants=getVariantSectionPre2014b(taskNode,model);
    otherwise
        variants=getVariantSectionPost2014b(taskNode,model);
    end

end

function variants=getVariantSectionPost2014b(taskNode,model)

    variantNodes=getField(taskNode,'VariantsToApply');
    if isempty(variantNodes)
        variants=[];
        return;
    end


    if~isempty(model)
        variantObjs=model.getvariant;
        variantObjNames={variantObjs.name};
    else
        variantObjs=[];
        variantObjNames={};
    end


    variantNodes=variantNodes.VariantRowObject;
    template=getVariantTemplate;
    variants=repmat(template,numel(variantNodes),1);


    for i=1:numel(variants)
        variants(i).name=getAttribute(variantNodes(i),'Name');
        variants(i).use=getAttribute(variantNodes(i),'Selected');

        obj=variantObjs(ismember(variantObjNames,variants(i).name));
        if~isempty(obj)
            variants(i).sessionID=obj.sessionID;
            variants(i).UUID=obj.UUID;
        end
    end

end

function variants=getVariantSectionPre2014b(taskNode,model)

    variants=[];
    variantNode=getField(taskNode,'Variants');
    if isempty(variantNode)
        return;
    end

    numVariants=getAttribute(variantNode,'SelectedVariantsCount');

    if~isempty(numVariants)&&~isnan(numVariants)

        if~isempty(model)
            variantObjs=model.getvariant;
            variantObjNames={variantObjs.name};
        else
            variantObjs=[];
            variantObjNames={};
        end


        variants=getVariantTemplate;
        variants=repmat(variants,numVariants,1);

        for i=1:numVariants
            variants(i).name=getAttribute(variantNode,sprintf('SelectedVariants%d',(i-1)));
            variants(i).message={};

            obj=variantObjs(ismember(variantObjNames,variants(i).name));
            if~isempty(obj)
                variants(i).sessionID=obj.sessionID;
                variants(i).UUID=obj.UUID;
            end
        end
    end

end

function variants=getVariantSectionPre2012a(taskNode,model)

    variantNodes=getField(taskNode,'Variants');
    if isempty(variantNodes)
        variants=[];
        return;
    end


    if~isempty(model)
        variantObjs=model.getvariant;
        variantObjNames={variantObjs.name};
    else
        variantObjs=[];
        variantObjNames={};
    end


    variantNames=getAttribute(variantNodes,'SelectedVariants');
    if~isempty(variantNames)
        variantNames=textscan(variantNames(2:end-1),'%s','Delimiter',',');
        variantNames=variantNames{1};
    end

    numVariants=numel(variantNames);
    variants=getVariantTemplate;
    variants=repmat(variants,numVariants,1);

    for i=1:numVariants
        variants(i).name=variantNames{i};
        variants(i).message={};

        obj=variantObjs(ismember(variantObjNames,variants(i).name));
        if~isempty(obj)
            variants(i).sessionID=obj.sessionID;
            variants(i).UUID=obj.UUID;
        end
    end

end

function modelStep=getModelStepTemplate

    modelStep=struct;
    modelStep.accelerate=false;
    modelStep.doses=[];
    modelStep.enabled=false;
    modelStep.explorer=getExplorerSectionTemplate;
    modelStep.internal=getInternalStructTemplate;
    modelStep.model=-1;
    modelStep.name='Model';
    modelStep.observables=[];
    modelStep.statesToLog=struct;
    modelStep.statesToLogAll=false;
    modelStep.statesToLogUseConfigset=true;
    modelStep.type='Model';
    modelStep.variants=[];
    modelStep.version=1;

end

function out=getDoseInternalTemplate

    out=struct;
    out.ID=0;
    out.children=[];
    out.columnSpan=[1,1,4];
    out.description='Target Name';
    out.equal='';
    out.expand=false;
    out.externalDataColumn='';
    out.externalDataName='';
    out.isChild=false;
    out.message=[];
    out.name='';
    out.sessionID=-1;
    out.UUID=-1;
    out.targetSessionID=-1;
    out.targetUUID=-1;
    out.type='dosesSection';
    out.use=true;
    out.value='';

end

function out=getDoseTemplate

    out.isUndefined=false;
    out.message=[];
    out.name='';
    out.sessionID=-1;
    out.use=true;
    out.UUID=-1;
    out.type='dose';

end

function out=getStatesToLogTemplate

    out.isUndefined=false;
    out.message=[];
    out.name='';
    out.sessionID=-1;
    out.use=true;
    out.UUID=-1;
    out.type='';

end

function out=getVariantTemplate

    out.isUndefined=false;
    out.message=[];
    out.name='';
    out.sessionID=-1;
    out.use=true;
    out.UUID=-1;
    out.type='variant';

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getExplorerSectionTemplate

    out=SimBiology.web.internal.converter.utilhandler('getExplorerSectionTemplate');

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');

end

function model=getModelFromSessionID(sessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);

end

function obj=getObject(model,name)

    obj=SimBiology.web.internal.converter.utilhandler('getObject',model,name);

end

function out=isDoseUsedInTask(doses,name)

    out=true;

    for i=1:numel(doses)
        if strcmp(doses(i).name,name)
            out=doses(i).use;
            return;
        end
    end

end

function out=isDoseInTask(doses,name)

    out=false;

    for i=1:numel(doses)
        if strcmp(doses(i).name,name)
            out=true;
            return;
        end
    end

end

function out=roundValue(value,digits)

    out=value;
    if isnumeric(value)
        out=round(value,digits);
    end
end
