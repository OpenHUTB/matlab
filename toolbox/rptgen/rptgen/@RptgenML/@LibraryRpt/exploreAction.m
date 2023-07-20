function exploreAction(this)





    if isempty(this.PathName)


        refreshReportList(RptgenML.Root,false);
    else
        addReport(RptgenML.Root,fullfile(this.PathName,this.FileName));
    end
