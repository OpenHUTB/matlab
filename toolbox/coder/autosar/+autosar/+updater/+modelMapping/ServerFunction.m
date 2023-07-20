classdef ServerFunction<autosar.updater.ModelMappingMatcher





    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=ServerFunction(modelName)
            this=this@autosar.updater.ModelMappingMatcher(modelName);

            this.UnmatchedElements=autosar.mm.util.Set(...
            'InitCapacity',40,...
            'KeyType','char',...
            'HashFcn',@(x)x);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for ii=1:length(modelMapping.ServerFunctions)
                fcnCallInportPath=modelMapping.ServerFunctions(ii).Block;
                this.UnmatchedElements.set(fcnCallInportPath);
            end
        end

        function[isMapped,blk]=isMapped(this,varargin)

            isMapped=false;
            blk={};

            m3iRunnable=[];
            if nargin<4
                m3iRunnable=varargin{1};
            else
                sys=varargin{1};
                m3iServerPort=varargin{2};
                m3iMethod=varargin{3};


                sys=strrep(sys,newline,' ');
            end

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.ServerFunctions)
                serverFcnMapping=modelMapping.ServerFunctions(ii);

                if~isempty(m3iRunnable)

                    if~strcmp(modelMapping.ServerFunctions(ii).MappedTo.Runnable,m3iRunnable.Name)
                        continue;
                    end
                else

                    if strncmp(serverFcnMapping.Block,sys,length(sys))
                        if~(strcmp(serverFcnMapping.MappedTo.Port,m3iServerPort.Name)&&...
                            strcmp(serverFcnMapping.MappedTo.Method,m3iMethod.Name))
                            continue;
                        end
                    end
                end

                isMapped=true;
                blk=serverFcnMapping.Block;
                this.UnmatchedElements.remove(blk);
                break;
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'Runnable','MarkBlockForDelete',changeLogger);
        end
    end
end
