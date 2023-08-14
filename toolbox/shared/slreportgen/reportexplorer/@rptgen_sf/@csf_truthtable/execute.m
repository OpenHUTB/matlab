function out=execute(this,d,varargin)






    if~isempty(this.RuntimeTruthTable)
        out=this.makeTable(d);
    else
        ttHandles=rptgen_sf.csf_truthtable.findTruthTables;
        out=d.createDocumentFragment;

        for i=1:length(ttHandles)
            this.RuntimeTruthTable=ttHandles{i};
            out.appendChild(makeTable(this,d));
        end
        this.RuntimeTruthTable=[];
    end