classdef LanesWidgets<driving.internal.scenarioApp.UITools

    properties

        ShowLanes=false

        ShowMarking=false
        SelectedLane=1
        SelectedMarking=1
        ShowLaneTypes=false
        SelectedType=1
        MultiIndex=1;
        SelectedMultiMarking=1;
        MarkerRange;
        MultipleChecked=false;
hMarkerSelectionCheckbox
        MultipleCheckedState=false;

        MultiLaneSpecs=false;
        ShowLaneConnector=false;
        RoadSegmentRange;
        RoadSegments;
        SelectedRoadSegment=1
        SelectedConnector=1
    end

    properties(Hidden)

hLanePicker
hShowLanes
hLanesPanel
LanesLayout
hNumLanes
hLaneWidth
hShowMarking
hMarkingPanel
MarkingLayout
hSelectedLane
hSelectedMarking
hMarkingType
hMarkingColor
hMarkingStrength
hMarkingWidth
hMarkingLength
hMarkingSpace

hShowLaneTypes
hLaneTypePanel
LaneTypeLayout
hSelectedType
hLaneType
hLaneTypeColor
hLaneTypeStrength

hNumMarkings
hMarkerSegments
hSegmentRange
hMarkerRange
        numMarkings;
hMultipleMarkingPanel
MultipleMarkingLayout


hNumRoadSegments
hRoadSegmentRange
hRoadSegments
hSegmentsPanel
SegmentsLayout
        numRoadSegments=1;

hShowLaneConnector
hSelectedConnector
hConnectorPosition
hConnectorShape
hConnectorLength
hConnectorPanel
ConnectorLayout


        BoundaryTypes=LaneBoundaryType(["Unmarked","Solid","Dashed",...
        "DoubleSolid","DoubleDashed","SolidDashed","DashedSolid"])
        BoundaryStrings=[string(getString(message('driving:scenarioApp:MarkingTypeUnmarked'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeSolid'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDoubleSolid'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDoubleDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeSolidDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDashedSolid')))]

        tLaneTypes=LaneTypes(["Driving","Parking","Border","Shoulder","Restricted"]);
        LaneTypeStrings=[string(getString(message('driving:scenarioApp:LaneTypeDriving'))),...
        string(getString(message('driving:scenarioApp:LaneTypeParking'))),...
        string(getString(message('driving:scenarioApp:LaneTypeBorder'))),...
        string(getString(message('driving:scenarioApp:LaneTypeShoulder'))),...
        string(getString(message('driving:scenarioApp:LaneTypeRestricted')))]

        lPositions=ConnectorPosition(["Right","Left","Both"])
        lPositionStrings=[string(getString(message('driving:scenarioApp:PositionRight'))),...
        string(getString(message('driving:scenarioApp:PositionLeft'))),...
        string(getString(message('driving:scenarioApp:PositionBoth')))]
        lShape=ConnectorTaperShape(["Linear","None"])
        lShapeStrings=[string(getString(message('driving:scenarioApp:ShapeLinear'))),...
        string(getString(message('driving:scenarioApp:ShapeNone')))]
    end

    methods
        function update(this,road)
            if nargin<2
                road=getSpecification(this);
            end
            if isempty(road)
                set([this.hNumLanes,this.hLaneWidth,this.hMarkingColor...
                ,this.hMarkingStrength,this.hMarkingWidth,this.hMarkingLength...
                ,this.hMarkingSpace,this.hLaneTypeColor,this.hLaneTypeStrength],...
                'String','','Enable','off');
                set([this.hSelectedMarking,this.hMarkingType,this.hSelectedType...
                ,this.hLaneType,this.hNumMarkings,this.hMarkerRange,this.hMarkerSegments],'Enable',...
                'off','String',{''},'Value',1);
                set([this.hNumRoadSegments,this.hRoadSegmentRange...
                ,this.hConnectorLength],'String','','Enable','off');
                set([this.hRoadSegments,this.hSelectedConnector...
                ,this.hConnectorPosition,this.hConnectorShape],'Enable',...
                'off','String',{''},'Value',1);
                set(this.hShowLaneConnector,'Visible','off');
                set(this.hSelectedConnector,'Visible','off');
                this.hMarkerSelectionCheckbox.Value=0;
                set(this.hMarkerSelectionCheckbox,'Enable','off');
                this.MultipleChecked=false;
                this.MultiLaneSpecs=false;
                this.SelectedRoadSegment=1;
                this.SelectedConnector=1;
                this.SelectedType=1;
                this.SelectedLane=1;
                this.SelectedMarking=1;
                this.SelectedMultiMarking=1;
                updateLayout(this);
                return;
            end
            laneSpec=getLaneSpecification(this);
            if~isa(laneSpec,'compositeLaneSpec')
                this.MultiLaneSpecs=false;
                this.numRoadSegments=1;
                updateLaneSections(this,laneSpec);
                updateLayout(this);
            else
                SegmentSuffix=string(getString(message('driving:scenarioApp:SegmentSuffix')));
                ConnectorSuffix=string(getString(message('driving:scenarioApp:ConnectorSuffix')));
                SegmentRangePrefix=string(getString(message('driving:scenarioApp:SegmentRangePrefix')));
                nRoadSegments=(numel(laneSpec.LaneSpecification));
                roadSegmentRanges=mat2str(laneSpec.SegmentRange);
                this.RoadSegmentRange=laneSpec.SegmentRange;
                this.MultiLaneSpecs=true;
                this.numRoadSegments=nRoadSegments;
                roadSegmentNames=strings(1,nRoadSegments);

                roadSegmentIndex=this.SelectedRoadSegment;
                ls=laneSpec.LaneSpecification(roadSegmentIndex);

                updateLaneSections(this,ls);
                laneSpecData=laneSpec.LaneSpecification;

                conIndex=this.SelectedConnector;
                currentNumLanes=laneSpecData(conIndex).NumLanes;
                nextNumLanes=laneSpecData(conIndex+1).NumLanes;
                currentLaneSpecWidth=sum(laneSpecData(conIndex).Width);
                nextLaneSpecWidth=sum(laneSpecData(conIndex+1).Width);
                conPositionVisible='on';
                conShapeEnable='on';

                if isscalar(currentNumLanes)&&isscalar(nextNumLanes)
                    if(isempty(laneSpec.Connector(conIndex).Position))||(currentLaneSpecWidth==nextLaneSpecWidth&&currentNumLanes==nextNumLanes)

                        conPositionVisible='off';
                    end
                    if currentNumLanes==nextNumLanes
                        if currentLaneSpecWidth==nextLaneSpecWidth
                            conShapeEnable='off';
                            laneSpec.Connector(conIndex).TaperShape=ConnectorTaperShape.None;
                        end
                    else
                        if~isempty(laneSpec.Connector(conIndex).Position)
                            if laneSpec.Connector(conIndex).Position==ConnectorPosition.Both
                                diffLanes=abs(currentNumLanes-nextNumLanes);
                                if rem(diffLanes,2)~=0
                                    laneSpec.Connector(conIndex).Position=ConnectorPosition.Right;
                                end
                            end
                        else
                            laneSpec.Connector(conIndex).Position=ConnectorPosition.Right;
                        end
                        if currentLaneSpecWidth==nextLaneSpecWidth&&(isempty(laneSpec.Connector(conIndex).Position)||laneSpec.Connector(conIndex).Position==ConnectorPosition.Right)
                            conShapeEnable='off';
                            laneSpec.Connector(conIndex).TaperShape=ConnectorTaperShape.None;
                        end
                    end
                elseif~(isscalar(currentNumLanes)&&isscalar(nextNumLanes))
                    conPositionVisible='off';
                    if~isscalar(currentNumLanes)&&~isscalar(nextNumLanes)
                        leftLanes=currentNumLanes(1);
                        rightLanes=currentNumLanes(2);
                        leftWidth=sum(laneSpecData(conIndex).Width(1:leftLanes));
                        rightWidth=sum(laneSpecData(conIndex).Width(leftLanes+1:leftLanes+rightLanes));
                        nextLeftLanes=nextNumLanes(1);
                        nextRightLanes=nextNumLanes(2);
                        nextLeftWidth=sum(laneSpecData(conIndex+1).Width(1:nextLeftLanes));
                        nextRightWidth=sum(laneSpecData(conIndex+1).Width(nextLeftLanes+1:nextLeftLanes+nextRightLanes));
                        if leftWidth==nextLeftWidth&&rightWidth==nextRightWidth
                            conShapeEnable='off';
                            laneSpec.Connector(conIndex).TaperShape=ConnectorTaperShape.None;
                        end
                    elseif isscalar(currentNumLanes)&&~isscalar(nextNumLanes)
                        conShapeEnable='off';
                    end
                end


                set(this.hConnectorPosition,'Visible',conPositionVisible);
                conPanel=this.hConnectorPanel;
                strPositionLabel=string(getString(message('driving:scenarioApp:ConnectorPositionLabel')));
                for cndx=1:numel(conPanel.Children)
                    if strcmp(conPanel.Children(cndx).String,strPositionLabel)
                        conPanel.Children(cndx).Visible=conPositionVisible;
                    end
                end


                for segIndx=1:nRoadSegments
                    roadSegmentNames(segIndx)=SegmentSuffix+" "+...
                    segIndx+" ("+SegmentRangePrefix...
                    +" = "+laneSpec.SegmentRange(segIndx)*100...
                    +"% )";
                end
                nConnectors=numel(laneSpec.Connector);
                connectorNames=strings(1,nConnectors);

                for conIndx=1:nConnectors
                    connectorNames(conIndx)=ConnectorSuffix+" "+conIndx;
                end
                lsConnector=laneSpec.Connector(this.SelectedConnector);
                if~isempty(lsConnector.Position)
                    positionIndex=find(lsConnector.Position==this.lPositions);
                else
                    positionIndex=1;
                end
                shapeIndex=find(lsConnector.TaperShape==this.lShape);
                segmentEnable='on';

                set(this.hRoadSegments,...
                'String',roadSegmentNames,...
                'Value',roadSegmentIndex,...
                'Enable',segmentEnable);
                set(this.hRoadSegmentRange,...
                'String',roadSegmentRanges,...
                'Enable',segmentEnable);

                set(this.hSelectedConnector,...
                'String',connectorNames,...
                'Value',this.SelectedConnector,...
                'Enable',segmentEnable);
                set(this.hConnectorPosition,...
                'String',this.lPositionStrings,...
                'Value',positionIndex,...
                'Enable',conPositionVisible);

                set(this.hConnectorShape,...
                'String',this.lShapeStrings,...
                'Value',shapeIndex,...
                'Enable',conShapeEnable);
                if lsConnector.TaperShape=="None"
                    set(this.hConnectorLength,'String',lsConnector.TaperLength,'Enable','off');
                else
                    set(this.hConnectorLength,'String',lsConnector.TaperLength,'Enable','on');
                end
                laneSpec=getLaneSpecification(this);

                if isa(laneSpec,'compositeLaneSpec')
                    ls=laneSpec.LaneSpecification;
                    for lsndx=1:numel(ls)
                        segmentWidth(lsndx)=sum(ls(lsndx).Width);
                    end
                    if numel(ls)<3&&length(unique(segmentWidth))==1
                        set(this.hSelectedConnector,'Enable','off');
                    end
                end
                this.hShowLaneConnector.Visible='on';
                this.hSelectedConnector.Visible='on';
                updateLayout(this);
            end
        end

        function updateLaneSections(this,ls)
            enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);


            numLanes='';
            laneWidth='';
            markingNames=" ";
            segmentMarkerNames=" ";
            lmIndex=this.SelectedMarking;
            lmsIndex=this.SelectedMultiMarking;
            lmTypeIndex=1;
            lmColor='';
            lmStrength='';
            lmWidth='';
            lmLength='';
            lmSpace='';
            laneEnable='off';
            markerSegmentEnable='off';
            solidPropsEnable='off';
            dashedPropsEnable='off';
            ltIndex=this.SelectedType;
            lTypes=" ";
            lTypeColor='';
            lTypeStrength='';
            laneTypeIndex=1;
            this.hMarkerSelectionCheckbox.Value=0;
            noofMarSegments='';
            marSegmentRanges='';
            ltsuffix=string(getString(message('driving:scenarioApp:LaneTypeSuffix')));
            lmSuffix=string(getString(message('driving:scenarioApp:MarkerSuffix')));
            lmsSuffix=string(getString(message('driving:scenarioApp:MarkerSegmentSuffix')));
            mmsSuffix=string(getString(message('driving:scenarioApp:MultipleMarkerSuffix')));
            if~isempty(ls)
                ls=ls(this.SelectedLane);
                if isempty(ls.Type)
                    totalLanes=sum(ls.NumLanes);


                    ls.Type=repmat(laneType(LaneTypes.Driving),1,totalLanes);
                end


                laneEnable=enable;
                solidPropsEnable=enable;
                dashedPropsEnable=enable;
                numLanes=mat2str(ls.NumLanes);
                width=ls.Width;

                if all(width==width(1))
                    width=width(1);
                end
                laneWidth=mat2str(width);
                marking=ls.Marking;
                numMarking=length(marking);

                markingNames=strings(1,numMarking);
                for kndx=1:numMarking
                    if~isa(marking(kndx),'driving.scenario.CompositeMarking')
                        markingNames(kndx)=lmSuffix+" "+kndx+":"+" "+...
                        this.BoundaryStrings(this.BoundaryTypes==marking(kndx).Type);
                    else

                        markingNames(kndx)=lmSuffix+" "+kndx+":"+" "+mmsSuffix;
                    end
                end

                if~isa(marking(lmIndex),'driving.scenario.CompositeMarking')
                    this.MultipleChecked=false;
                    segmentMarkerNames=lmsSuffix+" "+" 1:"+" "+this.BoundaryStrings...
                    (this.BoundaryTypes==marking(lmIndex).Type);
                    lm=marking(lmIndex);
                    noofMarSegments=1;
                    marSegmentRanges=1;
                    lmsIndex=1;
                    lmTypeIndex=find(lm.Type==this.BoundaryTypes);
                    this.MultipleChecked=false;
                else
                    segmentMarkerNames=strings(1,length(marking(lmIndex).Markings));


                    for kndx=1:length(marking(lmIndex).Markings)
                        segmentMarkerNames(kndx)=lmsSuffix+" "+kndx+":"+" "+this.BoundaryStrings...
                        (this.BoundaryTypes==marking(lmIndex).Markings(kndx).Type);
                    end
                    noofMarSegments=length(marking(this.SelectedMarking).Markings);
                    marSegmentRanges=mat2str(marking(this.SelectedMarking).SegmentRange);
                    lm=marking(lmIndex).Markings(lmsIndex);
                    lmTypeIndex=find(marking(this.SelectedMarking).Markings(this.SelectedMultiMarking).Type...
                    ==this.BoundaryTypes);

                    this.hMarkerSelectionCheckbox.Value=1;
                    this.MultipleChecked=true;
                    markerSegmentEnable='on';
                end
                if~(isequal(lm.Type,LaneBoundaryType('Unmarked')))

                    lmColor=mat2str(lm.Color);
                    lmStrength=mat2str(lm.Strength);
                    lmWidth=mat2str(lm.Width);
                else


                    solidPropsEnable='off';
                    dashedPropsEnable='off';
                end
                if contains(string(lm.Type),'Dashed')

                    lmLength=mat2str(lm.Length);
                    lmSpace=mat2str(lm.Space);
                else


                    dashedPropsEnable='off';
                end

                set(this.hWidth,'Enable','off');
                if~isempty(ls.Type)
                    lnTypes=ls.Type;
                    numTypes=length(lnTypes);

                    lTypes=strings(1,numTypes);
                    lt=lnTypes(ltIndex);


                    laneTypeIndex=find(lt.Type==this.tLaneTypes);
                    if~(isequal(lt.Type,laneType('Driving')))
                        lTypeColor=mat2str(lt.Color);
                        lTypeStrength=mat2str(lt.Strength);
                    end
                    for ltInd=1:length(lTypes)
                        lTypes(ltInd)=ltsuffix+' '+ltInd+":"+' '+this.LaneTypeStrings(this.tLaneTypes...
                        ==lnTypes(ltInd).Type);
                    end
                else
                    set([this.hSelectedType,this.hLaneType,this.hLaneTypeColor,this.hLaneTypeStrength],'Enable',...
                    'off','String',{''},'Value',1);
                end
                set(this.hMarkerSelectionCheckbox,'Enable','on');
            else


                lmIndex=1;
                lmsIndex=1;
                ltIndex=1;
                this.hMarkerSelectionCheckbox.Value=0;
                set(this.hMarkerSelectionCheckbox,'Enable','off');
            end

            set(this.hNumRoadSegments,'String',this.numRoadSegments,'Enable',enable);
            if this.numRoadSegments==1
                set(this.hNumRoadSegments,'String',1,'Enable',enable);
            end

            set(this.hNumLanes,'String',numLanes,'Enable',enable);
            set(this.hLaneWidth,'String',laneWidth,'Enable',laneEnable);
            set(this.hSelectedMarking,...
            'String',markingNames,...
            'Value',lmIndex,...
            'Enable',laneEnable);
            set(this.hMarkerSegments,...
            'String',segmentMarkerNames,...
            'Value',lmsIndex,...
            'Enable',markerSegmentEnable);
            set(this.hMarkingType,...
            'String',this.BoundaryStrings,...
            'Value',lmTypeIndex,...
            'Enable',laneEnable);
            set(this.hMarkingColor,'String',lmColor,'Enable',solidPropsEnable);
            set(this.hMarkingStrength,'String',lmStrength,'Enable',solidPropsEnable);
            set(this.hMarkingWidth,'String',lmWidth,'Enable',solidPropsEnable);
            set(this.hMarkingLength,'String',lmLength,'Enable',dashedPropsEnable);
            set(this.hMarkingSpace,'String',lmSpace,'Enable',dashedPropsEnable);
            set(this.hNumMarkings,'String',noofMarSegments,'Enable',markerSegmentEnable);
            set(this.hMarkerRange,'String',marSegmentRanges,'Enable',markerSegmentEnable);
            set(this.hSelectedType,...
            'String',lTypes,...
            'Value',ltIndex,...
            'Enable',laneEnable);
            set(this.hLaneType,...
            'String',this.LaneTypeStrings,...
            'Value',laneTypeIndex,...
            'Enable',laneEnable);
            set(this.hLaneTypeColor,'String',lTypeColor,'Enable',laneEnable);
            set(this.hLaneTypeStrength,'String',lTypeStrength,'Enable',laneEnable);
            set(this.hMarkerSelectionCheckbox,'Value',this.MultipleChecked,'Enable',laneEnable);

        end
    end

    methods(Hidden)
        function updateLayout(this,lanesRow)
            parentLayout=this.Layout;
            if nargin<2
                lanesRow=find(parentLayout.Grid==this.hShowLanes)+1;
            end

            lanesPanel=this.hLanesPanel;
            lanesLayout=this.LanesLayout;
            if this.ShowLanes
                if~parentLayout.contains(lanesPanel)
                    insert(parentLayout,'row',lanesRow)
                    add(parentLayout,lanesPanel,lanesRow,[1,size(parentLayout.Grid,2)]);
                end
                lanesPanel.Visible='on';

                markingPanel=this.hMarkingPanel;
                laneTypePanel=this.hLaneTypePanel;
                multipleMarkingPanel=this.hMultipleMarkingPanel;

                vwLanesLayout=[0,0,0];
                if this.ShowLaneTypes
                    if~lanesLayout.contains(laneTypePanel)
                        insert(lanesLayout,'row',4)
                        add(lanesLayout,laneTypePanel,4,[1,2]);
                    end
                    laneTypePanel.Visible='on';
                elseif lanesLayout.contains(laneTypePanel)
                    laneTypePanel.Visible='off';
                    lanesLayout.remove(laneTypePanel);
                    lanesLayout.clean;
                end
                if this.ShowMarking
                    this.hMarkerSelectionCheckbox.Visible='on';
                    rowNumber=6;
                    if lanesLayout.contains(laneTypePanel)
                        rowNumber=7;
                    end
                    clearPanels(this);
                    if this.hMarkerSelectionCheckbox.Value==true||this.MultipleChecked==true
                        insert(lanesLayout,'row',rowNumber)
                        add(lanesLayout,multipleMarkingPanel,rowNumber,[1,2]);
                        multipleMarkingPanel.Visible='on';
                        insert(lanesLayout,'row',rowNumber+1)
                        add(lanesLayout,markingPanel,rowNumber+1,[1,2]);
                        markingPanel.Visible='on';
                    else
                        multipleMarkingPanel.Visible='off';
                        lanesLayout.remove(multipleMarkingPanel);
                        lanesLayout.clean;
                        insert(lanesLayout,'row',rowNumber)
                        add(lanesLayout,markingPanel,rowNumber,[1,2]);
                        markingPanel.Visible='on';
                    end
                else
                    this.hMarkerSelectionCheckbox.Visible='off';
                    clearPanels(this);
                end


                [~,h]=getMinimumSize(lanesLayout);
                setConstraints(parentLayout,this.hLanesPanel,'MinimumHeight',h);
                lanesLayout.VerticalWeights=vwLanesLayout;
                lanesPanel.Visible='on';
            else
                lanesPanel.Visible='off';
                if parentLayout.contains(lanesPanel)
                    parentLayout.remove(lanesPanel);
                    parentLayout.clean;
                end
            end
            matlabshared.application.setToggleCData(this.hShowLanes);
            matlabshared.application.setToggleCData(this.hShowMarking);
            matlabshared.application.setToggleCData(this.hShowLaneTypes);
        end
        function clearPanels(this)
            lanesLayout=this.LanesLayout;
            markingPanel=this.hMarkingPanel;
            multipleMarkingPanel=this.hMultipleMarkingPanel;
            multipleMarkingPanel.Visible='off';
            markingPanel.Visible='off';
            lanesLayout.remove(multipleMarkingPanel);
            lanesLayout.remove(markingPanel);
            lanesLayout.clean;
            this.SelectedLane=1;
        end

        function setDefaultProperties(this)
            lanesLayout=this.LanesLayout;
            markingPanel=this.hMarkingPanel;
            multipleMarkingPanel=this.hMultipleMarkingPanel;
            multipleMarkingPanel.Visible='off';
            markingPanel.Visible='off';
            lanesLayout.remove(multipleMarkingPanel);
            lanesLayout.remove(markingPanel);
            lanesLayout.clean;
            this.MultipleChecked=false;
        end

        function[numTiles]=getTiles(this)
            roadSpec=getSpecification(this);
            roadCenters=roadSpec.Centers;
            n=size(roadSpec.Centers,1);
            course=NaN(n,1);
            if any(isnan(course))
                course=matlabshared.tracking.internal.scenario.clothoidG2fitMissingCourse(roadCenters,course);
            end

            hip=complex(roadCenters(:,1),roadCenters(:,2));

            [~,~,hl]=matlabshared.tracking.internal.scenario.clothoidG1fit2(hip(1:n-1),course(1:n-1),hip(2:n),course(2:n));

            hcd=[0;cumsum(hl)];
            targetLength=2;
            roadLength=hcd(end);
            numTiles=ceil(roadLength/targetLength);
        end

        function numRoadSegmentsCallback(this,src,~)
            try
                currentValue=this.numRoadSegments;

                newValue=strToNum(this,get(src,'String'));

                validateattributes(newValue,{'numeric'},{'integer',...
                'nonempty','finite','positive'},'Dialog','NumRoadSegments');

                numTiles=getTiles(this);
                if numTiles<newValue
                    error(message('driving:scenario:ExceedNumRoadSegments'));
                end
                this.SelectedRoadSegment=1;
                this.SelectedConnector=1;
                if currentValue~=newValue
                    laneSpec=getLaneSpecification(this);

                    if isa(laneSpec,'compositeLaneSpec')
                        ls=laneSpec.LaneSpecification;
                        lsConnector=laneSpec.Connector;
                    else
                        ls=laneSpec;
                    end
                    numLaneSpecs=numel(ls);
                    if numLaneSpecs==0&&isempty(ls)
                        roadWidth=6;
                        ls=lanespec(1,'Width',roadWidth);
                    end
                    if newValue~=numLaneSpecs
                        if newValue==1
                            ls=ls(1);
                            this.MultiLaneSpecs=false;
                        elseif numLaneSpecs<newValue
                            lastSpec=ls(end);
                            ls(end+1:newValue)=lastSpec;
                            if numLaneSpecs==1||numLaneSpecs==0
                                lsConnector=laneSpecConnector('TaperShape','None');
                            end
                            lsConnector(end+1:(newValue-1))=laneSpecConnector('TaperShape','None');
                            ls=compositeLaneSpec(ls,'Connector',lsConnector);
                            this.RoadSegmentRange=ls.SegmentRange;
                            this.MultiLaneSpecs=true;
                        elseif numLaneSpecs>newValue
                            lsArray=ls(1:newValue);
                            connArray=lsConnector(1:newValue-1);
                            ls=compositeLaneSpec(lsArray,'Connector',connArray);
                            this.RoadSegmentRange=ls.SegmentRange;
                            this.MultiLaneSpecs=true;
                        end
                        this.numRoadSegments=newValue;
                        setLaneSpecification(this,ls);
                    else
                        setLaneSpecification(this,laneSpec);
                    end
                end
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            update(this);
            updateLayout(this);
        end

        function roadSegmentRangeCallback(this,src,~)

            try
                newValue=strToNum(this,get(src,'String'));
                laneSpec=getLaneSpecification(this);
                ls=compositeLaneSpec(laneSpec.LaneSpecification,'Connector',laneSpec.Connector,...
                'SegmentRange',newValue);
            catch ME
                update(this);
                if ME.identifier=="driving:scenario:LaneSpecificationSegmentRangeMismatch"
                    msg=getString(message('driving:scenarioApp:InvalidRoadSegmentRange'));
                    ident='driving:scenarioApp:InvalidRoadSegmentRange';
                    errorMessage(this,msg,ident);
                    return;
                else
                    errorMessage(this,ME.message,ME.identifier);
                    return;
                end
            end
            setLaneSpecification(this,ls);
            UpdatedLaneSpec=getLaneSpecification(this);
            taperLength=[ls.Connector(:).TaperLength];
            updatedTaperLength=[UpdatedLaneSpec.Connector(:).TaperLength];
            roadSegmentId=find(any(taperLength~=updatedTaperLength,1));
            if any(taperLength~=updatedTaperLength)
                warningMessage(this,getString(message('driving:scenarioApp:ConnectorLengthExceedWarning',string(roadSegmentId(1)))),"ConnectorLength");
            end
        end


        function roadSegmentsCallback(this,src,eventData)
            currentValue=this.SelectedRoadSegment;
            newValue=src.Value;
            defaultPopupCallback(this,src,eventData);
            if currentValue~=newValue

                this.SelectedRoadSegment=newValue;
                this.SelectedLane=1;
                this.SelectedType=1;
                this.SelectedMarking=1;
                this.SelectedMultiMarking=1;
                update(this);
                updateLayout(this);
            end
        end

        function numMarkingsCallback(this,src,~)

            try

                newValue=strToNum(this,get(src,'String'));
                validateattributes(newValue,{'numeric'},{'integer',...
                'finite','positive','<=',30},'Dialog','NumMarkings');
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                marking=ls.Marking;

                if isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    cmLength=length(marking(this.SelectedMarking).Markings);
                    lmarkerRange=newValue;
                    lnumMarkings=newValue;
                    if newValue==1
                        lm=marking(this.SelectedMarking).Markings(newValue);
                        marking(this.SelectedMarking)=lm;
                        this.MultipleChecked=false;
                    elseif cmLength<newValue


                        lm=marking(this.SelectedMarking).Markings;
                        lm(end+1:newValue)=marking(this.SelectedMarking).Markings(1,end);
                        cm=laneMarking(lm);
                        marking(this.SelectedMarking)=cm;
                        lnumMarkings=mat2str(cm.SegmentRange);
                    elseif cmLength>newValue
                        lm=marking(this.SelectedMarking).Markings(1:newValue);
                        cm=laneMarking(lm);
                        marking(this.SelectedMarking)=cm;
                        lnumMarkings=mat2str(cm.SegmentRange);
                    end
                    this.MarkerRange=lmarkerRange;
                    this.numMarkings=lnumMarkings;
                end
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',marking,'Type',ls.Type);
                this.SelectedMultiMarking=1;
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:NumMarkingsMismatch')),...
                'driving:scenarioApp:NumMarkingsMismatch');
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function connectorData=resetTaperPosition(~,laneSpecData,connectorData)
            nLanespec=numel(laneSpecData);
            for lsndx=1:nLanespec
                if lsndx~=nLanespec
                    currentLaneSpec=laneSpecData(lsndx);
                    nextLaneSpec=laneSpecData(lsndx+1);

                    if isscalar(currentLaneSpec.NumLanes)
                        leftLanes=0;
                        rightLanes=currentLaneSpec.NumLanes(1);
                    else
                        leftLanes=currentLaneSpec.NumLanes(1);
                        rightLanes=currentLaneSpec.NumLanes(2);
                    end

                    if isscalar(nextLaneSpec.NumLanes)
                        nextLeftLanes=0;
                        nextRightLanes=nextLaneSpec.NumLanes(1);
                    else
                        nextLeftLanes=nextLaneSpec.NumLanes(1);
                        nextRightLanes=nextLaneSpec.NumLanes(2);
                    end

                    if~isscalar(laneSpecData(lsndx).NumLanes)&&~isscalar(laneSpecData(lsndx+1).NumLanes)
                        if~isempty(connectorData(lsndx).Position)
                            if leftLanes==nextLeftLanes&&rightLanes~=nextRightLanes&&connectorData(lsndx).Position~=ConnectorPosition.Right
                                connectorData(lsndx).Position=ConnectorPosition.Right;
                            elseif leftLanes~=nextLeftLanes&&rightLanes==nextRightLanes&&connectorData(lsndx).Position~=ConnectorPosition.Left
                                connectorData(lsndx).Position=ConnectorPosition.Left;
                            elseif leftLanes~=nextLeftLanes&&rightLanes~=nextRightLanes&&connectorData(lsndx).Position~=ConnectorPosition.Both
                                connectorData(lsndx).Position=ConnectorPosition.Both;
                            elseif leftLanes==nextLeftLanes&&rightLanes==nextRightLanes
                                connectorData(lsndx).Position=ConnectorPosition.empty;
                            end
                        elseif leftLanes==nextLeftLanes&&rightLanes~=nextRightLanes
                            connectorData(lsndx).Position=ConnectorPosition.Right;
                        elseif leftLanes~=nextLeftLanes&&rightLanes==nextRightLanes
                            connectorData(lsndx).Position=ConnectorPosition.Left;
                        elseif leftLanes~=nextLeftLanes&&rightLanes~=nextRightLanes
                            connectorData(lsndx).Position=ConnectorPosition.Both;
                        end

                    elseif isscalar(laneSpecData(lsndx).NumLanes)&&isscalar(laneSpecData(lsndx+1).NumLanes)
                        if rightLanes==nextRightLanes
                            connectorData(lsndx).Position=ConnectorPosition.empty;
                        elseif rightLanes~=nextRightLanes
                            if isempty(connectorData(lsndx).Position)
                                connectorData(lsndx).Position=ConnectorPosition.Right;
                            elseif connectorData(lsndx).Position==ConnectorPosition.Both
                                diffLanes=abs(rightLanes-nextRightLanes);
                                if rem(diffLanes,2)~=0
                                    connectorData(lsndx).Position=ConnectorPosition.Right;
                                end
                            end
                        end
                    elseif rightLanes==nextRightLanes

                        connectorData(lsndx).Position=ConnectorPosition.Left;
                    else

                        connectorData(lsndx).Position=ConnectorPosition.Both;
                    end
                end
            end
        end

        function numLanesCallback(this,src,~)

            try
                newValue=strToNum(this,get(src,'String'));
                roadSpec=getSpecification(this);
                lsData=roadSpec.Lanes;
                ls=lsData;
                if~isempty(lsData)&&isa(lsData,'compositeLaneSpec')
                    if isempty(newValue)
                        newValue=NaN;
                    end
                    laneSpecData=lsData.LaneSpecification;
                    laneSpecData(this.SelectedRoadSegment)=lanespec(newValue);
                    connectorData=lsData.Connector;
                    connectorData=resetTaperPosition(this,laneSpecData,connectorData);
                    lsData.Connector=connectorData;
                    ls=lsData.LaneSpecification(this.SelectedRoadSegment);
                    lsArray=lsData.LaneSpecification;
                end
                if isempty(newValue)

                    setProperty(this,'Lanes',lanespec.empty);
                    this.SelectedType=1;
                    update(this);

                    this.SelectedMarking=1;
                    return;
                end


                if isempty(ls)



                    rw=roadSpec.Width;
                    lsUpdate=lanespec(newValue);
                    if rw~=roadSpec.getDefaultWidth
                        lw=round(((rw-0.15)/sum(newValue)),5);

                        if lw<0.5
                            lw=0.5;
                        end
                        lsUpdate.Width=lw;
                    end
                else

                    width=ls.Width;
                    numWidth=length(width);
                    totalLanes=sum(newValue);

                    validateattributes(totalLanes,{'numeric'},{'integer',...
                    'finite','positive','<=',30},'Dialog','NumLanes');
                    numLanes=ls.NumLanes;
                    lType=ls.Type;
                    marking=ls.Marking;
                    if size(lType,1)>1
                        lType=lType';
                    end
                    if size(marking,1)>1
                        marking=marking';
                    end
                    try
                        if~isscalar(newValue)&&~isscalar(numLanes)
                            leftWidth=width(1:numLanes(1));
                            rightWidth=width(numLanes(1)+1:sum(numLanes));
                            lTypeLeft=lType(1:numLanes(1));
                            lTypeRight=lType(numLanes(1)+1:sum(numLanes));
                            leftMarking=marking(1:numLanes(1)+1);
                            rightMarking=marking(numLanes(1)+2:end);
                            if numLanes(1)>newValue(1)
                                leftWidth=leftWidth(end-newValue(1)+1:end);
                                lTypeLeft=lTypeLeft(end-newValue(1)+1:end);
                                leftMarking=leftMarking(end-newValue(1):end);
                                leftMarking(1)=laneMarking('Solid');
                            elseif numLanes(1)<newValue(1)
                                diffLanes=newValue(1)-numLanes(1);
                                preWidth=repelem(leftWidth(1),diffLanes);
                                leftWidth=[preWidth,leftWidth];
                                preTypes=repelem(laneType(LaneTypes.Driving),diffLanes);
                                lTypeLeft=[preTypes,lTypeLeft];
                                leftMarking(1)=laneMarking('Solid');
                                preLaneMarkings=repelem(laneMarking('Dashed'),diffLanes);
                                leftMarking=[leftMarking(1),preLaneMarkings,leftMarking(2:end)];
                            end
                            if numLanes(2)>newValue(2)
                                rightWidth=rightWidth(1:newValue(2));
                                lTypeRight=lTypeRight(1:newValue(2));
                                rightMarking=rightMarking(1:newValue(2));
                                rightMarking(end)=laneMarking('Solid');
                            elseif numLanes(2)<newValue(2)
                                diffLanes=newValue(2)-numLanes(2);
                                preWidth=repelem(rightWidth(end),diffLanes);
                                rightWidth=[rightWidth,preWidth];
                                preTypes=repelem(laneType(LaneTypes.Driving),diffLanes);
                                lTypeRight=[lTypeRight,preTypes];
                                preLaneMarkings=repelem(laneMarking('Dashed'),diffLanes);
                                rightMarking=[rightMarking(1:end-1),preLaneMarkings,rightMarking(end)];
                                rightMarking(end)=laneMarking('Solid');
                            end
                            width=[leftWidth,rightWidth];
                            lType=[lTypeLeft,lTypeRight];
                            marking=[leftMarking,rightMarking];
                        elseif numWidth>totalLanes
                            width=width(1:totalLanes);
                            lType=lType(1:totalLanes);
                            marking=marking(1:totalLanes+1);
                        elseif numWidth<totalLanes


                            width(end+1:totalLanes)=width(end);
                            lType(end+1:totalLanes)=laneType(LaneTypes.Driving);
                            marking(end:totalLanes)=laneMarking('Dashed');
                            marking(end+1)=laneMarking('Solid');
                        end



                        if(isscalar(numLanes)~=isscalar(newValue))
                            lsUpdate=lanespec(newValue,'Width',width,'Type',lType);
                        else
                            lsUpdate=lanespec(newValue,'Width',width,'Marking',marking,'Type',lType);
                        end
                    catch







                        lsUpdate=lanespec(newValue,'Width',width);
                    end
                    if isa(lsData,'compositeLaneSpec')
                        lsArray(this.SelectedRoadSegment)=lsUpdate;
                        lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                    end
                end

                this.SelectedMarking=1;
                this.SelectedType=1;
            catch
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:InvalidNumLanes')),...
                'driving:scenarioApp:InvalidNumLanes');
                return;
            end
            setLaneSpecification(this,lsUpdate);
            update(this);
            updateLayout(this);
        end

        function laneTypeColorCallback(this,src,~)
            try
                newValue=get(src,'String');

                newValueColor=strToNum(this,newValue);
                if isnan(newValueColor)

                    newValueColor=newValue;
                end
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                if isempty(ls.Type)
                    totalLanes=sum(ls.NumLanes);
                    ls.Type=repmat(laneType(LaneTypes.Driving),1,totalLanes);
                end
                lType=ls.Type;
                lType(this.SelectedType).Color=newValueColor;
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',ls.Marking,'Type',lType);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function selectedLaneTypeCallback(this,src,eventData)

            currentValue=this.SelectedType;
            newValue=src.Value;
            defaultPopupCallback(this,src,eventData);
            if currentValue~=newValue

                this.ShowLaneTypes=true;
                setToggleValue(this,'ShowLaneTypes',true);
                update(this);
                updateLayout(this);
            end
        end

        function laneTypeCallback(this,src,~)
            try
                newValue=LaneTypes(this.tLaneTypes(get(src,'Value')));
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                if isempty(ls.Type)
                    totalLanes=sum(ls.NumLanes);
                    ls.Type=repmat(laneType(LaneTypes.Driving),1,totalLanes);
                end
                lType=ls.Type;
                lType(this.SelectedType)=laneType(newValue);
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',ls.Marking,'Type',lType);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function laneTypeStrengthCallback(this,src,~,propName)

            try
                newValue=round(strToNum(this,get(src,'String')),5);
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                if isempty(ls.Type)
                    totalLanes=sum(ls.NumLanes);
                    ls.Type=repmat(laneType(LaneTypes.Driving),1,totalLanes);
                end
                lType=ls.Type;
                lType(this.SelectedType).(propName)=newValue;
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',ls.Marking,'Type',lType);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch
                update(this);
                msg=getString(message('driving:scenarioApp:InvalidLaneTypeStrength'));
                ident='driving:scenarioApp:InvalidLaneTypeStrength';
                errorMessage(this,msg,ident);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function laneWidthCallback(this,src,~)

            newValue=strToNum(this,get(src,'String'));
            if isempty(newValue)
                newValue=NaN;
            end
            lsData=getLaneSpecification(this);


            try
                newValue=round(newValue,5);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                lsUpdate=lanespec(ls.NumLanes,'Width',newValue,'Marking',ls.Marking,'Type',ls.Type);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:InvalidLaneWidth')),...
                'driving:scenarioApp:InvalidLaneWidth');
                return;
            end
            setLaneSpecification(this,lsUpdate);
            update(this);
            updateLayout(this);
        end

        function markerRangeCallback(this,src,~)

            try
                newValue=strToNum(this,get(src,'String'));
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                marking=ls.Marking;
                if isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    cm=laneMarking(marking(this.SelectedMarking).Markings,'SegmentRange',newValue);
                    marking(this.SelectedMarking)=cm;
                    lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',marking,'Type',ls.Type);
                    this.MarkerRange=mat2str(cm.SegmentRange);
                end
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                if ME.identifier=="driving:scenario:SegmentRangeMismatch"
                    msg=getString(message('driving:scenarioApp:InvalidSegmentRange'));
                    ident='driving:scenarioApp:InvalidSegmentRange';
                    errorMessage(this,msg,ident);
                    return;
                else
                    errorMessage(this,ME.message,ME.identifier);
                    return;
                end
            end
            setLaneSpecification(this,lsUpdate);
        end

        function markingTypeCallback(this,src,~)

            try

                newValue=LaneBoundaryType(this.BoundaryTypes(get(src,'Value')));
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                marking=ls.Marking;


                if~isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    clm=marking(this.SelectedMarking);
                else
                    clm=marking(this.SelectedMarking).Markings(this.SelectedMultiMarking);
                end
                newValue=laneMarking(newValue);
                if isprop(clm,'Color')&&isprop(newValue,'Color')
                    newValue.Color=clm.Color;
                end
                if isprop(clm,'Width')&&isprop(newValue,'Width')
                    newValue.Width=clm.Width;
                end
                if isprop(clm,'Strength')&&isprop(newValue,'Strength')
                    newValue.Strength=clm.Strength;
                end
                if isprop(clm,'Length')&&isprop(newValue,'Length')
                    newValue.Length=clm.Length;
                end
                if isprop(clm,'Space')&&isprop(newValue,'Space')
                    newValue.Space=clm.Space;
                end
                if~isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    marking(this.SelectedMarking)=newValue;
                else
                    cMarking=marking(this.SelectedMarking).Markings;
                    cMarking(this.SelectedMultiMarking)=newValue;
                    newComMarking=laneMarking(cMarking,'SegmentRange',...
                    marking(this.SelectedMarking).SegmentRange);
                    marking(this.SelectedMarking)=newComMarking;
                end
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Type',ls.Type,'Marking',marking);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function markingColorCallback(this,src,~)

            try

                newValue=get(src,'String');

                newValueColor=strToNum(this,newValue);
                if isnan(newValueColor)

                    newValueColor=newValue;
                end
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                marking=ls.Marking;
                lType=ls.Type;
                if~isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    marking(this.SelectedMarking).Color=newValueColor;
                else
                    lm=marking(this.SelectedMarking).Markings(this.SelectedMultiMarking);
                    lm.Color=newValueColor;
                    cMarking=marking(this.SelectedMarking).Markings;
                    cMarking(this.SelectedMultiMarking)=lm;
                    newComMarking=laneMarking(cMarking,'SegmentRange',...
                    marking(this.SelectedMarking).SegmentRange);
                    marking(this.SelectedMarking)=newComMarking;
                end
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',marking,'Type',lType);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function markingDoubleCallback(this,src,~,propName)

            try
                newValue=round(strToNum(this,get(src,'String')),5);
                lsData=getLaneSpecification(this);
                [ls,lsArray]=getSelectedRoadSegment(this,lsData);
                marking=ls.Marking;
                if~isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    marking(this.SelectedMarking).(propName)=newValue;
                else
                    lm=marking(this.SelectedMarking).Markings(this.SelectedMultiMarking);
                    lm.(propName)=newValue;
                    cMarking=marking(this.SelectedMarking).Markings;
                    cMarking(this.SelectedMultiMarking)=lm;
                    newComMarking=laneMarking(cMarking,'SegmentRange',...
                    marking(this.SelectedMarking).SegmentRange);
                    marking(this.SelectedMarking)=newComMarking;
                end
                lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Type',ls.Type,'Marking',marking);
                if~isempty(lsArray)
                    lsArray(this.SelectedRoadSegment)=lsUpdate;
                    lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
                end
            catch ME
                update(this);
                switch propName
                case 'Strength'
                    msg=getString(message('driving:scenarioApp:InvalidMarkingStrength'));
                    ident='driving:scenarioApp:InvalidMarkingStrength';
                case 'Width'
                    if strcmp(ME.identifier,'driving:scenario:InvalidWidthLanes')
                        msg=ME.message;
                        ident=ME.identifier;
                    else
                        msg=getString(message('driving:scenarioApp:InvalidMarkingWidth'));
                        ident='driving:scenarioApp:InvalidMarkingWidth';
                    end
                case 'Length'
                    msg=getString(message('driving:scenarioApp:InvalidMarkingLength'));
                    ident='driving:scenarioApp:InvalidMarkingLength';
                case 'Space'
                    msg=getString(message('driving:scenarioApp:InvalidMarkingSpace'));
                    ident='driving:scenarioApp:InvalidMarkingSpace';
                otherwise
                    msg='';
                    ident='';
                end
                errorMessage(this,msg,ident);
                return;
            end
            setLaneSpecification(this,lsUpdate);
        end

        function selectedMarkingCallback(this,src,eventData)

            currentValue=this.SelectedMarking;
            newValue=src.Value;
            defaultPopupCallback(this,src,eventData);
            ls=getLaneSpecification(this);
            if isa(ls,'compositeLaneSpec')
                ls=ls.LaneSpecification(this.SelectedRoadSegment);
            end
            if currentValue~=newValue
                if~isa(ls.Marking(newValue),'driving.scenario.CompositeMarking')
                    this.MultipleChecked=false;
                    this.numMarkings=1;
                    this.MarkerRange=1;
                    this.SelectedMultiMarking=1;
                    this.SelectedMarking=newValue;
                else
                    this.MultipleChecked=true;
                    this.SelectedMultiMarking=1;

                    this.numMarkings=length(ls.Marking(newValue).Markings);
                    this.MarkerRange=mat2str(ls.Marking(newValue).SegmentRange);
                end

                this.ShowMarking=true;
                setToggleValue(this,'ShowMarking',true);
                matlabshared.application.setToggleCData(this.hShowMarking);
                update(this);
                updateLayout(this);
            end
        end

        function markerSegmentsCallback(this,src,~)
            currentValue=this.SelectedMultiMarking;
            newValue=src.Value;
            if currentValue~=newValue
                this.SelectedMultiMarking=newValue;
                this.MultiIndex=newValue;

                this.ShowMarking=true;
                this.MultiIndex=true;
                setToggleValue(this,'ShowMarking',true);
                update(this);
                updateLayout(this);
            end
        end

        function markerSelectionCheckboxCallback(this,hcbo,~)
            lsData=getLaneSpecification(this);
            [ls,lsArray]=getSelectedRoadSegment(this,lsData);
            marking=ls.Marking;
            multipleMarkingPanel=this.hMultipleMarkingPanel;
            if hcbo.Value==1
                this.MultipleChecked=true;
                if~isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    lm=marking(this.SelectedMarking);

                    newLaneMarkings=repmat(lm,1,1);
                    cm=laneMarking([lm,newLaneMarkings]);
                    marking(this.SelectedMarking)=cm;
                    this.SelectedMultiMarking=1;
                    lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',marking,'Type',ls.Type);
                end
            else
                this.MultipleChecked=false;
                if isa(marking(this.SelectedMarking),'driving.scenario.CompositeMarking')
                    lm=marking(this.SelectedMarking).Markings(1);
                    marking(this.SelectedMarking)=lm;
                    this.SelectedMultiMarking=1;
                    lsUpdate=lanespec(ls.NumLanes,'Width',ls.Width,'Marking',marking,'Type',ls.Type);
                end
            end
            if this.MultipleChecked==true
                this.MultipleCheckedState='on';
            else
                this.MultipleCheckedState='off';
            end
            for i=1:size(multipleMarkingPanel.Children,1)
                multipleMarkingPanel.Children(i).Visible=this.MultipleCheckedState;
            end
            if~isempty(lsArray)
                lsArray(this.SelectedRoadSegment)=lsUpdate;
                lsUpdate=compositeLaneSpec(lsArray,'Connector',lsData.Connector,'SegmentRange',lsData.SegmentRange);
            end
            setLaneSpecification(this,lsUpdate);
            updateLayout(this);
            notify(this,'HeightChanged');

        end

        function selectedLaneCallback(this,src,ev)
            currentValue=this.SelectedLane;
            newValue=src.Value;
            defaultPopupCallback(this,src,ev);
            if currentValue~=newValue

                this.ShowLanes=true;
                setToggleValue(this,'ShowLanes',true);
                update(this)
                updateLayout(this);
            end
        end

        function SelectedConnectorCallback(this,src,eventData)
            currentValue=this.SelectedConnector;
            newValue=src.Value;
            defaultPopupCallback(this,src,eventData);
            if currentValue~=newValue
                this.SelectedConnector=newValue;
                this.ShowLaneConnector=true;
                setToggleValue(this,'ShowLaneConnector',true);
                update(this);
                updateLayout(this);
            end
        end

        function taperPositionCallback(this,src,~)
            try
                newValue=ConnectorPosition(this.lPositions(get(src,'Value')));
                positionValue=newValue;
                lsData=getLaneSpecification(this);
                lsConnArray=lsData.Connector;
                lsConn=lsConnArray(this.SelectedConnector);
                conIndex=this.SelectedConnector;
                currentNumLanes=lsData.LaneSpecification(conIndex).NumLanes;
                nextNumLanes=lsData.LaneSpecification(conIndex+1).NumLanes;
                if newValue==ConnectorPosition.Both
                    diffLanes=abs(currentNumLanes-nextNumLanes);
                    if rem(diffLanes,2)~=0
                        newValue=lsConn.Position;
                    end
                end
                lsConnUpdate=laneSpecConnector('Position',newValue,'TaperShape',lsConn.TaperShape,'TaperLength',lsConn.TaperLength);
                lsConnArray(this.SelectedConnector)=lsConnUpdate;
                lsComp=compositeLaneSpec(lsData.LaneSpecification,'Connector',lsConnArray,'SegmentRange',lsData.SegmentRange);
                setLaneSpecification(this,lsComp);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            if positionValue==ConnectorPosition.Both
                diffLanes=abs(currentNumLanes-nextNumLanes);
                if rem(diffLanes,2)~=0
                    warningMessage(this,getString(message('driving:scenarioApp:BothPositionNotMatchWithLaneSpec')),"ConnectorPosition");
                end
            end
        end

        function taperShapeCallback(this,src,~)
            try
                newValue=ConnectorTaperShape(this.lShape(get(src,'Value')));
                lsData=getLaneSpecification(this);
                lsConnArray=lsData.Connector;
                lsConn=lsConnArray(this.SelectedConnector);
                lsConnUpdate=laneSpecConnector('Position',lsConn.Position,'TaperShape',newValue);
                lsConnArray(this.SelectedConnector)=lsConnUpdate;

                lsComp=compositeLaneSpec(lsData.LaneSpecification,'Connector',lsConnArray,'SegmentRange',lsData.SegmentRange);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsComp);
            update(this);
            updateLayout(this);
        end

        function taperLengthCallback(this,src,~)
            try
                newValue=strToNum(this,get(src,'String'));

                validateattributes(newValue,{'numeric'},{'real',...
                'finite','scalar','nonnegative'},'Dialog','Length');

                lsData=getLaneSpecification(this);
                lsConnArray=lsData.Connector;
                lsConn=lsConnArray(this.SelectedConnector);
                lsConnUpdate=laneSpecConnector('Position',lsConn.Position,'TaperShape',lsConn.TaperShape,'TaperLength',newValue);
                lsConnArray(this.SelectedConnector)=lsConnUpdate;
                lsComp=compositeLaneSpec(lsData.LaneSpecification,'Connector',lsConnArray,'SegmentRange',lsData.SegmentRange);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,lsComp);
            updatedValue=strToNum(this,get(src,'String'));
            if newValue~=updatedValue
                setLaneSpecification(this,lsData);
                errorMessage(this,getString(message('driving:scenarioApp:TaperLengthExceedSegmentLength')),...
                'driving:scenarioApp:TaperLengthExceedSegmentLength');
                return;
            end
        end
    end

    methods(Access=protected)
        function createWidgets(this)
            p=this.Panel;
            createToggle(this,p,'ShowLanes');
            laneNames=getAllLaneNames(this);
            if numel(laneNames)>1
                createEditbox(this,p,'SelectedLane',@this.selectedLaneCallback,'popupmenu',...
                'String',laneNames,...
                'Value',this.SelectedLane);
            end
            panelProps={'Visible','off','BorderType','none',...
            'AutoResizeChildren','off'};
            lanesPanel=uipanel(p,panelProps{:},'Tag','lanesPanel');

            hNumLanesLabel=createLabelEditPair(this,lanesPanel,'NumLanes',@this.numLanesCallback,...
            'TooltipString',getString(message('driving:scenarioApp:NumLanesDescription')));

            hLaneWidthLabel=createLabelEditPair(this,lanesPanel,'LaneWidth',@this.laneWidthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:LaneWidthDescription')));

            createCheckbox(this,lanesPanel,'MarkerSelectionCheckbox',@this.markerSelectionCheckboxCallback);

            createToggle(this,lanesPanel,'ShowMarking');
            markingPanel=uipanel(lanesPanel,panelProps{:},'Tag','markingPanel');

            createEditbox(this,lanesPanel,'SelectedMarking',@this.selectedMarkingCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:SelectedMarkingDescription')));

            hMarkingTypeLabel=createLabel(this,markingPanel,'MarkingType');
            createEditbox(this,markingPanel,'MarkingType',@this.markingTypeCallback,'popupmenu');
            hMarkingColorLabel=createLabelEditPair(this,markingPanel,...
            'MarkingColor',@this.markingColorCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MarkingColorDescription')));
            hMarkingStrengthLabel=createLabelEditPair(this,markingPanel,...
            'MarkingStrength',@(src,evnt)markingDoubleCallback(this,src,evnt,"Strength"),...
            'TooltipString',getString(message('driving:scenarioApp:MarkingStrengthDescription')));
            hMarkingWidthLabel=createLabelEditPair(this,markingPanel,...
            'MarkingWidth',@(src,evnt)markingDoubleCallback(this,src,evnt,"Width"));
            hMarkingLengthLabel=createLabelEditPair(this,markingPanel,...
            'MarkingLength',@(src,evnt)markingDoubleCallback(this,src,evnt,"Length"));
            hMarkingSpaceLabel=createLabelEditPair(this,markingPanel,...
            'MarkingSpace',@(src,evnt)markingDoubleCallback(this,src,evnt,"Space"));


            multipleMarkingPanel=uipanel(lanesPanel,panelProps{:},'Tag','multipleMarkingPanel');
            hNumMarkingsLabel=createLabelEditPair(this,multipleMarkingPanel,'NumMarkings',@this.numMarkingsCallback,...
            'TooltipString',getString(message('driving:scenarioApp:NumMarkingsDescription')));
            hMarkerRangeLabel=createLabelEditPair(this,multipleMarkingPanel,'MarkerRange',@this.markerRangeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:SegmentRangeDescription')));
            hMarkerSegmentsLabel=createLabel(this,multipleMarkingPanel,'MarkerSegments');
            createEditbox(this,multipleMarkingPanel,'MarkerSegments',@this.markerSegmentsCallback,'popupmenu');

            createToggle(this,lanesPanel,'ShowLaneTypes');
            laneTypePanel=uipanel(lanesPanel,panelProps{:},'Tag','laneTypePanel');

            createEditbox(this,lanesPanel,'SelectedType',@this.selectedLaneTypeCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:SelectedLaneTypeDescription')));

            hLaneTypeLabel=createLabel(this,lanesPanel,'LaneType');
            createEditbox(this,laneTypePanel,'LaneType',@this.laneTypeCallback,'popupmenu');
            hLaneTypeColorLabel=createLabelEditPair(this,lanesPanel,...
            'LaneTypeColor',@this.laneTypeColorCallback,...
            'TooltipString',getString(message('driving:scenarioApp:LaneTypeColorDescription')));
            hLaneTypeStrengthLabel=createLabelEditPair(this,lanesPanel,...
            'LaneTypeStrength',@(src,evnt)laneTypeStrengthCallback(this,src,evnt,"Strength"),...
            'TooltipString',getString(message('driving:scenarioApp:LaneTypeStrengthDescription')));
            spacing=2;
            labelInset=3;
            labelHeight=20-labelInset;
            leftInset=13;

            layout=matlabshared.application.layout.GridBagLayout(lanesPanel,...
            'VerticalGap',spacing,...
            'HorizontalGap',spacing,...
            'HorizontalWeights',[0,1],...
            'VerticalWeights',[0,0,0]);
            labelConstraints={...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'Anchor','SouthWest',...
            'TopInset',labelInset,...
            'MinimumHeight',labelHeight};
            add(layout,hNumLanesLabel,1,1,'LeftInset',leftInset,labelConstraints{:});
            add(layout,this.hNumLanes,1,2,'Fill','Horizontal');
            add(layout,hLaneWidthLabel,2,1,'LeftInset',leftInset,labelConstraints{:});
            add(layout,this.hLaneWidth,2,2,'Fill','Horizontal');
            add(layout,this.hShowLaneTypes,3,1,'LeftInset',leftInset,'Fill','Horizontal');
            add(layout,this.hSelectedType,3,2,'TopInset',3,'Fill','Horizontal');
            add(layout,this.hShowMarking,4,1,'LeftInset',leftInset,'Fill','Horizontal');
            add(layout,this.hSelectedMarking,4,2,'TopInset',3,'Fill','Horizontal');
            add(layout,this.hMarkerSelectionCheckbox,5,[1,2],'LeftInset',leftInset,...
            'MinimumWidth',layout.getMinimumWidth(this.hMarkerSelectionCheckbox)+20,'Anchor','West');
            this.hLanesPanel=lanesPanel;
            this.LanesLayout=layout;
            laneTypeLayout=matlabshared.application.layout.GridBagLayout(laneTypePanel,...
            'VerticalGap',spacing+2,...
            'HorizontalGap',spacing);
            laneTypeLabelInset=-spacing;
            laneTypeLeftInset=leftInset+5;
            add(laneTypeLayout,this.hLaneType,2,1,'LeftInset',leftInset,'Fill','Horizontal');

            add(laneTypeLayout,hLaneTypeLabel,1,1,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',laneTypeLabelInset,...
            'LeftInset',laneTypeLeftInset,...
            'Fill','Horizontal');
            add(laneTypeLayout,hLaneTypeColorLabel,1,2,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',laneTypeLabelInset,...
            'Fill','Horizontal');
            add(laneTypeLayout,hLaneTypeStrengthLabel,1,3,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',laneTypeLabelInset,...
            'Fill','Horizontal');

            add(laneTypeLayout,this.hLaneType,2,1,...
            'LeftInset',laneTypeLeftInset,...
            'Fill','Horizontal');
            add(laneTypeLayout,this.hLaneTypeColor,2,2,...
            'Fill','Horizontal');
            add(laneTypeLayout,this.hLaneTypeStrength,2,3,...
            'Fill','Horizontal');
            this.hLaneTypePanel=laneTypePanel;
            this.LaneTypeLayout=laneTypeLayout;
            markingLayout=matlabshared.application.layout.GridBagLayout(markingPanel,...
            'VerticalGap',spacing+5,...
            'HorizontalGap',spacing);
            markingLabelInset=-spacing;
            markingLeftInset=leftInset+2;

            add(markingLayout,hMarkingTypeLabel,1,1,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingColorLabel,1,2,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset-9,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingStrengthLabel,1,3,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset-9,...
            'Fill','Horizontal');

            add(markingLayout,this.hMarkingType,2,1,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');
            add(markingLayout,this.hMarkingColor,2,2,...
            'Fill','Horizontal');
            add(markingLayout,this.hMarkingStrength,2,3,...
            'Fill','Horizontal');

            add(markingLayout,hMarkingWidthLabel,3,1,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingLengthLabel,3,2,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingSpaceLabel,3,3,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'Fill','Horizontal');

            add(markingLayout,this.hMarkingWidth,4,1,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');
            add(markingLayout,this.hMarkingLength,4,2,...
            'Fill','Horizontal');
            add(markingLayout,this.hMarkingSpace,4,3,...
            'Fill','Horizontal');
            this.hMarkingPanel=markingPanel;
            this.MarkingLayout=markingLayout;


            multipleMarkingLayout=matlabshared.application.layout.GridBagLayout(multipleMarkingPanel,...
            'VerticalGap',spacing+5,...
            'HorizontalWeights',[0,1],...
            'VerticalWeights',[0,0,0],...
            'HorizontalGap',spacing);


            add(multipleMarkingLayout,hNumMarkingsLabel,1,1,...
            'MinimumHeight',labelHeight+13,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'LeftInset',markingLeftInset,...
            'TopInset',labelInset);
            add(multipleMarkingLayout,this.hNumMarkings,1,2,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');

            add(multipleMarkingLayout,hMarkerRangeLabel,2,1,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'LeftInset',markingLeftInset,...
            'MinimumHeight',labelHeight);
            add(multipleMarkingLayout,this.hMarkerRange,2,2,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');

            add(multipleMarkingLayout,hMarkerSegmentsLabel,3,1,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'MinimumHeight',labelHeight,...
            'LeftInset',markingLeftInset);
            add(multipleMarkingLayout,this.hMarkerSegments,3,2,...
            'MinimumWidth',layout.getMinimumWidth([hNumLanesLabel,hLaneWidthLabel]),...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');

            this.hMultipleMarkingPanel=multipleMarkingPanel;
            this.MultipleMarkingLayout=multipleMarkingLayout;

            topInset=-4;
            rightInset=-5;
            [~,h]=getMinimumSize(layout);
            layout.setConstraints(lanesPanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
            [~,h]=getMinimumSize(this.LaneTypeLayout);
            layout.setConstraints(laneTypePanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
            [~,h]=getMinimumSize(this.MarkingLayout);
            layout.setConstraints(markingPanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
            [~,h]=getMinimumSize(this.MultipleMarkingLayout);
            layout.setConstraints(multipleMarkingPanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
        end

        function addLanesWidgetsToLayout(this,rowCount)


            labelInset=3;
            labelLeftInset=5;
            layout=this.Layout;
            layout.add(this.hShowLanes,rowCount,1,...
            'LeftInset',labelLeftInset,...
            'TopInset',labelInset,...
            'Anchor','NorthWest',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowLanes)+20);
            if numel(getAllLaneNames(this))>1
                layout.add(this.hSelectedLane,rowCount,[2,size(layout.Grid,2)],...
                'Anchor','NorthEast',...
                'Fill','Horizontal');
            end
        end

        function laneNames=getAllLaneNames(~)


            laneNames={'lane'};
        end

        function spec=getLaneSpecification(this,index)




            if nargin<2
                index=this.SelectedLane;
            end

            road=getSpecification(this);
            lanes=road.Lanes;
            if isempty(lanes)
                spec=lanespec.empty;
            else
                spec=lanes(index);
            end
        end

        function setLaneSpecification(this,spec,index)



            if nargin<3
                index=this.SelectedLane;
            end
            road=getSpecification(this);
            allLanes=road.Lanes;
            if isnumeric(allLanes)



                allLanes=spec;
            elseif isa(allLanes,'lanespec')&&isa(spec,'lanespec')
                allLanes(index)=spec;
            else
                allLanes=spec;
            end
            setProperty(this,'Lanes',allLanes);
        end

        function[ls,lsArray]=getSelectedRoadSegment(this,lsData)
            lsArray=[];
            ls=lsData;
            if isa(lsData,'compositeLaneSpec')
                lsArray=lsData.LaneSpecification;
                ls=lsArray(this.SelectedRoadSegment);
            end
        end
    end
end



