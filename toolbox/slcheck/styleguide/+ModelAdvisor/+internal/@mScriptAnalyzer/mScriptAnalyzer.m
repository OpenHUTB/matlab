classdef mScriptAnalyzer<handle



    properties
        name;
        fmain;
        fdefs;
        mtreeObject;
        object;
        visitedFcns;
        location;
        emlCallables;
    end


    methods
        function this=mScriptAnalyzer(object)
            this.object=object;


            switch class(object)
            case{'Stateflow.EMChart','Stateflow.EMFunction'}
                this.mtreeObject=mtree(object.Script,'-com','-cell');
                this.name=[object.Path,'/',object.Name];
            case 'char'
                this.mtreeObject=mtree(object,'-com','-cell','-file');
                this.name=object;
            otherwise

                if isequal(class(object),'struct')&&isfield(object,'Script')
                    this.mtreeObject=mtree(object.Script,'-com','-cell');
                    this.name=object.Path;
                end
            end
        end
    end


    methods(Access=public)
        result=getFunctionDetails(this,visitedFiles);

        function setEMLCallables(this,emlCallables)
            if isequal(class(this.object),'Stateflow.EMFunction')
                this.emlCallables=emlCallables;
            end
        end

    end


    methods(Access=private)
        result=getCallsInFunction(this,fcn,visitedFiles);

    end
end












