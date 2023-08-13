classdef(Abstract)HasAsyncCacheWriter<handle
    properties(Abstract,Constant,Access=protected)

WebOptions
    end

    properties(SetAccess=immutable)

        Cache driving.internal.heremaps.FileSystemCacheHandler
    end

    properties(Access=private)

        Writer=matlab.internal.asynchttpsave.AsyncHTTPContentFileWriter
    end

    properties(Constant,Access=private)
        Timeout=15
    end

    methods

        function this=HasAsyncCacheWriter(cache)



            this.Cache=cache;
            this.Writer.Options=this.WebOptions;
            this.Writer.Options.Timeout=this.Timeout;
        end

        function filenames=save(this,filenames,urls)


            this.Cache.open();


            this.Writer.Filename=filenames;
            this.Writer.URL=urls;


            this.Writer.NumThreads=min(length(filenames),...
            this.Writer.MaxNumThreads);


            this.Writer.writeContentToFilesAndBlock();
            this.waitForFilesExist(filenames);
        end

        function tf=isCached(this,filename)

            tf=this.Cache.fileExists(filename);
        end

        function fullFilePath=getCachePath(this,relativePath)

            fullFilePath=this.Cache.getFilePath(relativePath);
        end

        function addCacheFolder(this,varargin)

            this.Cache.open();
            this.Cache.addFolder(varargin{:});
        end

    end

    methods(Static,Access=protected)

        function waitForFilesExist(filenames)


            folder=fileparts(filenames(1));

            timeStep=0.01;
            maxNumSteps=driving.internal.heremaps.HasAsyncCacheWriter.Timeout/timeStep;
            numSteps=0;

            while~all(arrayfun(@exist,filenames))&&(numSteps<maxNumSteps)
                fschange(folder);
                pause(timeStep);
                numSteps=numSteps+1;
            end
        end

    end

end