function out=reporthandler(action,varargin)











    out={action};

    switch(action)
    case 'generateReport'
        out=generateReport(varargin{:});
    case 'okToCreateReport'
        out=okToCreateReport(varargin{:});
    end

end

function out=okToCreateReport(input)

    matfile=input.matfilename;
    out.canCreateReport=SimBiology.internal.variableExistsInMatFile(matfile,'programInfo');
    out.isModelCached=false;
    out.useCurrentModel=false;
    out.programName=input.programName;
    out.resultsName=input.resultsName;

    if(out.canCreateReport)
        out.isModelCached=~isempty(input.modelCacheName);



        if~out.isModelCached&&~isempty(input.modelInfo)
            sessionID=input.modelInfo.sessionID;
            transactionID=input.modelInfo.transactionID;

            if any(sessionID==input.sessionIDs)
                model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);
                tID=SimBiology.Transaction.getUndoIndex(model);
                out.useCurrentModel=(transactionID==tID);
            end
        end
    end

end

function out=generateReport(input)


    out=[];
    msg='';


    fullfilename=input.filename;
    [filepath,filename]=fileparts(fullfilename);


    programInfo=load(input.matfileName);
    programInfo=programInfo.programInfo;
    steps=programInfo.steps;
    configset=[];
    model=[];


    if(input.useAvailableModel)&&isfield(programInfo,'modelInfo')

        model=SimBiology.web.modelhandler('getModelFromSessionID',programInfo.modelInfo.sessionID);
    else

        if isfield(programInfo,'modelCacheName')
            modelCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,programInfo.modelCacheName,'.mat'];
            if exist(modelCacheFile,'file')
                modelCache=load(modelCacheFile);
                model=modelCache.model;
                modelCleanup=onCleanup(@()delete(model));
            end
        end
    end


    dataCache='';
    if isfield(programInfo,'dataCache')
        dataCache=programInfo.dataCache;
    end

    if isfield(programInfo,'configset')
        configset=programInfo.configset;
    end


    [variants,modelStepDoses]=getModelStepVariantAndDoses(programInfo);
    doseStepDoses=getDoseStepDoses(programInfo);
    variantList=createVariants(variants);
    modelStepDoseList=createDoses(modelStepDoses);


    template=SimBiology.web.codegenerationutil('readTemplate','report.html');


    [fid,errmsg]=fopen(fullfilename,'w');
    if~isempty(errmsg)&&fid==-1
        out.message=sprintf('Report generation failed with the error: Unable to write to file: %s because the folder is read-only.',fullfilename);
        return;
    end


    isShowingModelInfo=false;
    isShowingModelEquations=false;
    if~isempty(model)
        isShowingModelInfo=input.showModelTables;
        isShowingModelEquations=input.showModelEquations;
    end


    template=strrep(template,'$PAGE_TITLE',filename);


    description=steps{1}.description;
    if~isempty(description)&&input.includeProgramDescription
        header=createHeaderLine('h1',input.name,0);
        header=appendLineWithPad(header,'<div class="horizontal_border" style="margin-bottom:4px;"></div>',1);
        description=addBreaksToText(description);
        description=appendLine(header,description);
        template=strrep(template,'$DESCRIPTION',description);
    else
        template=strrep(template,'$DESCRIPTION','');
    end




    input.showVariants=false;
    input.showDoses=false;
    input.showODEsOnly=isShowingModelInfo;
    input.sessionID=-1;
    input.variants=variantList;
    input.doses=modelStepDoseList;

    if~isempty(model)
        input.sessionID=model.SessionID;
    end


    if isShowingModelInfo
        modelInfo=buildModelHTML(model,input);
        header=createHeaderLine('h1',['Model: ',model.Name],0);
        header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
        modelInfo.html=appendLine(header,modelInfo.html);
    else
        modelInfo.initialValuesMsg='';%#ok<*UNRCH>
        modelInfo.html='';
    end

    template=strrep(template,'<$INITIAL_VALUE_MESSAGE/>',modelInfo.initialValuesMsg);
    template=strrep(template,'$MODEL',modelInfo.html);

    if isShowingModelEquations
        oldWarnState=warning('off','SimBiology:DimAnalysisNotDone_MatlabFcn_Dimensionless');
        cleanup=onCleanup(@()warning(oldWarnState));


        input.includeModelNotes=false;

        info=SimBiology.web.modelhandler('getModelEquations',input);
        info=info{2};


        modelInfo=buildModelEquationsHTML(model,info,input);


        equationsLabel='Model Equations';
        if~isShowingModelInfo
            equationsLabel=['Model Equations: ',model.Name];
        end

        header=createHeaderLine('h1',equationsLabel,0);
        header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
        modelInfo.html=appendLine(header,modelInfo.html);
    else
        modelInfo.html='';
    end

    template=strrep(template,'$EQUATIONS',modelInfo.html);


    dataHTML='';
    if input.includeProgramData
        dataHTML=generateProgramDataHTML(dataCache);
        if~isempty(dataHTML)
            header=createHeaderLine('h1','Program Data',0);
            header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
            dataHTML=appendLine(header,dataHTML);
        end
    end

    template=strrep(template,'$DATA',dataHTML);


    programHTML='';
    if input.showProgramSetup
        programHTML=generateProgramHTML(steps,configset,variants,modelStepDoses,doseStepDoses,input);
        header=createHeaderLine('h1','Program Setup',0);
        header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
        programHTML=appendLine(header,programHTML);
    end

    template=strrep(template,'$PROGRAM',programHTML);


    resultsHTML='';
    if input.showProgramResults
        resultsHTML=generateResultsHTML(steps,input.matfileName);
    end
    template=strrep(template,'$RESULTS',resultsHTML);


    plotHTML='';
    if input.showProgramPlots||input.showDataPlots
        [plotHTML,msg]=generatePlots(input,filepath,dataCache);
    end
    template=strrep(template,'$PLOTS',plotHTML);


    footNote=SimBiology.web.report.utilhandler('generateFooter');
    template=strrep(template,'$FOOTNOTE',footNote);


    template=strrep(template,'$DIAGRAM','');


    fwrite(fid,template);
    fclose(fid);


    web(fullfilename,'-browser','-display');


    if input.saveModel
        out.name=input.name;
        out.resultsName=input.resultsName;
        out.modelCacheName=SimBiology.web.savecodegenerator('saveModelCache',model);


        programInfo.modelCacheName=out.modelCacheName;
        programInfo.modelInfo=SimBiology.web.savecodegenerator('getModelInfo',model);
        programInfo.modelName=model.Name;
        programInfo.configset=SimBiology.web.savecodegenerator('getConfigsetInfo',model);


        SimBiology.web.datahandler('saveDataToMATFile',programInfo,'programInfo',input.matfileName);
    end

    out.message=msg;



    app=SimBiology.web.desktophandler('getModelAnalyzer');
    if~isempty(app.webWindow)
        app.webWindow.bringToFront;
    end

end

function html=generateProgramHTML(steps,configset,variants,modelStepDoses,doseStepDoses,input)


    html='';

    for i=1:length(steps)
        step=steps{i};
        if step.enabled
            if~isempty(html)
                html=appendLine(html,'');
            end

            data=[];
            switch(step.type)
            case 'Model'
                data=SimBiology.web.report.modelStep('generateHTML',html,variants,modelStepDoses,input);
            case 'Sensitivity'
                data=SimBiology.web.report.sensitivityStep('generateHTML',html,configset,step,input);
            case 'Ensemble Run'
                data=SimBiology.web.report.ensembleRunStep('generateHTML',html,configset,step,input);
            case 'Steady State'
                data=SimBiology.web.report.steadyStateStep('generateHTML',html,step,input);
            case 'Simulation'
                data=SimBiology.web.report.simulationStep('generateHTML',html,configset,step,input);
            case 'Dose'
                data=SimBiology.web.report.doseStep('generateHTML',html,doseStepDoses);
            case 'NCA'
                data=SimBiology.web.report.ncaStep('generateHTML',html,step,steps,input);
            case 'Fit'
                data=SimBiology.web.report.fitStep('generateHTML',html,step,input);
            case 'DataFit'
                data=SimBiology.web.report.fitStep('generateDataMapHTML',html,step);
            case 'Variant and Dose Setup'
                data=SimBiology.web.report.fitStep('generateVariantDoseSetupHTML',html,step);
            case 'Group Simulation'
                data=SimBiology.web.report.fitStep('generateGroupSimulationHTML',html,step,input);
            case 'Confidence Interval'
                data=SimBiology.web.report.confidenceIntervalStep('generateHTML',html,step,steps,input);
            case 'Calculate Observables'
                data=SimBiology.web.report.calculateObservablesStep('generateHTML',html,step,input);
            case 'Generate Samples'
                data=SimBiology.web.report.generateSamplesStep('generateHTML',html,step,input);
            case 'Global Sensitivity Analysis'
                data=SimBiology.web.report.gsaStep('generateHTML',html,step,input);
            case 'MPGSA'
                data=SimBiology.web.report.gsaStep('generateSecondStepMPGSAHTML',html,step,steps,input);
            case 'Custom Code'
                data=SimBiology.web.report.customCodeStep('generateHTML',html,step,configset);
            end

            if~isempty(data)
                html=data.html;
            end
        end
    end

end

function html=generateResultsHTML(steps,matfileName)

    html='';
    data=load(matfileName);
    matfileData=data.data;

    for i=1:length(steps)
        step=steps{i};
        if step.enabled
            if~isempty(html)
                html=appendLine(html,'');
            end

            data=[];
            switch(step.type)
            case 'NCA'
                data=SimBiology.web.report.ncaStep('generateResultsHTML',html,matfileData,steps);
            case 'Fit'
                data=SimBiology.web.report.fitStep('generateResultsHTML',html,matfileData);
            case 'Global Sensitivity Analysis'
                data=SimBiology.web.report.gsaStep('generateResultsHTML',html,matfileData,step,'results');
            case 'MPGSA'
                data=SimBiology.web.report.gsaStep('generateResultsHTML',html,matfileData,step,'mpgsaresults');
            case 'Calculate Observables'
                data=SimBiology.web.report.calculateObservablesStep('generateResultsHTML',html,matfileData,step,steps);
            case 'Confidence Interval'
                data=SimBiology.web.report.confidenceIntervalStep('generateResultsHTML',html,matfileData);
            case 'Steady State'
                data=SimBiology.web.report.steadyStateStep('generateResultsHTML',html,matfileData);
            end

            if~isempty(data)&&~isempty(data.html)
                if isempty(html)
                    html=createHeaderLine('h1','Program Results',0);
                    html=appendLineWithPad(html,'<div class="horizontal_border"></div>',1);
                    html=appendLine(html,data.html);
                else
                    html=data.html;
                end
            end
        end
    end

end

function html=generateProgramDataHTML(dataCache)

    info=struct;
    count=1;
    dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];

    if exist(dataCacheLookupFile,'file')
        dataCacheLookup=load(dataCacheLookupFile);
        dataCacheLookup=dataCacheLookup.dataCacheLookup;

        if~isempty(dataCacheLookup)
            names={dataCacheLookup.name};

            for i=1:numel(dataCache)
                dataName=dataCache(i).dataName;
                dataCacheName=dataCache(i).dataCacheName;
                idx=strcmp(dataCacheName,names);

                if any(idx)
                    dataInfo=dataCacheLookup(idx).dataInfo;
                    info(count).name=dataName;
                    info(count).dataInfo=dataInfo;
                    info(count).dataCacheName=dataCacheName;
                    count=count+1;
                end
            end
        end
    end


    if isfield(info,'name')
        out=SimBiology.web.report.dataStep('generateHTML',info);
        html=out.html;
    else
        html='';
    end

end

function[html,msg]=generatePlots(input,filepath,dataCache)


    html='';
    msg='';
    imgDir=fullfile(filepath,'images');

    dataPlots=input.dataPlots;
    plots=input.plots;
    madeDir=false;

    if~isempty(plots)||~isempty(dataPlots)
        if~exist(imgDir,'file')
            try
                madeDir=true;
                mkdir(imgDir);
            catch
                msg='Plots were not generated. Unable to create directory for images.';
                html='';
                return;
            end
        end
    end



    dataInfo=[];
    if input.showDataPlots||input.showProgramPlots
        if~isempty(dataCache)
            dataInfo=getDataInfo(dataCache);
        end
    end

    dataPlotHTML='';
    dataHasError=false;
    if~isempty(dataPlots)&&input.showDataPlots
        [dataPlotHTML,dataHasError]=generatePlotSectionHTML('Data Plots',dataPlots,dataInfo,imgDir,0);
    end

    programPlotHTML='';
    programHasError=false;
    if~isempty(plots)&&input.showProgramPlots
        [programPlotHTML,programHasError]=generatePlotSectionHTML('Program Plots',plots,dataInfo,imgDir,numel(dataPlots));
    end

    if~isempty(dataPlotHTML)
        html=dataPlotHTML;
    end

    if~isempty(programPlotHTML)
        if isempty(html)
            html=programPlotHTML;
        else
            html=appendLine(html,programPlotHTML);
        end
    end

    if madeDir&&exist(imgDir,'dir')
        rmdir(imgDir,'s');
    end

    if dataHasError||programHasError
        msg='Some plots were not generated because the necessary data was not available.';
    end

end

function[imgHTML,hasError]=generatePlotSectionHTML(heading,plots,dataInfo,imgDir,count)

    imgHTML=createHeaderLine('h1',heading,0);
    imgHTML=appendLineWithPad(imgHTML,'<div class="horizontal_border"></div>',1);
    hasError=false;

    for i=1:length(plots)
        try
            [width,height]=getPlotSizeForReport(plots(i));
            next=updatePlotArgumentsToUseCachedDataFile(plots(i),dataInfo);
            h=SimBiology.web.plothandler('recreateFigureForReport',next,width,height);
            name=['plot_',num2str(i+count),'.png'];
            caption=sprintf('Figure %d : %s Plot',i+count,convertPlotStyle(plots(i).definition.plotStyle));
            fileName=fullfile(imgDir,name);

            saveas(h.handles,fileName,'png');
            close(h.handles);

            imgInfo=SimBiology.web.diagram.utilhandler('getImageData',fileName);

            img=['<img src="',imgInfo.imageData,'" alt="Plot" width=',width,' height=',height,' style="padding-bottom:10px;">'];

            imgHTML=appendLineWithPad(imgHTML,'<div style="text-align:center;padding-bottom:30px">',2);
            imgHTML=appendLineWithPad(imgHTML,img,3);
            imgHTML=appendLineWithPad(imgHTML,caption,3);
            imgHTML=appendLineWithPad(imgHTML,'</div>',2);

            deleteFile(fileName);
        catch
            hasError=true;
        end
    end

end

function next=updatePlotArgumentsToUseCachedDataFile(next,dataInfo)

    for i=1:numel(next.definition.plotArguments)
        dataSource=next.definition.plotArguments(i).dataSource;
        if isempty(dataSource.programName)&&dataInfo.isKey(dataSource.dataName)
            dataLookup=dataInfo(dataSource.dataName);
            next.definition.plotArguments(i).matfileInfo.matfileName=dataLookup.dataCacheFileName;
            next.definition.plotArguments(i).matfileInfo.matfileVariableName='data';
            next.definition.plotArguments(i).matfileInfo.matfileDerivedVariableName='';
            next.definition.plotArguments(i).matfileInfo.columnInfo=dataLookup.dataInfo.columnInfo;
        end
    end

end

function out=getDataInfo(dataCache)

    out=containers.Map('KeyType','char','ValueType','any');
    dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];

    if exist(dataCacheLookupFile,'file')
        dataCacheLookup=load(dataCacheLookupFile);
        dataCacheLookup=dataCacheLookup.dataCacheLookup;

        if~isempty(dataCacheLookup)
            names={dataCacheLookup.name};

            for i=1:numel(dataCache)
                dataName=dataCache(i).dataName;
                dataCacheName=dataCache(i).dataCacheName;
                dataCacheFileName=[SimBiology.web.internal.desktopTempdir,filesep,dataCacheName,'.mat'];
                idx=strcmp(dataCacheName,names);
                if any(idx)
                    dataInfo=dataCacheLookup(idx).dataInfo;
                    out(dataName)=struct('dataCacheFileName',dataCacheFileName,'dataInfo',dataInfo);
                end
            end
        end
    end

end

function plotStyle=convertPlotStyle(plotStyle)

    switch(plotStyle)
    case 'xy'
        plotStyle='XY';
    otherwise
        plotStyle=[upper(plotStyle(1)),plotStyle(2:end)];
    end

end

function[width,height]=getPlotSizeForReport(plotInfo)


    width=560;
    height=420;


    rows=plotInfo.figure.props.Row;
    columns=plotInfo.figure.props.Column;



    if rows>1
        height=max(height,rows*200);
        height=min(height,1000);
    end



    if columns>1
        width=max(width,columns*200);
        width=min(width,1000);
    end

end

function[variants,doses]=getModelStepVariantAndDoses(programInfo)

    variants=[];
    doses=[];

    if isfield(programInfo,'variant')
        variants=programInfo.variant;
    end

    if isfield(programInfo,'dose')
        doses=programInfo.dose;
    end

    if~isempty(variants)&&isfield(variants,'modelStep')
        variants=variants.modelStep;
    else
        variants=[];
    end

    if~isempty(doses)&&isfield(doses,'modelStep')
        doses=doses.modelStep;
    else
        doses=[];
    end

end

function doses=getDoseStepDoses(programInfo)

    doses=[];

    if isfield(programInfo,'dose')
        doses=programInfo.dose;
    end

    if~isempty(doses)&&isfield(doses,'doseStep')
        doses=doses.doseStep;
    else
        doses=[];
    end

end

function out=createVariants(vinfo)

    out=cell(1,numel(vinfo));
    for i=1:numel(vinfo)
        v=sbiovariant(vinfo(i).Name);
        v.Content=vinfo(i).Content;
        out{i}=v;
    end

    out=[out{:}];

end

function out=createDoses(dinfo)

    out=cell(1,numel(dinfo));
    for i=1:numel(dinfo)
        t=dinfo(i).Table;
        tableProps=t.Properties.VariableNames;
        isRepeat=false;
        if any(strcmp(tableProps,'StartTime'))
            isRepeat=true;
        end

        if isRepeat
            d=sbiodose(dinfo(i).Name,'repeat');
        else
            d=sbiodose(dinfo(i).Name,'schedule');
        end


        for j=1:numel(tableProps)
            prop=t.(tableProps{j});


            if iscellstr(prop)%#ok<ISCLSTR> 
                prop=prop{1};
            end
            set(d,tableProps{j},prop);
        end


        objProps=fieldnames(dinfo(i));
        for j=1:numel(objProps)
            prop=objProps{j};
            if~strcmp(prop,'Table')
                set(d,prop,dinfo(i).(prop));
            end
        end

        out{i}=d;
    end

    out=[out{:}];

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function out=buildModelHTML(model,inputs)

    out=SimBiology.web.report.modelhandler('buildModelHTML',model,inputs);

end

function out=buildModelEquationsHTML(model,info,inputs)

    out=SimBiology.web.report.modelhandler('buildModelEquationsHTML',model,info,inputs);

end

function out=createHeaderLine(header,text,numTabs)

    out=SimBiology.web.report.utilhandler('createHeaderLine',header,text,numTabs);

end

function text=addBreaksToText(text)

    text=strrep(text,newline,'<br>');

end

function deleteFile(name)

    SimBiology.web.report.utilhandler('deleteFile',name);
end
