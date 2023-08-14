classdef FileDeleter<handle




    properties(Access=private)
        files={};
        dirs={};
    end

    methods(Static)
        function addFiles(newFiles)
            obj=matlab.system.internal.FileDeleter.getInstance();
            if ischar(newFiles)
                newFiles={newFiles};
            end
            for i=1:length(newFiles)
                obj.files(end+1)=newFiles(i);
            end
            obj.files=unique(obj.files);
        end
        function addDirs(newDirs)
            obj=matlab.system.internal.FileDeleter.getInstance();
            if ischar(newDirs)
                newDirs={newDirs};
            end
            for i=1:length(newDirs)
                obj.dirs(end+1)=newDirs(i);
            end
            obj.dirs=unique(obj.dirs);
        end
        function deleteFiles()



            munlock;
            matlab.system.internal.FileDeleter.getInstance(false);
        end
    end


    methods(Access=protected)
        function obj=FileDeleter()
        end
    end

    methods(Access=protected,Static)
        function obj=getInstance(~)
            persistent pFiles
            if isempty(pFiles)&&(nargin==0)
                pFiles=matlab.system.internal.FileDeleter();
                mlock;
            end
            if(nargin==1)
                pFiles=[];
            end
            obj=pFiles;
        end
    end

    methods
        function delete(obj)
            for i=1:length(obj.files)
                if exist(obj.files{i},'file')
                    delete(obj.files{i});
                end
            end
            for i=1:length(obj.dirs)
                if exist(obj.dirs{i},'dir')
                    rmdir(obj.dirs{i},'s');
                end
            end
        end
    end

end

