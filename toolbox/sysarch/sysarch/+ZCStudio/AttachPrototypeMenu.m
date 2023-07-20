function schema=AttachPrototypeMenu(cbinfo)





    enabled=true;
    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    thisModelName=ZCStudio.getArchitectureFromCurrentContext(cbinfo);
    for i=1:numel(blocks)

        archElem=systemcomposer.utils.getArchitecturePeer(blocks(i).handle);
        if isa(archElem,'systemcomposer.architecture.model.design.BaseComponent')&&...
            (archElem.isReferenceComponent||isa(archElem,'systemcomposer.architecture.model.design.VariantComponent'))
            enabled=false;
            break;
        end
    end
    if isempty(blocks)
        elem=getSelectedElementOnCanvas(cbinfo);
        if isempty(elem)


            enabled=false;
        else
            enabled=true;
        end
        for k=1:numel(elem)


            if isa(elem(k),'systemcomposer.architecture.model.design.ArchitecturePort')
                mdlName1=elem(k).getTopLevelArchitecture.getName;
                isReference=~strcmp(mdlName1,thisModelName.getName);
                if isReference
                    if strcmp(get_param(mdlName1,'SimulinkSubDomain'),'Architecture')||...
                        strcmp(get_param(mdlName1,'SimulinkSubDomain'),'SoftwareArchitecture')
                        enabled=false;
                        break;
                    end
                end

                isVariantPort=isa(elem(k).getContainingArchitecture().getParentComponent,...
                'systemcomposer.architecture.model.design.VariantComponent');
                if isVariantPort
                    enabled=false;
                    break;
                end
            end
            if isa(elem(k),'systemcomposer.architecture.model.design.Architecture')
                if elem(k).isVariantArchitecture()
                    enabled=false;
                    break;
                end
            end
        end
    end
    schema=sl_container_schema;
    schema.tag='SystemComposer:AttachPrototypeMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:ApplyPrototypeMenuItem');
    if enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.generateFcn=@(cbinfo)generateLoadedPrototypeMenu(cbinfo);
end

function children=generateLoadedPrototypeMenu(cbinfo)

    topArchMdl=ZCStudio.getArchitectureFromCurrentContext(cbinfo);
    try
        if hasUserDefinedProfiles(topArchMdl.p_Model)
            archName=topArchMdl.getName;
            [~,type]=areSelectedElementsUnique(cbinfo);
            SLM3Iblk=SLStudio.Utils.getSelectedBlocks(cbinfo);
            if(~isempty(SLM3Iblk))
                handle=SLM3Iblk.handle;
                blk=systemcomposer.utils.getArchitecturePeer(handle);
                if(isa(blk,'systemcomposer.architecture.model.design.Component')&&blk.isSubsystemReferenceComponent)
                    allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(...
                    blk.getReferencedArchitecture.getName,true,getPrototypeClassForElement(type));
                elseif(isa(blk,'systemcomposer.architecture.model.design.BaseComponent')&&blk.hasReferencedArchitecture)
                    allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(blk.getArchitecture.getName,true,getPrototypeClassForElement(type));
                else
                    allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(archName,true,getPrototypeClassForElement(type));
                end
            else
                allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(archName,true,getPrototypeClassForElement(type));
            end
            children={};
            elemPrototypes={};
            mixinPrototypes={};
            if~isempty(allPrototypes)
                for i=1:numel(allPrototypes)
                    if systemcomposer.internal.isPrototypeMixin(allPrototypes(i))
                        mixinPrototypes{end+1}={@CreatePrototypeAsAction,allPrototypes(i).fullyQualifiedName};%#ok<AGROW>
                    else

                        elemPrototypes{end+1}={@CreatePrototypeAsAction,allPrototypes(i).fullyQualifiedName};%#ok<AGROW>
                    end
                end
                children=[elemPrototypes,mixinPrototypes];
            else
                children{1}={@CreatePrototypeAsAction,'NoValidPrototypes'};
            end
        else
            children{1}={@CreatePrototypeAsAction,'NoValidProfiles'};
        end
    catch ME
        if(strcmpi(ME.identifier,'SystemArchitecture:Profile:ProfileNotFound'))
            children{1}={@CreatePrototypeAsAction,'NoValidProfiles'};
        else
            rethrow(ME)
        end
    end
end

function schema=CreatePrototypeAsAction(cbinfo)
    prototypeFQN=cbinfo.UserData;
    if any(strcmp(prototypeFQN,{'NoValidProfiles','NoValidPrototypes'}))
        schema=DAStudio.ActionSchema;
        schema.label=DAStudio.message(['SystemArchitecture:studio:',prototypeFQN]);
        schema.state='Disabled';
        schema.tag=['SystemComposer:CreatePrototypeAsAction:',prototypeFQN];
    else
        schema=DAStudio.ToggleSchema;
        schema.label=prototypeFQN;
        schema.userdata=prototypeFQN;
        schema.tag=['SystemComposer:CreatePrototypeAsAction:',prototypeFQN];
        elem=getSelectedElement(cbinfo);
        if(allSelectedHaveSamePrototype(elem,prototypeFQN))
            schema.checked='Checked';
            if all(arrayfun(@(x)~x.hasPrototype(prototypeFQN,false),elem))




                schema.state='Disabled';
            end
            schema.callback=@(x,y)RemovePrototypeCB(elem,prototypeFQN);
        else
            schema.checked='Unchecked';
            schema.callback=@(x,y)ApplyPrototypeCB(elem,prototypeFQN);
        end
    end
end

function ApplyPrototypeCB(elem,prototypeName)
    for element=elem
        systemcomposer.internal.arch.applyPrototype(element,prototypeName);

        refreshPropertyInspector(element);
    end
end

function RemovePrototypeCB(elem,prototypeName)
    for element=elem
        systemcomposer.internal.arch.removePrototype(element,prototypeName);

        refreshPropertyInspector(element);
    end
end

function elem=getSelectedElementOnCanvas(cbinfo)


    compPrts=SLStudio.Utils.getSelectedPorts(cbinfo);
    compPrts(compPrts==-1)=[];
    prts=findSLPortsFromComponentPort(compPrts);


    blks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);


    segs=SLStudio.Utils.getSelectedSegmentHandles(cbinfo);
    if numel(segs)>1
        segsChildren=get_param(segs,'LineChildren');
        idxValidZcConn=cellfun(@isempty,segsChildren);
        segs=segs(idxValidZcConn);
    end

    handles=horzcat(blks,prts,segs);
    elem=[];
    if isempty(handles)

        hdlCurrentElem=SLStudio.Utils.getDiagramHandle(cbinfo);
        currentElem=systemcomposer.utils.getArchitecturePeer(hdlCurrentElem);
        if isa(currentElem,'systemcomposer.architecture.model.design.BaseComponent')
            currentElem=systemcomposer.internal.getArchitectureInContext(currentElem);
        end
        elem=currentElem;
    else
        for i=1:numel(prts)
            subDomain=get_param(bdroot(prts(i)),'SimulinkSubdomain');
            if strcmpi(subDomain,'Simulink')
                rootImplArch=get_param(bdroot(prts(i)),'SystemComposerArchitecture');
                implRootPorts=rootImplArch.Ports;
                archPort=findobj(implRootPorts,'SimulinkHandle',prts(i));
                if~isempty(archPort)
                    elem=[elem,archPort.getImpl];
                end
            else
                elem=[elem,systemcomposer.utils.getArchitecturePeer(prts(i))];%#ok<AGROW>
                if isa(elem(end),'systemcomposer.architecture.model.design.BaseComponent')
                    elem(end)=systemcomposer.internal.getArchitectureInContext(elem(end));
                end
            end
        end
        handles=horzcat(blks,segs);
        for m=1:numel(handles)
            thisElem=systemcomposer.utils.getArchitecturePeer(handles(m));
            if~isempty(thisElem)
                elem=[elem,thisElem];%#ok<AGROW>
                if isa(elem(end),'systemcomposer.architecture.model.design.BaseComponent')
                    elem(end)=systemcomposer.internal.getArchitectureInContext(elem(end));
                end
            end
        end

    end
end

function elem=getSelectedElementOnSpotlight(cbinfo)
    elem=[];
    studioApp=cbinfo.studio.App;
    if studioApp.hasSpotlightView()
        topLevelDiagram=studioApp.topLevelDiagram;
        modelHandle=topLevelDiagram.handle;

        appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
        editorController=appMgr.getCurrentEditor();
        selectElements=editorController.getSelection().getSelected();

        elemNum=0;
        for i=1:length(selectElements)
            selectElem=selectElements(i);
            if(selectElem.isValid())
                semElem=systemcomposer.internal.getArchitectureElementFromDiagram(appMgr.getName(),selectElem.uuid);
                elemNum=elemNum+1;
                elem(elemNum)=semElem;
            end
        end
    end
end

function elem=getSelectedElement(cbinfo)
    studioApp=cbinfo.studio.App;
    if studioApp.hasSpotlightView()
        elem=getSelectedElementOnSpotlight(cbinfo);
    else
        elem=getSelectedElementOnCanvas(cbinfo);
    end

    if isempty(elem)

        hdlCurrentElem=SLStudio.Utils.getDiagramHandle(cbinfo);
        currentElem=systemcomposer.utils.getArchitecturePeer(hdlCurrentElem);
        if isa(currentElem,'systemcomposer.architecture.model.design.BaseComponent')
            currentElem=systemcomposer.internal.getArchitectureInContext(currentElem);
        end
        elem=currentElem;
    end
end

function result=allSelectedHaveSamePrototype(elemArray,prototypeFQN)


    result=false;
    for elem=elemArray
        el=elem;
        if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
            el=systemcomposer.internal.getArchitectureInContext(elem);
        end
        if~isempty(el.getPropertySet(prototypeFQN))
            result=true;
        else
            result=false;
            break;
        end
    end
end

function[isUnique,type]=areSelectedElementsUnique(cbinfo)
    elem=getSelectedElement(cbinfo);
    elemClass=arrayfun(@class,elem,'UniformOutput',false);
    uniqueClasses=unique(elemClass);
    if length(uniqueClasses)==1
        isUnique=true;
        type=uniqueClasses{1};
    else
        isUnique=false;
        type='MIXIN';
    end
end

function type=getPrototypeClassForElement(elemClass)
    switch elemClass
    case 'systemcomposer.architecture.model.design.Component'
        type='systemcomposer.Component';
    case{'systemcomposer.architecture.model.design.BaseConnector',...
        'systemcomposer.architecture.model.design.BinaryConnector',...
        'systemcomposer.architecture.model.design.NAryConnector'}
        type='systemcomposer.Connector';
    case 'systemcomposer.architecture.model.design.Architecture'
        type='systemcomposer.Component';
    case 'systemcomposer.architecture.model.sldomain.StateflowArchitecture'
        type='systemcomposer.Component';
    case 'systemcomposer.architecture.model.design.ArchitecturePort'
        type='systemcomposer.Port';
    otherwise
        type='MIXIN';
    end
end

function result=hasUserDefinedProfiles(mdl)
    try
        profiles=mdl.getProfiles;
    catch ME
        if(strcmpi(ME.identifier,'SystemArchitecture:Profile:ProfileNotFound'))
            result=false;
            return;
        end
        rethrow(ME);
    end
    if numel(profiles)>0
        result=true;
    else
        result=false;
    end
end

function archPrtHdls=findSLPortsFromComponentPort(compPrtHdls)
    archPrtHdls=systemcomposer.internal.getBlockHandleFromPortHandle(compPrtHdls);
end

function refreshPropertyInspector(element)

    piElemToRefresh=element;
    if isa(element,'systemcomposer.architecture.model.design.Architecture')
        if element.hasParentComponent
            piElemToRefresh=element.getParentComponent;
        else

            piElemToRefresh=[];
            hdl=get_param(element.getName,'Handle');
        end
    end

    if~isempty(piElemToRefresh)
        hdl=systemcomposer.utils.getSimulinkPeer(piElemToRefresh);
    end

    if ishandle(hdl)
        systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(hdl);
    end
end


