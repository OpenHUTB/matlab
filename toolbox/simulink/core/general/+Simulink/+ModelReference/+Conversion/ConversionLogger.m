




classdef ConversionLogger<handle
    properties(SetAccess=private,GetAccess=private)
        Warnings={}
        Info={}
        FixResults={};
    end


    methods(Access=public)
        function delete(this)
            cellfun(@(msg)warning(msg),this.Warnings);
        end
    end



    methods(Hidden,Access=public)
        function addWarning(this,message)
            this.Warnings{end+1}=message;
        end


        function list=getWarning(this)
            list=this.Warnings;
        end


        function status=hasWarning(this)
            status=~isempty(this.Warnings);
        end


        function clearWarning(this)
            this.Warnings={};
        end


        function addInfo(this,message)
            this.Info{end+1}=message;
        end


        function list=getInfo(this)
            list=this.Info;
        end


        function status=hasInfo(this)
            status=~isempty(this.Info);
        end


        function clearInfo(this)
            this.Info={};
        end

        function addFixResults(this,results)
            if iscell(results)
                if isempty(this.FixResults)
                    this.FixResults=results;
                else
                    this.FixResults=horzcat(this.FixResults,results);
                end
            else
                this.FixResults{end+1}=results;
            end
        end

        function results=getFixResults(this)
            results=this.FixResults;
            this.FixResults={};
        end
    end

    methods(Static,Access=public)
        function msgs=createMessageFromException(me)
            msgs={};
            msgs{end+1}=message(me.identifier,me.arguments{:});
            causes=me.cause;
            if~isempty(causes)
                N=numel(causes);
                for idx=1:N
                    msgs=horzcat(msgs,Simulink.ModelReference.Conversion.ConversionLogger.createMessageFromException(causes{idx}));%#ok
                end
            end
        end
    end
end
