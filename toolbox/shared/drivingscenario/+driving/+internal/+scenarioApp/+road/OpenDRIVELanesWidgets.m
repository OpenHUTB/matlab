classdef OpenDRIVELanesWidgets<driving.internal.scenarioApp.UITools

    properties

        ShowLanes=false


        ShowMarking=false
        SelectedLane=1
        SelectedMarking=1
hNumLanes
    end

    properties(Hidden)

hLanePicker
hShowLanes
hLanesPanel
LanesLayout

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
        BoundaryTypes=LaneBoundaryType(["Unmarked","Solid","Dashed",...
        "DoubleSolid","DoubleDashed","SolidDashed","DashedSolid"])
        BoundaryStrings=[string(getString(message('driving:scenarioApp:MarkingTypeUnmarked'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeSolid'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDoubleSolid'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDoubleDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeSolidDashed'))),...
        string(getString(message('driving:scenarioApp:MarkingTypeDashedSolid')))]
    end

    methods
        function update(this,road)
            if nargin<2
                road=getSpecification(this);
            end
            if isempty(road)
                set([this.hNumLanes,this.hLaneWidth,this.hMarkingColor...
                ,this.hMarkingStrength,this.hMarkingWidth...
                ,this.hMarkingLength,this.hMarkingSpace],...
                'String','','Enable','off');
                set([this.hSelectedMarking,this.hMarkingType],'Enable',...
                'off','String',{''},'Value',1);
                return;
            end

            enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
            if strcmp(enable,'on')
                enable=IsEnableLanes(this,road);
            end



            numLanes='';
            laneWidth='';
            markingNames=" ";
            lmIndex=this.SelectedMarking;
            lmTypeIndex=1;
            lmColor='';
            lmStrength='';
            lmWidth='';
            lmLength='';
            lmSpace='';
            ls=getLaneSpecification(this);
            laneEnable='off';
            solidPropsEnable='off';
            dashedPropsEnable='off';
            if~isempty(ls)
                ls=ls(this.SelectedLane);


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
                    markingNames(kndx)=kndx+":"+this.BoundaryStrings(this.BoundaryTypes==marking(kndx).lm(1).Type);
                end
                lm=marking(lmIndex).lm(1);
                lmTypeIndex=find(lm.Type==this.BoundaryTypes);
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
            else
                lmIndex=1;
            end

            set(this.hNumLanes,'String',numLanes,'Enable',enable);
            set(this.hLaneWidth,'String',laneWidth,'Enable',laneEnable);
            set(this.hSelectedMarking,...
            'String',markingNames,...
            'Value',lmIndex,...
            'Enable',laneEnable);
            set(this.hMarkingType,...
            'String',this.BoundaryStrings,...
            'Value',lmTypeIndex,...
            'Enable',laneEnable);
            set(this.hMarkingColor,'String',lmColor,'Enable',solidPropsEnable);
            set(this.hMarkingStrength,'String',lmStrength,'Enable',solidPropsEnable);
            set(this.hMarkingWidth,'String',lmWidth,'Enable',solidPropsEnable);
            set(this.hMarkingLength,'String',lmLength,'Enable',dashedPropsEnable);
            set(this.hMarkingSpace,'String',lmSpace,'Enable',dashedPropsEnable);
            this.hShowLanes.Enable=enable;
            this.hShowRoadCenters.Enable=enable;
            if strcmp(enable,'off')
                this.ShowLanes=0;
                this.ShowRoadCenters=0;
                setToggleValue(this,'ShowLanes',false);
                this.ShowLanes=logical(getToggleValue(this,'ShowLanes'));
                matlabshared.application.setToggleCData(this.hShowLanes);
                setToggleValue(this,'ShowRoadCenters',0);
                this.ShowRoadCenters=logical(getToggleValue(this,'ShowRoadCenters'));
                matlabshared.application.setToggleCData(this.hShowRoadCenters);
            else
                this.ShowLanes=1;
                this.ShowRoadCenters=1;
                this.ShowLanes=logical(getToggleValue(this,'ShowLanes'));
                matlabshared.application.setToggleCData(this.hShowLanes);
                this.ShowRoadCenters=logical(getToggleValue(this,'ShowRoadCenters'));
                matlabshared.application.setToggleCData(this.hShowRoadCenters);
            end
            updateLayout(this);
        end

        function enable=IsEnableLanes(this,roadSpec)
            enable='on';
            ls=roadSpec.Lanes;
            if~isempty(ls)
                if numel(ls)>1||ls.IsAsymmetric
                    enable='off';
                else
                    isVariableMarkers=false;
                    for lmndx=1:numel(ls.Marking)
                        if numel(ls.Marking(lmndx).lm)>1
                            isVariableMarkers=true;
                            break;
                        end
                    end
                    if isVariableMarkers
                        enable='off';
                    end
                end
            end
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
                vwLanesLayout=[0,0,0];
                if this.ShowMarking
                    if~lanesLayout.contains(markingPanel)
                        insert(lanesLayout,'row',4)
                        add(lanesLayout,markingPanel,4,[1,2]);
                    end
                    markingPanel.Visible='on';
                    vwLanesLayout=[0,0,0,1];
                elseif lanesLayout.contains(markingPanel)
                    markingPanel.Visible='off';
                    lanesLayout.remove(markingPanel);
                    lanesLayout.clean;
                end


                [~,h]=getMinimumSize(lanesLayout);
                setConstraints(parentLayout,this.hLanesPanel,'MinimumHeight',h);
                lanesLayout.VerticalWeights=vwLanesLayout;
            else
                lanesPanel.Visible='off';
                if parentLayout.contains(lanesPanel)
                    parentLayout.remove(lanesPanel);
                    parentLayout.clean;
                end
            end
            matlabshared.application.setToggleCData(this.hShowLanes);
            matlabshared.application.setToggleCData(this.hShowMarking);
        end

        function numLanesCallback(this,src,~)

            newValue=strToNum(this,get(src,'String'));
            if isempty(newValue)

                setProperty(this,'Lanes',[]);
                update(this);

                this.SelectedMarking=1;
                return;
            end


            try
                roadSpec=getSpecification(this);
                ls=roadSpec.Lanes;
                if isempty(ls)



                    rw=roadSpec.Width;
                    ls=driving.scenario.internal.lanesection(newValue);
                    lw=round(((rw-0.15)/sum(newValue)),5);

                    if lw<0.5
                        lw=0.5;
                    end
                    ls.Width=lw;
                else

                    width=ls.Width;
                    numWidth=length(width);
                    totalLanes=sum(newValue);

                    validateattributes(totalLanes,{'numeric'},{'integer',...
                    'finite','positive','<=',30},'Dialog','NumLanes');
                    if numWidth>totalLanes
                        width=width(1:totalLanes);
                    elseif numWidth<totalLanes


                        width(end+1:totalLanes)=width(end);
                    end
                    marking=ls.Marking;



                    current_numLanes=ls.NumLanes;
                    try
                        if(isscalar(current_numLanes)~=isscalar(newValue))||...
                            ((length(newValue)>1)&&newValue(1)~=current_numLanes(1))
                            ls=driving.scenario.internal.lanesection(newValue,'Width',width);
                        else
                            numMarking=length(marking);
                            if numMarking>totalLanes+1
                                marking=marking(1:totalLanes+1);
                            elseif numWidth<totalLanes
                                for mndx=length(marking):totalLanes
                                    marking(mndx).lm=driving.scenario.internal.roadLaneMarking('Dashed','Offset',0);
                                end
                                marking(end+1).lm=driving.scenario.internal.roadLaneMarking('Solid','Offset',0);
                            end
                            if numel(ls)>1
                                ls=driving.scenario.internal.lanesection(newValue,'Width',width,'Marking',marking,'IsAsymmetric',ls(1).IsAsymmetric,'Vertices',0,'IsOpenDRIVE',ls(1).IsOpenDRIVE);
                            else
                                ls=driving.scenario.internal.lanesection(newValue,'Width',width,'Marking',marking,'IsAsymmetric',ls.IsAsymmetric,'Vertices',ls.Vertices,'IsOpenDRIVE',ls.IsOpenDRIVE);
                            end
                        end
                    catch ME %#ok<NASGU>







                        ls=lanespec(newValue);
                    end
                end

                this.SelectedMarking=1;
            catch ME %#ok<NASGU>
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:InvalidNumLanes')),...
                'driving:scenarioApp:InvalidNumLanes');
                return;
            end
            setLaneSpecification(this,ls);
            update(this);
        end

        function laneWidthCallback(this,src,~)

            newValue=strToNum(this,get(src,'String'));
            if isempty(newValue)
                newValue=NaN;
            end
            ls=getLaneSpecification(this);


            try
                newValue=round(newValue,5);
                if numel(ls)>1
                    ls=driving.scenario.internal.lanesection(ls(1).NumLanes,'Width',newValue,'Marking',ls(1).Marking,'IsAsymmetric',ls(1).IsAsymmetric,'Vertices',0,'IsOpenDRIVE',ls(1).IsOpenDRIVE);
                else
                    ls=driving.scenario.internal.lanesection(ls.NumLanes,'Width',newValue,'Marking',ls.Marking,'IsAsymmetric',ls.IsAsymmetric,'Vertices',ls.Vertices,'IsOpenDRIVE',ls.IsOpenDRIVE);
                end
            catch ME %#ok<NASGU>
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:InvalidLaneWidth')),...
                'driving:scenarioApp:InvalidLaneWidth');
                return;
            end
            setLaneSpecification(this,ls);
        end

        function markingTypeCallback(this,src,~)

            try

                newValue=LaneBoundaryType(this.BoundaryTypes(get(src,'Value')));
                ls=getLaneSpecification(this);
                marking=ls.Marking;


                clm=marking(this.SelectedMarking);
                newValue=driving.scenario.internal.roadLaneMarking(newValue,'Offset',0);
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
                marking(this.SelectedMarking).lm=newValue;

                ls=driving.scenario.internal.lanesection(ls.NumLanes,'Width',ls.Width,'Marking',marking,'IsAsymmetric',ls.IsAsymmetric,'Vertices',ls.Vertices,'IsOpenDRIVE',ls.IsOpenDRIVE);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            setLaneSpecification(this,ls);
        end

        function markingColorCallback(this,src,~)

            try
                newValue=get(src,'String');

                newValueColor=strToNum(this,newValue);
                if isnan(newValueColor)

                    newValueColor=newValue;
                end
                ls=getLaneSpecification(this);
                marking=ls.Marking;
                marking(this.SelectedMarking).lm.Color=newValueColor;

                ls=driving.scenario.internal.lanesection(ls.NumLanes,'Width',ls.Width,'Marking',marking,'IsAsymmetric',ls.IsAsymmetric,'Vertices',ls.Vertices,'IsOpenDRIVE',ls.IsOpenDRIVE);
            catch ME %#ok<NASGU>
                update(this);
                errorMessage(this,getString(message('driving:scenarioApp:InvalidMarkingColor')),...
                'driving:scenarioApp:InvalidMarkingColor');
                return;
            end
            setLaneSpecification(this,ls);
        end

        function markingDoubleCallback(this,src,~,propName)

            try
                newValue=round(strToNum(this,get(src,'String')),5);
                ls=getLaneSpecification(this);
                marking=ls.Marking;
                marking(this.SelectedMarking).lm.(propName)=newValue;

                ls=driving.scenario.internal.lanesection(ls.NumLanes,'Width',ls.Width,'Marking',marking,'IsAsymmetric',ls.IsAsymmetric,'Vertices',ls.Vertices,'IsOpenDRIVE',ls.IsOpenDRIVE);
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
            setLaneSpecification(this,ls);
        end

        function selectedMarkingCallback(this,src,eventData)

            currentValue=this.SelectedMarking;
            newValue=src.Value;
            defaultPopupCallback(this,src,eventData);
            if currentValue~=newValue

                this.ShowMarking=true;
                setToggleValue(this,'ShowMarking',true);
                updateLayout(this);
                update(this);
            end
        end

        function selectedLaneCallback(this,src,ev)
            currentValue=this.SelectedLane;
            newValue=src.Value;
            defaultPopupCallback(this,src,ev);
            if currentValue~=newValue

                this.ShowLanes=true;
                setToggleValue(this,'ShowLanes',true);
                updateLayout(this);
                update(this)
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
            lanesPanel=uipanel(p,...
            'Visible','off',...
            'Tag','lanesPanel',...
            'AutoResizeChildren','off',...
            'BorderType','none');

            hNumLanesLabel=createLabelEditPair(this,lanesPanel,'NumLanes',@this.numLanesCallback,...
            'TooltipString',getString(message('driving:scenarioApp:NumLanesDescription')));

            hLaneWidthLabel=createLabelEditPair(this,lanesPanel,'LaneWidth',@this.laneWidthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:LaneWidthDescription')));

            createToggle(this,lanesPanel,'ShowMarking');
            markingPanel=uipanel(lanesPanel,...
            'Visible','off',...
            'Tag','markingPanel',...
            'AutoResizeChildren','off',...
            'BorderType','none');

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
            spacing=3;
            labelInset=3;
            labelHeight=20-labelInset;
            leftInset=5;

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
            add(layout,hLaneWidthLabel,2,1,'LeftInset',leftInset,labelConstraints{:});
            add(layout,this.hNumLanes,1,2,'Fill','Horizontal');
            add(layout,this.hLaneWidth,2,2,'Fill','Horizontal');
            add(layout,this.hShowMarking,3,1,'LeftInset',leftInset,'Fill','Horizontal');
            add(layout,this.hSelectedMarking,3,2,'TopInset',3,'Fill','Horizontal');
            this.hLanesPanel=lanesPanel;
            this.LanesLayout=layout;

            markingLayout=matlabshared.application.layout.GridBagLayout(markingPanel,...
            'VerticalGap',spacing,...
            'HorizontalGap',spacing);

            markingLabelInset=-spacing;
            markingLeftInset=leftInset+5;
            add(markingLayout,hMarkingTypeLabel,1,1,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'LeftInset',markingLeftInset,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingColorLabel,1,2,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
            'Fill','Horizontal');
            add(markingLayout,hMarkingStrengthLabel,1,3,...
            'MinimumHeight',labelHeight-2,...
            'BottomInset',markingLabelInset,...
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

            topInset=-4;
            rightInset=-5;

            [~,h]=getMinimumSize(layout);
            layout.setConstraints(lanesPanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
            [~,h]=getMinimumSize(this.MarkingLayout);
            layout.setConstraints(markingPanel,...
            'RightInset',rightInset,...
            'TopInset',topInset,...
            'Fill','Both',...
            'MinimumHeight',h);
        end

        function addLanesWidgetsToLayout(this,rowCount)


            labelInset=3;
            layout=this.Layout;
            layout.add(this.hShowLanes,rowCount,1,...
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
            allLanes=road.Lanes(1);
            allLanes(index)=spec;
            setProperty(this,'Lanes',allLanes);
        end
    end
end


