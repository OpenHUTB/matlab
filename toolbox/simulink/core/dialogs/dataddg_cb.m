function[varargout]=dataddg_cb(dlgH,action,varargin)










    switch action
    case 'preapply_cb'
        dlgH.refresh;
        varargout={true,''};

    case 'refresh_me_cb'
        dispatcher=DAStudio.EventDispatcher;
        obj=varargin{1};
        if~isobject(obj)
            dispatcher.broadcastEvent('PropertyChangedEvent',obj);
        end
    case 'datatype_callback'

        tag=varargin{1};
        event=varargin{2};
        oCallback=varargin{3};
        feval(oCallback,event,dlgH,tag);
        dlgH.refresh;
    otherwise
        assert(false,'Unexpected action');
    end




