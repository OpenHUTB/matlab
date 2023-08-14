classdef ParallelTaskStatus<handle




    properties(SetAccess=private)
        IsSuccess logical=true;
        Warnings=[];
        Error=[];
        DidImport logical=false;
    end

    properties(Access=private)
        WarningsCollector;
    end

    methods(Access=public)
        function this=ParallelTaskStatus()
            this.WarningsCollector=parallel.internal.general.WarningsCollector();
        end

        function setImportState(this,didImport)
            this.DidImport=didImport;
            this.Warnings=this.WarningsCollector.Warnings;
        end

        function setError(this,exception)
            this.Error=exception;
            this.IsSuccess=false;
        end
    end

end
