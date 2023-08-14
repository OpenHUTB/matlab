function out=customCodeStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,step,configset)


    html=SimBiology.web.report.simulationStep('generateHTML',html,configset,[],[]);
    html=html.html;


    html=buildBlackSectionHeader(html,'Custom Code Step','');
    code=step.customCode;
    html=appendLineWithPad(html,'<h2>Custom Code</h2>',1);

    lines=splitlines(code);
    html=appendLineWithPad(html,'<pre>',2);
    for i=1:numel(lines)
        html=appendLineWithPad(html,sprintf('%s',lines{i}),2);
    end
    html=appendLineWithPad(html,'</pre>',2);


    out.html=html;

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end
