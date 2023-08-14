function updatePIInStudio(varargin)



    if(nargin<2)
        return;
    end

    modelName=varargin{1};
    diagramUuid=varargin{2};
    if(nargin>=3)
        studioTag=varargin{3};
        studios=DAS.Studio.getStudio(studioTag);
    else
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    end

    if~isempty(studios)
        activeStudio=studios(1,1);
        pi=activeStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');


        if(nargin==4&&~isempty(varargin{4}))
            elementData=varargin{4};
            if isstruct(elementData)&&isfield(elementData,'type')&&strcmp(elementData.type,'hierarchyConnection')
                obj=ZCStudio.HierarchyConnectorObject(elementData.data);
                pi.updateSource('GLUE2:PropertyInspector',obj);
                return;
            end
        end

        semElem=systemcomposer.internal.getArchitectureElementFromDiagram(modelName,diagramUuid);
        if~isempty(semElem)
            if semElem.StaticMetaClass.isA(systemcomposer.architecture.model.design.ComponentPort.StaticMetaClass)

                semElem=semElem.getArchitecturePort;
            end

            if semElem.StaticMetaClass.isA(systemcomposer.architecture.model.design.Architecture.StaticMetaClass)
                topLevelCompArch=semElem.getTopLevelArchitecture;
                slBlkH=get_param(topLevelCompArch.getName,'Handle');
            else
                slBlkH=systemcomposer.utils.getSimulinkPeer(semElem);
            end
            slBlk=get_param(slBlkH(1),'Object');
            pi.updateSource('GLUE2:PropertyInspector',slBlk);
        end
    end

end