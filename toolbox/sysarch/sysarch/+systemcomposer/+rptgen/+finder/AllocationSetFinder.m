classdef AllocationSetFinder<mlreportgen.finder.Finder





















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
AllocationObj
        AllocationSet=[]
        AllocationCount{mustBeInteger}=0
        NextAllocationIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods(Static,Access=private,Hidden)
        function allocationStruct=createAllocationStruct(allocation)
            allocationStruct.obj=allocation.UUID;
            allocationStruct.Name=string(allocation.Name);
            allocationStruct.SourceModel=string(allocation.SourceModel.Name);
            allocationStruct.TargetModel=string(allocation.TargetModel.Name);
            allocationStruct.Description=string(allocation.Description);
            allocationStruct.Scenarios=systemcomposer.rptgen.finder.AllocationSetFinder.createScenarioStruct(allocation);
        end

        function scenarioStruct=createScenarioStruct(allocation)
            scenarioStruct=[];
            scenarios=allocation.Scenarios;
            if~isempty(scenarios)
                for i=1:length(scenarios)
                    allocations=scenarios(i).Allocations;
                    sc=[];
                    for j=1:length(allocations)
                        sc(j).SourceElement=allocations(j).Source.getQualifiedName;
                        sc(j).TargetElement=allocations(j).Target.getQualifiedName;
                    end
                    scenarioStruct(i).Name=scenarios(i).Name;
                    scenarioStruct(i).allocations=sc;
                    scenarioStruct(i).UUID=scenarios(i).UUID;
                end
            end
        end
    end

    methods(Hidden)



        function results=getResultsArrayFromStruct(this,allocationInformation)
            n=numel(allocationInformation);
            allocSet=systemcomposer.allocation.load(this.Container);
            results=mlreportgen.finder.Result.empty();
            for i=1:n
                temp=allocationInformation(i);
                results(i)=systemcomposer.rptgen.finder.AllocationSetResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).SourceModel=temp.SourceModel;
                results(i).TargetModel=temp.TargetModel;
                results(i).Description=temp.Description;
                results(i).Scenarios=temp.Scenarios;

            end
            this.AllocationSet=results;
            this.AllocationCount=numel(results);
        end

        function results=findAllocationsInModel(this)
            allocationInformation=[];

            allocSet=systemcomposer.allocation.load(this.Container);
            if~isempty(allocSet)
                allocationInformation=systemcomposer.rptgen.finder.AllocationSetFinder.createAllocationStruct(allocSet);
            end
            results=getResultsArrayFromStruct(this,allocationInformation);
        end


        function results=helper(this)
            results=findAllocationsInModel(this);
        end
    end

    methods
        function this=AllocationSetFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
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
                helper(this);
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

                result=this.AllocationSet(this.NextAllocationIndex);

                this.NextAllocationIndex=this.NextAllocationIndex+1;
            else
                result=systemcomposer.rptgen.finder.AllocationSetResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.AllocationCount=0;
            this.AllocationSet=[];
            this.NextAllocationIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end
