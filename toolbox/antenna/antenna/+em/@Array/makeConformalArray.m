function makeConformalArray(obj)




    if iscell(obj.Element)
        tempElement=makeTemporaryElementCacheForConformal(obj,size(obj.FeedLocation,1));
    else
        tempElement=makeTemporaryElementCacheForConformal(obj,size(obj.ElementPosition,1));
    end

    numelements=numel(tempElement);
    if iscell(obj.Reference)
        tempReference=obj.Reference;
    else
        tempReference=repmat({obj.Reference},1,numelements);
    end


    cellfun(@createGeometry,tempElement,'UniformOutput',false);
    temp=cellfun(@getGeometry,tempElement,'UniformOutput',false);
    pcbIdx=cell2mat(cellfun(@(x)isa(x,'pcbStack'),tempElement,'UniformOutput',false));
    pcbIndex=find(pcbIdx);
    for i=1:numel(pcbIndex)
        temp{pcbIndex(i)}=assemblePCBGeom(temp{pcbIndex(i)});
    end
    feedWidths=cellfun(@getFeedWidth,tempElement,'UniformOutput',false);
    if any(iscell(feedWidths))
        feedwidth=cell2mat(feedWidths);
        feedWidths=feedwidth(:);
    end



    isSubstrate=cellfun(@(x)isprop(x,'Substrate')&&...
    ~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),...
    tempElement,'UniformOutput',false);
    for i=1:numel(tempElement)
        if isprop(tempElement{i},'Element')
            isaBackingStructureAntenna(i)=isa(tempElement{i}.Element,'em.BackingStructure');
        else
            isaBackingStructureAntenna(i)=isa(tempElement{i},'em.BackingStructure');
        end
    end



    id=find(isaBackingStructureAntenna);
    if~isempty(id)
        for i=1:numel(id)
            if isprop(tempElement{id(i)},'Element')
                tempofTempElem{i}=tempElement{id(i)}.Element.Exciter;
            else
                tempofTempElem{i}=tempElement{id(i)}.Exciter;
            end
        end
        isExciterSubstrate=cellfun(@(x)isprop(x,'Substrate')&&...
        ~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),...
        tempofTempElem,'UniformOutput',false);
        s=cell2mat(isExciterSubstrate);
        for i=1:numel(id)
            if s(i)==1
                isSubstrate{id(i)}=true;
            end
        end
    end
    isSubstrate=cell2mat(isSubstrate);
    maxFeatureSize=nan;

    elementTilt=nan(numelements,1);





    for i=1:numelements
        maxFeatureSize=max(temp{i}.MaxFeatureSize,maxFeatureSize);
        elementFeedLoc{i,:}=tempElement{i}.FeedLocation;
    end




    dist=sqrt((obj.ElementPosition(:,1)).^2+...
    (obj.ElementPosition(:,2)).^2+...
    (obj.ElementPosition(:,3)).^2);
    [~,distIndx]=sort(dist,'descend');
    feature_size=norm(obj.ElementPosition(distIndx(1),:)-obj.ElementPosition(distIndx(2),:));

    translateVector=obj.TranslationVector;
    for i=1:numel(tempElement)
        if isprop(tempElement{i},'Element')
            isaBackingStructureAntenna(i)=isa(tempElement{i}.Element,'em.BackingStructure');
        else
            isaBackingStructureAntenna(i)=isa(tempElement{i},'em.BackingStructure');
        end
    end



    if any(isaBackingStructureAntenna)
        isProbeFeedEnabled=cellfun(@(x)isprop(x,'EnableProbeFeed')&&isequal(x.('EnableProbeFeed'),1),tempElement);
        if any(isProbeFeedEnabled)
            isaBackingStructureAntenna=~isaBackingStructureAntenna;
        end
    end


    infgndstatus=cellfun(@getInfGPState,tempElement);

    if any(isaBackingStructureAntenna)
        temp=assembleArrayGeomWithBacking(obj,temp,translateVector,numelements,...
        isaBackingStructureAntenna,tempReference,isSubstrate,(infgndstatus));
    else
        temp=assembleArrayGeom(obj,temp,translateVector,numelements,isSubstrate);
    end


    setFeedWidth(obj,feedWidths);
    obj.MesherStruct.Geometry=temp;








end

function tmpgeom=assemblePCBGeom(pcbgeomcellarray)
    geomVal=pcbgeomcellarray';
    tmpgeom=[];
    tmpgeom.BorderVertices=geomVal{1}.BorderVertices;
    tmpgeom.polygons=geomVal{1}.polygons;
    tmpgeom.BoundaryEdges=geomVal{1}.BoundaryEdges;
    tmpgeom.doNotPlot=geomVal{1}.doNotPlot;
    tmpgeom.MaxFeatureSize=geomVal{1}.MaxFeatureSize;
    tmpgeom.SubstrateVertices=geomVal{1}.SubstrateVertices;
    tmpgeom.SubstratePolygons=geomVal{1}.SubstratePolygons;
    for i=2:numel(geomVal)
        offsetVal=size(tmpgeom.BorderVertices,1);
        offsetSubstrateVal=size(tmpgeom.SubstrateVertices,1);
        tmpgeom.BorderVertices=[tmpgeom.BorderVertices;geomVal{i}.BorderVertices];
        tmpgeom.polygons{1}=[tmpgeom.polygons{1};geomVal{i}.polygons{1}+offsetVal];

        tmpgeom.BoundaryEdges=[tmpgeom.BoundaryEdges,{geomVal{i}.BoundaryEdges{1}+offsetVal}];

        tmpgeom.MaxFeatureSize=max(tmpgeom.MaxFeatureSize,geomVal{i}.MaxFeatureSize);
    end
end


function temp=assembleArrayGeom(obj,temp,translateVector,numelements,isSubstrate)
    for i=1:numelements
        temp{i}.BorderVertices=positionTheGeometry(obj,temp{i}.BorderVertices',translateVector(i,:))';
        if isSubstrate(i)
            temp{i}.SubstrateVertices=positionTheGeometry(obj,temp{i}.SubstrateVertices',translateVector(i,:))';
        end
        if numel(obj.Element)>1&&iscell(obj.Element)
            if isa(obj.Element{i},'draCylindrical')||(isa(obj.Element{i},'em.HelixAntenna')&&isDielectricSubstrate(obj.Element{i}))
                temp{i}.SubstrateBoundaryVertices=positionTheGeometry(obj,temp{i}.SubstrateBoundaryVertices',translateVector(i,:))';
            end
        elseif numel(obj.Element)==1&&(isa(obj.Element,'draCylindrical')||(isa(obj.Element,'em.HelixAntenna')&&isDielectricSubstrate(obj.Element)))
            temp{i}.SubstrateBoundaryVertices=positionTheGeometry(obj,temp{i}.SubstrateBoundaryVertices',translateVector(i,:))';
        elseif numel(obj.Element)>1&&(isa(obj.Element(i),'draCylindrical')||(isa(obj.Element(i),'em.HelixAntenna')&&isDielectricSubstrate(obj.Element(i))))
            temp{i}.SubstrateBoundaryVertices=positionTheGeometry(obj,temp{i}.SubstrateBoundaryVertices',translateVector(i,:))';
        end

    end
end

function temp=assembleArrayGeomWithBacking(obj,temp,translateVector,numelements,...
    isabacking,tempref,isSubstrate,hasinfGP)
    for i=1:numelements
        if isabacking(i)
            if strcmpi(tempref{i},'feed')
                nongpid=extractNonGndPolyId(temp{i},hasinfGP(i));
                temp{i}.BorderVertices(nongpid,:)=positionTheGeometry(obj,temp{i}.BorderVertices(nongpid,:)',translateVector(i,:))';
            else
                temp{i}.BorderVertices=positionTheGeometry(obj,temp{i}.BorderVertices',translateVector(i,:))';
            end
        else
            temp{i}.BorderVertices=positionTheGeometry(obj,temp{i}.BorderVertices',translateVector(i,:))';
        end
        if isSubstrate(i)
            temp{i}.SubstrateVertices=positionTheGeometry(obj,temp{i}.SubstrateVertices',translateVector(i,:))';
        end
    end

end

function newvertices=positionTheGeometry(obj,vertices,tvec)

    newvertices=em.internal.translateshape(vertices,tvec);
    newvertices=orientGeom(obj,newvertices);

end

function nongpid=extractNonGndPolyId(geom,hasinfGP)
    nongpid=[];
    if~hasinfGP
        startid=2;
    else
        startid=1;
    end
    for i=startid:numel(geom.polygons)
        tempid=cell2mat(geom.polygons(i));
        tempid=tempid(:);
        nongpid=[nongpid;tempid];%#ok<AGROW> 
    end

end
