function makeHomogeneousArray(obj)

    if getHasStructureChanged(obj)

        clearGeometryData(obj);
    end
    if any(strcmpi(class(obj.Element),{'linearArray','rectangularArray'}))
        sub_array=em.Array.makeSubArray(obj);
        tempElement=makeTemporaryElementCacheForConformal(sub_array,size(sub_array.FeedLocation,1));
        cellfun(@createGeometry,tempElement,'UniformOutput',false);
        temp=cellfun(@getGeometry,tempElement,'UniformOutput',false);%#ok<NASGU>
        feedWidths=cellfun(@getFeedWidth,tempElement,'UniformOutput',false);
        if any(iscell(feedWidths))
            feedwidth=cell2mat(feedWidths);
            feedWidths=feedwidth(:);
        end
        obj.MesherStruct.Mesh.FeedWidth=feedWidths;
        obj.MesherStruct.Geometry=getGeometry(sub_array);
        obj.TranslationVector=sub_array.TranslationVector;
        return
    end


    createGeometry(obj.Element);
    temp=getGeometry(obj.Element);
    if~any(strcmpi(class(obj.Element),{'dipoleCrossed','conformalArray'}))
        maxFeatureSize=temp.MaxFeatureSize;
        cross_present=0;
    else
        maxFeatureSize=temp{1,1}.MaxFeatureSize;
        cross_present=1;
    end
    offset=0;


    dynamicPropState=getDynamicPropertyState(obj);
    if dynamicPropState
        if~isequal(obj.Element.Tilt,0)
            error(message('antenna:antennaerrors:Unsupported',...
            'Non-zero Tilt for Elements with Groundplane',class(obj)));
        end
        ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
        (isequal(obj.GroundPlaneWidth,0));


        if ZeroGPState&&isArrayOnDielectricSubstrate(obj)

            if~isequal(obj.Element.Tilt,0)
                error(message('antenna:antennaerrors:Unsupported',...
                'Tilt on elements with substrate and no groundplane','arrays'));
            end
        end


        if ZeroGPState
            dynamicPropState=~dynamicPropState;
        end
    end



    if dynamicPropState&&~(getInfGPState(obj.Element))

        if~isequal(obj.Element.Tilt,0)
            error(message('antenna:antennaerrors:Unsupported',...
            'Tilt on elements with groundplane','arrays'));
        end

        numGPPoints=max(max(temp.BoundaryEdges{1}));
        temp.BorderVertices(1:numGPPoints,:)=[];

        offset=4;
        if numel(temp.BoundaryEdges{1})>4
            if~isa(obj.Element,'reflectorCircular')
                temp.BoundaryEdges{2}=temp.BoundaryEdges{2}-...
                numel(temp.BoundaryEdges{1})+4;
                temp.BoundaryEdges=temp.BoundaryEdges(2);
            else
                offset=numGPPoints;
            end
        end



        if numel(temp.BoundaryEdges)>=2
            temp.BoundaryEdges=temp.BoundaryEdges(2:end);
        end
        if numel(temp.polygons)==1
            temppoly=temp.polygons{1};
            idx=ceil(find(temppoly'==numGPPoints,1,'last')/3);
            temppoly(1:idx,:)=[];
            temppoly=temppoly-numGPPoints+offset;
            temp.polygons={temppoly};
        else
            temppoly=temp.polygons(2:end);
            temppoly=cellfun(@(x)x-numGPPoints+offset,temppoly,...
            'UniformOutput',false);
            temp.polygons=temppoly;
        end
    end


    if isa(obj,'linearArray')
        checkLinearArrayParameters(obj);
        numFeeds=obj.NumElements;
        feature_size=max(cumsum(obj.ElementSpacing));
    elseif isa(obj,'rectangularArray')
        checkRectangularArrayParameters(obj);
        numFeeds=prod(obj.Size);
        feature_size=max(cumsum(obj.RowSpacing));
    elseif isa(obj,'circularArray')
        checkCircularArrayParameters(obj);
        numFeeds=obj.NumElements;
        feature_size=max(obj.Radius);
    end


    temp=obj.copystruct(temp,numFeeds);
    feedWidths=getFeedWidth(obj.Element).*ones(1,numFeeds);
    obj.TranslationVector=obj.DefaultFeedLocation-...
    repmat(obj.Element.FeedLocation,numFeeds,1);
    if cross_present==0
        if isprop(obj.Element,'Exciter')&&...
            strcmpi(class(obj.Element.Exciter),'dipoleCrossed')
            flag=1;
            [BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
            em.ArrayProp.makeArrayGeometryForConformalArray(temp,...
            obj.TranslationVector,offset,getInfGPState(obj.Element),flag);
        else
            [BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
            em.ArrayProp.makeArrayGeometry(temp,obj.TranslationVector,...
            offset,getInfGPState(obj.Element));
        end
    else
        [BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
        em.ArrayProp.makeArrayGeometryForConformalArray(temp,...
        obj.TranslationVector,offset,getInfGPState(obj.Element));
    end
    if strcmpi(class(obj.Element),'dipoleHelixMultifilar')
        DoNotPlot=zeros(1,numel(Polygons));
    end

    if dynamicPropState
        if~getInfGPState(obj.Element)

            [pointsGP,maxFeatureSize,poly,boundary]=makeGroundPlane(obj);
            BorderVertices=[pointsGP';BorderVertices];
            Polygons=[{poly},Polygons(:)'];
            DoNotPlot=[0,DoNotPlot];
            feature_size=max(feature_size,maxFeatureSize);
            BoundaryEdges=[{boundary},BoundaryEdges];
            setInfGPState(obj,false);
        else
            feature_size=max(obj.TotalArraySpacing)+maxFeatureSize;
            setInfGPState(obj,true);
        end
        bool=getInfGPConnState(obj.Element);
        setInfGPConnState(obj,bool);
    end

    MaxFeatureSize=feature_size;
    setFeedWidth(obj,feedWidths);


    BorderVertices=orientGeom(obj,BorderVertices.');
    BorderVertices=BorderVertices.';


    saveGeometry(obj,BorderVertices,Polygons,DoNotPlot,MaxFeatureSize,BoundaryEdges);

end