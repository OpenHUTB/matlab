classdef ScenarioSceneDialog<dialogmgr.DCTableForm



    properties
hVisual
uiRadars
    end

    properties(Dependent,SetObservable)
ReferenceRadar
Title
TrailLength
ShowBeam
BeamWidth
BeamRange
BeamSteering
ShowLegend
ShowGround
    end
    properties(Dependent)
RadarNames
    end
    properties(Access=private)
        pTrailLength=500
        pShowBeam=2
        pBeamWidth=15
        pBeamRange=1000
        pBeamSteering=[0;0]
        pShowLegend=false
    end

    properties(SetObservable)
        pShowReferenceRadarProp=true
    end
    methods
        function this=ScenarioSceneDialog(hVisual)
            this.Name='Scene';
            this.hVisual=hVisual;
        end
        function set.RadarNames(this,value)
            if this.ReferenceRadar>numel(value)
                this.ReferenceRadar=1;
            end
            if numel(value)==1
                this.pShowReferenceRadarProp=false;
            else
                this.pShowReferenceRadarProp=true;
            end
            this.uiRadars.String=value;
        end
        function value=get.RadarNames(this)

            value=this.hVisual.RadarNames;
        end
        function set.ReferenceRadar(this,value)
            this.hVisual.pReferenceRadar=value;

            this.ShowBeam=this.ShowBeam;

        end
        function value=get.ReferenceRadar(this)
            value=this.hVisual.ReferenceRadar;
        end
        function set.Title(this,value)
            this.hVisual.hTitle.String=value;
        end

        function value=get.Title(this)
            value=this.hVisual.hTitle.String;
        end
        function set.TrailLength(this,value)
            this.pTrailLength=value;
            if~isempty(this.hVisual.Trajectories)
                trajectories=this.hVisual.Trajectories;
                numTrajectories=numel(trajectories);
                N=value;
                if isscalar(N)
                    N=N*ones(numTrajectories,1);
                end
                for k=1:numTrajectories
                    trajectories(k).MaximumNumPoints=N(k);
                end
            end
        end
        function value=get.TrailLength(this)
            value=this.pTrailLength;
        end
        function set.ShowLegend(this,value)
            this.pShowLegend=logical(value);
            if~isempty(this.hVisual.Beam)
                if value
                    legend(this.hVisual.Axes,'show');
                else
                    legend(this.hVisual.Axes,'hide');
                end
            end
        end
        function value=get.ShowLegend(this)
            value=this.pShowLegend;
        end
        function set.ShowGround(this,value)


            if value
                this.hVisual.Ground.Visible='on';
            else
                this.hVisual.Ground.Visible='off';
            end
        end
        function value=get.ShowGround(this)
            if strcmp(this.hVisual.Ground.Visible,'on')
                value=true;
            else
                value=false;
            end
        end
        function set.ShowBeam(this,value)
            this.pShowBeam=value;
            if~isempty(this.hVisual.Beam)
                if value==1
                    set(this.hVisual.Beam,'Visible','off');
                elseif value==2
                    set(this.hVisual.Beam,'Visible','off');
                    this.hVisual.Beam(this.ReferenceRadar).Visible='on';
                else
                    set(this.hVisual.Beam,'Visible','on');
                end
            end
            updateVisual(this);
        end
        function value=get.ShowBeam(this)
            value=this.pShowBeam;
        end
        function set.BeamWidth(this,value)
            this.pBeamWidth=value;
            if~isempty(this.hVisual.Beam)
                this.hVisual.resetBeam();
            end
        end
        function value=get.BeamWidth(this)
            value=this.pBeamWidth;
        end
        function set.BeamRange(this,value)
            this.pBeamRange=value;
            if~isempty(this.hVisual.Beam)
                this.hVisual.resetBeam();
            end
        end
        function value=get.BeamRange(this)
            value=this.pBeamRange;
        end
        function set.BeamSteering(this,value)
            this.pBeamSteering=value;
            updateVisual(this)
        end
        function value=get.BeamSteering(this)
            value=this.pBeamSteering;
        end
    end

    methods(Access=protected)
        function initTable(this)
            this.InterColumnSpacing=2;
            this.InterRowSpacing=2;
            this.InnerBorderSpacing=4;
            this.ColumnWidths={'min','max','min','min','min'};
            this.HorizontalAlignment={'right','left','right','left','left'};



            c=uipopup(this,this.RadarNames,'label',getString(message('phased:scopes:SVRadar')));
            this.uiRadars=c;
            c.Tag='RadarCDTag';
            c.TooltipString=getString(message('phased:scopes:SVRadarTT'));
            connectPropertyAndControl(this,'ReferenceRadar',c,'value');
            setVisibilityOnState(this,...
            {'pShowReferenceRadarProp'},{true},{'RadarCDTag'},true);

            this.mergecols(2:4);
            this.newrow;


            c=uipopup(this,{'None','Reference Radar','All Radars'},'label',getString(message('phased:scopes:SVBeam')));
            c.Tag='BeamCDTag';
            c.TooltipString=getString(message('phased:scopes:SVBeamTT'));
            connectPropertyAndControl(this,'ShowBeam',c,'value');
            this.mergecols(2:4);
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVBeamWidth')));
            c.Tag='BeamWidthCDTag';
            c.TooltipString=getString(message('phased:scopes:SVBeamWidthTT'));
            c.ValidAttributes={this};
            c.ValidationFunction=@validateBeamWidth;
            connectPropertyAndControl(this,'BeamWidth',c);
            this.skipcol;this.skipcol;
            uitext(this,'deg');
            this.mergecols(2:4);
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVBeamRange')));
            c.Tag='BeamRangeCDTag';
            c.TooltipString=getString(message('phased:scopes:SVBeamRangeTT'));
            c.ValidAttributes={this};
            c.ValidationFunction=@validateBeamRange;
            connectPropertyAndControl(this,'BeamRange',c);
            this.skipcol;this.skipcol;
            uitext(this,'m');
            this.mergecols(2:4);
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVBeamSteering')));
            c.Tag='BeamSteeringCDTag';
            c.TooltipString=getString(message('phased:scopes:SVBeamSteeringTT'));
            c.ValidAttributes={this};
            c.ValidationFunction=@validateBeamSteering;
            connectPropertyAndControl(this,'BeamSteering',c);
            this.skipcol;this.skipcol;
            uitext(this,'deg');
            this.mergecols(2:4);
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVTrail')));
            c.Tag='TrailCDTag';
            c.TooltipString=getString(message('phased:scopes:SVTrailTT'));
            c.ValidAttributes={this};
            c.ValidationFunction=@validateTrailLength;
            connectPropertyAndControl(this,'TrailLength',c);
            this.skipcol;this.skipcol;
            uitext(this,'points');
            this.mergecols(2:4);
            this.newrow;


            c=uiedit(this,'label',getString(message('phased:scopes:SVTitle')),'HorizontalAlignment','left');
            c.Tag='TitleCDTag';
            c.TooltipString=getString(message('phased:scopes:SVTitleTT'));

            connectPropertyAndControl(this,'Title',c);
            this.mergecols(2:4);
            this.newrow;


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVLegend')));
            c.Tag='LegendCDTag';
            c.TooltipString=getString(message('phased:scopes:SVLegendTT'));
            connectPropertyAndControl(this,'ShowLegend',c);

            c=uicheckbox(this,'label','Ground:');
            c.Tag='GroundCDTag';
            c.TooltipString=getString(message('phased:scopes:SVGroundTT'));
            connectPropertyAndControl(this,'ShowGround',c);
            this.newrow;

        end
        function updateVisual(this)

            if~isempty(this.hVisual.lastTime)
                update(this.hVisual);
            end
        end
    end
end

function validateBeamWidth(value,varargin)
    this=varargin{3}{1};
    numRadars=length(this.RadarNames);
    setupCalled=~isempty(this.hVisual.lastTime);
    if setupCalled&&...
        (size(value,1)>2||(size(value,2)~=numRadars&&size(value,2)~=1))
        if numRadars==1
            error(message('phased:scopes:expectedScalarVector',varargin{2},'column',2));
        else
            error(message('phased:scopes:expectedScalarVectorMatrix',varargin{2},2,numRadars));
        end
    end
    sigdatatypes.validateAngle(value,varargin{1},varargin{2},{'positive','<=',360});
end

function validateBeamRange(value,varargin)
    this=varargin{3}{1};
    numRadars=length(this.RadarNames);
    setupCalled=~isempty(this.hVisual.lastTime);
    if setupCalled&&...
        (size(value,1)~=1||(size(value,2)~=numRadars&&size(value,2)~=1))
        if numRadars==1
            error(message('phased:scopes:expectedScalar',varargin{2}));
        else
            error(message('phased:scopes:expectedScalarVector',varargin{2},'row',numRadars));
        end
    end
    sigdatatypes.validateDistance(value,varargin{1},varargin{2});
end
function validateBeamSteering(value,varargin)
    this=varargin{3}{1};
    numRadars=length(this.RadarNames);
    setupCalled=~isempty(this.hVisual.lastTime);
    if setupCalled&&...
        (size(value,2)~=numRadars&&size(value,2)~=1)
        if numRadars==1
            error(message('phased:scopes:expectedOneColumn',varargin{2}));
        else
            error(message('phased:scopes:expectedOneOrNumColumns',varargin{2},numRadars));
        end
    end
    sigdatatypes.validateAzElAngle(value,varargin{1},varargin{2});
end

function validateTrailLength(value,varargin)
    this=varargin{3}{1};
    setupCalled=~isempty(this.hVisual.lastTime);
    numPlatforms=this.hVisual.NumTrajectories;
    if~isscalar(value)&&setupCalled&&numPlatforms&&numel(value)~=numPlatforms
        error(message('phased:scopes:expectedScalarVector',varargin{2},'row',numPlatforms));
    end
    sigdatatypes.validateIndex(value,varargin{1},varargin{2},{'vector'});
end
