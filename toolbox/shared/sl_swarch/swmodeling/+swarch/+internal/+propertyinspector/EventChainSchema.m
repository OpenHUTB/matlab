classdef EventChainSchema<swarch.internal.propertyinspector.SoftwareElementPropertySchema

    properties(Constant)
        StimulusPortTitleId='Swarch:StimulusPortTitle';
        ResponsePortTitleId='Swarch:ResponsePortTitle';
        StimulusPortId='Swarch:StimulusPort';
        ResponsePortId='Swarch:ResponsePort';
        StimulusPortElementId='Swarch:StimulusPortElementId';
        ResponsePortElementId='Swarch:ResponsePortElementId';
        TimingConstraintsTitleId='Swarch:TimingConstraints';
        DurationId='Swarch:DurationId';
    end


    properties
pBDHandle
pEventChain
    end


    methods
        function this=EventChainSchema(studio,trObj)
            this=this@swarch.internal.propertyinspector.SoftwareElementPropertySchema(studio,trObj);
            this.pBDHandle=studio.App.blockDiagramHandle;
            this.pEventChain=trObj;
        end


        function typeStr=getObjectType(~)
            typeStr='EventChain';
        end


        function setPrototypableName(this,value)
            this.getPrototypable().setName(value);
        end


        function name=getPrototypableName(this)
            name=this.getPrototypable().getName();
        end


        function subProps=subProperties(this,prop)
            subProps=...
            subProperties@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
            if isempty(prop)
                subProps=[subProps,this.StimulusPortTitleId,this.ResponsePortTitleId];
                if slfeature('ZCEventChainAdvanced')>0

                    subProps=[subProps,this.TimingConstraintsTitleId];
                end
            elseif strcmp(prop,this.StimulusPortTitleId)
                subProps=[subProps,this.StimulusPortId,this.StimulusPortElementId];
            elseif strcmp(prop,this.ResponsePortTitleId)
                subProps=[subProps,this.ResponsePortId,this.ResponsePortElementId];
            elseif strcmp(prop,this.TimingConstraintsTitleId)
                subProps=[subProps,this.DurationId];
            end
        end


        function tf=hasSubProperties(this,prop)
            tf=...
            hasSubProperties@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop)||...
            strcmp(prop,this.StimulusPortTitleId)||...
            strcmp(prop,this.ResponsePortTitleId)||...
            strcmp(prop,this.TimingConstraintsTitleId);
        end


        function setPropertyValue(this,prop,value)
            if strcmp(prop,this.StimulusPortId)
                setPortEvent(this,'stimulus',value);
            elseif strcmp(prop,this.ResponsePortId)
                setPortEvent(this,'response',value);
            elseif strcmp(prop,this.DurationId)
                ownerArch=this.pEventChain.parent.p_Architecture;
                mdl=mf.zero.getModel(ownerArch);
                t=str2double(value);
                timeNanoSec=t*1e9;
                unit=systemcomposer.architecture.model.traits.TimingConstraintUnit.UNIT_1NS;
                this.pEventChain.duration=systemcomposer.architecture.model.traits.TimingConstraint.createTimingConstraint(mdl,timeNanoSec,unit);
            else
                setPropertyValue@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop,value);
            end
        end


        function editor=propertyEditor(this,prop)
            if strcmp(prop,this.StimulusPortId)||strcmp(prop,this.ResponsePortId)
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=DAStudio.message('SoftwareArchitecture:PortRelationship:SelectPortStr');
                editor.Editable=true;
                portEntries={};
                arch=this.pEventChain.parent.p_Architecture;
                ports=getPorts(arch);
                for p=ports
                    if p.getPortAction==systemcomposer.architecture.model.core.PortAction.REQUEST||...
                        p.getPortAction==systemcomposer.architecture.model.core.PortAction.PROVIDE
                        portEntries=[portEntries,{getFullPortName(this,p)}];%#ok
                    end
                end

                if~arch.hasParentComponent()
                    swComponents=swarch.utils.getAllSoftwareComponents(arch);
                    for swComp=swComponents
                        ports=swComp.getPorts();
                        for p=ports
                            if p.getPortAction==systemcomposer.architecture.model.core.PortAction.REQUEST||...
                                p.getPortAction==systemcomposer.architecture.model.core.PortAction.PROVIDE
                                portEntries=[portEntries,{getFullPortName(this,p)}];%#ok
                            end
                        end
                    end
                end
                editor.Entries=portEntries;
            else
                editor=...
                propertyEditor@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
            end
        end


        function value=propertyValue(this,prop)

            if strcmp(prop,this.StimulusPortTitleId)||...
                strcmp(prop,this.ResponsePortTitleId)||...
                strcmp(prop,this.TimingConstraintsTitleId)
                value='';
            elseif strcmp(prop,this.StimulusPortId)
                value=DAStudio.message('SoftwareArchitecture:PortRelationship:SelectPortStr');
                event=this.pEventChain.stimulus;
                if~isempty(event)&&isPortEvent(this,event)
                    p=event.port;
                    value=getFullPortName(this,p);
                end
            elseif strcmp(prop,this.ResponsePortId)
                value=DAStudio.message('SoftwareArchitecture:PortRelationship:SelectPortStr');
                event=this.pEventChain.response;
                if~isempty(event)&&isPortEvent(this,event)
                    p=event.port;
                    value=getFullPortName(this,p);
                end
            elseif strcmp(prop,this.StimulusPortElementId)||strcmp(prop,this.ResponsePortElementId)
                value=DAStudio.message('SoftwareArchitecture:PortRelationship:EditPortMapping');
            elseif strcmp(prop,this.DurationId)
                t=this.pEventChain.duration.timeValue;
                t=t*power(10,-double(this.pEventChain.duration.unit));
                value=num2str(t);
            else
                value=...
                propertyValue@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
            end
        end


        function label=propertyDisplayLabel(this,prop)
            if strcmp(prop,this.StimulusPortTitleId)
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:StimulusPortTitle');
            elseif strcmp(prop,this.ResponsePortTitleId)
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:ResponsePortTitle');
            elseif strcmp(prop,this.StimulusPortId)||strcmp(prop,this.ResponsePortId)
                rootArch=get_param(this.pBDHandle,...
                'SystemComposerModel').Architecture.getImpl();
                arch=this.pEventChain.parent.p_Architecture;
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:PortLabel');
                if arch~=rootArch
                    label=[label,' (',arch.getName(),')'];
                end
            elseif strcmp(prop,this.StimulusPortElementId)||strcmp(prop,this.ResponsePortElementId)
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:InterfaceElementsLabel');
            elseif strcmp(prop,this.TimingConstraintsTitleId)
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:TimingConstraintsTitle');
            elseif strcmp(prop,this.DurationId)
                label=DAStudio.message('SoftwareArchitecture:PortRelationship:DurationLabel');
            else
                label=...
                propertyDisplayLabel@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
            end
        end


        function tooltip=propertyTooltip(this,prop)
            tooltip=...
            propertyTooltip@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
        end


        function mode=propertyRenderMode(this,prop)
            if strcmp(prop,this.StimulusPortId)||strcmp(prop,this.ResponsePortId)
                mode='RenderAsComboBox';
            elseif strcmp(prop,this.StimulusPortElementId)
                event=this.pEventChain.stimulus;
                pi=[];
                if~isempty(event)&&isPortEvent(this,event)
                    first=event;
                    pi=first.port.getPortInterface();
                end
                if~isempty(pi)
                    mode='RenderAsHyperlink';
                else
                    mode='RenderAsText';
                end
            elseif strcmp(prop,this.ResponsePortElementId)
                event=this.pEventChain.response;
                pi=[];
                if~isempty(event)&&isPortEvent(this,event)
                    first=event;
                    pi=first.port.getPortInterface();
                end
                if~isempty(pi)
                    mode='RenderAsHyperlink';
                else
                    mode='RenderAsText';
                end
            else
                mode=...
                propertyRenderMode@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop);
            end
        end


        function tf=isPropertyEditable(this,prop)
            tf=...
            isPropertyEditable@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop)||...
            strcmp(prop,this.StimulusPortId)||...
            strcmp(prop,this.ResponsePortId)||...
            strcmp(prop,this.StimulusPortElementId)||...
            strcmp(prop,this.ResponsePortElementId)||...
            strcmp(prop,this.DurationId);
        end


        function tf=isPropertyEnabled(this,prop)

            if strcmp(prop,this.StimulusPortElementId)
                event=this.pEventChain.stimulus;
                pi=[];
                if~isempty(event)&&isPortEvent(this,event)
                    first=event;
                    pi=first.port.getPortInterface();
                end
                tf=~isempty(pi);
            elseif strcmp(prop,this.ResponsePortElementId)
                event=this.pEventChain.response;
                pi=[];
                if~isempty(event)&&isPortEvent(this,event)
                    first=event;
                    pi=first.port.getPortInterface();
                end
                tf=~isempty(pi);
            else
                tf=...
                isPropertyEnabled@swarch.internal.propertyinspector.SoftwareElementPropertySchema(this,prop)||...
                strcmp(prop,this.StimulusPortTitleId)||...
                strcmp(prop,this.ResponsePortTitleId)||...
                strcmp(prop,this.StimulusPortId)||...
                strcmp(prop,this.ResponsePortId)||...
                strcmp(prop,this.TimingConstraintsTitleId)||...
                strcmp(prop,this.DurationId);
            end
        end


        function name=getFullPortName(~,port)

            prefix='';
            if port.isArchitecturePort
                if port.getArchitecture.hasParentComponent
                    comp=port.getArchitecture.getParentComponent;
                    prefix=[comp.getName(),':'];
                else
                    prefix='';
                end
            elseif port.isComponentPort
                comp=port.getComponent;
                prefix=[comp.getName(),':'];
            end
            name=[prefix,port.getName()];
        end


        function performPropertyAction(this,prop,~)
            if strcmp(prop,this.StimulusPortElementId)||strcmp(prop,this.ResponsePortElementId)
                dlg=swarch.internal.portrelationship.Dialog.dialogFor(this.getPrototypable());
                if isempty(dlg)||~ishandle(dlg)
                    dObj=swarch.internal.portrelationship.Dialog(this.getPrototypable(),...
                    strcmp(prop,this.StimulusPortElementId),...
                    this.pBDHandle);
                    dlg=DAStudio.Dialog(dObj);

                    swarch.internal.portrelationship.Dialog.dialogFor(this.getPrototypable(),dlg);
                end
                dlg.show();
                dlg.refresh();
            end
        end
    end


    methods(Access=private)
        function setPortEvent(this,portEventType,value)
            ec=this.pEventChain;
            if strcmp(portEventType,'stimulus')
                event=ec.stimulus;
            else
                event=ec.response;
            end

            if~isempty(event)
                event.destroy();
            end
            ownerArch=ec.parent.p_Architecture;
            if contains(value,':')
                names=strsplit(value,':');
                compName=names{1};
                portName=names{2};
            else
                compName='';
                portName=value;
            end
            if~isempty(compName)&&~ownerArch.hasParentComponent()
                c=ownerArch.getComponent(compName);
                p=c.getPort(portName);
            else
                p=ownerArch.getPort(portName);
            end
            swarch.utils.addPortEvent(ec,p,portEventType);
        end


        function tf=isPortEvent(~,event)
            tf=event.eventType==...
            systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_RECEIVE||...
            event.eventType==...
            systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_SEND;
        end
    end
end


