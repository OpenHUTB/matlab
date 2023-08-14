classdef Logs<handle




    properties
        version;
        model;
        isResultMessage;
        logsSSColumn1=DAStudio.message('sl_pir_cpp:creator:logsSSColumn1');
    end
    methods(Access=public)

        function this=Logs(model,version,isResultMessage)
            if(nargin>0)
                this.version=version;
                this.model=model;
                this.isResultMessage=isResultMessage;
            end
        end
        function label=getDisplayLabel(this)
            label=this.version;
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case this.logsSSColumn1
                propValue=this.version;
            otherwise
                propValue='';
            end
        end



        function isHyperlink=propertyHyperlink(this,propName,clicked)
            isHyperlink=false;
            if strcmp(propName,this.logsSSColumn1)&&~this.isResultMessage
                isHyperlink=true;
            end
            if clicked
                cdUIObj=CloneDetectionUI.CloneDetectionUI.getActiveInstance(this.model);
                if exist(['m2m_',get_param(this.model,'name')],'dir')==0
                    cdUIObj.ddgBottom.status='error';
                    cdUIObj.ddgBottom.result=DAStudio.message('sl_pir_cpp:creator:backupFolderForModelNotFound',['m2m_',get_param(this.model,'name')]);
                    dlgBottom=DAStudio.ToolRoot.getOpenDialogs(cdUIObj.ddgBottom);
                    dlgBottom.refresh;
                    return;
                end
                cdUIObj.ddgBottom.status='success';
                reportObj=CloneDetectionUI.internal.util.findExistingDlg(get_param(this.model,'Name'),this.version);
                if isempty(reportObj)
                    reportObj=CloneDetectionUI.internal.DDGViews.ReportDialog(this.model,this.version);
                end
                CloneDetectionUI.internal.util.show(reportObj);
            end
        end


        function isValid=isValidProperty(this,propName)
            switch propName
            case this.logsSSColumn1
                isValid=true;
            otherwise
                isValid=false;
            end
        end


        function getPropertyStyle(this,~,propertyStyle)
            if this.isResultMessage
                aStyle=propertyStyle;
                aStyle.Bold=true;
            end
        end



        function readOnly=isReadonlyProperty(~,~)
            readOnly=true;
        end

    end
end


