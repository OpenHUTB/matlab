classdef SysarchLinePropertySchema<systemcomposer.internal.arch.internal.propertyinspector.SysarchBaseSchema





    properties(SetAccess=private)
ArchName
slLineObj
SrcPrtHdl
DstPrtHdl
ConnOwningParent
SelectedConn

hilitedConn
hiliter
userSelectionMade

isSegment
isPhysicalConnector
IsAUTOSARArchModel
    end

    properties(Constant,Access=private)


        SelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:Select');
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
    end

    methods
        function delete(this)

            this.removeHilite();
        end


        function this=SysarchLinePropertySchema(objH)
            this.setSchemaSource(objH);
            this.hiliter=this.createHighlighter();
            this.isPhysicalConnector=false;
            if(isa(objH,'Simulink.Segment'))
                this.isSegment=true;
                h=objH.getLine();
                this.SrcPrtHdl=h.getSourcePort.Handle;
                this.DstPrtHdl=get_param(objH.Handle,'DstPortHandle');
                this.userSelectionMade=true;

                zcDstPrt=systemcomposer.utils.getArchitecturePeer(this.DstPrtHdl);
                zcSrcPrt=systemcomposer.utils.getArchitecturePeer(this.SrcPrtHdl);
                this.SelectedConn=zcSrcPrt.getConnectorTo(zcDstPrt);
                this.hiliteSelectedSegment();
            elseif~isempty(objH.getSourcePort)
                this.isSegment=false;
                h=objH;
                this.SrcPrtHdl=h.getSourcePort.Handle;
                this.DstPrtHdl=-1;
                this.userSelectionMade=false;








                this.SelectedConn=systemcomposer.architecture.model.design.BaseConnector.empty;
            else
                assert(isempty(objH.getSourcePort));
                this.isSegment=false;
                h=objH;
                this.SrcPrtHdl=-1;
                this.DstPrtHdl=-1;
                this.hiliter=[];
                this.userSelectionMade=false;
                this.SelectedConn=systemcomposer.architecture.model.design.BaseConnector.empty;





                segmentHandles=find_system(h.Parent,'SearchDepth','1','findall','on','type','line');
                segmentObjs=arrayfun(@(x)get_param(x,'Object'),segmentHandles);
                filteredSegIdxs=arrayfun(@(x)x.getLine==h,segmentObjs);
                filteredSegmentObjs=segmentObjs(filteredSegIdxs);

                slConnEndObjs=arrayfun(@(x)x.getSourcePort,filteredSegmentObjs,'UniformOutput',false);
                validSourcePortIdx=find(~cellfun(@isempty,slConnEndObjs));
                validSlConnEndObj=slConnEndObjs{validSourcePortIdx};

                zcSrcPrt=systemcomposer.utils.getArchitecturePeer(validSlConnEndObj.Handle);
                this.SelectedConn=zcSrcPrt.getConnectors;
                this.isPhysicalConnector=true;
            end

            this.ArchName=bdroot(h.Parent);
            this.IsAUTOSARArchModel=Simulink.internal.isArchitectureModel(this.ArchName,'AUTOSARArchitecture');
            this.ConnOwningParent=get_param(h.Parent,'Handle');
            this.slLineObj=h;

        end


        function toolTip=propertyTooltip(this,prop)
            if contains(prop,'Sysarch:Prototype:')
                if~isempty(this.SelectedConn)&&isvalid(this.SelectedConn)
                    toolTip=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyTooltip(this.SelectedConn,prop);
                else
                    toolTip='';
                end
            else
                toolTip=this.propertyDisplayLabel(prop);
            end
        end


        function name=getObjectType(~)
            name=DAStudio.message('SystemArchitecture:PropertyInspector:Connector');
        end


        function hasSub=hasSubProperties(this,prop)
            hasSub=false;%#ok<NASGU>
            switch prop
            case{'Line:Root','Line:Main'}
                hasSub=true;
            case 'Line:Connector'
                hasSub=true;
            case{'Line:Main:SrcPrt','Line:Main:DstPrt'}
                hasSub=false;
            case{'Line:Connector:Name'}
                hasSub=false;
            case 'Sysarch:Prototype'
                hasSub=false;
            otherwise

                hasSub=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.hasSubProperties(this.SelectedConn,prop);
            end
        end


        function subprops=subProperties(this,prop)
            subprops={};
            if isempty(prop)
                if this.isPhysicalConnector

                    subprops={'Line:Root'};
                else
                    subprops={'Line:Root','Simulink:Dialog:Info'};
                end
            else
                switch prop
                case 'Line:Root'
                    if~this.isPhysicalConnector
                        subprops={'Line:Main','Line:Connector'};
                        if~this.IsAUTOSARArchModel||(this.IsAUTOSARArchModel&&slfeature('ZCProfilesForAUTOSAR'))
                            subprops{end+1}='Sysarch:Prototype';
                        end
                    else
                        assert(this.isPhysicalConnector);
                        subprops={'Line:Connector','Sysarch:Prototype'};
                    end

                    if(~this.isSegment&&~this.isPhysicalConnector)






                        if~this.userSelectionMade||isempty(this.SelectedConn)



                            [isSingle,selectedLines]=this.isSingleSegmentSelected;
                            if isSingle

                                prt=get_param(selectedLines,'DstPortHandle');
                            else
                                if isempty(selectedLines)
                                    this.refresh();
                                    return
                                end

                                segsChildren=get_param(selectedLines,'LineChildren');
                                idxValidZcConn=cellfun(@isempty,segsChildren);
                                selectedLines=selectedLines(idxValidZcConn);
                                prt=get_param(selectedLines(1),'DstPortHandle');
                            end
                        else


                            prt=this.DstPrtHdl;
                            this.userSelectionMade=false;
                        end

                        if~isequal(prt,this.DstPrtHdl)

                            this.removeHilite();
                            if~ishandle(prt)

                                this.SelectedConn=systemcomposer.architecture.model.design.BaseConnector.empty;
                            else
                                this.DstPrtHdl=prt;
                                zcDstPrt=systemcomposer.utils.getArchitecturePeer(prt);
                                zcSrcPrt=systemcomposer.utils.getArchitecturePeer(this.SrcPrtHdl);
                                this.SelectedConn=zcSrcPrt.getConnectorTo(zcDstPrt);
                                this.hiliteSelectedSegment();


                                this.refresh();
                            end
                        end
                    end
                    if~isempty(this.SelectedConn)&&isvalid(this.SelectedConn)
                        if length(this.SelectedConn.getPrototype)>=1
                            prototypeProps=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.subProperties(this.SelectedConn,'Sysarch:Prototype');
                        else
                            prototypeProps={};
                        end
                        subprops=horzcat(subprops,prototypeProps);
                    end
                case 'Line:Main'
                    subprops={'Line:Main:SrcPrt','Line:Main:DstPrt'};
                case 'Line:Connector'
                    subprops={'Line:Connector:Name'};
                otherwise
                    if~isempty(this.SelectedConn)
                        subprops=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.subProperties(this.SelectedConn,prop);
                    end
                end
            end
        end


        function value=propertyValue(this,prop)
            switch prop
            case 'Simulink:Dialog:Info'
                value=this.SourceObject.getPropValue(prop);
            case 'Line:Main'
                value='';
            case 'Line:Main:SrcPrt'
                value=systemcomposer.utils.getArchitecturePeer(this.SrcPrtHdl).getName;
            case 'Line:Main:DstPrt'
                if isvalid(this.SelectedConn)
                    value=this.SelectedConn.getDestination.getName;
                else
                    value='';
                end
            case 'Line:Connector'
                if~this.isPhysicalConnector
                    src=systemcomposer.utils.getArchitecturePeer(this.SrcPrtHdl).getName;
                    if ishandle(this.DstPrtHdl)
                        dst=systemcomposer.utils.getArchitecturePeer(this.DstPrtHdl);
                    else
                        dst=double.empty;
                    end
                    if~isempty(dst)&&isvalid(dst)
                        value=[src,' -> ',dst.getName];
                    else
                        value='';
                        this.userSelectionMade=true;
                        this.refresh();
                    end
                elseif this.isPhysicalConnector
                    if isvalid(this.SelectedConn)
                        ports=this.SelectedConn.getPorts;
                        portNames={};
                        for idx=1:numel(ports)
                            portNames{idx}=ports(idx).getName;
                        end
                        value=strcat('[',strjoin(portNames,','),']');
                    else
                        value='';
                    end
                end
            case 'Line:Connector:Name'
                if isvalid(this.SelectedConn)
                    value=this.SelectedConn.getName;
                else
                    value='';
                end
            case 'Sysarch:Prototype'
                value=this.AddStr;
            otherwise
                value=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyValue(this.SelectedConn,prop);
            end
        end


        function enabled=isPropertyEnabledHook(this,prop)

            if isempty(this.SelectedConn)
                enabled=false;
            elseif contains(prop,':NoPropertiesDefined')

                enabled=false;
                return;
            else
                if contains(prop,'Sysarch:Prototype:')

                    enabled=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.isPropertyEnabled(this.SelectedConn,prop);
                    return
                else
                    enabled=true;
                end
            end
        end


        function editable=isPropertyEditableHook(this,prop)
            if this.hasSubProperties(prop)


                if strcmp(prop,'Sysarch:Prototype')
                    editable=true;
                elseif contains(prop,'Sysarch:Prototype:')
                    editable=true;
                else
                    editable=false;
                end
            else
                switch prop
                case 'Line:Main:DstPrt'
                    if this.isSingleSegmentSelected||this.isSegment
                        editable=false;
                    else
                        editable=true;
                    end
                case 'Line:Main:SrcPrt'
                    editable=false;
                otherwise
                    editable=true;
                end
            end
        end

        function errors=setPropertyValues(this,vals,~)
            errors={};
            for idx=1:2:numel(vals)
                prop=vals{idx};
                value=vals{idx+1};
                err=this.setPropertyVal(prop,value);
                if~isempty(err)
                    if strcmp(prop,'Sysarch:Prototype')
                        subError=DAStudio.UI.Util.Error(prop,...
                        'Error',...
                        err.message,...
                        []);
                        subError.DisplayValue=value;

                    else
                        propTags=strsplit(prop,':');
                        if any(strcmp(propTags{end},{'Unit','Value'}))
                            panelID=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.removeFakeProperty(prop);
                        else
                            panelID=prop;
                        end
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
                    end
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


            this.refresh();
        end

        function err=setPropertyVal(this,prop,newValue)
            err={};
            switch prop
            case 'Line:Main:DstPrt'
                this.removeHilite()


                if strcmp(newValue,this.SelectStr)
                    return
                end
                zcSrcPrt=systemcomposer.utils.getArchitecturePeer(this.SrcPrtHdl);
                zcDstPrt=this.findDstPrt(newValue);
                conn=zcSrcPrt.getConnectorTo(zcDstPrt);
                this.SelectedConn=conn;
            case 'Sysarch:Prototype'
                if strcmp(newValue,this.RemoveStr)
                    systemcomposer.internal.arch.removePrototype(this.SelectedConn,'all');

                elseif strcmp(newValue,this.OpenProfEditorStr)
                    systemcomposer.internal.profile.Designer.launch
                    return

                elseif any(strcmp(newValue,{this.SelectStr,''}))
                    return

                else
                    systemcomposer.internal.arch.applyPrototype(this.SelectedConn,newValue);
                end
            case 'Line:Connector:Name'
                txn=mf.zero.getModel(this.SelectedConn).beginTransaction;
                this.SelectedConn.setName(newValue);
                txn.commit;
            otherwise
                if this.SourceObject.isValidProperty(prop)
                    this.SourceObject.setPropValue(prop,newValue);
                else
                    err=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.setPropertyVal(this.SelectedConn,prop,newValue);
                end
            end
            this.userSelectionMade=true;
            this.refresh();
        end


        function result=propertyDisplayLabel(this,prop)
            result=prop;%#ok<NASGU>
            switch prop
            case 'Line:Root'
                result=this.getConnectorKindDisplayLabel;
            case 'Line:Main'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:PortSelection');
            case 'Line:Main:SrcPrt'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Source');
            case 'Line:Main:DstPrt'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Destination');
            case 'Line:Connector'
                result=this.getConnectorKindDisplayLabel;
            case 'Line:Connector:Name'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
            case 'Sysarch:Prototype'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Stereotype');
            case 'Simulink:Dialog:Info'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Info');
            otherwise
                result=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyDisplayLabel(prop);
            end
        end


        function editor=propertyEditor(this,prop)
            editor={};
            switch prop
            case 'Line:Main:DstPrt'
                if~this.isSingleSegmentSelected()
                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.Entries=this.findAllDstPrtNames();
                    currentPrt=systemcomposer.utils.getArchitecturePeer(this.DstPrtHdl);
                    currentPrtName=[currentPrt.getComponent.getName,'/',currentPrt.getName];
                    currentPrtIdx=find(strcmp(editor.Entries,currentPrtName));
                    editor.Index=currentPrtIdx-1;
                end
            case 'Sysarch:Prototype'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=this.SelectStr;
                editor.Editable=true;
                allValidPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(this.ArchName,true,'systemcomposer.Connector');
                elemPrototypes={};
                mixinPrototypes={};
                for i=1:numel(allValidPrototypes)
                    if systemcomposer.internal.isPrototypeMixin(allValidPrototypes(i))
                        mixinPrototypes{end+1}=allValidPrototypes(i).fullyQualifiedName;%#ok<AGROW>
                    else
                        elemPrototypes{end+1}=allValidPrototypes(i).fullyQualifiedName;%#ok<AGROW>
                    end
                end
                editor.Entries=horzcat(elemPrototypes,mixinPrototypes);
                if~isempty(this.SelectedConn)&&isvalid(this.SelectedConn)
                    if numel(this.SelectedConn.getPrototype)>=1

                        editor.Entries{end+1}=this.RemoveStr;
                    end
                else
                    this.userSelectionMade=true;
                    this.refresh();
                    return
                end
                editor.Entries{end+1}=this.OpenProfEditorStr;
            case 'Line:Connector:Name'
                editor={};
            otherwise
                editor=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyEditor(this.SelectedConn,prop);
            end
        end

        function mode=propertyRenderMode(this,prop)
            switch prop
            case{'Line:Connector','Line:Connector:Name',...
                'Line:Main','Line:Main:SrcPrt'}
                mode='RenderAsText';
            case 'Line:Main:DstPrt'


                if~this.isSingleSegmentSelected&&~this.isSegment
                    mode='RenderAsComboBox';
                else
                    mode='RenderAsText';
                end
            case 'Sysarch:Prototype'
                mode='RenderAsComboBox';
            otherwise
                mode=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyRenderMode(this.SelectedConn,prop);
            end
        end


        function performPropertyAction(this,prop,~)

            systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.performPropertyAction(this.SelectedConn,prop,this.slLineObj);
        end


        function result=supportTabView(~)
            result=true;
        end


        function result=rootNodeViewMode(~,rootNode)
            if strcmp(rootNode,'Simulink:Dialog:Info')

                result='SlimDialogView';
            else
                result='TreeView';
            end
        end

    end


    methods(Static,Access=public)
    end


    methods(Access=private)
        function dstPrtNames=findAllDstPrtNames(this)
            dstPrtNames={};
            [~,selectedLines]=this.isSingleSegmentSelected();
            allDstPrt=get_param(selectedLines,'DstPortHandle');
            allDstPrtSize=cellfun(@size,allDstPrt,'UniformOutput',false);



            allDstPrtNoChild=allDstPrt(cellfun(@isequal,allDstPrtSize,...
            repmat({[1,1]},size(allDstPrtSize))));

            allDstPrtNoChild(~cellfun(@ishandle,allDstPrtNoChild))=[];
            allDstPrts=cellfun(@systemcomposer.utils.getArchitecturePeer,...
            allDstPrtNoChild,'UniformOutput',false);
            for ii=1:numel(allDstPrts)
                zcDstPrt=allDstPrts{ii};
                switch class(zcDstPrt)
                case 'systemcomposer.architecture.model.design.ComponentPort'
                    dstPrtNames{end+1}=[zcDstPrt.getComponent.getName,'/',zcDstPrt.getName];%#ok<AGROW>
                case 'systemcomposer.architecture.model.design.ArchitecturePort'
                    dstPrtNames{end+1}=zcDstPrt.getName;%#ok<AGROW>
                end
            end
        end

        function zcDstPrt=findDstPrt(this,userSelection)
            connArch=this.SelectedConn.getArchitecture;
            if contains(userSelection,'/')
                names=strsplit(userSelection,'/');
                compName=names{1};
                portName=names{2};
                comp=connArch.getComponent(compName);
                port=comp.getPort(portName);
                this.DstPrtHdl=systemcomposer.utils.getSimulinkPeer(port);
            else
                port=connArch.getPort(userSelection);
                portBlockHandle=systemcomposer.utils.getSimulinkPeer(port);
                lineHandles=get_param(portBlockHandle,'LineHandles');
                this.DstPrtHdl=get_param(lineHandles.Inport,'DstPortHandle');
            end
            zcDstPrt=port;
        end

        function[isTrue,selectedLines]=isSingleSegmentSelected(this)


            if~isempty(this.slLineObj.SignalObjectClass)
                selectedLines=find_system(this.slLineObj.Parent,...
                'searchdepth',1,'followlinks','off','findall','on',...
                'lookundermasks','off','type','line','selected','on');
            else


                selectedLines=cell(0,1);
            end
            if numel(selectedLines)==1
                isTrue=true;
            else
                isTrue=false;
            end
        end

        function refresh(this)
            this.removeHilite();
            h=DAStudio.EventDispatcher;
            h.broadcastEvent('PropertyChangedEvent',this.slLineObj);
            this.hiliteSelectedSegment();
        end

        function hiliter=createHighlighter(this)%#ok<MANU>
            stylerName='Sysarch.SegmentGlyphStyler';
            hiliter=diagram.style.getStyler(stylerName);

            if isempty(hiliter)
                diagram.style.createStyler(stylerName);
                hiliter=diagram.style.getStyler(stylerName);
            end


            darkBlue=[0.0,0.0,0.5,0.8];
            glow=MG2.GlowEffect;
            glow.Color=darkBlue;
            glow.Spread=2.5;
            glow.Gain=10;

            style=diagram.style.Style;
            style.set('Glow',glow)






            archConnTagRule=hiliter.addRule(style,diagram.style.ClassSelector('ArchConnector'));%#ok<NASGU>
        end

        function hiliteSelectedSegment(this)
            if~isempty(this.hiliter)&&isvalid(this.hiliter)
                selectedSegDiagObj=diagram.resolver.resolve([this.SrcPrtHdl,this.DstPrtHdl]);
                this.hilitedConn=selectedSegDiagObj;
                this.hiliter.applyClass(selectedSegDiagObj,'ArchConnector')
            end
        end

        function removeHilite(this)
            if~isempty(this.hilitedConn)&&~isempty(this.hiliter)&&isvalid(this.hiliter)
                this.hiliter.removeClass(this.hilitedConn,'ArchConnector')
            end
        end

        function result=getConnectorKindDisplayLabel(this)
            if this.isPhysicalConnector
                result=DAStudio.message('SystemArchitecture:PropertyInspector:PhysicalConnector');
            else
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Connector');
            end
        end
    end
end



