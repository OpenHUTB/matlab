classdef AllocationListFinder<mlreportgen.finder.Finder






















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
AllocationObj
        AllocationList=[]
        AllocationCount{mustBeInteger}=0
        NextAllocationIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties




ComponentName
    end

    methods(Static,Access=private,Hidden)
        function[allocatedFrom,allocatedTo]=createAllocationStruct(this)
            af=systemcomposer.rptgen.finder.AllocationSetFinder(this.Container);
            f=find(af);
            scenarios=f.Scenarios;
            source=[];
            target=[];
            for i=1:length(scenarios)
                allocations=scenarios(i).allocations;
                for alloc=allocations
                    source=[source,string(alloc.SourceElement)];
                    target=[target,string(alloc.TargetElement)];
                end
            end
            allocatedToIndex=source==this.ComponentName;
            allocatedTo=target(allocatedToIndex);
            alloactedFromIndex=target==this.ComponentName;
            allocatedFrom=source(alloactedFromIndex);
        end
    end


    methods(Hidden)



        function results=getResultsArrayFromStruct(this,allocatedFromComponents,allocatedToComponents)
            hdl=get_param(this.ComponentName,'Handle');
            component=systemcomposer.internal.getWrapperForImpl...
            (systemcomposer.utils.getArchitecturePeer(hdl),...
            'systemcomposer.arch.Component');
            results=systemcomposer.rptgen.finder.AllocationListResult(component.UUID);
            if~isempty(allocatedFromComponents)
                results.AllocatedFrom=allocatedFromComponents;
            else
                results.AllocatedFrom=[];
            end
            if~isempty(allocatedToComponents)
                results.AllocatedTo=allocatedToComponents;
            else
                results.AllocatedTo=[];
            end

            this.AllocationList=results;
            this.AllocationCount=numel(results);
        end

        function results=findAllocationsInModel(this)
            [allocatedFromComponents,allocatedToComponents]=...
            systemcomposer.rptgen.finder.AllocationListFinder.createAllocationStruct(this);
            results=getResultsArrayFromStruct(this,allocatedFromComponents,...
            allocatedToComponents);
        end

        function results=helper(this)
            results=findAllocationsInModel(this);
        end
    end

    methods
        function this=AllocationListFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)








            results=helper(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextAllocationIndex<=this.AllocationCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this)
                if this.AllocationCount>0
                    this.NextAllocationIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.AllocationList(this.NextAllocationIndex);

                this.NextAllocationIndex=this.NextAllocationIndex+1;
            else
                result=systemcomposer.rptgen.finder.AllocationListResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.AllocationCount=0;
            this.AllocationList=[];
            this.NextAllocationIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end