

classdef ConstraintManagerInstance<handle

    properties(SetAccess=private,GetAccess=public)
        m_Dialog;
        m_MessageService;
        m_ConstraintManagerModel;
    end

    methods(Access=public)
        function obj=ConstraintManagerInstance(aBlockHandle)
            try
                obj.m_MessageService=constraint_manager.MessageService();

                obj.m_ConstraintManagerModel=constraint_manager.ConstraintManagerModel(aBlockHandle,obj.m_MessageService.m_ChannelId);


                obj.m_Dialog=constraint_manager.BrowserDialogFactory.create('CEF',obj.m_MessageService.getURL());


                onCloseFcn=@(varargin)constraint_manager('Delete',aBlockHandle);@(x)isa(x,'function_handle');
                obj.m_Dialog.addOnCloseFcn(onCloseFcn);

            catch exception
                throw(exception);
            end
        end

        function constraintManagerModelObj=getConstraintManagerModelObject(this)
            constraintManagerModelObj=this.m_ConstraintManagerModel.ConstraintManagerModelData;
        end

        function addSharedConstraintToModel(this,sharedConstraintList,product,matFileName,matFilePath)

            if~isempty(sharedConstraintList)
                this.m_ConstraintManagerModel.ConstraintManagerDataLoader.addNewMATFileToModel(...
                sharedConstraintList,product,matFileName,matFilePath);
            end
        end

        function delete(this)
            this.m_Dialog.delete();
        end

        function show(this)
            this.m_Dialog.show();
        end

        function hide(this)
            this.m_Dialog.hide();
        end

        function[bIsVisible]=isVisible(this)
            bIsVisible=this.m_Dialog.isVisible();
        end
    end
end

