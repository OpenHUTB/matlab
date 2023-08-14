function setInterfaceToSelectedPorts(this,interfaceUUID)




    intrf=this.piCatalog.getPortInterfaceInClosureByUUID('',interfaceUUID);

    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    assert(numel(allStudios)>0);
    st=allStudios(1);

    editor=st.App.getActiveEditor();


    elements=editor.getSelection;
    doRefresh=false;
    lastElem=[];
    for i=1:elements.size
        element=elements.at(i);
        archElem=systemcomposer.utils.getArchitecturePeer(element.handle);
        if isa(archElem,'systemcomposer.architecture.model.design.Port')



            if(archElem.isComponentPort)
                comp=archElem.getComponent;
                if comp.hasReferencedArchitecture


                    continue;
                end
                archElem=archElem.getArchitecturePort;
            end


            doRefresh=true;
            lastElem=archElem;


            systemcomposer.architecture.model.design.ArchitecturePort.validateInterfaceCompatibility(archElem,intrf);
            intrfWrapper=systemcomposer.internal.getWrapperForImpl(intrf);
            systemcomposer.BusObjectManager.SetPortInterface(archElem,intrf.getName,class(intrfWrapper));
        end
    end


    pi=st.getComponent('GLUE2:PropertyInspector','Property Inspector');
    if(pi.isVisible&&doRefresh)
        simPort=systemcomposer.utils.getSimulinkPeer(lastElem);
        systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(simPort(1));
    end

end


