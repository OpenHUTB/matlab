classdef(Hidden=true)CodeInstrSpecCoverageSL<coder.internal.CodeInstrSpec





    properties(GetAccess=public,SetAccess=private)
CodeCovSettingsSL
    end

    properties(Access=private)
TopModel
IsSil
    end

    methods(Access=public)

        function folders=getInstrObjFolders(this,modules,protectedModels)
            if isempty(modules)
                modules={};
            else
                modules=cellstr(modules);
            end

            folders=cell(size(modules));
            folders(1:end)={''};

            isTopModel=strcmp(modules,this.TopModel);
            protectedIdx=ismember(modules,protectedModels);

            folderInstr='instrumented';

            if strcmp(this.CodeCovSettingsSL.ReferencedModelCoverage,'on')
                folders(~isTopModel&~protectedIdx)={folderInstr};
            end
            if strcmp(this.CodeCovSettingsSL.TopModelCoverage,'on')
                folders(isTopModel)={folderInstr};
            end
        end


        function folder=getInstrSrcFolder(~,~)



            folder='';
        end


        function[folder,relativePathToParent]=getSharedUtilObjFolder(this)
            folder='';
            relativePathToParent='';
            if strcmp(this.CodeCovSettingsSL.ReferencedModelCoverage,'on')
                folder='instrumented';
                relativePathToParent='..';
            end
            if strcmp(this.CodeCovSettingsSL.TopModelCoverage,'on')
                folder='instrumented';
                relativePathToParent='..';
            end
        end


        function this=CodeInstrSpecCoverageSL(lCodeCovSettingsSL,lTopModel,isSil)
            this.CodeCovSettingsSL=lCodeCovSettingsSL;
            this.TopModel=lTopModel;
            this.IsSil=isSil;
        end

    end

end
