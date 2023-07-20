function out=exportModel(action,varargin)











    out={action};

    switch(action)
    case 'exportDiagram'
        out=exportDiagram(action,varargin{:});
    case 'exportModelToHTML'
        out=exportModelToHTML(action,varargin{:});
    case 'getScreenSizeInInches'
        out=getScreenSizeInInches(varargin{:});
    end

end

function out=exportDiagram(action,inputs)

    msg='';
    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.sessionID);
    exporter=SimBiology.web.report.modelhandler('createDiagramExporter',model);

    try
        SimBiology.web.report.modelhandler('exportDiagramOnly',exporter,inputs.filename,inputs);
    catch ex
        msg=ex.message;
    end

    out={action,msg};

end

function html=exportModelToHTML(action,inputs)

    msg='';


    [fid,errmsg]=fopen(inputs.filename,'w');
    if~isempty(errmsg)&&fid==-1
        msg=sprintf('Export Model failed with the error: Unable to write to file: %s because the folder is read-only.',inputs.filename);
        html={action,msg};
        return;
    end


    warnState=warning('off','cefclient:webwindow:updatePositionMinSize');
    cleanup=onCleanup(@()warning(warnState));


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.sessionID);
    variants=getvariant(model);
    doses=getdose(model);
    inputs.variants=sbioselect(variants,'Active',true);
    inputs.doses=sbioselect(doses,'Active',true);


    if inputs.showModelDiagram
        diagramFileName=[SimBiology.web.internal.desktopTempdir,filesep,'model.jpg'];
        exporter=SimBiology.web.report.modelhandler('createDiagramExporter',model);
        SimBiology.web.report.modelhandler('exportDiagram',exporter,diagramFileName,inputs);
    end


    template=SimBiology.web.codegenerationutil('readTemplate','report.html');
    template=strrep(template,'$PAGE_TITLE',model.Name);
    template=strrep(template,'$MODEL_NAME',model.Name);

    if inputs.showModelTables
        modelInfo=buildModelHTML(model,inputs);
        header=createHeaderLine('h1',['Model: ',model.Name],0);
        header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
        modelInfo.html=appendLine(header,modelInfo.html);

        template=strrep(template,'<$INITIAL_VALUE_MESSAGE/>',modelInfo.initialValuesMsg);
        template=strrep(template,'$MODEL',modelInfo.html);
    else
        template=strrep(template,'<$INITIAL_VALUE_MESSAGE/>','');
        template=strrep(template,'$MODEL','');
    end

    if inputs.showModelEquations

        inputs.includeModelNotes=false;
        inputs.showVariants=false;
        inputs.showDoses=false;

        info=SimBiology.web.modelhandler('getModelEquations',inputs);
        info=info{2};


        modelInfo=buildModelEquationsHTML(model,info,inputs);


        equationsLabel='Model Equations';
        if~inputs.showModelTables
            equationsLabel=['Model Equations: ',model.Name];
        end

        header=createHeaderLine('h1',equationsLabel,0);
        header=appendLineWithPad(header,'<div class="horizontal_border"></div>',1);
        modelInfo.html=appendLine(header,modelInfo.html);
    else
        modelInfo.html='';
    end

    template=strrep(template,'$EQUATIONS',modelInfo.html);

    if inputs.showModelDiagram
        diagramHtml=SimBiology.web.report.modelhandler('generateDiagramHTML',diagramFileName);
        template=strrep(template,'$DIAGRAM',diagramHtml);
    else
        template=strrep(template,'$DIAGRAM','');
    end


    template=strrep(template,'$DESCRIPTION','');
    template=strrep(template,'$DATA','');
    template=strrep(template,'$PROGRAM','');
    template=strrep(template,'$RESULTS','');
    template=strrep(template,'$PLOTS','');


    footNote=SimBiology.web.report.utilhandler('generateFooter');
    template=strrep(template,'$FOOTNOTE',footNote);


    fwrite(fid,template);
    fclose(fid);


    web(inputs.filename,'-browser','-display');

    html={action,msg};

end

function out=getScreenSizeInInches(out)

    screenSize=get(0,'ScreenSize');
    pixelsPerInch=get(0,'ScreenPixelsPerInch');
    out.width=floor(screenSize(3)/pixelsPerInch);
    out.height=floor(screenSize(4)/pixelsPerInch);

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
