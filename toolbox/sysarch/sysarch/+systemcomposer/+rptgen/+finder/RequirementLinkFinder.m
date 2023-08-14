classdef RequirementLinkFinder<mlreportgen.finder.Finder




















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
RequirementLinkObj
        RequirementLinkList=[]
        RequirementLinkCount{mustBeInteger}=0
        NextRequirementLinkIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods(Static,Access=private,Hidden)
        function reqStruct=createReqStruct(reqSet)
            links=reqSet.getLinks;
            source=[];
            if~isempty(links)
                for i=1:length(links)
                    compObj=slreq.structToObj(links(i).source);
                    if~isempty(compObj)
                        if isa(compObj,"systemcomposer.arch.BaseComponent")||isa(compObj,"systemcomposer.arch.BasePort")
                            source=compObj.Name;
                        else
                            source=compObj.Id;
                        end
                    end
                    reqStruct(i).Source=source;
                    reqStruct(i).Type=links(i).Type;
                    reqStruct(i).Destination=links(i).destination.id;
                end
            end
        end
    end

    methods(Hidden)
        function results=getResultsArrayFromStruct(this,requirementSetInformation)
            n=numel(requirementSetInformation);
            reqSet=slreq.load(this.Container);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=requirementSetInformation(i);
                results(i)=systemcomposer.rptgen.finder.RequirementLinkResult(reqSet.Filename);
                results(i).Source=temp.Source;
                results(i).Type=temp.Type;
                results(i).Destination=temp.Destination;
            end
            this.RequirementLinkList=results;
            this.RequirementLinkCount=numel(results);
        end

        function results=findRequirementSet(this)
            requirementSetInformation=[];
            reqSet=slreq.load(this.Container);
            requirementSetInformation=systemcomposer.rptgen.finder.RequirementLinkFinder.createReqStruct(reqSet);
            results=getResultsArrayFromStruct(this,requirementSetInformation);
        end


        function results=helper(this)
            results=findRequirementSet(this);
        end
    end

    methods
        function this=RequirementLinkFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)
            results=helper(this);
        end

        function tf=hasNext(this)
            if this.IsIterating
                if this.NextRequirementLinkIndex<=this.RequirementLinkCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this)
                if this.RequirementLinkCount>0
                    this.NextRequirementLinkIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)
            if hasNext(this)
                result=this.RequirementLinkList(this.NextRequirementLinkIndex);
                this.NextRequirementLinkIndex=this.NextRequirementLinkIndex+1;
            else
                result=systemcomposer.rptgen.finder.ProfileResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)
            this.IsIterating=false;
            this.RequirementLinkCount=0;
            this.RequirementLinkList=[];
            this.NextRequirementLinkIndex=0;
        end

        function tf=isIterating(this)
            tf=this.IsIterating;
        end
    end
end