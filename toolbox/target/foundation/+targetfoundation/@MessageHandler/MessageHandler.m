



classdef MessageHandler<errorhandler.MessageHandler

    properties(Constant=true)
    end

    methods(Static=true)

        function throwError(messageID,varargin)
            fullID=[targetfoundation.Utilities.getProductID,':',messageID];
            errorhandler.MessageHandler.generateError(fullID,varargin{:});
        end

        function throwWarning(messageID,varargin)
            fullID=[targetfoundation.Utilities.getProductID,':',messageID];
            errorhandler.MessageHandler.generateWarning(fullID,varargin{:});
        end

        function ME=getException(messageID,varargin)
            fullID=[targetfoundation.Utilities.getProductID,':',messageID];
            ME=errorhandler.MessageHandler.generateException(fullID,varargin{:});
        end

        function msg=getMessage(messageID,varargin)
            fullID=[targetfoundation.Utilities.getProductID,':',messageID];
            msg=errorhandler.MessageHandler.generateMessage(fullID,varargin{:});
        end

    end

end
