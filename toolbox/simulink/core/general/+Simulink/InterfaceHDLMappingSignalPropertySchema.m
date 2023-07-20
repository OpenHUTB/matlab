classdef InterfaceHDLMappingSignalPropertySchema<Simulink.InterfaceMappingPropertySchema





    methods(Static)
        function name=getTabName()
            name=DAStudio.message('codemapping_hdl:mapping:DataViewSignals');
        end
    end

    methods
        function this=InterfaceHDLMappingSignalPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('Signals');
                if(isa(obj.Source.getForwardedObject,'Simulink.Port'))

                    props={};
                    props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
                end
                props=[props,names];
            else
                props={'Simulink:studio:DataViewPerspective_CodeGen'};
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=true;
        end
        function props=getPerInstanceProperties(obj,perspective)
            props={};
            if isa(obj.Source,'DataView')
                return;
            else
                ownerHandle=obj.Source.getForwardedObject.Handle;
            end
            if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                ownerHandle=obj.Source.getForwardedObject.Handle;
                if strcmp(get_param(ownerHandle,'Type'),'port')



                    props=hdlcoder.mapping.internal.ui.getPerInstancePropertyList(ownerHandle,5);
                end
            end
        end

        function isVisible=isTabVisible(~,~)%#ok<INUSL>
            if slfeature('HDLTargetModelMapping')
                isVisible=true;
            else
                isVisible=false;
            end

        end

        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end

        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'SignalMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function handleRemoveBtnClick(obj)
            if isa(obj.Source,'DataView')
                return;
            end

            ownerHandle=obj.Source.getForwardedObject.Handle;
            if strcmp(get_param(ownerHandle,'Type'),'port')


                obj.deleteEntry;
            end
        end

        function deleteEntry(obj,~)
            portHandle=obj.Source.getForwardedObject.Handle;
            model=get_param(bdroot(portHandle),'Name');
            simulinkcoder.internal.util.CanvasElementSelection.removeSignal(model,portHandle);
        end
    end


    methods(Access=protected)
        function props=getCommonProperties(~,~,~)
            props={'Source'};
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                props={};
                if slfeature('HDLTargetModelMapping')>0
                    mmgr=get_param(model,'MappingManager');
                    hm=mmgr.getActiveMappingFor('HDLTarget');
                    if contains(hm.Name,'HDLTarget')
                        props{end+1}=DAStudio.message('codemapping_hdl:mapping:InterfaceLabel');
                        props{end+1}=DAStudio.message('codemapping_hdl:mapping:InterfaceElementLabel');
                    end
                end
            otherwise
                props={};
            end
        end
    end

end




