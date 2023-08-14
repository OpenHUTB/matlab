classdef ScenarioAnnotationDialog<dialogmgr.DCTableForm




    properties
hVisual
    end

    properties(SetObservable)
        ShowName=true;
        ShowPosition=false;
        ShowAltitude=false;
        ShowSpeed=false;
        ShowAzEl=false;
        ShowRange=false;
        ShowRadialSpeed=false;
    end
    methods
        function this=ScenarioAnnotationDialog(hVisual)
            this.Name='Annotations';
            this.hVisual=hVisual;
        end
        function set.ShowName(this,value)
            this.ShowName=logical(value);
            updateVisual(this);
        end
        function set.ShowPosition(this,value)
            this.ShowPosition=logical(value);
            updateVisual(this);
        end
        function set.ShowAltitude(this,value)
            this.ShowAltitude=logical(value);
            updateVisual(this);
        end
        function set.ShowSpeed(this,value)
            this.ShowSpeed=logical(value);
            updateVisual(this);
        end
        function set.ShowAzEl(this,value)
            this.ShowAzEl=logical(value);
            updateVisual(this);
        end
        function set.ShowRange(this,value)
            this.ShowRange=logical(value);
            updateVisual(this);
        end
        function set.ShowRadialSpeed(this,value)
            this.ShowRadialSpeed=logical(value);
            updateVisual(this);
        end
    end

    methods(Access=protected)

        function initTable(this)
            this.InterColumnSpacing=2;
            this.InterRowSpacing=2;
            this.InnerBorderSpacing=4;
            this.ColumnWidths={'min','min','min','max','min','min'};
            this.HorizontalAlignment={'right','left','right','left','right','left'};



            c=uicheckbox(this,'label',getString(message('phased:scopes:SVName')));
            c.Tag='NameCDTag';
            c.TooltipString=getString(message('phased:scopes:SVNameTT'));
            connectPropertyAndControl(this,'ShowName',c);


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVPosition')));
            c.Tag='PositionCDTag';
            c.TooltipString=getString(message('phased:scopes:SVPositionTT'));
            connectPropertyAndControl(this,'ShowPosition',c);
            this.newrow;


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVAltitude')));
            c.Tag='AltitudeCDTag';
            c.TooltipString=getString(message('phased:scopes:SVAltitudeTT'));
            connectPropertyAndControl(this,'ShowAltitude',c);


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVSpeed')));
            c.Tag='SpeedCDTag';
            c.TooltipString=getString(message('phased:scopes:SVSpeedTT'));
            connectPropertyAndControl(this,'ShowSpeed',c);
            this.newrow;


            uihline(this);
            this.mergecols(1:6);
            this.newrow;
            this.mergecols(1:4);
            uitext(this,'Relative measurements:','FontWeight','bold');
            this.newrow;


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVAzEl')));
            c.Tag='AzElCDTag';
            c.TooltipString=getString(message('phased:scopes:SVAzElTT'));
            connectPropertyAndControl(this,'ShowAzEl',c);


            c=uicheckbox(this,'label',getString(message('phased:scopes:SVRange')));
            c.Tag='RangeCDTag';
            c.TooltipString=getString(message('phased:scopes:SVRangeTT'));
            connectPropertyAndControl(this,'ShowRange',c);



            c=uicheckbox(this,'label',getString(message('phased:scopes:SVRadialSpeed')));
            c.Tag='RadialSpeedCDTag';
            c.TooltipString=getString(message('phased:scopes:SVRadialSpeedTT'));
            connectPropertyAndControl(this,'ShowRadialSpeed',c);
            this.newrow;
        end
        function updateVisual(this)

            if~isempty(this.hVisual.lastTime)
                update(this.hVisual);
            end
        end
    end
end
