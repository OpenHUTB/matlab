classdef ReportDialog<handle




    properties(Constant)
        id='Report'
    end
    properties
        historyVersion;
        model;
        title='';
        eventListener=[];
        fDialogHandle=[];
        mdls;
        m2m_dir;
        backmdlprefix;
        changelibraries;
        libname;
    end

    methods
        function this=ReportDialog(model,historyVersion)
            this.historyVersion=historyVersion;
            this.model=model;
            CloneDetectionUI.internal.util.setEventHandler(this);
        end

        function restoreModel(this)
            if exist(this.m2m_dir,'dir')==0
                DAStudio.error('sl_pir_cpp:creator:BackupFolderNotFound',...
                this.m2m_dir);
            end
            slEnginePir.undoModelRefactor(this.mdls,this.backmdlprefix,...
            this.m2m_dir);

            slEnginePir.undoModelRefactor(this.changelibraries,...
            this.backmdlprefix,this.m2m_dir);
            close_system(this.libname,0);
        end

        function closeReportDialog(obj)

            delete(obj.fDialogHandle);
        end

        html=getReportHTML(this,activeObj);
        html=getReportFoldersHTML(this,activeObj);
        dlgStruct=getDialogSchema(obj);
    end
end


