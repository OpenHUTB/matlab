function props=getElementProperties(appname,uuid,options)







    bdH=get_param(appname,'Handle');
    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);

    if isempty(app)||isempty(uuid)


        props='';
        return;
    end

    mdl=app.getArchViewsAppMgr.getModel();
    occurrenceElem=mdl.findElement(uuid);
    selection={};

    switch class(occurrenceElem)
    case 'systemcomposer.architecture.model.views.ComponentOccurrence'
        semElem=occurrenceElem.getComponent;
    case 'systemcomposer.architecture.model.views.FlatCompOccurrence'
        semElem=occurrenceElem.getComponent;
    case 'systemcomposer.architecture.model.views.ViewComponentPort'
        if isa(occurrenceElem.getArchitecturePort,'systemcomposer.architecture.model.views.ComponentOccurPort')||...
            isa(occurrenceElem.getArchitecturePort,'systemcomposer.architecture.model.views.FlatCompOccurPort')
            semElem=occurrenceElem.getArchitecturePort.getDesignComponentPort;
        else
            assert(isa(occurrenceElem.getArchitecturePort,'systemcomposer.architecture.model.views.ViewArchitecturePort'));
            semElem=occurrenceElem.getArchitecturePort;
        end
    case{'systemcomposer.architecture.model.views.ViewArchitecture',...
        'systemcomposer.architecture.model.views.ViewComponent',...
        'systemcomposer.architecture.model.views.LinkedViewComponent'}
        semElem=occurrenceElem;
    case 'systemcomposer.architecture.model.views.ViewConnector'
        semElem=occurrenceElem.getConnectors;
        if~isempty(options)
            selection=options.dstPort;
        end

    otherwise
        props='';
        return
    end


    props=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider(semElem,bdH,selection,false);




end

