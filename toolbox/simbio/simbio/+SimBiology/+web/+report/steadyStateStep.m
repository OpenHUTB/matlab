function out=steadyStateStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    end

end

function out=generateHTML(html,step,input)


    if~isempty(step)&&input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'Steady State Step',step.description);
    else
        html=buildBlackSectionHeader(html,'Steady State Step','');
    end

    props={'Method','Min StopTime','Max StopTime','Absolute Tolerance','Relative Tolerance'};
    values={step.method,step.minStopTime,step.maxStopTime,step.absoluteTolerance,step.relativeTolerance};

    html=buildSectionHeader(html,'Steady State Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);


    out.html=html;

end

function out=generateResultsHTML(html,data)

    out=[];
    if isfield(data,'success')&&isfield(data,'variant')
        success=data.success;
        variant=data.variant;


        html=buildBlackSectionHeader(html,'Steady State Step','');


        if success
            status='Steady state was found';
            tableHeading='Values at Steady State';
        else
            status='Steady state was not found';
            tableHeading='Last Values Found';
        end

        html=appendLineWithPad(html,'<h2>Status</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>%s</label>',status),2);


        if~isempty(variant)
            tableHTML=SimBiology.web.report.modelhandler('buildSingleVariantTable',variant,tableHeading);
            if~isempty(tableHTML)
                html=appendLine(html,tableHTML);
            end
        end

        out.html=html;
    end

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);
end
