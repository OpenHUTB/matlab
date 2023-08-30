classdef LaneSpecificationSelector<matlab.mixin.SetGet

    properties
        LaneSpecification lanespec
        Selection(1,1)struct=getDefaultSelection()
    end


    properties(Dependent)
        Orientation{mustBeMember(Orientation,{'horizontal','vertical'})}
        MaximizeAxes(1,1)logical
        Parent(1,1)
Visible
        Position(1,4)double
        Units char{mustBeMember(Units,{'pixels','normalized'})}
    end

    properties(SetAccess=protected,Hidden)
Panel
Axes

RoadPatch
LaneTypesPatch
LaneMarkingsPatch
SelectionLine
    end


    events
SelectionChanged
    end


    methods
        function this=LaneSpecificationSelector(varargin)
            panel=matlab.ui.container.Panel(...
            'BorderType','none',...
            'DeleteFcn',@this.onPanelDeleted,...
            'ResizeFcn',@this.onPanelResized);
            this.Panel=panel;
            if nargin>0
                set(this,varargin{:});
            end
            if isempty(this.Parent)
                this.Parent=figure('HandleVisibility','off','MenuBar','none');
            end
            axesInputs=matlabshared.application.structToPVPairs(this.Axes);
            this.Axes=axes('Parent',panel,...
            'Color',[0,0,0],...
            'YLim',[-5,105],...
            'ButtonDownFcn',@this.onAxesClick,...
            axesInputs{:});
            this.SelectionLine=line('Parent',this.Axes,...
            'Color',[0,1,1],...
            'LineWidth',3,...
            'LineStyle',':',...
            'HitTest','off');
            xlabel(this.Axes,getString(message('driving:scenarioApp:BirdsEyeYLabel')));

            updateLanes(this);
            updateSelection(this);
        end


        function set.LaneSpecification(this,newSpec)
            this.LaneSpecification=newSpec;
            updateLanes(this);
            if validateSelection(this,this.Selection)%#ok<*MCSUP>
                updateSelection(this);
            else
                this.Selection=getDefaultSelection();
            end
        end


        function set.Selection(this,newSelection)
            if this.validateSelection(newSelection)
                this.Selection=newSelection;


                updateSelection(this);


                notify(this,'SelectionChanged');
            end
        end

        function set.Parent(this,newParent)
            this.Panel.Parent=newParent;
        end
        function parent=get.Parent(this)
            parent=this.Panel.Parent;
        end

        function set.Visible(this,newVis)
            set(this.Panel,'Visible',newVis);
        end
        function v=get.Visible(this)
            v=this.Panel.Visible;
        end

        function set.Position(this,pos)
            this.Panel.Position=pos;
        end
        function pos=get.Position(this)
            pos=this.Panel.Position;
        end


        function set.Units(this,units)
            this.Panel.Units=units;
        end
        function units=get.Units(this)
            units=this.Panel.Units;
        end

        function set.Orientation(this,orientation)
            if strcmp(orientation,'horizontal')
                upVector=[0,1,0];
            else

                upVector=[-1,0,0];
            end
            this.Axes.CameraUpVector=upVector;
        end

        function orientation=get.Orientation(this)
            upVector=this.Axes.CameraUpVector;
            if isequal(upVector,[0,1,0])
                orientation='horizontal';
            else
                orientation='vertical';
            end
        end

        function set.MaximizeAxes(this,maximize)
            if maximize
                prop='Position';
            else
                prop='OuterPosition';
            end
            this.Axes.(prop)=[0,0,1,1];


            updateYTickLabels(this);
        end
        function maximize=get.MaximizeAxes(this)
            maximize=isequal(this.Axes.Position,[0,0,1,1]);
        end

        function d=double(this)
            d=double(this.Panel);
        end
    end

    methods(Hidden)
        function onPanelDeleted(this,~,~)
            delete(this);
        end

        function onPanelResized(this,~,~)


            updateLanes(this);
            updateSelection(this);
        end

        function b=validateSelection(this,selection)
            b=true;
            lanes=this.LaneSpecification;
            if isempty(lanes)
                return;
            end
            if~isfield(selection,'type')||~isfield(selection,'index')

                b=false;
            elseif strcmp(selection.type,'lane')


                if selection.index>sum(lanes.NumLanes)
                    b=false;
                end
            elseif strcmp(selection.type,'marking')


                if selection.index(1)>numel(lanes.Marking)
                    b=false;
                elseif numel(selection.index)>1




                    marking=lanes.Marking(selection.index(1));
                    if~isa(marking,'driving.scenario.CompositeMarking')||...
                        selection.index(2)>numel(marking.Markings)
                        b=false;
                    end
                end
            else

                b=false;
            end
        end

        function updateLanes(this)

            hAxes=this.Axes;
            lanes=this.LaneSpecification;
            delete(this.RoadPatch);
            delete(this.LaneTypesPatch);
            delete(this.LaneMarkingsPatch);

            if isempty(hAxes)||~ishghandle(hAxes)
                return;
            end
            scenario=drivingScenario;



            rc=[0,0,0;0,100,0];

            road(scenario,rc,'Lanes',lanes);

            rt=scenario.RoadTiles;

            opts=struct(...
            'RoadTileFaceColor',[.8,.8,.8],...
            'RoadTileEdgeColor',[.7,.7,.7],...
            'RoadBorderColor',[0,0,0],...
            'RoadCenterlineColor',[1,1,1],...
            'Centerline','off');


            [this.RoadPatch,~,lmCount,lCount]=driving.scenario.internal.plotRoadTiles(rt,hAxes,opts);
            this.RoadPatch.EdgeColor='none';


            this.LaneTypesPatch=driving.scenario.internal.plotLaneTypes(rt,hAxes,opts,lCount);


            this.LaneMarkingsPatch=driving.scenario.internal.plotLaneMarkings(rt,hAxes,lmCount,opts);


            xData=this.RoadPatch.XData;
            xLim=[min(xData(:)),max(xData(:))];
            set(hAxes,'XLim',xLim+[-1,1]*diff(xLim)*0.05);



            children=[this.SelectionLine;this.LaneMarkingsPatch;this.LaneTypesPatch;this.RoadPatch];
            hAxes.Children=children;
            set(children,'HitTest','off');
            updateYTickLabels(this);
        end

        function updateYTickLabels(this)
            hAxes=this.Axes;
            yTicks=hAxes.YTick;
            yTickLabels=cell(1,numel(yTicks));

            for indx=1:numel(yTicks)
                yTickLabels{indx}=sprintf('%g%%',yTicks(indx));
            end

            hAxes.YTickLabel=yTickLabels;
        end

        function updateSelection(this)
            select=this.Selection;
            hAxes=this.Axes;
            lanes=this.LaneSpecification;
            selectLine=this.SelectionLine;
            if isempty(select)||isempty(hAxes)||isempty(lanes)
                set(selectLine,'XData',[],'YData',[]);
                return;
            end

            pos=getpixelposition(hAxes);
            if strcmp(this.Orientation,'horizontal')
                pixels=pos(3);
            else
                pixels=pos(4);
            end
            pixelsPerXData=pixels/diff(hAxes.XLim);


            dists=[0,cumsum([lanes.Width])]-sum([lanes.Width])/2;
            index=select.index;
            if strcmp(select.type,'lane')

                left=dists(index);
                right=dists(index+1);
                top=100;
                bottom=0;
            elseif strcmp(select.type,'marking')
                if numel(index)>1
                    composite=lanes.Marking(index(1));
                    marking=composite.Markings(index(2));
                    ranges=[0,cumsum(composite.SegmentRange)*100];
                    bottom=ranges(index(2));
                    top=ranges(index(2)+1);
                else
                    marking=lanes.Marking(index(1));
                    top=100;
                    bottom=0;
                end
                width=getMaxMarkerWidth(marking)+(selectLine.LineWidth+1)/pixelsPerXData;
                left=dists(index(1))-width/2;
                right=dists(index(1))+width/2;
            end
            set(selectLine,...
            'XData',[left,right,right,left,left],...
            'YData',[top,top,bottom,bottom,top]);
        end

        function onAxesClick(this,hAxes,~)
            x=hAxes.CurrentPoint(1,1);
            y=hAxes.CurrentPoint(1,2);
            lanes=this.LaneSpecification;
            if y>100||y<0||isempty(lanes)
                return;
            end

            widths=[lanes.Width];

            pos=getpixelposition(this.Axes);
            pixelsPerXData=pos(3)/diff(this.Axes.XLim);

            cumsumWidths=[0,cumsum(widths)];
            cumsumWidths=cumsumWidths-cumsumWidths(end)/2;

            pixelsToLaneEdge=(cumsumWidths-x)*pixelsPerXData;
            [~,index]=min(abs(pixelsToLaneEdge));
            type='marking';





            index=checkLaneMarkingIndex(lanes.Marking(index),index,x-cumsumWidths(index),y);

            if isempty(index)
                type='lane';
                index=find(x>cumsumWidths&x<cumsumWidths(end),1,'last');
            end
            if~isempty(index)
                this.Selection=struct('type',type,'index',index);
            end
        end

        function addToDSD(this,hDSD)

            ll(1)=event.listener(this,'SelectionChanged',@(~,~)onSelectionChanged(this,hDSD));
            ll(2)=event.listener(hDSD,'RoadPropertyChanged',@(~,~)onRoadPropertyChanged(hDSD,this));
            ll(3)=event.listener(hDSD,'CurrentRoadChanged',@(~,~)onCurrentRoadChanged(hDSD,this));
            ll(4)=event.listener(hDSD,'ApplicationClosing',@(~,~)onApplicationClosing(this));

            setappdata(this.Parent,'Listeners',ll);

            onCurrentRoadChanged(hDSD,this);

        end
    end
end

function m=getMaxMarkerWidth(marking)

    if isa(marking,'driving.scenario.CompositeMarking')
        m=0;
        for indx=1:numel(marking.Markings)
            m=max(m,getMaxMarkerWidth(marking.Markings(indx)));
        end
    else
        m=getMarkerWidth(marking);
    end

end

function m=getMarkerWidth(marking)

    if marking.Type==LaneBoundaryType.Unmarked
        m=0.2;
    else
        m=marking.Width;
        if marking.Type==LaneBoundaryType.DoubleSolid||...
            marking.Type==LaneBoundaryType.SolidDashed||...
            marking.Type==LaneBoundaryType.DashedSolid||...
            marking.Type==LaneBoundaryType.DashedSolid
            m=m*3;
        end
    end

end

function index=checkLaneMarkingIndex(marking,index,x,y)

    if isa(marking,'driving.scenario.CompositeMarking')
        index2=find(y>[0,cumsum(marking.SegmentRange)*100],1,'last');
        marking=marking.Markings(index2);
        index2=checkLaneMarkingIndex(marking,index2,x,y);
        if isempty(index2)
            index=[];
        else
            index=[index,index2];
        end
    elseif abs(x)>getMarkerWidth(marking)/2
        index=[];
    end

end

function selection=getDefaultSelection()

    selection=struct('type','lane','index',1);

end

function onApplicationClosing(hSelector)

    delete(hSelector.Parent);
end

function onCurrentRoadChanged(hDSD,hSelector)

    index=hDSD.RoadProperties.SpecificationIndex;
    roads=hDSD.RoadSpecifications;
    if index>numel(roads)
        hSelector.LaneSpecification=lanespec.empty;
    else
        hSelector.LaneSpecification=roads(index).Lanes;
    end
end

function onRoadPropertyChanged(hDSD,hSelector)

    index=hDSD.RoadProperties.SpecificationIndex;
    hSelector.LaneSpecification=hDSD.RoadSpecifications(index).Lanes;

end

function onSelectionChanged(hSelector,hDSD)

    selection=hSelector.Selection;

    roadProps=hDSD.RoadProperties;

    sheet=roadProps.CurrentPropertySheet;
    if strcmp(selection.type,'lane')
        sheet.SelectedType=selection.index;
        sheet.SelectedMarking=1;
    else
        sheet.SelectedMarking=selection.index(1);
        if numel(selection.index)>1
            sheet.MultiSelected=selection.index(2);
        end
    end

    roadProps.update;
end



