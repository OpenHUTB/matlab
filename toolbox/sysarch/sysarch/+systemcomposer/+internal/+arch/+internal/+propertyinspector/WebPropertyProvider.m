classdef WebPropertyProvider<handle





    properties
        app;
        isViews;
    end

    methods(Static)

        function props=getElementProperties(bdH,uuid,isViews)






            if(nargin<3)
                isViews=false;
            end

            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            if isempty(app)


                props={};
                return;
            end
            obj=systemcomposer.internal.arch.internal.propertyinspector.WebPropertyProvider(app,isViews);

            [semElem,synElem]=obj.findElementFromModel(uuid);

            if isempty(semElem)
                props={};
            else
                props=obj.getProps(semElem,synElem);
            end
        end
    end

    methods(Access=private)

        function this=WebPropertyProvider(app,isViews)
            this.app=app;
            this.isViews=isViews;
        end


        function syntax=getSyntax(this)
            if(this.isViews)
                syntax=this.app.getArchViewsAppMgr.getSyntax;
            else
                syntax=this.app.getSyntax;
            end
        end


        function props=getProps(this,elem,synElem)
            import systemcomposer.architecture.model.*;
            elemClass=elem.MetaClass;




            props={};

            if elemClass.isA(design.Architecture.StaticMetaClass)
                props=this.getArchitectureProps(elem,synElem);

            elseif elemClass.isA(design.Component.StaticMetaClass)
                props=this.getComponentProps(elem,synElem);

            elseif elemClass.isA(design.ArchitecturePort.StaticMetaClass)
                props=this.getArchitecturePortProps(elem,synElem);

            elseif elemClass.isA(design.ComponentPort.StaticMetaClass)
                props=this.getComponentPortProps(elem,synElem);

            elseif elemClass.isA(design.Connector.StaticMetaClass)
                props=this.getConnectorProps(elem,synElem);

            elseif elemClass.isA(views.ComponentOccurrence.StaticMetaClass)
                comp=elem.getComponent;
                props=this.getComponentProps(comp,synElem);

            elseif elemClass.isA(views.ViewArchitecture.StaticMetaClass)
                props=this.getViewArchitectureProps(elem,synElem);
            elseif elemClass.isA(views.LinkedViewComponent.StaticMetaClass)
                props=this.getLinkedViewCompProps(elem,synElem);
            elseif elemClass.isA(views.ViewComponent.StaticMetaClass)
                props=this.getViewCompProps(elem,synElem);


            elseif elemClass.isA(views.ViewComponentPort.StaticMetaClass)
                props=this.getViewCompPortProps(elem,synElem);
            elseif elemClass.isA(views.ViewArchitecturePort.StaticMetaClass)
                props=this.getViewArchPortProps(elem,synElem);
            elseif elemClass.isA(views.ComponentOccurPort.StaticMetaClass)
                compPort=elem.getDesignComponentPort;
                props=this.getComponentPortProps(compPort,synElem);

            elseif elemClass.isA(view.View.StaticMetaClass)
                props=this.getViewProps_old(elem,synElem);

            elseif elemClass.isA(view.ViewComponent.StaticMetaClass)
                props=this.getViewComponentProps_old(elem,synElem);

            elseif elemClass.isA(view.ComponentOccurrence.StaticMetaClass)
                props=this.getComponentOccurrenceProps_old(elem,synElem);

            elseif elemClass.isA(view.BaseViewPort.StaticMetaClass)
                props=this.getBaseViewPortProps_old(elem,synElem);

            elseif elemClass.isA(view.ViewConnector.StaticMetaClass)
                props=this.getViewConnectorProps_old(elem,synElem);

            elseif elemClass.isA(interface.CompositeDataInterface.StaticMetaClass)||...
                elemClass.isA(interface.CompositePhysicalInterface.StaticMetaClass)
                props=this.getPortInterfaceProps(elem);
            elseif elemClass.isA(interface.InterfaceElement.StaticMetaClass)
                props=this.getPortInterfaceElementProps(elem);
            end
        end


        function props=getArchitectureProps(this,elem,~)

            name=this.getName(elem);
            common=this.getCommonProperties(elem);
            custom=this.getCustomProperties(elem);

            props=[{name},common(:)',custom(:)'];
        end


        function props=getComponentProps(this,elem,synElem)

            name=this.getName(elem);
            common=this.getCommonProperties(elem);
            custom=this.getCustomProperties(elem);

            if(this.isViews)
                props=[{name},common(:)',custom(:)'];
            else

                req.id='requirementID';
                req.label=upper('Requirement ID');
                req.type='string';
                req.value=synElem.requirementID;
                props=[{name},common(:)',{req},custom(:)'];
            end
        end


        function props=getArchitecturePortProps(this,elem,~)

            name=this.getName(elem);
            common=this.getCommonProperties(elem);
            custom=this.getCustomProperties(elem);

            commonPort=this.getCommonPortProps(elem);

            props=[{name},common(:)',commonPort(:)',custom(:)'];
        end


        function props=getComponentPortProps(this,elem,~)

            name=this.getName(elem);


            archPort=elem.getArchitecturePort();
            common=this.getCommonProperties(archPort);
            custom=this.getCustomProperties(archPort);
            commonPort=this.getCommonPortProps(archPort);

            props=[{name},common(:)',commonPort(:)',custom(:)'];
        end


        function props=getConnectorProps(this,elem,~)

            name=this.getName(elem);
            common=this.getCommonProperties(elem);
            custom=this.getCustomProperties(elem);

            props=[{name},common(:)',custom(:)'];
        end


        function props=getViewArchitectureProps(this,elem,~)
            name=this.getName(elem);



            props=[{name}];
        end


        function props=getLinkedViewCompProps(this,elem,~)
            name=this.getName(elem);













            props=[{name}];
        end


        function props=getViewCompProps(this,elem,~)
            name=this.getName(elem);










            props=[{name}];
        end


        function props=getViewConnectorProps(~,~,~)

            props=[];
        end


        function props=getViewCompPortProps(this,elem,synElem)
            name=this.getName(elem);


            if(elem.getArchitecturePort().MetaClass.isA(...
                systemcomposer.architecture.model.views.ViewArchitecturePort.StaticMetaClass))

                commonPort=this.getCommonPortProps(elem);
                props=[{name},commonPort(:)'];
            else

                compPort=elem.getArchitecturePort().getDesignComponentPort;
                props=this.getComponentPortProps(compPort,synElem);
            end
        end


        function props=getViewArchPortProps(this,elem,~)
            name=this.getName(elem);
            commonPort=this.getCommonPortProps(archPort);

            props=[{name},commonPort(:)'];
        end


        function props=getViewProps_old(this,elem,~)

            name=this.getName(elem);
            common=this.getCommonViewProperties(elem);

            props=[{name},common(:)'];
        end


        function props=getViewComponentProps_old(this,elem,synElem)

            name=this.getName(elem);
            common=this.getCommonViewProperties(elem);


            if(synElem.MetaClass.isA(sysarch.syntax.architecture.Box.StaticMetaClass))
                req.id='requirementID';
                req.label=upper('Requirement ID');
                req.type='string';
                req.value=synElem.requirementID;
                props=[{name},common(:)',{req}];
            else
                props=[{name},common(:)'];
            end
        end


        function props=getComponentOccurrenceProps_old(this,elem,~)

            name=this.getName(elem);

            props=[{name}];
        end


        function props=getBaseViewPortProps_old(this,elem,~)

            name=this.getName(elem);

            commonPort=this.getCommonPortProps(elem);
            common=this.getCommonViewProperties(elem);

            props=[{name},common(:)',commonPort(:)'];
        end


        function props=getViewConnectorProps_old(this,elem,~)

            name=this.getName(elem);
            common=this.getCommonViewProperties(elem);

            props=[{name},common(:)'];
        end


        function props=getPortInterfaceProps(this,intf)

            elems=intf.getElements;
            props=cell(1,length(elems)+1);
            props{1}=this.getName(intf);
            for idx=2:numel(props)
                elem=elems(idx-1);
                prop.id=[intf.getName,'-',elem.getName];
                prop.label=elem.getName;
                prop.type='string';
                prop.value='';
                props{idx}=prop;
            end
        end


        function props=getPortInterfaceElementProps(this,intfElem)
            name=this.getName(intfElem);

            props={name};
        end


        function[semElem,synElem]=findElementFromModel(this,uuid)

            semElem=mf.zero.ModelElement.empty;


            synModel=this.getSyntax().getModel();
            synElem=synModel.findElement(uuid);



            if~isempty(synElem)
                semElem=this.findSemanticElement(synElem.semanticElement);

            else

                intfModel=this.app.getInterfaceEditorViewModel();
                viewElem=intfModel.findElement(uuid);

                if isempty(viewElem)
                    return;
                end

                semElem=this.findSemanticElement(viewElem.SemanticElementId);
            end
        end


        function semElem=findSemanticElement(this,uuid)

            if isempty(uuid)
                semElem=mf.zero.ModelElement.empty;
                return;
            end

            if(this.isViews)
                mdl=this.app.getArchViewsAppMgr.getModel;
                semElem=mdl.findElement(uuid);
            else


                cM=this.app.getCompositionArchitectureModel();
                semElem=cM.findElement(uuid);

                if isempty(semElem)

                    vM=this.app.getArchitectureViewsManager().getModel();
                    semElem=vM.findElement(uuid);
                end
            end
        end


        function name=getName(this,elem)
            name.id='Name';
            if(this.isViews)
                name.label='Name';
            else
                name.label=upper('Name');
            end
            name.type='string';
            name.value=elem.getName;
            name.readonly=this.isViews;
        end


        function props=getCommonPortProps(this,elem,~)


            if(elem.getPortAction==systemcomposer.internal.arch.PROVIDE||...
                elem.getPortAction==systemcomposer.architecture.model.core.PortAction.SERVER)
                dirVal='out';
            else
                dirVal='in';
            end
            dir.id='Direction';
            if(this.isViews)
                dir.label='Direction';
            else
                dir.label=upper('Direction');
            end
            dir.type='option';
            dir.options={'in','out'};
            dir.value=dirVal;
            dir.readonly=this.isViews;



            if isempty(elem.getPortInterface)
                intfVal='';
            else
                intfVal=elem.getPortInterface.getName;
            end

            opts=systemcomposer.internal.arch.getInterfaces(this.app);

            intf.id='Interface';
            if(this.isViews)
                intf.label='Interface';
            else
                intf.label=upper('Interface');
            end
            intf.type='option';
            intf.options=opts;
            intf.value=intfVal;
            intf.readonly=this.isViews;

            props=[{dir},{intf}];
        end


        function common=getCommonViewProperties(~,~)




            tagProp.id='defaultproperty-Common-Tag';
            tagProp.label='TAG';
            tagProp.type='string';
            tagProp.value='';
            common=[{tagProp}];
        end


        function common=getCommonProperties(this,elem)

            common={};
            psus=elem.PropertySets.toArray;
            for i=1:length(psus)
                psu=psus(i);
                if strcmp(psu.getName,'Common')
                    pus=psu.properties.toArray;
                    for k=1:length(pus)
                        pu=pus(k);
                        aProp.id=['defaultproperty-',psu.getName,'-',pu.getName];
                        aProp.label=upper(pu.getName);
                        if(this.isViews)
                            aProp.label=pu.getName;
                        else
                            aProp.label=upper(pu.getName);
                        end
                        aProp.type='string';

                        val=pu.derivedInitialValue.expression;
                        if isempty(val)
                            val='';
                        elseif iscell(val)
                            val=string(val);
                            val=strjoin(val,',');
                        elseif~ischar(val)
                            val=mat2str(val);
                        end
                        aProp.value=val;
                        aProp.readonly=this.isViews;
                        common=[common,{aProp}];%#ok<AGROW>
                    end
                end
            end
        end


        function props=getCustomProperties(this,elem)

            custom.id='CustomProperties';
            if(this.isViews)
                custom.label='Custom Properties';
            else
                custom.label=upper('Custom Properties');
            end
            custom.value='';

            props={custom};

            psus=elem.PropertySets.toArray;
            for i=1:length(psus)
                psu=psus(i);
                if~strcmp(psu.getName,'Common')
                    section.id=psu.getName;
                    section.label=psu.getName;
                    section.parent=custom.id;
                    section.value='';
                    props=[props,{section}];%#ok<AGROW>

                    pus=psu.properties.toArray;
                    for k=1:length(pus)
                        pu=pus(k);
                        aProp.id=['customproperty-',section.id,'-',pu.getName];
                        aProp.label=pu.getName;
                        aProp.parent=section.id;
                        aProp.type='string';
                        aProp.value=mat2str(pu.derivedInitialValue.expression);
                        aProp.readonly=this.isViews;
                        props=[props,{aProp}];%#ok<AGROW>
                    end
                end
            end
        end
    end
end


