function fName=reportTruthTable(varargin)













    rpt=rptgen.loadRpt('truthtable');
    if isempty(rpt)
        warning(message('RptgenSL:rptgen_sf:fileNotFound'));
        fName='';
        return;
    end

    if~isempty(varargin)
        if isnumeric(varargin{1})
            sfID=find(slroot,'ID',varargin{1});
        elseif isa(varargin{1},'Stateflow.TruthTable')
            sfID=varargin{1};
        else
            sfID=[];
        end
        isPrint=any(strcmpi(varargin,'-print'));
    else
        isPrint=false;
        sfID=[];
    end

    rpt.isView=~isPrint;
    if~isempty(sfID)
        ttComp=find(rpt,'-isa','rptgen_sf.csf_truthtable');
        ttComp.RuntimeTruthTable=sfID(1);
    end

    fName=rpt.execute;

    delete(rpt);

