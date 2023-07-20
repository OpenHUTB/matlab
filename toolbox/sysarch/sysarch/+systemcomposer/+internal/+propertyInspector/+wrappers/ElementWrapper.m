classdef ElementWrapper<handle




    properties
        h;
        uuid;
        archName;
        contextBdH;
        sourceHandle;
        element;
        elemType;
        dispClass;
        options;
        app;
    end

    methods(Access=public)
        function obj=ElementWrapper(varargin)
            if nargin>0&&nargin<2
                obj.h=varargin{1};



                if strcmp(varargin{1}.Type,'line')
                    [isSelected,selectedLine]=systemcomposer.internal.propertyInspector.wrappers.ConnectorElementWrapper.DestinationPortConnector(varargin{1});
                    if isSelected
                        obj.sourceHandle=selectedLine;
                    else
                        if isempty(selectedLine)

                            selectedLine=find_system(varargin{1}.Parent,'searchdepth',1,'followlinks','off','findall','on','lookundermasks','off','type','line','selected','off');
                            if numel(selectedLine)==1
                                obj.sourceHandle=selectedLine;
                            end
                        end
                        if numel(selectedLine)>1
                            selectedLine=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getSelectedLineFromConnectors(selectedLine);
                            obj.sourceHandle=selectedLine(1);
                        end
                    end
                    obj.archName=bdroot(getfullname(obj.h.Parent));
                else
                    obj.sourceHandle=varargin{1}.Handle;
                    obj.archName=bdroot(getfullname(obj.sourceHandle));
                end
                obj.element=systemcomposer.utils.getArchitecturePeer(obj.sourceHandle);
                if~isempty(obj.element)
                    obj.uuid=obj.element.UUID;
                else
                    obj.uuid=[];
                end
            elseif nargin>=2
                obj.uuid=varargin{1};
                obj.archName=varargin{2};
                obj.options=varargin{3};
            end
            obj.setPropElement();
        end

        function element=getPropElement(obj)
            element=obj.element;
        end

        function type=getObjectType(obj)
            type=obj.elemType;
        end

        function setPropElement(obj)
            obj.element={};
        end
        function zcElement=getZCElement(obj)



            zcElement=mf.zero.ModelElement.empty;
            if isempty(obj.archName)||~Simulink.internal.isArchitectureModel(obj.archName)
                return;
            end


            obj.app=systemcomposer.internal.arch.load(obj.archName);
            compMFModel=obj.app.getCompositionArchitectureModel;
            viewMFModel=obj.app.getArchViewsAppMgr.getModel;
            if~(isempty(obj.archName))&&isempty(obj.uuid)
                zcElement=obj.element;
                return;
            end

            if~isempty(obj.app)
                model=obj.app.getArchViewsAppMgr.getModel;
                if~isempty(model)
                    zcElement=viewMFModel.findElement(obj.uuid);
                    if isempty(zcElement)
                        zcElement=compMFModel.findElement(obj.uuid);
                    end
                end
            end
        end
    end
    methods(Static)
        function obj=getWrapperFromHandle(varargin)
            if~isempty(varargin)
                handle=varargin{1}.Handle;
                if strcmp(varargin{1}.Type,'line')
                    [isSelected,selectedLine]=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.DestinationPortConnector(varargin{1});
                    if isSelected
                        element=systemcomposer.utils.getArchitecturePeer(selectedLine);
                    else
                        if isempty(selectedLine)


                            selectedLine=find_system(varargin{1}.Parent,'searchdepth',1,'followlinks','off','findall','on','lookundermasks','off','type','line','selected','off');
                            if numel(selectedLine)==1

                                element=systemcomposer.utils.getArchitecturePeer(selectedLine);
                            end
                        end
                        if numel(selectedLine)>1
                            selectedLine=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getSelectedLineFromConnectors(selectedLine);
                            element=systemcomposer.utils.getArchitecturePeer(selectedLine(1));
                        end
                    end
                else

                    element=systemcomposer.utils.getArchitecturePeer(handle);
                    if isempty(element)
                        obj=[];
                        return;
                    end
                end

                type=systemcomposer.internal.propertyInspector.getElemType(element);
                if isempty(type)&&strcmp(varargin{1}.Type,'line')&&isequal(handle,-1)
                    type='Connector';
                end
                obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(type,varargin{1});
            else
                obj=[];
                return;
            end
        end

        function obj=getWrapperFromUUID(varargin)
            uuid=varargin{1};
            appName=varargin{2};
            options=varargin{3};
            context=varargin{4};
            if isempty(uuid)
                obj='';
                return;
            end
            if strcmp(context,'View')||strcmp(context,'ClassDiagramView')
                if isempty(uuid)
                    obj='';
                    return;
                end

                if~isempty(options)&&isfield(options,'subcontext')&&strcmp(options.subcontext,'SequenceDiagram')
                    subtype='SequenceDiagram';
                    obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(subtype,uuid,appName,options,true);
                    return;
                elseif~isempty(options)&&isfield(options,'subcontext')&&strcmp(options.subcontext,'SequenceDiagramMessage')
                    subtype='SequenceDiagramMessage';
                    obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(subtype,uuid,appName,options,true);
                    return;
                elseif~isempty(options)&&isfield(options,'subcontext')&&strcmp(options.subcontext,'SequenceDiagramLifeline')
                    appName=options.contextname;
                end

                bdH=get_param(appName,'Handle');
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
                mdl=app.getArchViewsAppMgr.getModel();
                occurrenceElem=mdl.findElement(uuid);
                if(isempty(occurrenceElem))
                    compMFModel=app.getCompositionArchitectureModel;
                    occurrenceElem=compMFModel.findElement(uuid);
                end
                type=systemcomposer.internal.propertyInspector.getElemType(occurrenceElem);
                if strcmp(type,'Component')&&strcmp(context,'ClassDiagramView')
                    subtype='ArchitectureType';
                    obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(subtype,uuid,appName,options,true);
                elseif strcmp(type,'Architecture')&&strcmp(context,'ClassDiagramView')
                    subtype='RootArchitectureType';
                    obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(subtype,uuid,appName,options,true);
                else
                    obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(type,uuid,appName,options,true);
                end
            end

            if strcmp(context,'Allocation')
                appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
                allocationSet=appCatalog.getAllocationSet(appName);
                allocElement=mf.zero.getModel(allocationSet).findElement(uuid);
                type=systemcomposer.internal.propertyInspector.getElemType(allocElement);
                obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(type,uuid,appName,options);
            end
            if strcmp(context,'Profile')
                profile=systemcomposer.internal.profile.Profile.findLoadedProfile(appName);
                element=mf.zero.getModel(profile).findElement(uuid);
                type=systemcomposer.internal.propertyInspector.getElemType(element);
                obj=systemcomposer.internal.propertyInspector.getElementWrapperFromType(type,uuid,appName,options);
            end
        end
        function selectedLine=getSelectedLineFromConnectors(selectedLines)
            segsChildren=get_param(selectedLines,'LineChildren');
            idxValidZcConn=cellfun(@isempty,segsChildren);
            selectedLine=selectedLines(idxValidZcConn);
        end
        function[isSelected,selectedLine]=DestinationPortConnector(inputHandleObject)
            if~isempty(inputHandleObject.SignalObjectClass)
                selectedLine=find_system(inputHandleObject.Parent,...
                'searchdepth',1,'followlinks','off','findall','on',...
                'lookundermasks','off','type','line','selected','on');
            else
                selectedLine=cell(0,1);
            end
            if numel(selectedLine)==1
                isSelected=true;
            else
                isSelected=false;

            end
        end
    end

    methods
        function editor=getLastActiveEditor(~)
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            editor=[];
            if(~isempty(studios))
                studio=studios(1);
                studioApp=studio.App;
                editor=studioApp.getActiveEditor;
            end
        end
    end
end


