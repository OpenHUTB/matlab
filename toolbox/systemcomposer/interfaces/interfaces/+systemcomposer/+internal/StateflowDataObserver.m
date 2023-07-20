classdef StateflowDataObserver<handle






    properties(Access=private)
PropertyChangedListener
    end

    methods(Static)
        function obj=instance()
mlock
            persistent uniqueSFDataInstance
            if isempty(uniqueSFDataInstance)
                uniqueSFDataInstance=systemcomposer.internal.StateflowDataObserver();
            end
            obj=uniqueSFDataInstance;
        end

        function initialize(bdHandle)
            obj=systemcomposer.internal.StateflowDataObserver.instance;

            bdObj=get_param(bdHandle,'Object');
            dataObjs=bdObj.find('-isa','Stateflow.Data','-or','-isa','Stateflow.Message');
            for i=1:length(dataObjs)
                systemcomposer.internal.StateflowDataObserver.registerPropChangeListener(dataObjs(i));
            end
        end

        function registerPropChangeListener(dataObj)


            obj=systemcomposer.internal.StateflowDataObserver.instance;



            obj.PropertyChangedListener=[obj.PropertyChangedListener...
            ,addlistener(dataObj,'PropertyChangedEvent',@systemcomposer.internal.StateflowDataObserver.PropertyChangedEventCallback)];
        end

        function PropertyChangedEventCallback(~,e)
            if isa(e.Source,'Stateflow.Data')||isa(e.Source,'Stateflow.Message')
                dataObj=e.Source;
                if strcmpi(dataObj.Scope,'Input')||strcmpi(dataObj.Scope,'Output')
                    if isa(dataObj.up,'Stateflow.Chart')&&isa(dataObj.up.up,'Simulink.SubSystem')
                        subsystemHandle=get_param(dataObj.up.Path,'handle');
                        rootHdl=bdroot(subsystemHandle);
                        parentSubDomain=get_param(get_param(subsystemHandle,'Parent'),'SimulinkSubDomain');
                        allowedSubDomains={'Architecture','SoftwareArchitecture'};
                        if ismember(parentSubDomain,allowedSubDomains)



                            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(rootHdl);
                            comp=systemcomposer.utils.getArchitecturePeer(get_param(dataObj.Path,'Handle'));
                            compPort=comp.getPort(dataObj.Name);
                            if~isempty(app)&&~isempty(compPort)
                                if((compPort.getPortAction==systemcomposer.architecture.model.core.PortAction.REQUEST&&strcmp(dataObj.Scope,'Input'))||...
                                    (compPort.getPortAction==systemcomposer.architecture.model.core.PortAction.PROVIDE&&strcmp(dataObj.Scope,'Output')))
                                    archPort=compPort.getArchitecturePort;



                                    app.propertyChangedForStateflowData(archPort,dataObj);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

