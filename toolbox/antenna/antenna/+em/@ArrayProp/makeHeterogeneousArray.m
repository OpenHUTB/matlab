function makeHeterogeneousArray(obj)




    if getHasStructureChanged(obj)

        clearGeometryData(obj);
    end


















    arrayfun(@createGeometry,obj.Element,'UniformOutput',false);
    temp=arrayfun(@getGeometry,obj.Element,'UniformOutput',false);
    maxFeatureSize=nan;
    numelements=numel(obj.Element);
    elementFeedLoc=nan(numelements,3);
    elementTilt=[];
    for i=1:numelements
        maxFeatureSize=max(temp{i}.MaxFeatureSize,maxFeatureSize);
        elementFeedLoc(i,:)=obj.Element(i).FeedLocation;

        tempTilt=obj.Element(i).Tilt;
        if isrow(tempTilt)
            tempTilt=tempTilt';
        end
        elementTilt=[elementTilt;tempTilt];
    end

    feedWidths=arrayfun(@getFeedWidth,obj.Element);
    feedWidths=feedWidths(:);
    offset=0;


    dynamicPropState=getDynamicPropertyState(obj);

    if dynamicPropState
        if~isequal(obj.Element.Tilt,0)
            error(message('antenna:antennaerrors:Unsupported',...
            'Non-zero Tilt for Elements with Groundplane',class(obj)));
        end
        propNames=properties(obj.Element);
        gndPropLocId=strfind(propNames,'Ground');
        gndPropLocId=~cellfun(@isempty,gndPropLocId);
        gndProp=propNames(gndPropLocId);
        for i=1:numel(gndProp)
            gndVals=cell(1,numelements);
            [gndVals{1:end}]=deal(obj.Element.(gndProp{i}));
            gndVals=cell2mat(gndVals);
            isGndPlaneIdentical=isequal(gndVals(1:end-1),gndVals(2:end));
            if~isGndPlaneIdentical
                error(message('antenna:antennaerrors:Disallowed','Dissimilar Groundplanes','in arrays'));
            end
        end
        ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
        (isequal(obj.GroundPlaneWidth,0));


        if ZeroGPState&&isArrayOnDielectricSubstrate(obj)

            isElementTiltEqual=isequal(elementTilt(1:end-1,:),elementTilt(2:end,:));

            if~isElementTiltEqual
                error(message('antenna:antennaerrors:Unsupported','Tilt on elements with substrate and no groundplane','arrays'));
            end
        end


        if ZeroGPState
            dynamicPropState=~dynamicPropState;
        end

    end


    infGPState=arrayfun(@getInfGPState,obj.Element);
    if dynamicPropState&&~any(any(infGPState))


        isElementTiltEqual=isequal(elementTilt(1:end-1,:),elementTilt(2:end,:));

        if~isElementTiltEqual
            error(message('antenna:antennaerrors:Unsupported','Tilt on elements with groundplane','arrays'));
        end

        for i=1:numelements
            if~infGPState(i)
                numGPPoints=max(size(temp{i}.BoundaryEdges{1}));
                temp{i}.BorderVertices(1:numGPPoints,:)=[];

                offset=4;
                if numel(temp{i}.BoundaryEdges{1})>4
                    if~isa(obj.Element(i),'reflectorCircular')
                        temp{i}.BoundaryEdges{2}=temp{i}.BoundaryEdges{2}-...
                        numel(temp{i}.BoundaryEdges{1})+4;
                        temp{i}.BoundaryEdges=temp{i}.BoundaryEdges(2);
                    else
                        offset=numGPPoints;
                    end
                end



                if numel(temp{i}.BoundaryEdges)>=2
                    temp{i}.BoundaryEdges=temp{i}.BoundaryEdges(2:end);
                end

                if numel(temp{i}.polygons)==1
                    temppoly=temp{i}.polygons{1};
                    idx=ceil(find(temppoly'==numGPPoints,1,'last')/3);
                    temppoly(1:idx,:)=[];
                    temppoly=temppoly-numGPPoints+offset;
                    temp{i}.polygons={temppoly};
                else
                    temppoly=temp{i}.polygons(2:end);
                    temppoly=cellfun(@(x)x-numGPPoints+offset,...
                    temppoly,'UniformOutput',false);
                    temp{i}.polygons=temppoly;
                end
            end
        end
    end


    if isa(obj,'linearArray')
        checkLinearArrayParameters(obj);
        feature_size=max(cumsum(obj.ElementSpacing));
    elseif isa(obj,'rectangularArray')
        checkRectangularArrayParameters(obj);
        feature_size=max(cumsum(obj.RowSpacing));
    elseif isa(obj,'circularArray')
        feature_size=obj.Radius;
    end

    obj.TranslationVector=obj.DefaultFeedLocation-elementFeedLoc;
    [BorderVertices,Polygons,DoNotPlot,BoundaryEdges]=...
    em.Array.makeArrayGeometry(temp,obj.TranslationVector,offset,0);



    if dynamicPropState
        infGPState=zeros(numelements,1);
        bool=cell(numelements,1);
        for i=1:numel(obj.Element)
            infGPState(i)=getInfGPState(obj.Element(i));
            bool{i}=getInfGPConnState(obj.Element(i));
        end
        if any(infGPState)
            infGPState=1;
        else
            infGPState=0;
        end

        if any(cell2mat(bool))
            bool=1;
        else
            bool=0;
        end
        if~infGPState

            [pointsGP,maxFeatureSize,poly,boundary]=makeGroundPlane(obj);
            BorderVertices=[pointsGP';BorderVertices];
            Polygons=[{poly},Polygons];
            DoNotPlot=[0,DoNotPlot];
            feature_size=max(feature_size,maxFeatureSize);
            BoundaryEdges=[{boundary},BoundaryEdges];
            setInfGPState(obj,false);
        else
            feature_size=max(obj.TotalArraySpacing)+maxFeatureSize;
            setInfGPState(obj,true);
        end

        setInfGPConnState(obj,bool);
    end

    MaxFeatureSize=feature_size;
    setFeedWidth(obj,feedWidths);


    BorderVertices=orientGeom(obj,BorderVertices.');
    BorderVertices=BorderVertices.';


    saveGeometry(obj,BorderVertices,Polygons,DoNotPlot,MaxFeatureSize,BoundaryEdges);


end
