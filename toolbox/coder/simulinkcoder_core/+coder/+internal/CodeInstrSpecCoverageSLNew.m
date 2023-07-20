classdef(Hidden=true)CodeInstrSpecCoverageSLNew<coder.internal.CodeInstrSpec





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

            folderInstr='instrumented';

            for i=1:numel(modules)
                modelName=modules{i};
                covEnabled=SlCov.CodeCovUtils.isXILCoverageEnabled...
                (this.TopModel,modelName,this.IsSil);
                if covEnabled&&~ismember(modelName,protectedModels)
                    folders{i}=folderInstr;
                else
                    folders{i}='';
                end
            end
        end


        function folder=getInstrSpecSrcFolder(this,module)



            folder=getInstrObjFolders(this,{module},{});
            folder=folder{1};

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


        function this=CodeInstrSpecCoverageSLNew(lCodeCovSettingsSL,lTopModel,isSil)
            this.CodeCovSettingsSL=lCodeCovSettingsSL;
            this.TopModel=lTopModel;
            this.IsSil=isSil;
        end

    end

end
