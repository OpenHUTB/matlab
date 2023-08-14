function out=dataStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(data)

    html='';

    for i=1:numel(data)
        if~isempty(data(i).dataInfo)&&~isempty(data(i).dataInfo.columnInfo)
            next=generateIndividualDataHTML(data(i));
            html=appendLine(html,next);
        else
            dataCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,data(i).dataCacheName];
            matfileData=load(dataCacheFile);
            matfileData=matfileData.data;

            switch class(matfileData)
            case{'SimBiology.fit.NLMEResults','SimBiology.fit.OptimResults','SimBiology.fit.NLINResults'}
                tableHTML=SimBiology.web.report.fitStep('generateResultsHTML',html,struct('results',matfileData),data(i).name);
                html=appendLine('',tableHTML.html);
            case 'SimBiology.fit.ParameterConfidenceInterval'
                tableHTML=SimBiology.web.report.confidenceIntervalStep('generateResultsHTML','',struct('parameterCI',matfileData),data(i).name);
                html=appendLine(html,tableHTML.html);
            case 'SimBiology.fit.PredictionConfidenceInterval'
                tableHTML=SimBiology.web.report.confidenceIntervalStep('generateResultsHTML','',struct('predictionCI',matfileData),data(i).name);
                html=appendLine(html,tableHTML.html);
            end
        end
    end

    out.html=html;

end

function out=generateIndividualDataHTML(dataIn)

    headingLabel=dataIn.name;
    className='';
    styles={'','style="width:auto"','style="width:100px"'};
    headers={'','Name','Classification'};


    columnInfo=dataIn.dataInfo.columnInfo;
    if iscell(columnInfo)
        next=columnInfo{1};
    else
        next=columnInfo(1);
    end

    nextName='';
    if isfield(next,'name')
        nextName=next.name;
    end


    numRows=length(columnInfo);
    startIndex=1;
    if strcmp(nextName,'SimDataRun')
        numRows=numRows-1;
        startIndex=2;
    end


    rowNums=cell(1,numRows);
    name=cell(1,numRows);
    classification=cell(1,numRows);
    units=cell(1,numRows);
    expressions=cell(1,numRows);
    count=1;

    for i=startIndex:numel(columnInfo)
        if iscell(columnInfo)
            next=columnInfo{i};
        else
            next=columnInfo(i);
        end

        rowNums{count}=count;

        if isfield(next,'name')
            name{count}=next.name;
        else
            name{count}='';
        end

        if isfield(next,'classification')
            classification{count}=next.classification;
        else
            classification{count}='';
        end

        if isfield(next,'units')
            units{count}=next.units;
        else
            units{count}='';
        end

        if isfield(next,'expression')
            expressions{count}=next.expression;
        else
            expressions{count}='';
        end

        count=count+1;
    end

    data=[rowNums;name;classification]';
    if areValuesDefined(expressions)
        data=[data,expressions'];
        headers=[headers,'Expression'];
        styles{2}='style="width:250px"';
        styles=[styles,'style="width:auto"'];
    end

    if areValuesDefined(units)
        data=[data,units'];
        headers=[headers,'Units'];
        styles=[styles,'style="width:150px"'];
    end

    html=buildBlackSectionHeader('',headingLabel,'');
    tableHTML=buildTable(headers,data,styles,'Data Column Summary',className);
    out=appendLine(html,tableHTML);



    if(startIndex>1&&dataIn.dataInfo.rows>1)
        numRunsHTML=appendLineWithPad('','<h2>Number of Runs</h2>',1);
        numRunsHTML=appendLineWithPad(numRunsHTML,sprintf('<label>%d</label>',dataIn.dataInfo.rows),2);
        out=appendLine(out,numRunsHTML);
    end

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function out=areValuesDefined(list)

    out=SimBiology.web.report.utilhandler('areValuesDefined',list);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end

function out=buildTable(headers,data,styles,caption,className,varargin)

    out=SimBiology.web.report.utilhandler('buildTable',headers,data,styles,caption,className,varargin{:});

end
