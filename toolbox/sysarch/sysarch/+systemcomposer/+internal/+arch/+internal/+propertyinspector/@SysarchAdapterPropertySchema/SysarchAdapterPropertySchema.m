classdef SysarchAdapterPropertySchema<systemcomposer.internal.arch.internal.propertyinspector.SysarchBaseSchema




    properties(SetAccess=private)
ArchName
SourceHandle
Type
PropertySpecMap
Elem
IsSWArchAdapter
    end

    properties(Constant,Access=private)
        SelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:Select');
        InterfaceCreateOrSelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
        AnonymousInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');
        EmptyInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Empty');


        SourceProperties={'Sysarch:objName',...
'Sysarch:AdapterMode'...
        ,'Sysarch:LaunchAssistant'};
    end

    methods

        function this=SysarchAdapterPropertySchema(h)
            this.setSchemaSource(h);
            this.setType(h);
            this.SourceHandle=h.Handle;
            this.ArchName=bdroot(getfullname(this.SourceHandle));

            if~strcmp(this.Type,'Architecture')
                this.Elem=systemcomposer.utils.getArchitecturePeer(this.SourceHandle);
            else
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(this.SourceHandle);
                this.Elem=app.getTopLevelCompositionArchitecture;
            end
            this.IsSWArchAdapter=strcmp(get_param(this.ArchName,'SimulinkSubDomain'),...
            'SoftwareArchitecture');


            this.PropertySpecMap=containers.Map();
            this.PropertySpecMap('Sysarch:Main')=DAStudio.message('SystemArchitecture:PropertyInspector:Main');
            this.PropertySpecMap('Sysarch:LaunchAssistant')=DAStudio.message('SystemArchitecture:Adapter:Mappings');
            this.PropertySpecMap('Sysarch:AdapterMode')=DAStudio.message('SystemArchitecture:Adapter:InterfaceConversion');
            this.PropertySpecMap('Sysarch:objName')=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
        end


        function name=getObjectType(this)
            name=this.Type;
        end


        function hasSub=hasSubProperties(this,prop)
            if isempty(this.Elem)
                hasSub=false;
                systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema.refresh(this.SourceHandle);
                return
            end
            if any(strcmp(prop,{'Sysarch:root','Sysarch:Main',...
                'Sysarch:Port:Interface'}))
                hasSub=true;
            else
                hasSub=false;
            end
        end


        function subprops=subProperties(this,prop)
            subprops={};

            if(isempty(this.Elem))
                systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema.refresh(this.SourceHandle);
                return;
            end


            if isempty(prop)


                subprops{end+1}='Sysarch:root';
            elseif this.isSysarchRootProperty(prop)

                switch(prop)
                case 'Sysarch:root'
                    subprops{end+1}='Sysarch:Main';
                    if strcmp(this.Type,'Port')
                        subprops{end+1}='Sysarch:Port:Interface';
                    end
                case 'Sysarch:Main'

                    subprops=this.SourceProperties;
                case 'Sysarch:Port:Interface'

                    subprops{end+1}='Sysarch:Port:AInterface:Name';
                    subprops{end+1}='Sysarch:Port:AInterface:Action';
                    if(~isempty(this.Elem.getPortInterface())&&this.Elem.getPortInterface().isAnonymous())
                        subprops{end+1}='Sysarch:Port:AInterface:DataType';
                        subprops{end+1}='Sysarch:Port:AInterface:Dimensions';
                        subprops{end+1}='Sysarch:Port:AInterface:Units';
                        subprops{end+1}='Sysarch:Port:AInterface:Complex';
                        subprops{end+1}='Sysarch:Port:AInterface:Minimum';
                        subprops{end+1}='Sysarch:Port:AInterface:Maximum';
                    end
                end
            end
        end


        function enabled=isPropertyEnabledHook(this,prop)
            switch prop
            case 'Sysarch:Port:AInterface:Action'
                enabled=false;
            case 'Sysarch:LaunchAssistant'
                modeEnum=systemcomposer.internal.adapter.ModeEnums;
                enabled=~strcmpi(systemcomposer.internal.adapter.getAdapterMode(this.SourceHandle),...
                modeEnum.Merge);
            otherwise
                enabled=true;
            end
        end


        function toolTip=propertyTooltip(this,prop)
            if strcmp(prop,'Sysarch:LaunchAssistant')
                toolTip=DAStudio.message('SystemArchitecture:Adapter:LaunchAssistantTooltip');

            elseif strcmp(prop,'Sysarch:AdapterMode')
                if this.IsSWArchAdapter
                    toolTip=DAStudio.message('SystemArchitecture:Adapter:SWConversionTooltip');
                else
                    toolTip=DAStudio.message('SystemArchitecture:Adapter:ConversionTooltip');
                end

            elseif this.PropertySpecMap.isKey(prop)
                toolTip=this.PropertySpecMap(prop);
            end
        end


        function editable=isPropertyEditableHook(this,prop)
            if strcmp(prop,'Sysarch:Port:AInterface:Action')||...
                this.hasSubProperties(prop)
                editable=false;
            else
                editable=true;
            end
        end

        function errors=setPropertyValues(this,vals,~)
            errors={};
            for idx=1:2:numel(vals)
                prop=vals{idx};
                value=vals{idx+1};
                err=this.setPropertyVal(prop,value);
                if~isempty(err)
                    panelID=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.removeFakeProperty(prop);
                    if~isempty(err.cause)
                        causeMsg=err.cause{1}.message;
                    else
                        causeMsg='';
                    end
                    subError=DAStudio.UI.Util.Error(panelID,...
                    'Error',...
                    [err.message,' ',causeMsg],...
                    []);
                    subError.DisplayValue=this.propertyValue(panelID);
                    childError=DAStudio.UI.Util.Error(prop,...
                    'Error',...
                    [err.message,' ',causeMsg],...
                    []);
                    childError.DisplayValue=value;
                    subError.Children={childError};
                else
                    subError='';
                end
                errors=[errors,subError];%#ok<AGROW>
            end
            if~isempty(errors)

                errors={errors};
            else
                errors={};
            end


            systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema.refresh(this.SourceHandle);
        end


        function err=setPropertyVal(this,prop,newValue)
            err={};
            switch prop
            case 'Sysarch:objName'
                set_param(this.SourceHandle,'Name',newValue);

            case 'Sysarch:AdapterMode'
                systemcomposer.internal.adapter.setAdapterMode(this.SourceHandle,newValue,[]);
                systemcomposer.internal.adapter.resetAdapterMappingsForMerge(this.SourceHandle);

            otherwise



                try
                    set_param(this.SourceHandle,prop,newValue)
                catch ME
                    err=ME;
                end
            end
        end

        function performPropertyAction(this,prop,~)
            if strcmp(prop,'Sysarch:LaunchAssistant')
                dObj=systemcomposer.internal.adapter.Dialog(this.SourceHandle);

                dialogInstance=DAStudio.Dialog(dObj);


                dialogInstance.show();
                dialogInstance.refresh();
            end
        end


        function value=propertyValue(this,prop)
            if isempty(this.Elem)
                value='';
                systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema.refresh(this.SourceHandle);
                return
            end
            switch(prop)
            case 'Sysarch:objTag'
                value=this.getElemTagValue();
            case 'Sysarch:objName'
                value=get_param(this.SourceHandle,'Name');
            case 'Sysarch:AdapterMode'
                value=systemcomposer.internal.adapter.getAdapterMode(this.SourceHandle);
            case 'Sysarch:LaunchAssistant'
                value=DAStudio.message('SystemArchitecture:Adapter:LaunchAssistant');
            case 'Sysarch:Port:AInterface:Name'
                architecturePort=this.Elem;
                if(~isempty(architecturePort.getPortInterface()))
                    if(architecturePort.getPortInterface().isAnonymous())
                        value=this.AnonymousInterfaceStr;
                    else
                        value=architecturePort.getPortInterface().getName();
                    end
                else
                    value=this.InterfaceCreateOrSelectStr;
                end
            case 'Sysarch:Port:AInterface:Action'
                value=char(this.Elem.getPortAction());
            case{'Sysarch:Main','Sysarch:Port:Interface'}
                value='';
            end
        end


        function result=propertyDisplayLabel(this,prop)

            if any(strcmp(prop,this.SourceProperties))
                result=this.PropertySpecMap(prop);
            else
                switch(prop)
                case 'Sysarch:root'
                    result='Architecture';
                case 'Sysarch:Main'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Main');
                case{'Simulink:Dialog:Parameters'}
                    result='Parameters';
                case{'Simulink:Dialog:Properties','Simulink:Model:Properties'}
                    result='Properties';
                case{'Simulink:Dialog:Info','Simulink:Model:Info'}
                    result='Info';
                case 'Sysarch:Port:Interface'
                    result='Interface';
                case{'Simulink:Dialog:Domain','Simulink:Model:Domain'}
                    result='Domain';
                case 'Sysarch:Port:AInterface:Name'
                    result='Name';
                case 'Sysarch:Port:AInterface:Action'
                    result='Action';
                case 'Sysarch:Port:AInterface:DataType'
                    result='DataType';
                case 'Sysarch:Port:AInterface:Dimensions'
                    result='Dimensions';
                case 'Sysarch:Port:AInterface:Units'
                    result='Units';
                case 'Sysarch:Port:AInterface:Complex'
                    result='Complex';
                case 'Sysarch:Port:AInterface:Minimum'
                    result='Minimum';
                case 'Sysarch:Port:AInterface:Maximum'
                    result='Maximum';
                end
            end
        end

        function editor=propertyEditor(this,prop)
            switch(prop)
            case 'Sysarch:AdapterMode'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Editable=true;
                editor.CurrentText=systemcomposer.internal.adapter.getAdapterMode(this.SourceHandle);
                editor.Entries=systemcomposer.internal.adapter.getSupportedAdapterModes(this.SourceHandle);
                editor.Tag=prop;
            otherwise
                editor={};
            end
        end

        function mode=propertyRenderMode(~,prop)
            switch prop
            case{'Sysarch:Port:AInterface:Name','Sysarch:AdapterMode'}
                mode='RenderAsComboBox';
            case{'Sysarch:objTag','Sysarch:objName','Sysarch:Main'}
                mode='RenderAsText';
            case 'Sysarch:LaunchAssistant'
                mode='RenderAsHyperlink';
            end
        end


        function result=supportTabView(~)
            result=true;
        end


        function result=rootNodeViewMode(this,rootnode)
            if this.isSysarchRootProperty(rootnode)
                result='TreeView';
            else
                result='SlimDialogView';
            end
        end


        function result=getOwnerGraphHandle(this)
            result=this.SourceHandle;
        end

        function result=implicityGroupPropertySet(~)
            result=true;
        end

    end



    methods(Static,Access=public)
        refresh(hdl);
    end


    methods(Access=private)

        portInterfaces=getPortInterfaces(obj,archName)


        function result=isSysarchRootProperty(~,prop)
            result=any(strcmp(prop,{'Sysarch:root',...
            'Sysarch:Main',...
            'Sysarch:Port:Interface'}));
        end


        function result=isSLProperty(~,prop)
            result=any(strcmp(prop,{'Simulink:Dialog:Parameters',...
            'Simulink:Dialog:Properties',...
            'Simulink:Dialog:Info',...
            'Simulink:Dialog:Domain',...
            'Simulink:Model:Properties',...
            'Simulink:Model:Info',...
'Simulink:Model:Domain'...
            }));
        end


        function setType(this,h)
            switch(h.getDisplayClass)
            case{'Simulink.SubSystem','Simulink.ModelReference'}
                isSysarchAdapterSubDomain=strcmp(h.SimulinkSubDomain,...
                'ArchitectureAdapter');
                if isSysarchAdapterSubDomain
                    this.Type='Adapter';
                else
                    this.Type='Component';
                end
            case 'Simulink.BlockDiagram'
                this.Type='Architecture';
            case{'Simulink.Inport','Simulink.Outport','Simulink.Port'}
                this.Type='Port';
            otherwise

                error('Selected element not supported')
            end
        end

        function retVal=fetchPortBlockHandle(portHandle)
            retVal='';
            portNumber=get_param(portHandle,'PortNumber');
            portParent=get_param(portHandle,'Parent');
            portBlockType='Inport';
            if(strcmp(get_param(portHandle,'PortType'),'outport'))
                portBlockType='Outport';
            end
            portBlocks=find_system(portParent,'SearchDepth',1,'BlockType',portBlockType);
            for i=1:length(portBlocks)
                portBlockHandle=get_param(portBlocks{i},'Handle');
                portBlockIndex=str2double(get_param(portBlockHandle,'Port'));
                if(portBlockIndex==portNumber)
                    retVal=portBlockHandle;
                    break;
                end
            end
        end

        function setElemTagValue(this,val)



            tags=split(string(val),[","," ",";"]);
            tags(arrayfun(@(x)strlength(x)==0,tags))=[];
            tagVal=cellstr(tags)';
            systemcomposer.internal.arch.setPropertyValue(this.Elem,'Common','Tag',tagVal);
        end

        function val=getElemTagValue(this)



            elem=this.Elem;
            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                elem=elem.getArchitecture;
            end
            tagsCell=systemcomposer.internal.arch.getPropertyValue(elem,'Common','Tag');
            tagsArray=string(tagsCell);
            val=strjoin(tagsArray,', ');
            val=char(val);
        end

        function propval=getInterfaceElementPropertyValue(~,port,prop)
            pi=port.getPortInterface();
            pie=pi.getElement('');
            switch(prop)
            case 'Sysarch:Port:AInterface:DataType'
                propval=pie.getDataType();
            case 'Sysarch:Port:AInterface:Dimensions'
                propval=pie.getDimensions();
            case 'Sysarch:Port:AInterface:Units'
                propval=pie.getUnits();
            case 'Sysarch:Port:AInterface:Complex'
                propval=pie.getComplexity();
            case 'Sysarch:Port:AInterface:Minimum'
                propval=pie.getMinimum();
            case 'Sysarch:Port:AInterface:Maximum'
                propval=pie.getMaximum();
            end
        end

        function setInterfaceElementPropertyValue(this,mf0Model,port,prop,propval)
            pi=port.getPortInterface();
            txn=mf0Model.beginTransaction();
            pie=pi.getElement('');
            switch(prop)
            case 'Sysarch:Port:AInterface:DataType'
                pie.setDataType(propval);
                propName='OutDataTypeStr';
            case 'Sysarch:Port:AInterface:Dimensions'
                pie.setDimensions(propval);
                propName='PortDimensions';
            case 'Sysarch:Port:AInterface:Units'
                pie.setUnits(propval);
                propName='Unit';
            case 'Sysarch:Port:AInterface:Complex'
                pie.setComplexity(propval);
                propName='SignalType';
            case 'Sysarch:Port:AInterface:Minimum'
                pie.setMinimum(propval);
                propName='OutMin';
            case 'Sysarch:Port:AInterface:Maximum'
                pie.setMaximum(propval);
                propName='OutMax';
            end
            set_param(this.SourceHandle,propName,propval);
            txn.commit();
        end

    end
end


