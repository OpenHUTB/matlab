classdef InterfaceWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper




    properties
    end

    methods
        function obj=InterfaceWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            obj.element=obj.app.getTopLevelCompositionArchitecture;
        end
    end
end

