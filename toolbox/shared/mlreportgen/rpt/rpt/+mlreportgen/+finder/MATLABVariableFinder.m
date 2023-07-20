classdef MATLABVariableFinder<mlreportgen.finder.Finder































































    properties






        Name string{mustBeScalarOrEmpty(Name)}=string.empty();
























        Regexp(1,1)logical=false;













        IncludeReportVariables(1,1)logical=false;
    end

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
        function this=MATLABVariableFinder(varargin)
            if nargin==0
                varargin={"MATLAB"};%#ok<STRSCALR>
            elseif nargin>1&&~any(strcmp(string(varargin(1:2:end)),"Container"))
                varargin=[{"Container","MATLAB"},varargin];
            end
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)











            container=this.Container;
            if~endsWith(container,".mat","IgnoreCase",true)&&...
                ~ismember(lower(container),["matlab","global"])
                error(message("mlreportgen:finder:error:mustBeMATFileOrWorkspace"));
            end

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
                result=mlreportgen.finder.MATLABVariableResult.empty();
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





            nameArg={};
            if~isempty(this.Name)
                if this.Regexp
                    nameArg=["-regexp",this.Name];
                else
                    nameArg=this.Name;
                end
            end

            container=this.Container;
            filePath=string.empty();
            switch lower(container)
            case "matlab"

                callStr="whos(";
                if~isempty(nameArg)
                    nameArgStr="'"+strjoin(nameArg,"','")+"'";
                    callStr=strcat(callStr,nameArgStr);
                end
                callStr=strcat(callStr,")");
                variables=evalin("base",callStr);
            case "global"

                variables=whos("global",nameArg{:});
            otherwise

                filePath=mlreportgen.utils.findFile(container);
                try
                    variables=whos("-file",filePath,nameArg{:});
                catch me

                    error(message("mlreportgen:finder:error:MATFileNotFound",container));
                end
                container="MAT-File";
            end



            variables=filterVariables(this,variables);


            nTotal=numel(variables);
            results=mlreportgen.finder.MATLABVariableResult.empty(0,nTotal);

            for i=1:nTotal
                var=variables(i);

                results(i)=mlreportgen.finder.MATLABVariableResult(...
                "Object",string(var.name),"Location",container,...
                "FileName",filePath,"WhosInfo",var);
            end
            this.NodeList=results;
            this.NodeCount=nTotal;
        end

        function newVars=filterVariables(this,variables)
            newVars=variables;

            if~this.IncludeReportVariables
                rptClasses=["mlreportgen.","slreportgen.","rptgen."];
                varClasses={newVars.class};
                newVars(startsWith(varClasses,rptClasses))=[];
            end


            props=this.Properties;
            if~isempty(props)

                nEntries=numel(props);
                nVars=numel(newVars);
                isfiltered=false(1,nVars);
                for varIdx=1:nVars
                    currVar=newVars(varIdx);
                    for idx=1:2:nEntries
                        prop=props{idx};
                        try
                            propVal=currVar.(prop);
                        catch


                            isfiltered(varIdx)=true;
                            break;
                        end
                        targetVal=props{idx+1};
                        if~isequal(propVal,targetVal)


                            isfiltered(varIdx)=true;
                            break;
                        end
                    end
                end
                newVars(isfiltered)=[];
            end
        end
    end

end