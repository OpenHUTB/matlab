function mustBeTabular(value,holeId)

    exception='mlreportgen:report:validators:mustBeTabular';


    if ischar(value)
        value=string(value);
    end

    if~condition(value,holeId)
        throw(createValidatorException(exception,holeId));
    end
end


function is=condition(value,holeId)
    is=(isEmpty(value)||...
    isa(value,'mlreportgen.dom.Table')||...
    isa(value,'mlreportgen.dom.FormalTable')||...
    isa(value,'mlreportgen.dom.MATLABTable')||...
    isa(value,'table')||(iscell(value)&&~isReporterBase(value))||...
    (isTwoDimensional(value)&&~isa(value,'mlreportgen.report.HoleReporter')))&&...
    ~isa(value,'mlreportgen.report.ReporterBase');

    if~is&&isa(value,'mlreportgen.report.HoleReporter')
        if isempty(value.HoleId)
            is=isempty(holeId);
        else
            is=(value.HoleId==holeId);
        end
    end

end

function isReporter=isReporterBase(value)
    isReporter=false;
    for i=1:numel(value)
        isReporter=isa(value{i},'mlreportgen.report.ReporterBase');
        if(isReporter)
            break;
        end
    end
end