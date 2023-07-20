classdef(Sealed)SessionManager<handle





    methods(Access=private)
        function obj=SessionManager
            import evolutions.internal.session.*
            obj.EventHandler=EventHandler;
            obj.ErrorHandler=ErrorHandler;
            obj.VisitorFactory=VisitorFactory;
            obj.Mf0Data=Mf0Data;
            obj.Servers=Servers;
            obj.FeatureStates=FeatureStates;
            mlock;
        end

        function setup(obj)
            setup(obj.ErrorHandler);
        end
    end

    properties(GetAccess=private,SetAccess=?matlab.mock.TestCase)
        EventHandler evolutions.internal.session.EventHandler
        ErrorHandler evolutions.internal.session.ErrorHandler
        VisitorFactory evolutions.internal.session.VisitorFactory
        Mf0Data evolutions.internal.session.Mf0Data
        FeatureStates evolutions.internal.session.FeatureStates
        Servers evolutions.internal.session.Servers
    end

    methods(Static)
        function sessionManager=getSessionManager
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=evolutions.internal.session.SessionManager;
                localObj.setup;
            end
            sessionManager=localObj;
        end

        function clearSessionManager
            import evolutions.internal.session.*

            SessionManager.safeDelete(SessionManager.getEventHandler);


            SessionManager.safeDelete(SessionManager.getErrorHandler);


            SessionManager.safeDelete(SessionManager.getVisitorFactory);


            SessionManager.safeDelete(SessionManager.getMf0Data);


            SessionManager.safeDelete(SessionManager.getServers);


            SessionManager.safeDelete(SessionManager.getFeatureStates);


            munlock('SessionManager');
            SessionManager.safeDelete(SessionManager.getSessionManager);
        end

        function eventHandler=getEventHandler
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            eventHandler=sessionManager.EventHandler;
        end

        function errorHandler=getErrorHandler
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            errorHandler=sessionManager.ErrorHandler;
        end

        function visitorFactory=getVisitorFactory
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            visitorFactory=sessionManager.VisitorFactory;
        end

        function mf0Data=getMf0Data
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            mf0Data=sessionManager.Mf0Data;
        end

        function servers=getServers
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            servers=sessionManager.Servers;
        end

        function featureStates=getFeatureStates
            sessionManager=evolutions.internal.session.SessionManager.getSessionManager;
            featureStates=sessionManager.FeatureStates;
        end
    end

    methods(Static,Access=private)
        function safeDelete(handleObject)
            if~isempty(handleObject)&&isvalid(handleObject)
                delete(handleObject);
            end
        end
    end

end


