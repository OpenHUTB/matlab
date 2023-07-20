classdef AxesFinder<mlreportgen.finder.Finder

























































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)


        NodeList=[]


        NodeCount{mustBeInteger}=0


        NextNodeIndex{mustBeInteger}=0


        IsIterating logical=false
    end

    methods
        function this=AxesFinder(varargin)
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)











            findImpl(this);

            results=this.NodeList;
        end
    end

    methods
        function result=next(this)














            if hasNext(this)

                result=this.NodeList(this.NextNodeIndex);

                this.NextNodeIndex=this.NextNodeIndex+1;
            else
                result=mlreportgen.finder.AxesResult.empty();
            end
        end

        function tf=hasNext(this)
























            if this.IsIterating
                if this.NextNodeIndex<=this.NodeCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findImpl(this);
                if this.NodeCount>0
                    this.NextNodeIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end
    end

    methods(Access=protected)
        function tf=isIterating(this)






            tf=this.IsIterating;
        end

        function reset(this)







            this.NodeList=[];
            this.IsIterating=false;
            this.NodeCount=0;
            this.NextNodeIndex=0;
        end
    end

    methods(Access=private)
        function findImpl(this)





            container=resolveContainer(this);

            findTerms={'Type','axes'};

            this.NodeList=sort(feval('findobj',...
            container,...
            this.Properties,...
            findTerms{:}));

            nTotal=length(this.NodeList);
            results=mlreportgen.finder.AxesResult.empty(0,nTotal);

            for i=1:nTotal
                node=this.NodeList(i);

                results(i)=mlreportgen.finder.AxesResult(node);
            end
            this.NodeList=results;
            this.NodeCount=nTotal;
        end

        function container=resolveContainer(this)




            container=this.Container;
            if ischar(container)
                container=string(container);
            end

            if isstring(container)

                [~,~,ext]=fileparts(container);
                if isempty(ext)
                    figFile=strcat(container,".fig");
                elseif strcmp(ext,".fig")||strcmp(ext,".mat")
                    figFile=container;
                else
                    error(message("mlreportgen:finder:error:invalidFigure"));
                end

                container=openfig(figFile,"invisible");
            end

            assert(ishghandle(container),...
            message("mlreportgen:finder:error:invalidFigure"));
        end
    end

end