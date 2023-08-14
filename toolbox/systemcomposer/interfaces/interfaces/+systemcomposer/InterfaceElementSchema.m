classdef InterfaceElementSchema<handle




    properties(SetAccess=protected)
pie
pi
piC
mf0Model
    end

    properties(Constant,Access=private)
        Separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');
    end

    methods
        function this=InterfaceElementSchema(pie,pi,mf0Model)
            this.pie=pie;
            this.pi=pi;
            this.mf0Model=mf0Model;
            this.piC=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
        end

        function schema=getPropertySchema(this)
            schema=this;
        end

        function name=getObjectType(this)
            if(this.pi.isAnonymous)
                name=['Port : ',this.pi.p_AnonymousUsage.p_Port.getName(),' | Element : ',this.pie.getName()];
            else
                name=['Interface : ',this.pi.getName(),' | Element : ',this.pie.getName()];
            end
        end

        function hasSub=hasSubProperties(~,prop)
            hasSub=false;
            if(strcmp(prop,'Sysarch:Port:Interface:Element'))
                hasSub=true;
            end
        end

        function subprops=subProperties(this,prop)
            subprops={};
            if isempty(prop)
                subprops{end+1}='Sysarch:Port:Interface:Element';
            end
            if(strcmp(prop,'Sysarch:Port:Interface:Element'))
                if isa(this.pie,'systemcomposer.architecture.model.interface.PhysicalElement')
                    subprops{end+1}='Sysarch:Port:Interface:Type';
                else
                    assert(isa(this.pie,'systemcomposer.architecture.model.interface.DataElement'));
                    subprops{end+1}='Sysarch:Port:Interface:Type';
                    subprops{end+1}='Sysarch:Port:Interface:Dimensions';
                    subprops{end+1}='Sysarch:Port:Interface:Units';
                    subprops{end+1}='Sysarch:Port:Interface:Complex';
                    subprops{end+1}='Sysarch:Port:Interface:Minimum';
                    subprops{end+1}='Sysarch:Port:Interface:Maximum';
                    subprops{end+1}='Sysarch:Port:Interface:Description';
                end
            end
        end

        function propval=propertyValue(this,prop)
            switch(prop)
            case 'Sysarch:Port:Interface:Element'
                propval='';
            case 'Sysarch:Port:Interface:Type'
                propval=this.pie.getType();
            case 'Sysarch:Port:Interface:Dimensions'
                propval=this.pie.getDimensions();
            case 'Sysarch:Port:Interface:Units'
                propval=this.pie.getUnits();
            case 'Sysarch:Port:Interface:Complex'
                propval=this.pie.getComplexity();
            case 'Sysarch:Port:Interface:Minimum'
                propval=this.pie.getMinimum();
            case 'Sysarch:Port:Interface:Maximum'
                propval=this.pie.getMaximum();
            case 'Sysarch:Port:Interface:Description'
                propval=this.pie.getDescription();
            end
        end

        function errors=setPropertyValues(this,propValuePairs,~)
            errors={};
            for i=1:2:numel(propValuePairs)
                prop=propValuePairs{i};
                propval=propValuePairs{i+1};
                this.setPropertyValueHelper(prop,propval);
            end
            this.firePropertyChangeEvent();
        end

        function enabled=isPropertyEnabled(this,prop)
            if this.isIEOwnedByAdapterPort()

                enabled=false;
            elseif(any(strcmp(prop,{'Sysarch:Port:Interface:Type','Sysarch:Port:Interface:Dimensions','Sysarch:Port:Interface:Description'})))
                enabled=true;
            else
                pieType=this.pie.getType();
                pieType=pieType(~isspace(pieType));
                if(startsWith(pieType,'Bus:'))
                    enabled=false;
                else
                    enabled=true;
                end
            end
        end

        function editable=isPropertyEditable(~,prop)
            if(isempty(prop))

                editable=false;
            else
                editable=true;
            end
        end

        function setPropertyValueHelper(this,prop,propval)
            txn=this.mf0Model.beginTransaction();
            elem=systemcomposer.internal.getWrapperForImpl(this.pie);
            switch(prop)
            case 'Sysarch:Port:Interface:Type'
                if(~strcmp(propval,this.Separator))
                    elem.setTypeFromString(propval);
                end
            case 'Sysarch:Port:Interface:Dimensions'
                elem.setDimensions(propval);
            case 'Sysarch:Port:Interface:Units'
                elem.setUnits(propval);
            case 'Sysarch:Port:Interface:Complex'
                elem.setComplexity(propval);
            case 'Sysarch:Port:Interface:Minimum'
                elem.setMinimum(propval);
            case 'Sysarch:Port:Interface:Maximum'
                elem.setMaximum(propval);
            case 'Sysarch:Port:Interface:Description'
                elem.setDescription(propval);
            end
            txn.commit();
        end

        function result=propertyDisplayLabel(~,prop)
            switch(prop)
            case 'Sysarch:Port:Interface:Element'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Properties');
            case 'Sysarch:Port:Interface:Type'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
            case 'Sysarch:Port:Interface:Dimensions'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
            case 'Sysarch:Port:Interface:Units'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
            case 'Sysarch:Port:Interface:Complex'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
            case 'Sysarch:Port:Interface:Minimum'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
            case 'Sysarch:Port:Interface:Maximum'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
            case 'Sysarch:Port:Interface:Description'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Description');
            end
        end

        function editor=propertyEditor(this,prop)
            switch(prop)
            case 'Sysarch:Port:Interface:Type'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Editable=true;
                [editor.CurrentText,editor.Entries]=systemcomposer.internal.getTypeAndAvailableTypes(this.pie);
            case 'Sysarch:Port:Interface:Complex'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=this.pie.getComplexity();
                editor.Entries={'real','complex'};
            otherwise
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=this.propertyValue(prop);
            end
        end

        function mode=propertyRenderMode(~,~)
            mode='RenderAsText';
        end

        function result=supportTabView(~)
            result=true;
        end

        function result=rootNodeViewMode(~,~)
            result='TreeView';
        end

        function firePropertyChangeEvent(this)




            ueEditors=GLUE2.Util.findAllEditors(gcs);
            for i=1:length(ueEditors)
                ueStudio=ueEditors(i).getStudio;
                propInspector=ueStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');
                if propInspector.isVisible()
                    propInspector.updateSource(this.pie.getName(),this);
                end
            end








        end

        function tf=isIEOwnedByAdapterPort(this)



            tf=false;
            if(this.pi.isAnonymous)
                archPort=this.pi.p_AnonymousUsage.p_Port;
                compPort=archPort.getParentComponentPort();
                if~isempty(compPort)
                    comp=compPort.getComponent();
                    if~isempty(comp)
                        tf=comp.isAdapterComponent();
                    end
                end
            end
        end

    end
end
