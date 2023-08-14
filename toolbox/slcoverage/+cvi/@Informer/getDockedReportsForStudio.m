function dockedReports=getDockedReportsForStudio(this,studio)




    dockedReports=[];

    if this.dockedReports.isKey(studio.getStudioTag)
        dockedReports=this.dockedReports(studio.getStudioTag);
    end
end
