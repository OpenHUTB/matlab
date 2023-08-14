



classdef MessageHandler<handle

    methods(Static=true,Access='protected')

        function generateError(fullId,varargin)

            [msg,id]=DAStudio.message(fullId,varargin{:});

            exception=MException(id,msg);
            exception.throwAsCaller();
        end

        function generateWarning(fullId,varargin)

            MSLDiagnostic(fullId,varargin{:}).reportAsWarning;
        end

        function ME=generateException(fullId,varargin)

            [msg,id]=DAStudio.message(fullId,varargin{:});

            msg=strrep(msg,'%','%%');
            ME=MException(id,msg);
        end

        function msg=generateMessage(fullId,varargin)

            msg=DAStudio.message(fullId,varargin{:});
        end

    end

    methods(Static=true)

        function throwError(messageID,varargin)
            fullID=[errorhandler.Utilities.getProductID,':',messageID];
            errorhandler.MessageHandler.generateError(fullID,varargin{:});
        end

        function throwWarning(messageID,varargin)
            fullID=[errorhandler.Utilities.getProductID,':',messageID];
            errorhandler.MessageHandler.generateWarning(fullID,varargin{:});
        end

        function ME=getException(messageID,varargin)
            fullID=[errorhandler.Utilities.getProductID,':',messageID];
            ME=errorhandler.MessageHandler.generateException(fullID,varargin{:});
        end

        function msg=getMessage(messageID,varargin)
            fullID=[errorhandler.Utilities.getProductID,':',messageID];
            msg=errorhandler.MessageHandler.generateMessage(fullID,varargin{:});
        end

    end

end
