classdef ModelPropertySchema<handle
    properties(SetAccess=private)
        source='';
    end

    methods
        function this=ModelPropertySchema(h)
            if isa(h,'Simulink.BlockDiagram')
                this.source=h;
            else
                ME=MException('ModelPropertySchema:InvalidSourceType',...
                'The source type is not a block diagram');
                throw(ME);
            end
        end


        function tabview=supportTabView(~)
            tabview=true;
        end

        function mode=rootNodeViewMode(~,rootProp)
            mode='Undefined';
            if strcmp(rootProp,'Simulink:Model:Properties')||...
                strcmp(rootProp,'Simulink:Model:Info')||...
                strcmp(rootProp,'Simulink:Model:Domain')
                mode='SlimDialogView';
            end
        end

        function hasSub=hasSubProperties(~,prop)
            if(isempty(prop))
                hasSub=true;
            else
                hasSub=false;
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='Simulink:Model:Properties';
                subprops{2}='Simulink:Model:Info';
                subprops{3}='Simulink:Model:Domain';
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'Simulink:Model:Properties')
                label=DAStudio.message('dastudio:propertyinspector:PropertiesNode');
            elseif strcmp(prop,'Simulink:Model:Info')
                label=DAStudio.message('dastudio:propertyinspector:InfoNode');
            elseif strcmp(prop,'Simulink:Model:Domain')
                label=DAStudio.message('dastudio:propertyinspector:DomainNode');
            end
        end

        function handle=getOwnerGraphHandle(obj)
            handle=obj.source.Handle;
        end

        function showPropertyHelp(~,prop)
            if strcmp(prop,'Simulink:Model:Domain')
                helpview(fullfile(docroot,'simulink','helptargets.map'),'subsystem_domain_specification');
            else
                helpview([docroot,'/mapfiles/simulink.map'],'modelpropertiesdialog');
            end
        end

        function errors=setPropertyValues(obj,vals,~)
            wnBWS=warning('off','Simulink:dialog:BWSAccessViaDD');
            wnShd=warning('off','Simulink:Engine:MdlFileShadowing');
            errors={};
            for idx=1:2:numel(vals)
                propName=vals{idx};
                propVal=vals{idx+1};
                if strcmp(propName,'UpdateHistory')||...
                    strcmp(propName,'EnableAccessToBaseWorkspace')
                    propVal=str2double(propVal);
                end
                try
                    set_param(obj.source.Handle,propName,propVal);
                catch e


                    if(strcmp(propName,'EnableAccessToBaseWorkspace')||...
                        strcmp(propName,'DataDictionary'))&&...
                        strcmp(e.identifier,'Simulink:Data:NeedAccessToBaseWSOrDD')
                        error1=DAStudio.UI.Util.Error('DataDictionary',...
                        'Error',...
                        e.message);
                        error1.Tag='DataDictionary';
                        error2=DAStudio.UI.Util.Error('EnableAccessToBaseWorkspace',...
                        'Error',...
                        e.message);
                        error2.Tag='EnableAccessToBaseWorkspace';
                        errors(end+1:end+2)={error1,error2};
                    else
                        error=DAStudio.UI.Util.Error(propName,...
                        'Error',...
                        e.message);
                        error.Tag=propName;
                        errors(end+1)={error};%#ok<AGROW>
                    end
                end
            end
            warning(wnBWS);
            warning(wnShd);
        end

        function props=relatedProperties(obj,propName)%#ok<*INUSL>
            props={};
            if strcmp(propName,'DataDictionary')
                props={'EnableAccessToBaseWorkspace'};
            elseif strcmp(propName,'EnableAccessToBaseWorkspace')
                props={'DataDictionary'};
            end
        end

        function activeNode=defaultActiveRootNode(~)
            activeNode='Simulink:Model:Info';
        end

    end
end
