function result=setExportReportTemplate(this)
    result.success=false;
    result.fName='';

    [filename,filepath]=uigetfile('.dotx',DAStudio.message('ModelAdvisor:engine:SelectTemplateforRpt'),this.exportReportTemplate);


    dstFileName=[filepath,filename];
    if(dstFileName(1)~=0)
        this.exportReportTemplate=dstFileName;
        result.fName=truncatePath(dstFileName);
        result.success=true;
    end
    this.maObj.AdvisorWindow.bringToFront();
end

function out=truncatePath(path)
    parts=strsplit(path,filesep);
    out=['...',filesep,strjoin(parts(end-2:end),filesep)];
end