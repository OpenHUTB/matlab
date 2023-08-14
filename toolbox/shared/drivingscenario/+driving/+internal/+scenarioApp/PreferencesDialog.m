classdef PreferencesDialog<matlabshared.application.Dialog&...
    matlabshared.application.ComponentBanner&...
    driving.internal.scenarioApp.UITools

    properties(Dependent)
MajorArrowMoveDistance
MinorArrowMoveDistance
    end

    properties(Hidden)
hMajorArrowMoveDistance
hMinorArrowMoveDistance
    end

    methods
        function this=PreferencesDialog(varargin)
            this@matlabshared.application.Dialog(varargin{:});
        end

        function close(this)
            close@matlabshared.application.Dialog(this);
            clearAllMessages(this);
        end

        function refresh(this)


            this.hMajorArrowMoveDistance.String=this.MajorArrowMoveDistance;
            this.hMinorArrowMoveDistance.String=this.MinorArrowMoveDistance;

            clearAllMessages(this);
        end

        function set.MajorArrowMoveDistance(~,major)
            pref=driving.internal.scenarioApp.Preferences.Instance;
            pref.MajorArrowMoveDistance=major;
        end

        function major=get.MajorArrowMoveDistance(~)
            pref=driving.internal.scenarioApp.Preferences.Instance;
            major=pref.MajorArrowMoveDistance;
        end

        function set.MinorArrowMoveDistance(~,minor)
            pref=driving.internal.scenarioApp.Preferences.Instance;
            pref.MinorArrowMoveDistance=minor;
        end

        function minor=get.MinorArrowMoveDistance(~)
            pref=driving.internal.scenarioApp.Preferences.Instance;
            minor=pref.MinorArrowMoveDistance;
        end
    end

    methods(Hidden)

        function success=apply(this,~,~)

            success=false;
            clearAllMessages(this);

            major=str2double(this.hMajorArrowMoveDistance.String);
            minor=str2double(this.hMinorArrowMoveDistance.String);

            err='';
            if isnan(major)||major<=0
                err='driving:scenarioApp:MajorArrowMoveDistanceError';
            elseif isnan(minor)||minor<=0
                err='driving:scenarioApp:MinorArrowMoveDistanceError';
            end

            if~isempty(err)

                errorMessage(this,getString(message(err)),err);
                return
            end

            this.MajorArrowMoveDistance=major;
            this.MinorArrowMoveDistance=minor;

            saveToCache(driving.internal.scenarioApp.Preferences.Instance);
            success=true;
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:PreferencesTitle'));
        end

        function tag=getTag(~)
            tag='Preferences';
        end
    end

    methods(Access=protected)

        function fig=createFigure(this)

            if ispc
                width=250;
            else
                width=280;
            end
            fig=createFigure@matlabshared.application.Dialog(this,...
            'Position',getCenterPosition(this.Application,[width,200]));

            hpanel=this.hPanel;
            set(hpanel,'Tag','ScenarioCanvasPreferencesPanel',...
            'Title',getString(message('driving:scenarioApp:ScenarioCanvasPreferencesPanelTitle')));

            majorLabel=createLabelEditPair(this,hpanel,'MajorArrowMoveDistance',@this.genericCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MajorArrowMoveDistanceDescription')));
            minorLabel=createLabelEditPair(this,hpanel,'MinorArrowMoveDistance',@this.genericCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MinorArrowMoveDistanceDescription')));

            layout=matlabshared.application.layout.ScrollableGridBagLayout(hpanel,...
            'VerticalGap',3,...
            'HorizontalGap',3,...
            'HorizontalWeights',[0,1],...
            'VerticalWeights',[0,1]);
            labelWidth=layout.getMinimumWidth([majorLabel,minorLabel]);

            topInset=layout.LabelOffset;
            labelInputs={'Anchor','NorthWest',...
            'TopInset',topInset,...
            'MinimumHeight',20-topInset,...
            'MinimumWidth',labelWidth};
            add(layout,majorLabel,1,1,labelInputs{:},'TopInset',topInset+15);
            add(layout,this.hMajorArrowMoveDistance,1,2,'Fill','Horizontal','TopInset',15);
            add(layout,minorLabel,2,1,labelInputs{:});
            add(layout,this.hMinorArrowMoveDistance,2,2,'Anchor','North','Fill','Horizontal');
            update(layout,true);
        end
    end
end



