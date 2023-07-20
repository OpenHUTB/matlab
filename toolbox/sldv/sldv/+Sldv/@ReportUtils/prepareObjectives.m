function[objectives,summary]=prepareObjectives(opts,data,titles,createLink,justifiedInfo)




    if nargin<4
        createLink=1;
    end

    if nargin<5
        justifiedInfo.objectives=[];
        justifiedInfo.rationales=[];
    end

    isQDL=Sldv.utils.isQuickDeadLogic(data.AnalysisInformation.Options);
    [objectives,numQuickDeadLogicNotFoundToBeDead]=buildObjectives(data,titles,createLink,justifiedInfo);
    summary=buildSummary(objectives,numQuickDeadLogicNotFoundToBeDead,isQDL);




    if isQDL


        objectives=removeDeadLogicSection(objectives);
    end

    if opts.short
        objectives(1).objs={};
    end
end

function[objectives,numQuickDeadLogicNotFoundToBeDead]=buildObjectives(data,titles,createLink,justifiedInfo)





    satisfied=struct('designModel',[],'observerModel',[]);
    unsatisfiable=struct('designModel',[],'observerModel',[]);
    valid=struct('designModel',[],'observerModel',[]);
    validBounded=struct('designModel',[],'observerModel',[]);
    falsified=struct('designModel',[],'observerModel',[]);
    undecidable=struct('designModel',[],'observerModel',[]);
    errored=struct('designModel',[],'observerModel',[]);
    satisfiedNoTC=struct('designModel',[],'observerModel',[]);
    falsifiedNoTC=struct('designModel',[],'observerModel',[]);
    dead=struct('designModel',[],'observerModel',[]);
    deadunderapprox=struct('designModel',[],'observerModel',[]);
    active=struct('designModel',[],'observerModel',[]);
    activeneedssim=struct('designModel',[],'observerModel',[]);
    undecidedStubbing=struct('designModel',[],'observerModel',[]);
    undecidedApprox=struct('designModel',[],'observerModel',[]);
    nonlinear=struct('designModel',[],'observerModel',[]);
    divbyzero=struct('designModel',[],'observerModel',[]);
    outofbounds=struct('designModel',[],'observerModel',[]);
    validunderapprox=struct('designModel',[],'observerModel',[]);
    unsatunderapprox=struct('designModel',[],'observerModel',[]);
    satneedssim=struct('designModel',[],'observerModel',[]);
    falsifiedneedssim=struct('designModel',[],'observerModel',[]);
    undecidedwithtestcase=struct('designModel',[],'observerModel',[]);
    undecidedwithcounterexample=struct('designModel',[],'observerModel',[]);
    undecidedwithruntimeerror=struct('designModel',[],'observerModel',[]);
    excluded=struct('designModel',[],'observerModel',[]);
    justified=struct('designModel',[],'observerModel',[]);
    satbyexistingdata=struct('designModel',[],'observerModel',[]);

    opts=data.AnalysisInformation.Options;
    hasAnalysisTime=isfield(data.Objectives,'analysisTime');


    columnHeaders={...
    'Hash',...
    'Type',...
    'ModelItem',...
    'Description',...
    };

    filteredObjColumnHeaders=columnHeaders;
    existingDataColumnHeaders=columnHeaders;


    if Sldv.utils.isPathBasedTestGeneration(opts)
        columnHeaders{end+1}='DetectionStatus';
    end
    if hasAnalysisTime
        columnHeaders{end+1}='AnalysisTime';
    end

    noTestCaseColumnHeaders=columnHeaders;
    noTestCaseColumnHeaders=getHeader(noTestCaseColumnHeaders,titles);

    columnHeaders{end+1}='Test';
    header=getHeader(columnHeaders,titles);


    filteredObjColumnHeaders{end+1}='Rationale';
    filteredObjHeader=getHeader(filteredObjColumnHeaders,titles);


    existingDataColumnHeaders{end+1}='TestNCoverageData';
    existingDataHeader=getHeader(existingDataColumnHeaders,titles);


    isXilData=Sldv.DataUtils.isXilSldvData(data);

    numQuickDeadLogicNotFoundToBeDead=0;

    for objIdx=1:length(data.Objectives)
        objective=data.Objectives(objIdx);
        modelObject=data.ModelObjects(objective.modelObjectIdx);

        isFiltered=false;
        if~strcmpi(objective.type,'Range')
            if strcmp(objective.status,'Excluded')
                isFiltered=true;
                filteringMode=0;
                rationale=objective.rationale;
            elseif strcmp(objective.status,'Justified')
                isFiltered=true;
                filteringMode=1;
                rationale=objective.rationale;
            else
                idx=sldvshareprivate('util_get_obj_idx_in_list',objective,justifiedInfo.objectives);
                if~isempty(idx)

                    isFiltered=true;
                    filteringMode=1;
                    rationale=justifiedInfo.rationales{idx};
                end
            end
        end

        isUsingExistingData=(strcmpi(objective.status,'Satisfied by coverage data')||...
        strcmpi(objective.status,'Satisfied by existing testcase'))...
        &&strcmpi(data.AnalysisInformation.Options.IgnoreExistTestSatisfied,'on');

        if isFiltered
            if isempty(rationale)
                rationale=getString(message('Sldv:ReportUtils:prepareObjectives:None'));
            end
            reportedObjective=cell(1,length(filteredObjColumnHeaders));
        elseif isUsingExistingData
            reportedObjective=cell(1,length(existingDataColumnHeaders));
        else
            reportedObjective=cell(1,length(columnHeaders));
        end

        reportedObjective(1)={createObjectiveLinkAnchor(objIdx)};
        reportedObjective(2)={sldvprivate(...
        'util_translate_ObjectiveType',...
        objective.type)};



        numModelObjects=numel(modelObject);
        if numModelObjects>1
            reportedObjective{3}=cell(1,numModelObjects);
        end

        for jj=1:numModelObjects
            [sid,modelname]=Sldv.ReportUtils.getSidFromModelObjectData(data,modelObject(jj));
            if isempty(sid)
                sid=modelObject(jj).descr;
            end
            if isfield(objective,'linkInfo')
                linkInfo=objective.linkInfo;
            else
                linkInfo=[];
            end

            if isXilData




                sectionToReport='designModel';
                modelToLink=modelname;
            else


                if isfield(modelObject(jj),'modelScope')&&strcmp(modelObject(jj).modelScope,'ObserverReference')

                    modelToLink=Sldv.ReportUtils.getModelNameFromSid(sid);
                    sectionToReport='observerModel';
                else
                    modelToLink=modelname;
                    sectionToReport='designModel';
                end
            end



            if isempty(modelToLink)
                modelToLink=Sldv.ReportUtils.getAnalyzedModelName(data);
            end


            if createLink==0||(isXilData&&strcmp(modelObject(jj).descr,sldv.code.xil.ReportDataUtils.SHARED_UTILITY_LABEL))
                to={struct('url','','disp',modelObject(jj).descr,'type','char')};
            else
                allText=modelObject(jj).descr;
                if contains(allText,'State "')
                    tok=regexp(allText,'State "(.+)"','tokens');
                    link=Sldv.ReportUtils.externalLink(sid,tok{1}{1},modelToLink,...
                    false,[],linkInfo);
                    to={Sldv.ReportUtils.styleStructCat('State "',link,'"')};
                elseif contains(allText,'Transition "')
                    tok=regexp(allText,'Transition "(.+?)"(.+)','tokens');
                    linkStruct=Sldv.ReportUtils.externalLink(sid,tok{1}{1},modelToLink,...
                    false,[],linkInfo);
                    linkStruct(2)=linkStruct;
                    linkStruct(1).url='';
                    linkStruct(1).disp='Transition "';
                    linkStruct(3).disp=sprintf('"%s',tok{1}{2});
                    to={linkStruct};
                else
                    to={Sldv.ReportUtils.externalLink(sid,modelObject(jj).descr,modelToLink,...
                    false,[],linkInfo)};
                end
            end


            if numModelObjects==1
                reportedObjective(3)=to;
            else
                reportedObjective{3}(jj)=to;
            end
        end

        if isXilData
            coDescr=sldv.code.xil.ReportDataUtils.makeRptCodeLink(objective,createLink);
            reportedObjective(4)={coDescr};
        else
            if isfield(objective,'dscrptEmph')&&~isempty(objective.dscrptEmph)
                coDescr=objective.dscrptEmph;
            else
                coDescr=objective.descr;
            end

            if iscell(coDescr)
                cnt=numel(coDescr)/2;
                args=cell(1,cnt);

                for idx=1:cnt
                    if(coDescr{(2*idx)-1})
                        args{idx}=Sldv.ReportUtils.styleStruct(coDescr{2*idx},'bold');
                    else
                        args{idx}=coDescr{2*idx};
                    end
                end
                reportedObjective(4)={Sldv.ReportUtils.styleStructCat(args{:})};
            else
                reportedObjective(4)={coDescr};
            end
        end

        tcIdx=[];
        if~isFiltered&&isfield(objective,'testCaseIdx')
            tcIdx=objective.testCaseIdx;
        end

        if isfield(objective,'detectability')
            reportedObjective(strcmp('DetectionStatus',columnHeaders))=...
            {Sldv.ReportUtils.getObservabilityInformation(objective)};
        end

        if~isFiltered&&hasAnalysisTime&&~isUsingExistingData
            reportedObjective(strcmp('AnalysisTime',columnHeaders))={objective.analysisTime};
        end

        if isFiltered
            reportedObjective(strcmp('Rationale',filteredObjColumnHeaders))={rationale};
            if filteringMode==1


                justified.(sectionToReport)=cat(1,justified.(sectionToReport),reportedObjective);
                continue;
            end
        elseif isUsingExistingData
            if strcmpi(objective.status,'Satisfied by coverage data')
                reportedObjective(strcmp('TestNCoverageData',existingDataColumnHeaders))=...
                {data.AnalysisInformation.Options.CoverageDataFile};
            else
                reportedObjective(strcmp('TestNCoverageData',existingDataColumnHeaders))=...
                {Sldv.ReportUtils.internalLink('TestCase',tcIdx)};
            end
        elseif strcmp(objective.status,'Active Logic')||...
            strcmp(objective.status,'Active Logic - needs simulation')

        elseif~isempty(tcIdx)
            reportedObjective(strcmp('Test',columnHeaders))={Sldv.ReportUtils.internalLink('TestCase',tcIdx)};
        elseif strcmpi(objective.status,'Satisfied by coverage data')
            reportedObjective(strcmp('Test',columnHeaders))={data.AnalysisInformation.Options.CoverageDataFile};
        end



        switch objective.status
        case 'Satisfied'
            satisfied.(sectionToReport)=cat(1,satisfied.(sectionToReport),reportedObjective);
        case 'Satisfied - needs simulation'
            satneedssim.(sectionToReport)=cat(1,satneedssim.(sectionToReport),reportedObjective);
        case{'Satisfied by coverage data','Satisfied by existing testcase'}
            if isUsingExistingData
                satbyexistingdata.(sectionToReport)=cat(1,satbyexistingdata.(sectionToReport),reportedObjective);
            else
                satisfied.(sectionToReport)=cat(1,satisfied.(sectionToReport),reportedObjective);
            end
        case 'Unsatisfiable'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            unsatisfiable.(sectionToReport)=cat(1,unsatisfiable.(sectionToReport),reportedObjective);
        case 'n/a'
            if any(strcmp(objective.type,Sldv.utils.getDeadLogicObjectiveTypes))






                assert(Sldv.utils.isQuickDeadLogic(data.AnalysisInformation.Options));
                numQuickDeadLogicNotFoundToBeDead=numQuickDeadLogicNotFoundToBeDead+1;
            end
        case 'Valid'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            valid.(sectionToReport)=cat(1,valid.(sectionToReport),reportedObjective);
        case 'Valid within bound'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            validBounded.(sectionToReport)=cat(1,validBounded.(sectionToReport),reportedObjective);
        case 'Falsified'
            falsified.(sectionToReport)=cat(1,falsified.(sectionToReport),reportedObjective);
        case 'Falsified - needs simulation'
            falsifiedneedssim.(sectionToReport)=cat(1,falsifiedneedssim.(sectionToReport),reportedObjective);
        case 'Undecided due to approximations'
            undecidedApprox.(sectionToReport)=cat(1,undecidedApprox.(sectionToReport),reportedObjective);
        case 'Undecided due to stubbing'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            undecidedStubbing.(sectionToReport)=cat(1,undecidedStubbing.(sectionToReport),reportedObjective);
        case 'Undecided due to nonlinearities'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            nonlinear.(sectionToReport)=cat(1,nonlinear.(sectionToReport),reportedObjective);
        case 'Undecided due to division by zero'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            divbyzero.(sectionToReport)=cat(1,divbyzero.(sectionToReport),reportedObjective);
        case 'Undecided due to array out of bounds'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            outofbounds.(sectionToReport)=cat(1,outofbounds.(sectionToReport),reportedObjective);
        case 'Undecided'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            undecidable.(sectionToReport)=cat(1,undecidable.(sectionToReport),reportedObjective);
        case 'Produced error'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            errored.(sectionToReport)=cat(1,errored.(sectionToReport),reportedObjective);
        case 'Satisfied - No Test Case'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            satisfiedNoTC.(sectionToReport)=cat(1,satisfiedNoTC.(sectionToReport),reportedObjective);
        case 'Falsified - No Counterexample'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            falsifiedNoTC.(sectionToReport)=cat(1,falsifiedNoTC.(sectionToReport),reportedObjective);
        case 'Active Logic'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            active.(sectionToReport)=cat(1,active.(sectionToReport),reportedObjective);
        case 'Active Logic - needs simulation'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            activeneedssim.(sectionToReport)=cat(1,activeneedssim.(sectionToReport),reportedObjective);
        case 'Dead Logic'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            dead.(sectionToReport)=cat(1,dead.(sectionToReport),reportedObjective);
        case 'Dead Logic under approximation'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            deadunderapprox.(sectionToReport)=cat(1,deadunderapprox.(sectionToReport),reportedObjective);
        case 'Valid under approximation'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            validunderapprox.(sectionToReport)=cat(1,validunderapprox.(sectionToReport),reportedObjective);
        case 'Unsatisfiable under approximation'
            reportedObjective=removeTestColumn(reportedObjective,columnHeaders);
            unsatunderapprox.(sectionToReport)=cat(1,unsatunderapprox.(sectionToReport),reportedObjective);
        case 'Undecided with testcase'
            undecidedwithtestcase.(sectionToReport)=cat(1,undecidedwithtestcase.(sectionToReport),reportedObjective);
        case 'Undecided with counterexample'
            undecidedwithcounterexample.(sectionToReport)=cat(1,undecidedwithcounterexample.(sectionToReport),reportedObjective);
        case 'Undecided due to runtime error'
            undecidedwithruntimeerror.(sectionToReport)=cat(1,undecidedwithruntimeerror.(sectionToReport),reportedObjective);
        case 'Excluded'
            excluded.(sectionToReport)=cat(1,excluded.(sectionToReport),reportedObjective);
        case 'Justified'
            justified.(sectionToReport)=cat(1,justified.(sectionToReport),reportedObjective);
        otherwise
            warning(message('Sldv:RptGen:UnknownStatus'));
        end
    end

    objectives=[];

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesSatisfied'));
    objectives(end).objs=addHeader(header,satisfied);
    objectives(end).help=helpSatisfied;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesSatNeedsSim'));
    objectives(end).objs=addHeader(header,satneedssim);
    objectives(end).help=helpSatNeedsSim;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesSatByExistingData'));
    objectives(end).objs=addHeader(existingDataHeader,satbyexistingdata);
    objectives(end).help=helpSatByExistingData;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesProvenUnsatisfiable'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,unsatisfiable);
    objectives(end).help=helpUnsatisfiable(data);

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesProvenValid'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,valid);
    objectives(end).help=helpValid;

    objectives(end+1).label=getValidBoundedLabel(data);
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,validBounded);
    objectives(end).help=helpValidBounded;



    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesFalsifiedWithCounterexamples'));
    objectives(end).objs=addHeader(header,falsified);
    objectives(end).help=helpFalsified;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesFalsifiedNeedsSim'));
    objectives(end).objs=addHeader(header,falsifiedneedssim);
    objectives(end).help=helpFalsifiedNeedsSim;



    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedDueApprox'));
    objectives(end).objs=addHeader(header,undecidedApprox);
    objectives(end).help=helpUndecidedApprox;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedDueStubbing'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,undecidedStubbing);
    objectives(end).help=helpUndecidedStubbing;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedDueNonlinearities'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,nonlinear);
    objectives(end).help=helpNonLinear;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedDueDivisionZero'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,divbyzero);
    objectives(end).help=helpDivByZero;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedDueOutOfBounds'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,outofbounds);
    objectives(end).help=helpOutOfBounds;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedWithTestcase'));
    objectives(end).objs=addHeader(header,undecidedwithtestcase);
    objectives(end).help=helpUndecidedWithTestcase;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedWithCounterexample'));
    objectives(end).objs=addHeader(header,undecidedwithcounterexample);
    objectives(end).help=helpUndecidedWithCounterExample;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedRuntimeError'));
    objectives(end).objs=addHeader(header,undecidedwithruntimeerror);
    objectives(end).help=helpUndecidedWithRuntimeError(opts.Mode);

    objectives(end+1).label=getUndecidedLabel(data);
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,undecidable);
    objectives(end).help=helpUndecided;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesProducingErrors'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,errored);
    objectives(end).help=helpErrors;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesSatisfiedNo'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,satisfiedNoTC);
    objectives(end).help=helpSatisfiedNoTC;



    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesFalsifiedNoCounterexample'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,falsifiedNoTC);
    objectives(end).help=helpFalsifiedNoTC;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:DeadLogic'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,dead);
    objectives(end).help=helpDead(data);

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:DeadLogicUnderApprox'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,deadunderapprox);
    objectives(end).help=helpDeadUnderApprox(data);

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ActiveLogic'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,active);
    objectives(end).help=helpActive;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ActiveLogicNeedsSim'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,activeneedssim);
    objectives(end).help=helpActiveNeedssim;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:ValidUnderApprox'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,validunderapprox);
    objectives(end).help=helpValidUnderApprox;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:UnsatUnderApprox'));
    objectives(end).objs=addHeader(noTestCaseColumnHeaders,unsatunderapprox);
    objectives(end).help=helpUnsatUnderApprox(data);

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:Excluded'));
    objectives(end).objs=addHeader(filteredObjHeader,excluded);
    objectives(end).help=helpExcluded;

    objectives(end+1).label=getString(message('Sldv:ReportUtils:prepareObjectives:Justified'));
    objectives(end).objs=addHeader(filteredObjHeader,justified);
    objectives(end).help=helpJustified;





    if~isfield(data.ModelObjects,'modelScope')
        for objTypeIdx=1:numel(objectives)
            objectives(objTypeIdx).objs=rmfield(objectives(objTypeIdx).objs,'observerModel');
        end
    end
end

function reportedObjective=removeTestColumn(reportedObjective,columnHeaders)
    reportedObjective(strcmp('Test',columnHeaders))=[];
end

function headerString=getHeader(columnHeaders,titles)
    headerString=cell(1,length(columnHeaders));
    for iterator=1:length(columnHeaders)
        header=columnHeaders{iterator};
        if strcmp(header,'Test')
            headerString{1,iterator}=titles.test;
        else
            headerString{1,iterator}=getString(message(['Sldv:RptGen:',header]));
        end
    end
end

function summary=buildSummary(objectives,numQuickDeadLogicNotFoundToBeDead,isQDL)






    summary={getString(message('Sldv:ReportUtils:prepareObjectives:NumberofObjectives')),'0'};
    total=numQuickDeadLogicNotFoundToBeDead;
    for i=1:length(objectives)
        currObjCount=0;
        modelTypes=fields(objectives(i).objs);
        for modelTypeIdx=1:numel(modelTypes)
            dims=size(objectives(i).objs.(modelTypes{modelTypeIdx}));


            currObjCount=currObjCount+max(dims(1)-1,0);
        end




        if currObjCount>0||(isQDL&&(total>0)&&strcmp(objectives(i).label,getString(message('Sldv:ReportUtils:prepareObjectives:DeadLogic'))))
            total=total+currObjCount;
            label=[objectives(i).label,': '];
            if isempty(summary)
                summary={label,num2str(currObjCount)};
            else
                summary=cat(1,summary,{label,num2str(currObjCount)});
            end
        end
    end
    summary(1,2)={num2str(total)};





    summary(1,3)={' '};


    numUniqueObjStatus=size(summary,1)-1;

    if(numUniqueObjStatus>0)
        if(1==numUniqueObjStatus)






            currObjProportion=str2double(summary{end,2})/total;
            percentCount=round(currObjProportion,2)*100;
            summary{end,3}=['( ',num2str(percentCount),'% )'];
        else










            leftOverShare=100-round(numQuickDeadLogicNotFoundToBeDead/total,2)*100;
            for currObj=1:numUniqueObjStatus-1
                currObjProportion=str2double(summary{currObj+1,2})/total;
                percentCount=round(currObjProportion,2)*100;
                leftOverShare=leftOverShare-percentCount;
                summary{currObj+1,3}=['( ',num2str(percentCount),'% )'];
            end


            if(str2double(summary{end,2})>0)
                summary{end,3}=['( ',num2str(leftOverShare),'% )'];
            else
                summary{end,3}='( 0% )';
            end
        end
    end









    if~total
        summary=cat(1,summary,{' ',' ',' '});
    end
end

function objectives=removeDeadLogicSection(objectives)
    for i=1:length(objectives)
        if strcmp(objectives(i).label,getString(message('Sldv:ReportUtils:prepareObjectives:DeadLogic')))
            objectives(i)=[];
            break;
        end
    end
end

function label=getUndecidedLabel(data)
    d=data.AnalysisInformation;

    if~isempty(strfind(d.Status,'by user'))
        label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecidedWhenAnalysis'));
    else
        label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesUndecided'));
    end
end

function label=getValidBoundedLabel(data)
    d=data.AnalysisInformation;

    label=getString(message('Sldv:ReportUtils:prepareObjectives:ObjectivesHavingNoCounterexamples',d.Options.MaxViolationSteps));
end

function objStatusInfo=addHeader(header,objStatusInfo)


    modelType=fields(objStatusInfo);
    for i=1:numel(modelType)
        if~isempty(objStatusInfo.(modelType{i}))
            objStatusInfo.(modelType{i})=cat(1,header,objStatusInfo.(modelType{i}));
        end
    end
end

function objIdxAnchor=createObjectiveLinkAnchor(objIdx)
    objIdxAnchor.rpt_link_type='anchor';
    objIdxAnchor.rpt_link_id=['Objective#',num2str(objIdx)];
    objIdxAnchor.rpt_link_text=num2str(objIdx);
end

function help=helpSatisfied
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierSatisfied'));
end

function help=helpSatNeedsSim
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_SatNeedsSim'));
end

function help=helpSatByExistingData
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_SatByExistingData'));
end

function help=helpUnsatisfiable(data)
    help=helpDead(data);
end

function help=helpDead(data)
    opts=data.AnalysisInformation.Options;
    help=Sldv.ReportUtils.getDeadLogicHelpText(opts);
end

function help=helpDeadUnderApprox(data)
    help=helpDead(data);
    help=[help,' ',getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierDeadLogicApproximations'))];
end

function help=helpActive
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierActive'));
end

function help=helpActiveNeedssim
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_ActiveNeedsSim'));
end

function help=helpValid
    help='';
end

function help=helpValidBounded
    help='';
end

function help=helpFalsified
    help='';
end

function help=helpFalsifiedNeedsSim
    help='';
end

function help=helpUndecided
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas'));
end

function help=helpUndecidedStubbing
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas_1'));
end

function help=helpNonLinear
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas_2'));
end

function help=helpDivByZero
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas_3'));
end

function help=helpOutOfBounds
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas_5'));
end

function help=helpUndecidedApprox
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifierWas_4'));
end

function help=helpErrors
    help='';
end

function help=helpSatisfiedNoTC
    help='';
end

function help=helpFalsifiedNoTC
    help='';
end

function help=helpValidUnderApprox
    help='';
end

function help=helpUnsatUnderApprox(data)
    help=helpDeadUnderApprox(data);
end

function help=helpUndecidedWithTestcase
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_UndecidedTestcase'));
end

function help=helpUndecidedWithCounterExample
    help='';
end

function help=helpUndecidedWithRuntimeError(mode)
    if strcmp(mode,'TestGeneration')
        help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_UndecidedRuntimeError_testGeneration'));
    else
        help='';
    end
end

function help=helpExcluded
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_Excluded'));
end

function help=helpJustified
    help=getString(message('Sldv:ReportUtils:prepareObjectives:SimulinkDesignVerifier_Justified'));
end



