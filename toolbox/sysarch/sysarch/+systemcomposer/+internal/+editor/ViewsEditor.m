classdef ViewsEditor





    methods(Static)
        function appMgr=getAppMgrFromName(appName)
            app=systemcomposer.internal.arch.load(appName);
            appMgr=app.getArchViewsAppMgr;
        end

        function mfModel=getMfModel(appMgr)
            mfModel=appMgr.getModel;
        end

        function mfModel=getViewMfModel(appMgr)
            mfModel=appMgr.getViewBrowserModel;
        end

        function elem=findCompositionElem(appMgr,elemUUID)
            mfModel=mf.zero.getModel(appMgr.getZCModel);
            elem=mfModel.findElement(elemUUID);
        end

        function view=getViewFromUUID(appName,viewUUID)


            app=systemcomposer.internal.arch.load(appName);
            view=app.getCompositionArchitectureModel.findElement(viewUUID);
        end

        function[viewNames,viewUUIDs,compInViewIds,viewColors]=getOtherViewsForElement(appName,compUUID)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            compInView=mfModel.findElement(compUUID);
            if(isempty(compInView))
                bdH=get_param(appName,'Handle');
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
                compMFModel=app.getCompositionArchitectureModel;
                compInView=compMFModel.findElement(compUUID);
            end
            if isa(compInView,'systemcomposer.architecture.model.design.Architecture')
                viewNames{1}='Composition';
                viewUUIDs{1}='composition';
                viewColors{1}='composition';
                compInViewIds{1}=compUUID;
            else
                assert(isa(compInView,'systemcomposer.architecture.model.design.BaseComponent'));
                comp=compInView.p_Redefines;
                viewCatalog=systemcomposer.architecture.model.views.ViewCatalog.getCatalog(mfModel);
                allViews=viewCatalog.p_Views.toArray;
                views=[];
                compIds={};
                for i=1:numel(allViews)
                    compInView=allViews(i).getComponentInArchitecture(comp);
                    if~isempty(compInView)
                        views=[views,allViews(i)];
                        compIds=[compIds,compInView.UUID];
                    end
                end

                numViews=numel(views);
                numViews=numViews+1;
                startIdx=2;
                viewNames=cell(1,numViews);
                viewUUIDs=cell(1,numViews);
                viewColors=cell(1,numViews);
                compInViewIds=cell(1,numViews);

                viewNames{1}='Composition';
                viewUUIDs{1}='composition';
                viewColors{1}='composition';
                compInViewIds{1}=compUUID;

                for i=startIdx:numViews
                    j=i-1;
                    viewNames{i}=views(j).getName;
                    viewUUIDs{i}=views(j).UUID;
                    viewColors{i}=views(j).p_Color;
                    compInViewIds(i)=compIds(j);
                end
            end
        end

        function queryData=getQueryData(appName,elemUUID)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            queryData.canHaveQuery=false;
            if isempty(elemUUID)
                return;
            end
            elem=mfModel.findElement(elemUUID);
            elemGroup=[];
            if isa(elem,'systemcomposer.architecture.model.views.ComponentGroup')
                elemGroup=elem.p_Source;
            elseif isa(elem,'systemcomposer.architecture.model.views.View')
                elemGroup=elem.p_Root;
            elseif isa(elem,'systemcomposer.architecture.model.design.Architecture')
                if~isempty(elem.p_View)
                    elemGroup=elem.p_View.p_Root;
                end
            end

            queryData.groupBy={};
            if~isempty(elemGroup)
                queryData.canHaveQuery=elemGroup.canHaveQuery();
                queryData.elemGroupUUID=elemGroup.UUID;
                queryData.hidePorts=elemGroup.p_HidePorts;
                if~isempty(elemGroup.p_Query)
                    if isempty(elemGroup.p_GroupBy)
                        queryData.constraint=elemGroup.p_Query.p_Constraint;
                    else
                        curGroupBy=elemGroup.p_GroupBy;
                        while~isempty(curGroupBy)
                            queryData.groupBy{end+1}=curGroupBy.p_GroupByPropFQN;
                            curGroupBy=curGroupBy.p_SubGroupBy;
                        end
                        queryData.constraint=elemGroup.p_GroupBy.p_Query;
                    end
                end
                if~isempty(elemGroup.p_QueryPort)
                    queryData.constraintPort=elemGroup.p_QueryPort.p_Constraint;
                end
            end
            queryData.options=systemcomposer.internal.editor.ViewsEditor.getDiagramOptions(appName,elemUUID);
            if queryData.options.hidePorts
                queryData.hidePorts=true;
            end
        end

        function list=getArchitectureLists(appName)
            topSys=appName;


            subsysBlks=find_system(appName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','BlockType','SubSystem');

            allArchs=vertcat(topSys,subsysBlks);
            allArchs=sort(allArchs);
            list=struct('value',allArchs,'label',allArchs);
        end

        function list=getListOfGroupBy(appName)
            stereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.Component',true);
            propNames={};
            for i=1:numel(stereotypes)
                if(~isempty(stereotypes(i).propertySet))
                    props=stereotypes(i).propertySet.properties.toArray;
                    for j=1:numel(props)
                        if(props(j).type.MetaClass.isA(systemcomposer.property.Enumeration.StaticMetaClass))
                            propNames=[propNames,props(j).fullyQualifiedName];
                        end
                    end
                end
            end
            list=struct('value',propNames,'label',propNames);

        end

        function options=getDiagramOptions(appName,viewUUID)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            view=mfModel.findElement(viewUUID);
            options=struct;
            diagOptions=view.p_DiagramOptions;
            options.diagramType=diagOptions.p_DiagramType.double;
            options.displayDepth=diagOptions.p_DisplayDepth;
            options.hideUnconnectedPorts=diagOptions.p_HideUnconnectedPort;
            options.hidePorts=diagOptions.p_HidePorts;
            options.hideConnectors=diagOptions.p_HideConnectors;
            options.hideProps=diagOptions.p_HideProperties;
            options.hideMethods=diagOptions.p_HideMethods;
        end

        function options=updateDiagramOptions(appName,viewUUID,optStruct)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            view=mfModel.findElement(viewUUID);
            txn=mfModel.beginTransaction;
            diagOptions=view.p_DiagramOptions;
            if isfield(optStruct,'diagramType')
                if strcmpi(optStruct.diagramType,'component')
                    diagOptions.setDiagramType(systemcomposer.architecture.model.views.DiagramType.COMPONENT);
                elseif strcmpi(optStruct.diagramType,'hierarchy')
                    diagOptions.setDiagramType(systemcomposer.architecture.model.views.DiagramType.HIERARCHY);
                elseif strcmpi(optStruct.diagramType,'class')
                    diagOptions.setDiagramType(systemcomposer.architecture.model.views.DiagramType.CLASS);
                end
            end
            if isfield(optStruct,'hidePorts')
                diagOptions.setHidePorts(optStruct.hidePorts);
            end
            if isfield(optStruct,'hideUnconnectedPorts')
                diagOptions.setHideUnconnectedPorts(optStruct.hideUnconnectedPorts);
            end
            if isfield(optStruct,'hideConnectors')
                diagOptions.setHideConnectors(optStruct.hideConnectors);
            end
            if isfield(optStruct,'hideProps')
                diagOptions.setHideProperties(optStruct.hideProps);
            end
            if isfield(optStruct,'hideMethods')
                diagOptions.setHideMethods(optStruct.hideMethods);
            end
            txn.commit();
            options=systemcomposer.internal.editor.ViewsEditor.getDiagramOptions(appName,viewUUID);
        end

        function prop=buildPropertyStruct(propName,propType,values)
            prop.name=propName;
            prop.type=propType;
            if nargin>2
                prop.values=values;
            else
                prop.values=[];
            end
        end

        function[list,groupByData]=getDataForConstraintBuilder(appName)
            import systemcomposer.internal.editor.ViewsEditor.*;
            stereotypeList=buildStereotypeProperiesForConstraintBuilder(appName);
            nameProp=buildPropertyStruct('Name','string');
            if(Simulink.internal.isArchitectureModel(appName,'AUTOSARArchitecture'))
                if slfeature('ZCProfilesForAUTOSAR')>0
                    list.compProps=[stereotypeList.compStereotypes,nameProp];
                    list.portProps=[stereotypeList.portStereotypes,nameProp];
                else
                    list.compProps=nameProp;
                    list.portProps=nameProp;
                end


            else
                compProperties=[stereotypeList.compStereotypes,nameProp];
                compStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.Component',true);
                for compStereotype=compStereotypes
                    propNames=getPropertyNamesFromStereotype(compStereotype);
                    compProperties=[compProperties,propNames];%#ok<AGROW>
                end
                list.compProps=compProperties;


                portProperties=[stereotypeList.portStereotypes,nameProp];
                portStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.Port',true);
                for portStereotype=portStereotypes
                    propNames=getPropertyNamesFromStereotype(portStereotype);
                    portProperties=[portProperties,propNames];%#ok<AGROW>
                end
                list.portProps=portProperties;


                intrfProperties=[stereotypeList.intrfStereotypes,nameProp];
                intrfStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.PortInterface',true);
                for intrfStereotype=intrfStereotypes
                    propNames=getPropertyNamesFromStereotype(intrfStereotype);
                    intrfProperties=[intrfProperties,propNames];%#ok<AGROW>
                end
                list.intrfProps=intrfProperties;


                typeProp=buildPropertyStruct('Type','string');
                unitsProp=buildPropertyStruct('Units','string');
                intrfElemProperties=[nameProp,typeProp,unitsProp];
                list.intrfElemProps=intrfElemProperties;
            end
            groupByData=getListOfGroupBy(appName);
        end

        function props=getPropertyNamesFromStereotype(stereotype)
            import systemcomposer.internal.editor.ViewsEditor.*;
            propDefs=stereotype.propertySet.properties.toArray;

            function[type,values]=getTypeFromPropDef(propDef)
                className=class(propDef.type);
                values=[];
                switch className
                case 'systemcomposer.property.Enumeration'
                    type='picker_numeric';
                    values=cellfun(@(x)[propDef.type.MATLABEnumName,'.',x],propDef.type.getLiteralsAsStrings(),'UniformOutput',false);
                case 'systemcomposer.property.StringType'
                    type='string';
                otherwise
                    type='numeric';
                end
            end

            props=[];
            for i=1:numel(propDefs)
                propName=propDefs(i).fullyQualifiedName;
                [propType,propValues]=getTypeFromPropDef(propDefs(i));
                props=[props,buildPropertyStruct(propName,propType,propValues)];
            end
        end


        function list=buildStereotypeProperiesForConstraintBuilder(appName)
            import systemcomposer.internal.editor.ViewsEditor.*;

            compStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.Component',true);
            compStereotypeNames=arrayfun(@(x)x.fullyQualifiedName,compStereotypes,'UniformOutput',false);
            list.compStereotypes=buildPropertyStruct('Stereotype','picker',compStereotypeNames);


            portStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.Port',true);
            portStereotypeNames=arrayfun(@(x)x.fullyQualifiedName,portStereotypes,'UniformOutput',false);
            list.portStereotypes=buildPropertyStruct('Stereotype','picker',portStereotypeNames);


            intrfStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(appName,false,'systemcomposer.PortInterface',true);
            intrfStereotypeNames=arrayfun(@(x)x.fullyQualifiedName,intrfStereotypes,'UniformOutput',false);
            list.intrfStereotypes=buildPropertyStruct('Stereotype','picker',intrfStereotypeNames);
        end

        function showInComposition(appName,compToShowUUID,viewUUID)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            occur=mfModel.findElement(compToShowUUID);
            if(isempty(occur))
                bdH=get_param(appName,'Handle');
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
                compMFModel=app.getCompositionArchitectureModel;
                occur=compMFModel.findElement(compToShowUUID);
            end
            if isa(occur,'systemcomposer.architecture.model.design.Architecture')
                systemcomposer.internal.selectElementInComposition(appMgr.getZCModel.getRootArchitecture);
            else
                elements=occur.p_Redefines;
                view=mfModel.findElement(viewUUID);
                if isequal(view.p_DiagramOptions.p_DiagramType,systemcomposer.architecture.model.views.DiagramType.CLASS)&&occur.hasReferencedArchitecture
                    componentsInSameLevel={};
                    elementsFromSameRefArch={};
                    if~isempty(occur.getParentArchitecture)
                        componentsInSameLevel=occur.getParentArchitecture.getComponents;
                    else
                        componentsInSameLevel=occur.getParentComponent.getComponents;
                    end
                    for i=1:length(componentsInSameLevel)
                        if strcmp(occur.p_Redefines.getArchitecture.getName,componentsInSameLevel(i).getArchitecture.getName)
                            elementsFromSameRefArch=[elementsFromSameRefArch,componentsInSameLevel(i)];
                        end
                    end
                    systemcomposer.internal.selectElementInComposition(elementsFromSameRefArch);
                else
                    systemcomposer.internal.selectElementInComposition(elements);
                end
            end
        end

        function openHelpTopic(helpTopic)
            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),helpTopic);
        end

        function openAdapterDialog(appName,compUUID)
            appMgr=systemcomposer.internal.editor.ViewsEditor.getAppMgrFromName(appName);
            mfModel=systemcomposer.internal.editor.ViewsEditor.getMfModel(appMgr);
            occur=mfModel.findElement(compUUID);
            adapterComp=systemcomposer.internal.editor.ViewsEditor.getSrcElem(occur);

            blockHandle=systemcomposer.utils.getSimulinkPeer(adapterComp);
            dObj=systemcomposer.internal.adapter.Dialog(blockHandle);
            dialogInstance=DAStudio.Dialog(dObj);

            dialogInstance.show();
            dialogInstance.refresh();
        end

        function srcElem=getSrcElem(elem)
            redefElem=elem.p_Redefines;
            if isempty(redefElem)
                srcElem=elem;
            else
                srcElem=systemcomposer.internal.editor.ViewsEditor.getSrcElem(redefElem);
            end
        end


        function applyPortFilter(appName,viewUUID,compQuery,portQuery)
            if isempty(portQuery)
                return;
            end

            app=systemcomposer.internal.arch.load(appName);
            mfView=app.getArchViewsAppMgr.getModel.findElement(viewUUID);
            view=systemcomposer.internal.getWrapperForImpl(mfView);

            compQuery=systemcomposer.query.Constraint.createFromString(compQuery);
            view.modifyQuery(compQuery);

            view.getImpl.disableLiveSync(true);
            view.recreateArchitecture();

            portQuery=systemcomposer.query.Constraint.createFromString(portQuery);

            runner=systemcomposer.query.internal.QueryRunner(view.Architecture,~portQuery,true,true,'Port');
            runner.isEvaluatedUsingNewSystem=false;
            runner.execute;
            mdl=mf.zero.getModel(view.getImpl);
            txn=mdl.beginTransaction;
            for i=1:numel(runner.Elems)
                elem=runner.Elems(i);
                elem.getImpl.destroy;
            end
            txn.commit();
        end

        function printView(appName,rootUUID)
            [filename,pathname]=uiputfile('*.pdf',message('SystemArchitecture:ViewsUI:SaveViewDiagramAs').getString);
            filename=fullfile(pathname,filename);
            systemcomposer.internal.editor.Printer.takeScreenshotForDiagramUUID(appName,rootUUID,filename);
        end

        function refreshReqBadgesForModel(appName)
            if exist('slreq.app.MainManager','class')==8

                slreqManager=slreq.app.MainManager.getInstance;
                slreqManager.badgeManager.refreshBadges(appName);
            end
        end
    end
end


