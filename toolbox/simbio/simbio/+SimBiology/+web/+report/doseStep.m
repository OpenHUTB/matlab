function out=doseStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,doseStepDoses)

    if~isempty(doseStepDoses)
        html=buildBlackSectionHeader(html,'Doses For Simulation Step','');
        html=buildDoseHTML(html,doseStepDoses);
    end


    out.html=html;

end

function html=buildDoseHTML(html,doses)

    html=SimBiology.web.report.utilhandler('generateDoseHTMLFromDoseStruct',html,doses);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);
end
