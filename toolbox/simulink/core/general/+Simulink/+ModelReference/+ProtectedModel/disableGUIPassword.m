function varargout=disableGUIPassword(val)






    persistent flag;

    switch val
    case 'set'
        flag=true;
    case 'reset'
        flag=false;
    case 'get'
        if isempty(flag)
            flag=false;
        end
        varargout={flag};
    otherwise
        assert(false,'Unexpected branch of codegen build');
    end
end
