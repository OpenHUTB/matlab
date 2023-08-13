classdef(Sealed)FileSystemCacheHandler<handle

    properties(SetAccess=immutable)

        Path string


        IsTemporary logical=false
    end

    properties(Constant)

        CacheName='hdlm'
    end

    methods

        function this=FileSystemCacheHandler(parentFolder)


            if nargin==0

                this.Path=tempname;
                this.IsTemporary=true;
            else
                this.Path=fullfile(parentFolder,this.CacheName);
            end

        end

        function delete(this)

            this.deleteCache();
        end

        function fullPath=getFilePath(this,relativePath)

            fullPath=fullfile(this.Path,relativePath);
        end

        function tf=fileExists(this,filePath)

            tf=this.exists()&...
            arrayfun(@(f)exist(f,'file')==2,filePath);
        end

        function addFolder(this,varargin)

            if this.exists()&&...
                ~folderExists(fullfile(this.Path,varargin{:}))
                mkdir(this.Path,fullfile(varargin{:}))
            end
        end

        function tf=exists(this)





            tf=~isempty(this.Path)&&folderExists(this.Path);
        end

        function open(this)

            if~this.exists()
                this.createCache();
            end
        end

    end

    methods(Access=private)

        function createCache(this)

            [success,msg,msgID]=mkdir(this.Path);
            if~success
                throwFileSystemError(this.Path,msg,msgID);
            end
        end

        function deleteCache(this)

            if this.IsTemporary&&this.exists()
                [success,msg,msgID]=rmdir(this.Path,'s');
                if~success
                    throwFileSystemError(this.Path,msg,msgID);
                end
            end
        end

    end

end

function tf=folderExists(folder)

    tf=~isempty(dir(folder));
end

function throwFileSystemError(path,msg,msgID)


    if strcmpi(msgID,'matlab:mkdir:oserror')

        error(message('driving:heremaps:NewDirectoryFailure',path,msg));
    else

        error(message(msgID,'%s',msg));
    end
end