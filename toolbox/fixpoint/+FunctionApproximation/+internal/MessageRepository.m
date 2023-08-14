classdef(Sealed)MessageRepository<handle






    properties(SetAccess=private)
        Catalog(:,1)string
        Options FunctionApproximation.Options
    end

    methods
        function this=MessageRepository(options)
            this.Options=options;
        end

        function addMessage(this,msg)
            this.Catalog=[this.Catalog;string(msg)];
        end

        function displayMessages(this)
            if this.Options.Display
                for iMsg=1:size(this.Catalog,1)
                    fprintf('%s\n\n',this.Catalog(iMsg,1));
                end
                this.Catalog=string.empty;
            end
        end
    end
end