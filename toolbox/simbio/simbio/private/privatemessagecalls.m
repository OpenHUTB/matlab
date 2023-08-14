function varargout=privatemessagecalls(call,inputargs)










    messageManager=SimBiology.internal.Utils.StackedMessageManager.getInstance();

    switch call
    case 'adderror'
        messageManager.addError(inputargs{:});
    case 'addwarning'


        messageManager.addWarning(inputargs{:});
    case 'setcontextstatus'
        messageManager.MessageContextStatus=inputargs{:};
    case 'getcontextstatus'
        varargout{1}=messageManager.MessageContextStatus;
    case 'numerrors'
        varargout{1}=messageManager.getNumErrors();
    case 'flush'
        messageManager.flush;
    case 'sbiolasterror'
        if(isequal(length(inputargs),0))
            varargout{1}=messageManager.sblasterror;
        elseif(isequal(length(inputargs),1))
            varargout{1}=[];
            if isempty(inputargs{1})
                messageManager.resetlasterror;
            else
                errForBadStruct(inputargs{1},'Error');
                messageManager.setlasterror(inputargs{1});
                varargout{1}=inputargs{1};
            end
        end
    case 'sbiolastwarning'
        if(isequal(length(inputargs),0))
            varargout{1}=messageManager.sblastwarning;
        elseif(isequal(length(inputargs),1))
            varargout{1}=[];
            if isempty(inputargs{1})
                messageManager.resetlastwarning;
            else
                errForBadStruct(inputargs{1},'Warning');
                messageManager.setlastwarning(inputargs{1});
                varargout{1}=inputargs{1};
            end
        end
    case 'sbiofatalerror'
        messageManager.addError(inputargs{:});
        messageManager.flush;
    otherwise
        error(message('SimBiology:Internal:BadPrivateCall',call));
    end

    function errForBadStruct(args,type)
        issetproperly=false;
        if(isstruct(args))
            if isequal(sort(fieldnames(args)),{'Message';'MessageID';'Type'})
                if all(strcmp({args(:).Type},type))
                    issetproperly=true;
                end
            end
        end

        if~issetproperly
            error(message('SimBiology:sbiolasterror:InvalidMessageType'));
        end
