





classdef CodeInfoFile<handle
    properties

CodeDb


FileName
    end

    properties(Access=protected)

FileInfo
    end

    methods(Access=public)
        function this=CodeInfoFile(fileName,fileInfo)
            this.FileName=fileName;
            this.FileInfo=fileInfo;
        end




        function db=getDb(this)
            db=this.CodeDb;
        end


        function db=setDb(this,db)
            this.CodeDb=db;
        end




        function addAnalysis(this,codeAnalysis)
            this.CodeDb.addAnalysis(codeAnalysis);
            this.writeDb();
        end




        function[hasInfo,info]=hasExistingInfo(this,codeAnalysis,full,summary)
            [hasInfo,info]=this.CodeDb.hasExistingInfo(codeAnalysis,full,summary);
        end





        function clearInstances(this,codeAnalysis)
            changed=this.CodeDb.clearInstances(codeAnalysis);
            this.writeIfChanged(changed);
        end





        function clearEntries(this,codeAnalysis)
            changed=this.CodeDb.clearEntries(codeAnalysis);
            this.writeIfChanged(changed);
        end




        function clearModelName(this,codeAnalysis)
            changed=this.CodeDb.clearModelName(codeAnalysis);
            this.writeIfChanged(changed);
        end




        function clearOtherStaticChecksums(this,codeAnalysis)
            changed=this.CodeDb.clearOtherStaticChecksums(codeAnalysis);
            this.writeIfChanged(changed);
        end

        function writeIfChanged(this,changed)
            if changed
                this.writeDb();
            end
        end
    end

    methods(Access=public,Abstract)

        close(this)







        hasInfo=readDb(this)



        writeDb(this)
    end
end


