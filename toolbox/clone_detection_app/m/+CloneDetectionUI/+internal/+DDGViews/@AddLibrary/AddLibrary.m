classdef AddLibrary<handle







    properties
        id=DAStudio.message('sl_pir_cpp:creator:AddLibraryDialogTitle');
        title=DAStudio.message('sl_pir_cpp:creator:AddLibraryDialogTitle');
        libFilenamesText='';
        unsavedChanges=false;
        fDialogHandle=[];
        eventListener=[];
        files;
        cloneUIObj;
        model;
    end

    methods(Access='public')
        function this=AddLibrary(cloneUIObj)
            this.cloneUIObj=cloneUIObj;
            this.model=cloneUIObj.model;
            CloneDetectionUI.internal.util.setEventHandler(this);
        end

        function out=getUnsavedChanges(aObj)
            out=aObj.unsavedChanges;
        end

        function setUnsavedChanges(aObj,flag)
            aObj.unsavedChanges=flag;
        end

        function dirtyEditor(aObj)
            if~isempty(aObj.fDialogHandle)
                aObj.fDialogHandle.restoreFromSchema;
                aObj.fDialogHandle.enableApplyButton(true);
                aObj.fDialogHandle.setTitle([aObj.title,' *']);
                aObj.setUnsavedChanges(true);
            end
        end

        function saveLibFileNamesText(this)
            libText=this.fDialogHandle.getWidgetValue('libraryFileName');
            this.libFilenamesText=libText;
        end

        dlgStruct=getDialogSchema(this);
        browseLibraryFile(this);
        valid=checkUploadedFileNameValidity(this,filename);
        getLibFilesFromDir(this,dirName);
        setEventHandler(this);
        removeLibraryCallback(this);

    end

    methods(Static=true)
        valid=checkFileName(filename);

    end

end

