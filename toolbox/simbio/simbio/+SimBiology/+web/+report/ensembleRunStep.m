function out=ensembleRunStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,configset,step,input)

    html=SimBiology.web.report.simulationStep('generateHTML',html,configset,step,input);
    html=html.html;

    interpolation=step.interpolation;
    switch(interpolation)
    case 'zoh'
        interpolation='zero-order hold';
    case 'off'
        interpolation='no interpolation';
    case 'linear'
        interpolation='linear interpolation';
    end

    props={'Number of Runs','Interpolation'};
    values={step.numberOfRuns,interpolation};

    html=buildSectionHeader(html,'Ensemble Run Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);


    out.html=html;

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);
end
