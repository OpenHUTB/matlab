classdef FunctionCaller<autosar.updater.ModelMappingMatcher





    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=FunctionCaller(modelName)
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
            for ii=1:length(modelMapping.FunctionCallers)
                fcnCallerPath=modelMapping.FunctionCallers(ii).Block;
                if~autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(fcnCallerPath)
                    this.UnmatchedElements.set(fcnCallerPath);
                end
            end
        end

        function[isMapped,blks]=isMapped(this,varargin)

            isMapped=false;
            blks={};

            sys=varargin{1};
            m3iClientPort=varargin{2};
            m3iOperation=varargin{3};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);


            sys=strrep(sys,newline,' ');
            for ii=1:length(modelMapping.FunctionCallers)
                fcnCallerMapping=modelMapping.FunctionCallers(ii);

                if strncmp(fcnCallerMapping.Block,sys,length(sys))
                    if strcmp(fcnCallerMapping.MappedTo.ClientPort,m3iClientPort.Name)&&...
                        strcmp(fcnCallerMapping.MappedTo.Operation,m3iOperation.Name)
                        isMapped=true;
                        blk=fcnCallerMapping.Block;
                        blks=[blks,blk];%#ok<AGROW>
                        this.UnmatchedElements.remove(blk);
                    end
                end
            end
        end

        function logDeletions(this,changeLogger,~)
            unmatchedElems=this.UnmatchedElements.getKeys();
            bswCallerIdxs=cellfun(@(x)autosar.bsw.BasicSoftwareCaller.isBSWCallerBlock(x),unmatchedElems);
            this.logManualBlkDeletions(unmatchedElems(bswCallerIdxs),'Basic Software Caller','MarkBlockForDeleteAndComment',changeLogger);
            this.logManualBlkDeletions(unmatchedElems(~bswCallerIdxs),'Function Caller','MarkBlockForDelete',changeLogger);
        end
    end
end
