



classdef TestBenchResource<handle
    properties(SetAccess=private,GetAccess=private)

        Resource;

        IsFile;

        IsSynthetic;
    end
    methods(Access=public)
        function this=TestBenchResource(aResource)
            this.Resource=aResource;
            this.determineIfResourceIsFile();
        end

        function fcn=getTestBenchFunction(this)
            if this.isFile()
                [~,fcn]=fileparts(this.Resource);
            else
                fcn=this.Resource;
            end
        end

        function path=getTestBenchPath(this)
            if this.isFile()
                [path,~]=fileparts(this.Resource);
            else
                path='';
            end
        end

        function is=isFile(this)
            is=this.IsFile;
        end

        function is=isSynthetic(this)
            is=this.IsSynthetic;
        end

        function setIsSynthetic(this,aIsSynthetic)
            this.IsSynthetic=aIsSynthetic;
        end
    end

    methods(Access=private)
        function determineIfResourceIsFile(this)
            if~ischar(this.Resource)
                if isstring(this.Resource)
                    this.Resource=char(this.Resource);
                else
                    this.IsFile=false;
                    return;
                end
            end
            switch exist(this.Resource)%#ok<EXIST>
            case{0,...
                1,...
                4,...
                5,...
                7,...
                8,...
                }
                this.IsFile=false;
            case{2,...
                3,...
                6,...
                }
                this.IsFile=true;
            otherwise
                this.IsFile=false;
            end
        end
    end
end
