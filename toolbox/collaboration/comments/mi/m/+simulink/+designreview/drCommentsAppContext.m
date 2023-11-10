classdef drCommentsAppContext<dig.CustomContext

    properties(GetAccess=public,SetAccess=public,SetObservable=true)
        isNavigationEnabled=false;
    end

    methods(Access=public)
        function this=drCommentsAppContext()
            app=dig.Configuration.get().getApp('drCommentsApp');
            this@dig.CustomContext(app);
            this.isNavigationEnabled=false;
        end
    end

end