function out=sensitivityStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,configset,step,input)

    html=SimBiology.web.report.simulationStep('generateHTML',html,configset,step,input);
    html=html.html;
    html=buildSensitivityOptionsHTML(html,step);
    html=buildSensitivityTableHTML(html,step);


    out.html=html;

end

function html=buildSensitivityOptionsHTML(html,step)


    props=cell(1,1);
    props{1}='Normalization';
    values=cell(1,numel(props));
    values{1}=step.normalization;

    html=buildSectionHeader(html,'Sensitivity Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=buildSensitivityTableHTML(html,step)


    sens=step.sensitivity;
    rowNumber={};
    output={};
    input={};
    name={};
    count=1;

    for i=1:numel(sens)
        if(sens(i).output||sens(i).input)
            rowNumber{count}=count;%#ok<*AGROW> 
            output{count}=sens(i).output;
            input{count}=sens(i).input;
            name{count}=sens(i).name;
            count=count+1;
        end
    end

    data=[rowNumber;output;input;name]';
    headers={' ','Output','Input','Component Name'};
    styles={'style="width:30px"','style="width:60px"','style="width:60px"','style="width:70%"'};
    sensTable=buildTable(headers,data,styles,'Sensitivities Calculated');
    html=appendLine(html,sensTable);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=buildTable(headers,contentInfo,styles,caption)

    code=SimBiology.web.report.utilhandler('buildTable',headers,contentInfo,styles,caption);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);
end
