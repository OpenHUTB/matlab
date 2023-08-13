function str=lanespecToString(ls)

    str="";
    isMultiLanespec=false;
    laneSpec=ls;

    if~isa(ls,'lanespec')
        lanespecStringArray="[";
        laneSpec=ls.LaneSpecification;
        isMultiLanespec=true;
    end
    for lsndx=1:length(laneSpec)
        if lsndx>1
            lanespecStringArray=lanespecStringArray+newline;
        end
        numLanes=laneSpec(lsndx).NumLanes;
        laneWidth=laneSpec(lsndx).Width;
        marking=laneSpec(lsndx).Marking;
        laneType=laneSpec(lsndx).Type;

        lanespecArgs="";

        if~all(laneWidth==lanespec.DefaultWidth)

            if all(laneWidth==laneWidth(1))
                laneWidth=laneWidth(1);
            end
            lanespecArgs=lanespecArgs+', ''Width'', '+mat2str(laneWidth);
        end

        prototypeLanesObj=lanespec(numLanes);
        if~isequal(marking,prototypeLanesObj.Marking)

            isSameMarking=true;
            for kndx=2:length(marking)
                if~isequal(marking(1),marking(kndx))
                    isSameMarking=false;
                    break;
                end
            end
            if isSameMarking
                marking=marking(1);
            end
            numMarkings=length(marking);



            markingString="";
            if numMarkings>1
                markingString="[";
            end
            for kndx=1:numMarkings
                if~isa(marking(kndx),'driving.scenario.CompositeMarking')
                    multipleMarkings=length(marking(kndx));
                else
                    multipleMarkings=length(marking(kndx).Markings);
                end
                if kndx>1
                    markingString=markingString+newline;
                end

                if multipleMarkings>1
                    markingString=markingString+"laneMarking"+"("+"[";
                end
                for cndx=1:multipleMarkings
                    if cndx>1
                        markingString=markingString+' ';
                    end

                    markingArgs="";
                    if~isa(marking(kndx),'driving.scenario.CompositeMarking')
                        currentMarking=marking(kndx);
                    else
                        currentMarking=marking(kndx).Markings(cndx);
                    end

                    if isprop(currentMarking,'Color')&&~isequal(currentMarking.Color,currentMarking.DefaultColor)
                        markingArgs=markingArgs+', ''Color'', '+mat2str(currentMarking.Color);
                    end

                    if isprop(currentMarking,'Width')&&~isequal(currentMarking.Width,currentMarking.DefaultWidth)
                        markingArgs=markingArgs+', ''Width'', '+mat2str(currentMarking.Width);
                    end

                    if isprop(currentMarking,'Strength')&&~isequal(currentMarking.Strength,currentMarking.DefaultStrength)
                        markingArgs=markingArgs+', ''Strength'', '+mat2str(currentMarking.Strength);
                    end

                    if isprop(currentMarking,'Length')&&~isequal(currentMarking.Length,currentMarking.DefaultLength)
                        markingArgs=markingArgs+', ''Length'', '+mat2str(currentMarking.Length);
                    end

                    if isprop(currentMarking,'Space')&&~isequal(currentMarking.Space,currentMarking.DefaultSpace)
                        markingArgs=markingArgs+', ''Space'', '+mat2str(currentMarking.Space);
                    end
                    markingString=markingString+sprintf('laneMarking(''%s''%s)',...
                    currentMarking.Type,markingArgs);
                end

                if multipleMarkings>1
                    markingString=markingString+"]"+', ''SegmentRange'', '+mat2str(marking(kndx).SegmentRange)+")";
                end
            end

            if numMarkings>1
                markingString=markingString+"]";
            end
            if~isMultiLanespec

                str=str+'marking = '+markingString+';'+newline;
                lanespecArgs=lanespecArgs+', ''Marking'', marking';
            else

                str=str+'marking'+lsndx+' = '+markingString+';'+newline;
                lanespecArgs=lanespecArgs+', ''Marking'', marking'+lsndx;
            end
        end

        if~isempty(laneSpec(lsndx).Type)
            if~isequal(laneSpec(lsndx).Type,prototypeLanesObj.Type)
                numlaneType=length(laneSpec(lsndx).Type);
                laneTypeString="";
                if numlaneType>1
                    laneTypeString="[";
                end
                for kndx=1:numlaneType
                    if kndx>1
                        laneTypeString=laneTypeString+newline;
                    end

                    laneTypeArgs="";
                    currentLaneType=laneType(kndx);
                    switch(currentLaneType.Type)
                    case LaneTypes.Driving
                        laneTypeArgs=strcat(laneTypeArgs,getLaneArgs(currentLaneType,...
                        driving.scenario.DrivingLaneType.DefaultColor,driving.scenario.LaneType.DefaultStrength));
                    case LaneTypes.Parking
                        laneTypeArgs=strcat(laneTypeArgs,getLaneArgs(currentLaneType,...
                        driving.scenario.ParkingLaneType.DefaultColor,driving.scenario.LaneType.DefaultStrength));
                    case LaneTypes.Border
                        laneTypeArgs=strcat(laneTypeArgs,getLaneArgs(currentLaneType,...
                        driving.scenario.BorderLaneType.DefaultColor,driving.scenario.LaneType.DefaultStrength));
                    case LaneTypes.Shoulder
                        laneTypeArgs=strcat(laneTypeArgs,getLaneArgs(currentLaneType,...
                        driving.scenario.ShoulderLaneType.DefaultColor,driving.scenario.LaneType.DefaultStrength));
                    case LaneTypes.Restricted
                        laneTypeArgs=strcat(laneTypeArgs,getLaneArgs(currentLaneType,...
                        driving.scenario.RestrictedLaneType.DefaultColor,driving.scenario.LaneType.DefaultStrength));
                    end
                    laneTypeString=laneTypeString+sprintf('laneType(''%s''%s)',...
                    currentLaneType.Type,laneTypeArgs);
                end

                if numlaneType>1
                    laneTypeString=laneTypeString+"]";
                end
                if~isMultiLanespec
                    str=str+'lanetypes = '+laneTypeString+';'+newline;
                    lanespecArgs=lanespecArgs+', ''Type'', lanetypes';
                else
                    str=str+'lanetypes'+lsndx+' = '+laneTypeString+';'+newline;
                    lanespecArgs=lanespecArgs+', ''Type'', lanetypes'+lsndx;
                end
            end
        end

        if~isMultiLanespec

            lanespecString=sprintf('lanespec(%s%s);',mat2str(numLanes),lanespecArgs);
            str=str+'laneSpecification = '+lanespecString;
        else

            lanespecString=sprintf('lanespec(%s%s)',mat2str(numLanes),lanespecArgs);
            lanespecStringArray=lanespecStringArray+lanespecString;
            if~strcmp(str,"")
                str=str+newline;
            end
        end
    end

    if isMultiLanespec
        compositeArgs="";
        compositeString="";
        lanespecStringArray=lanespecStringArray+"]";

        str=str+'laneSpecifications = '+lanespecStringArray+';'+newline;

        connectors=ls.Connector;
        prototypecompLaneSpecObj=compositeLaneSpec(laneSpec);
        if~isequal(connectors,prototypecompLaneSpecObj.Connector)

            isSameConnector=true;
            for kndx=2:length(connectors)
                if~isequal(connectors(1),connectors(kndx))
                    isSameConnector=false;
                    break;
                end
            end
            if isSameConnector
                connectors=connectors(1);
            end
            connectorString="";
            numConnectors=length(connectors);
            if numConnectors>1
                connectorString="[";
            end
            for cndx=1:numConnectors
                connectorArgs="";
                if cndx>1
                    connectorString=connectorString+newline;
                end
                currentConnector=connectors(cndx);
                if~isequal(ConnectorPosition(currentConnector.Position),currentConnector.DefaultPosition)
                    connectorArgs=connectorArgs+'''Position'', '+mat2str(currentConnector.Position.char);
                end
                if~isequal(ConnectorTaperShape(currentConnector.TaperShape),currentConnector.DefaultTaperShape)
                    if~strlength(connectorArgs)==0
                        connectorArgs=connectorArgs+', ';
                    end
                    connectorArgs=connectorArgs+'''TaperShape'', '+mat2str(currentConnector.TaperShape.char);
                end
                if~isequal(currentConnector.TaperLength,currentConnector.DefaultTaperLength)&&isequal(ConnectorTaperShape(currentConnector.TaperShape),currentConnector.DefaultTaperShape)
                    if~strlength(connectorArgs)==0
                        connectorArgs=connectorArgs+', ';
                    end
                    connectorArgs=connectorArgs+'''TaperLength'', '+mat2str(currentConnector.TaperLength);
                end
                connectorString=connectorString+sprintf('laneSpecConnector(%s)',connectorArgs);
            end
            if length(connectors)>1
                connectorString=connectorString+"]";
            end
            str=str+'lsConnector = '+connectorString+';'+newline;
            compositeArgs=compositeArgs+', ''Connector'', lsConnector';
        end

        segmentRange=ls.SegmentRange;
        if~isequal(segmentRange,prototypecompLaneSpecObj.SegmentRange)
            compositeArgs=compositeArgs+', ''SegmentRange'', '+mat2str(segmentRange);
        end
        compositeString=compositeString+sprintf('compositeLaneSpec(%s%s);','laneSpecifications'+compositeArgs);
        str=str+'compLaneSpecification = '+compositeString+');';
    end
end

function laneTypeArgs=getLaneArgs(laneType,defaultColor,defaultStrength)
    laneTypeArgs="";

    if~isequal(laneType.Color,defaultColor)
        laneTypeArgs=laneTypeArgs+', ''Color'', '+mat2str(laneType.Color);
    end

    if~isequal(laneType.Strength,defaultStrength)
        laneTypeArgs=laneTypeArgs+', ''Strength'', '+mat2str(laneType.Strength);
    end
end
