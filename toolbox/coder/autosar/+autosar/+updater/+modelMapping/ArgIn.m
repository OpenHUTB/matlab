classdef ArgIn<autosar.updater.ModelMappingMatcher





    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=ArgIn(modelName)
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

                argInBlks=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(fcnCallInportPath,'ArgIn','');
                for jj=1:length(argInBlks)
                    this.UnmatchedElements.set(getfullname(argInBlks(jj)));
                end
            end
        end

        function[isMapped,blockPath]=isMapped(this,varargin)

            isMapped=false;
            blockPath=[];

            sys=varargin{1};
            m3iArgument=varargin{2};

            blockH=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            sys,'ArgIn','','ArgumentName',m3iArgument.Name);

            if~isempty(blockH)
                blockPath=getfullname(blockH);
                this.UnmatchedElements.remove(blockPath);
                isMapped=true;
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'ArgIn','MarkBlockForDelete',changeLogger);
        end
    end
end
