function varargout=registerPreDBCallbacks(this,type,varargin)








    persistent callbacks_predb
    if isempty(callbacks_predb)
        callbacks_predb={};
    end

    switch type
    case 'add'
        callbacks_predb{end+1,1}=varargin;

    case 'clear'
        for i=1:length(callbacks_predb)
            if isequal(callbacks_predb{i},varargin)
                callbacks_predb(i)=[];
                break;
            end
        end

    case 'clear all'
        callbacks_predb(:)=[];

    case 'get'


    otherwise
        warning('Incorrect type of action specified');
    end

    varargout{1}=callbacks_predb;
end