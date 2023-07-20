function writeToFile(this,exList)




    if strcmp(class(this),'ModelAdvisor.ExclusionEditor')
        checkType='ModelAdvisor';
    else
        checkType='CloneDetection';
    end
    if~this.storeInSLX
        [status,msg]=ModelAdvisor.generateExclusionFile(exList,'.*',this.fileName,checkType);
        if~status
            dp=DAStudio.DialogProvider;
            dp.errordlg(msg,'Error',true);
            this.fDialogHandle.enableApplyButton(true);
        end
        try
            if~strcmp(get_param(bdroot(this.fModelName),'MAModelExclusionFile'),this.fileName)
                set_param(bdroot(this.fModelName),'MAModelExclusionFile',this.fileName);
                set_param(bdroot(this.fModelName),'Dirty','on');



            end
        catch E
            msgbox(E.message);
        end
    else
        if~isempty(get_param(bdroot(this.fModelName),'MAModelExclusionFile'))
            set_param(bdroot(this.fModelName),'MAModelExclusionFile','');
        end
        partFile=Simulink.slx.getUnpackedFileNameForPart(this.fModelName,this.getSlxPartName);
        [~,~]=ModelAdvisor.generateExclusionFile(exList,'.*',partFile,checkType);
        mdlObj=get_param(this.fModelName,'Object');
        if this.unsavedChanges
            mdlObj.setDirty('ModelAdvisorExclusions',true);
        end
    end
    this.refreshExclusions();
