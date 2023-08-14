function varargout=registerCallbacks(this,type,varargin)








    persistent callbacks
    if isempty(callbacks)
        callbacks={};
    end

    switch type
    case 'add'
        callbacks{end+1,1}=varargin;

    case 'clear'
        for i=1:length(callbacks)
            if isequal(callbacks{i},varargin)
                callbacks(i)=[];
                break;
            end
        end

    case 'clear all'
        callbacks(:)=[];

    case 'get'


    otherwise
        warning('Incorrect type of action specified');
    end

    varargout{1}=callbacks;
end