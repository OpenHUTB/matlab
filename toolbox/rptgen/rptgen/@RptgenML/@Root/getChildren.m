function c=getChildren(this)






    c=this.ReportList;
    if isa(c,'RptgenML.Library')
        c=getChildren(c(1));



        if isempty(c)
            c=locGetSearchText();
        end

    elseif~isempty(this.Editor)


        if isempty(c)||~any(isa(c,'rptgen.DAObject'))
            c=locGetSearchText;
        else
            c(end+1)=locGetSearchText;
        end


        mlreportgen.utils.internal.defer(@()this.refreshReportList(true));

    else
        this.refreshReportList(true);


        c=getChildren(this);
    end


    function msg=locGetSearchText()



        msg=RptgenML.Message([getString(message('rptgen:RptgenML_Root:searchingLabel')),'                                   '],...
        getString(message('rptgen:RptgenML_Root:searchingForFilesLabel')));

