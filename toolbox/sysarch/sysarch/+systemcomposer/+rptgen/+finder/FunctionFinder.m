classdef FunctionFinder<mlreportgen.finder.Finder























    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties
        ComponentName;
    end

    properties(Access=private)
FunctionObj
        FunctionList=[]
        FunctionCount{mustBeInteger}=0
        NextFunctionIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods(Static,Access=private,Hidden)








        function functionsStruct=createFunctionsStruct(fnc)
            functionsStruct.obj=fnc.UUID;
            functionsStruct.Name=fnc.Name;
            functionsStruct.Component=fnc.Component.Name;
            functionsStruct.Parent=fnc.Parent.Name;
            functionsStruct.Period=fnc.Period;
            functionsStruct.ExecutionOrder=fnc.ExecutionOrder;
        end
    end

    methods(Hidden)



        function results=getResultsArrayFromStruct(this,functionsInformation)
            n=numel(functionsInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=functionsInformation(i);
                results(i)=systemcomposer.rptgen.finder.FunctionResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).Component=temp.Component;
                results(i).Parent=temp.Parent;
                results(i).Period=temp.Period;
                results(i).ExecutionOrder=temp.ExecutionOrder;
            end
            this.FunctionList=results;
            this.FunctionCount=numel(results);
        end

        function results=findFunctionsInModel(this)
            functionsInformation=[];
            model=systemcomposer.loadModel(this.Container);
            modelFuntions=model.Architecture.Functions;
            if~isempty(this.ComponentName)
                compNames=[];
                for f=modelFuntions
                    compNames=[compNames,string(f.Component.Name)];
                end
                index=find(compNames==this.ComponentName);
                if~isempty(index)
                    for i=index
                        functionsInformation=[functionsInformation,systemcomposer.rptgen.finder.FunctionFinder.createFunctionsStruct(modelFuntions(i))];
                    end
                end
            else
                if~isempty(modelFuntions)
                    for fnc=modelFuntions
                        functionsInformation=[functionsInformation,systemcomposer.rptgen.finder.FunctionFinder.createFunctionsStruct(fnc)];
                    end
                end
            end
            results=getResultsArrayFromStruct(this,functionsInformation);
        end
    end

    methods
        function this=FunctionFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)










            results=findFunctionsInModel(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextFunctionIndex<=this.FunctionCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findFunctionsInModel(this)
                if this.FunctionCount>0
                    this.NextFunctionIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.FunctionList(this.NextFunctionIndex);

                this.NextFunctionIndex=this.NextFunctionIndex+1;
            else
                result=systemcomposer.rptgen.finder.FunctionResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.FunctionCount=0;
            this.FunctionList=[];
            this.NextFunctionIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end