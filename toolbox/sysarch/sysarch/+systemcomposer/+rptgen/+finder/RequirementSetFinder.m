classdef RequirementSetFinder<mlreportgen.finder.Finder























    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
RequirementSetObj
        RequirementSetList=[]
        RequirementSetCount{mustBeInteger}=0
        NextRequirementSetIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties



        Depth=inf;
    end

    methods(Static,Access=private,Hidden)
        function reqStruct=findRequirements(reqSet,reqStruct,depth)
            children=reqSet.children;
            if~(depth==0)
                if~isempty(children)
                    for i=1:length(children)
                        len=length(reqStruct);
                        reqStruct(len+1).ID=children(i).Id;
                        reqStruct(len+1).Summary=children(i).Summary;
                        outLinks=[];
                        if~isempty(children(i).outLinks)
                            links=children(i).outLinks;
                            for j=1:length(links)
                                outLinks=[outLinks,string(links(j).destination.id)];
                            end
                            reqStruct(len+1).Link=outLinks;
                        else
                            reqStruct(len+1).Link="-";
                        end
                        reqStruct=systemcomposer.rptgen.finder.RequirementSetFinder.findRequirements(children(i),reqStruct,depth-1);
                    end
                end
            end
        end

    end

    methods(Hidden)
        function results=getResultsArrayFromStruct(this,requirementSetInformation)
            n=numel(requirementSetInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            reqSet=slreq.load(this.Container);
            for i=1:n
                temp=requirementSetInformation(i);
                results(i)=systemcomposer.rptgen.finder.RequirementSetResult(reqSet.Filename);
                results(i).ID=temp.ID;
                results(i).Summary=temp.Summary;
                results(i).Link=temp.Link;
            end
            this.RequirementSetList=results;
            this.RequirementSetCount=numel(results);
        end

        function results=findRequirementSet(this)
            requirementSetInformation=[];
            reqSet=slreq.load(this.Container);
            depth=this.Depth;
            reqStruct=struct.empty(0,1);
            requirementSetInformation=systemcomposer.rptgen.finder.RequirementSetFinder.findRequirements(reqSet,reqStruct,depth);

            results=getResultsArrayFromStruct(this,requirementSetInformation);
        end

        function results=helper(this)
            results=findRequirementSet(this);
        end
    end

    methods
        function this=RequirementSetFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)
            results=helper(this);
        end


        function tf=hasNext(this)
            if this.IsIterating
                if this.NextRequirementSetIndex<=this.RequirementSetCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this)
                if this.RequirementSetCount>0
                    this.NextRequirementSetIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)
            if hasNext(this)
                result=this.RequirementSetList(this.NextRequirementSetIndex);
                this.NextRequirementSetIndex=this.NextRequirementSetIndex+1;
            else
                result=systemcomposer.rptgen.finder.RequirementSetResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.RequirementSetCount=0;
            this.RequirementSetList=[];
            this.NextRequirementSetIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end