





classdef CodeInfoMatFile<sldv.code.internal.CodeInfoFile
    methods(Access=public)
        function this=CodeInfoMatFile(fileName,fileInfo)
            this@sldv.code.internal.CodeInfoFile(fileName,fileInfo);
        end


        function close(~)

        end

        function hasInfo=readDb(this)
            hasInfo=false;
            m=matfile(this.FileName);
            try
                varName=this.getVarName();
                instanceDb=m.(varName);
                if isa(instanceDb,this.FileInfo.getClassName())
                    this.CodeDb=instanceDb;
                    hasInfo=true;
                else
                    this.CodeDb=this.FileInfo.createCodeDb();
                end
            catch


                this.CodeDb=this.FileInfo.createCodeDb();
            end
        end

        function writeDb(this)
            m=matfile(this.FileName,'Writable',true);
            varName=this.getVarName();
            m.(varName)=this.CodeDb;
        end
    end

    methods(Access=private)
        function varName=getVarName(this)
            varName=this.FileInfo.getDataMemberName();
        end
    end
end


