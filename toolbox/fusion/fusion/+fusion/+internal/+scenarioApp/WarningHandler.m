classdef WarningHandler<handle
    properties
        Messages=message.empty
        MessageCatalog=''
    end


    methods
        function this=WarningHandler(subCatalog)
            this.MessageCatalog=subCatalog;
            clear(this);
        end

        function clear(this)
            this.Messages=message.empty;
        end

        function addMessage(this,msgid,varargin)
            if isempty(this.Messages)
                this.Messages=message([this.MessageCatalog,msgid],varargin{:});
            else
                this.Messages=vertcat(this.Messages,message([this.MessageCatalog,msgid],varargin{:}));
            end
        end

        function displayWarnings(this)

            backtraceState=warning('off','backtrace');
            [~,idx]=unique({this.Messages.Identifier},'stable');
            for i=1:numel(idx)
                warning(this.Messages(i));
                n=sum(strcmp(this.Messages(i).Identifier,{this.Messages.Identifier}));
                if n>1
                    warning(message([this.MessageCatalog,'PreviousWarningRepeated'],n-1));
                end
            end
            warning(backtraceState);
        end
    end
end