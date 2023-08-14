function out=modelStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,variants,modelStepDoses,input)


    if~isempty(variants)||~isempty(modelStepDoses)
        html=buildBlackSectionHeader(html,'Model Setup','');
    end


    if~isempty(variants)
        html=buildVariantHTML(html,variants,input);
    end


    if~isempty(modelStepDoses)
        html=buildDoseHTML(html,modelStepDoses);
    end


    out.html=html;

end

function html=buildVariantHTML(html,variants,input)

    if input.buildSingleVariantTable
        tableHTML=SimBiology.web.report.modelhandler('buildSingleVariantTable',variants);
    else
        tableHTML=SimBiology.web.report.modelhandler('buildVariantTables',variants);
    end

    html=appendLine(html,tableHTML);

end

function html=buildDoseHTML(html,doses)

    html=SimBiology.web.report.utilhandler('generateDoseHTMLFromDoseStruct',html,doses);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);
end
