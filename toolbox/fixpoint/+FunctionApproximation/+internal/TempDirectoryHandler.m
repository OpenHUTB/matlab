classdef TempDirectoryHandler<handle















    properties(SetAccess=private)
        TempDir=''
    end

    properties(Access=private)
        FallBackDir='';
    end

    methods
        function this=createDirectory(this,varargin)



            if isempty(this.TempDir)
                if nargin==1


                    directoryName=this.getDirectoryName();
                else
                    directoryName=varargin{1};
                end

                curDir=pwd;
                cd(tempdir);
                if~exist(directoryName,'dir')
                    mkdir(directoryName);
                end
                this.TempDir=[tempdir,directoryName];
                cd(curDir);

                this.FallBackDir=pwd;
            end
        end

        function this=addToPath(this)


            if~isempty(this.TempDir)&&~isDirectoryOnPath(this)
                addpath(this.TempDir);
            end
        end

        function this=removeFromPath(this)


            if isDirectoryOnPath(this)
                rmpath(this.TempDir);
            end
        end

        function flag=isDirectoryOnPath(this)
            flag=false;
            if~isempty(this.TempDir)
                curPath=path();
                if contains(curPath,this.TempDir)
                    flag=true;
                end
            end
        end

        function this=createDirectoryOnPath(this,varargin)

            createDirectory(this,varargin{:});
            addToPath(this);
        end

        function this=clearDirectory(this)

            removeFromPath(this);


            if~isempty(this.TempDir)&&exist(this.TempDir,'dir')
                if strcmp(pwd,this.TempDir)




                    cd(this.FallBackDir)
                end

                status=rmdir(this.TempDir,'s');%#ok<NASGU> collect status to avoid throwing any error
            end
            this.TempDir='';
        end

        function delete(this)


            if~isempty(this.TempDir)
                folderInfo=dir(this.TempDir);
                folderInfo=folderInfo(~cellfun('isempty',{folderInfo.date}));
                if strcmp([folderInfo.name],'...')
                    clearDirectory(this);
                end
            end
        end
    end

    methods(Static)
        function dirName=getDirectoryName()
            dirName=['FunctionApproximation_MATLAB_',datestr(now,'yyyymmddTHHMMSSFFF'),fixed.internal.compactButAccurateMat2Str(randi(2^52,1,16))];
            dirName=['FA_',fixed.internal.utility.shaHex(dirName)];
        end
    end
end
