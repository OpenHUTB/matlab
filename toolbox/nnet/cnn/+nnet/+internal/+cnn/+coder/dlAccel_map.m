classdef dlAccel_map<handle







    properties(SetAccess=private,Hidden=true)

        buildDir=[]

    end

    properties(Access=private)

dlMap

    end

    methods
        function dlAccelMap=dlAccel_map()
            dlAccelMap.dlMap=containers.Map;
        end

        function buildDir=initializeBuildDir(this)


            if isempty(this.buildDir)
                this.buildDir=tempname;
            end
            buildDir=this.buildDir;
        end

        function value=dl_getValue(this,key)
            value=this.dlMap(key);
        end

        function dl_insert(this,key,value)
            this.dlMap(key)=value;
        end

        function dl_remove(this,key)
            remove(this.dlMap,key);
        end

        function out=dl_isKey(this,key)
            out=isKey(this.dlMap,key);
        end

        function key=dl_keys(this)
            key=keys(this.dlMap);
        end


        function out=dl_checkDlAccelFile(this,key)
            if this.dl_isKey(key)
                dlAccel=this.dl_getValue(key);
                if dlAccel.isValid()
                    out=true;
                else
                    delete(dlAccel);
                    this.dl_remove(key);
                    out=false;
                end
            else
                out=false;
            end
        end


        function delete(this)

            allkeys=keys(this.dlMap);
            for i=1:numel(allkeys)
                delete(this.dlMap(allkeys{i}));
            end

            if~isempty(this.buildDir)
                S=warning('off','MATLAB:rmpath:DirNotFound');
                rmpath(this.buildDir);
                warning(S);

                try
                    rmdir(this.buildDir,'s');
                catch ME
                    if ME.identifier~="MATLAB:RMDIR:NotADirectory"
                        rethrow(ME);
                    end
                end
            end
        end

    end
end
