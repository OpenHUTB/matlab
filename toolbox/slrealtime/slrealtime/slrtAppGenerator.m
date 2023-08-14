function obj=slrtAppGenerator(varargin)






    obj=getInstance(varargin{:});
    if nargout==0
        clear obj;
    end
end




function obj=getInstance(varargin)
    obj=manageInstance('get');
    if isempty(obj)
        obj=slrealtime.internal.guis.AppGenerator;
        addlistener(obj,'Closing',@(o,e)setInstance([]));
        setInstance(obj);
    end
    obj.bringToFront();

    if nargin>0
        cancelled=obj.askToSaveSession();
        if cancelled,return;end
        obj.newSession(varargin{1});
    end
end

function setInstance(obj)
    manageInstance('set',obj);
end

function varargout=manageInstance(command,varargin)
    mlock;
    persistent theInstance;
    switch(command)
    case 'get'
        varargout{1}=theInstance;
    case 'set'
        theInstance=varargin{1};
    otherwise
        assert(false);
    end
end
