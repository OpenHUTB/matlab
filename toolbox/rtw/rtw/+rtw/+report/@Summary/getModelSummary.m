function out=getModelSummary(obj)

    out={};
    row=1;

    out{row,1}=message('RTW:report:Author').getString;
    out{row,2}=obj.AuthorName;
    row=row+1;



    if(~isempty(obj.LastModifiedBy))
        out{row,1}=message('RTW:report:LastModifiedBy').getString;
        out{row,2}=obj.LastModifiedBy;
        row=row+1;
    end

    out{row,1}=message('RTW:report:ModelVersion').getString;
    out{row,2}=obj.ModelVersion;
    row=row+1;


    if(strcmp(obj.ExportedString,'')==1)

        out{row,1}=message('RTW:report:SummaryTaskingMode').getString;
        out{row,2}=message(['RTW:report:SummaryMultitaskingMode',obj.TaskingMode]).getString;

    end
end
