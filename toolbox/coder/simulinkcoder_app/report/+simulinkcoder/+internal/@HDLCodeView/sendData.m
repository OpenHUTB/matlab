function sendData(obj,uid)




    studio=obj.studio;
    if isempty(studio)
        data=obj.getCodeData();
    else
        currentModel=obj.model;
        topModel=obj.top;
        isRef=~strcmp(topModel,currentModel);
        mdl=currentModel;


        cr=simulinkcoder.internal.Report.getInstance;

        cmp=studio.getComponent(cr.comp,'CodeView_HDL');
        if~isempty(cmp)
            hdlReportPath=hdlcoder.report.ReportInfo.getSavedRptPath(mdl,false);
            if~isempty(hdlReportPath)
                data=obj.getCodeData(hdlReportPath,mdl,isRef);
            else



                dir=obj.getHDLBuildDir(topModel);
                if~isempty(dir)
                    data=obj.getCodeData(dir,mdl,isRef);
                else
                    folder=pwd;
                    data.message=message('RTW:report:invalidBuildFolder',folder).getString;
                end
            end
        end
    end

    obj.publish('init',data,uid);


    if isfield(data,'current')&&~isempty(data.current)
        dispData.file=data.current;
        obj.publish('showFile',dispData);
    end
