



classdef StaticSFcnInfoReader<handle
    properties(Access=private)

        sfunction;

        outputDir;


        dbFile;

        staticDb;
    end

    methods(Access=public)
        function obj=StaticSFcnInfoReader(sfunction,outputDir)



            obj.sfunction=sfunction;
            if nargin<2
                outputDir=tempname;
            end
            obj.outputDir=outputDir;
            obj.dbFile='';
            obj.staticDb=[];
        end

        function delete(obj)
            obj.closeDb();
        end

        function closeDb(obj)
            if~isempty(obj.dbFile)
                obj.staticDb.close();
                delete(obj.dbFile);
                obj.dbFile='';
            end
        end

        function db=getDb(obj)
            obj.extractDatabase();
            db=obj.staticDb;
        end

        function fileNames=extractFiles(obj)
            fileNames=obj.extractInstrumentedFiles();
        end

        function sInfo=getSFunctionInfo(obj,convertMainPath)
            if nargin<2
                convertMainPath=true;
            end
            obj.extractDatabase();
            sInfo=obj.staticDb.getSFunctionInfo(obj.sfunction,obj.outputDir,convertMainPath);
        end

        function fileNames=extractInstrumentedFiles(obj)

            obj.extractDatabase();
            fileNames=obj.staticDb.extractInstrumentedFiles(obj.sfunction,obj.outputDir);
        end

        function extractDatabase(obj)



            if isempty(obj.dbFile)
                dbF=sldv.code.sfcn.internal.extractSFcnDb(obj.sfunction,obj.outputDir);
                obj.staticDb=sldv.code.sfcn.internal.StaticDb(dbF);
                obj.dbFile=dbF;
            end
        end
    end
end



