classdef AcrossFolders<handle





    properties
        id='ClonesAcrossFolders';
        title='Find Clones in Folders';
        selectedFolders={};
        model;
        cloneUIObj;
        fDialogHandle=[];
        eventListener=[];
    end

    methods(Access='public')
        function obj=AcrossFolders(cloneUIObj)


            obj.cloneUIObj=cloneUIObj;
            obj.model=cloneUIObj.model;
        end

        function dirtyEditor(obj)
            if~isempty(obj.fDialogHandle)
                obj.fDialogHandle.restoreFromSchema;
                obj.fDialogHandle.enableApplyButton(true);
                obj.fDialogHandle.setTitle([obj.title,' *']);

            end
        end

        browseFolders(obj);
        importFromBaseWorkspace(obj);
        exportToBaseWorkspace(obj);
        addFolderEditText(obj);
        s=covertFolderStrToDelimitedChar(obj);
        dlgStruct=getDialogSchema(obj);

    end
end
