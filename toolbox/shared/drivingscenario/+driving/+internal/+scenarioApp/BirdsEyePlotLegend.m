classdef BirdsEyePlotLegend<handle

    properties
        FirstStruct=struct;
    end

    properties(Dependent)
        Visible;
    end

    properties(Hidden,SetAccess=protected)
BirdsEyePlot
hContainer
        hSwatches=struct;
        hLabels=struct;
    end

    properties(Hidden,Constant)
        BOXWIDTH=40;
        BOXHEIGHT=17;
        SPACING=5;
    end

    methods
        function this=BirdsEyePlotLegend(bep)
            this.BirdsEyePlot=bep;
            con=uipanel(getFigure(bep),...
            'Units','pixels',...
            'AutoResizeChildren','off',...
            'Visible','off');
            this.hContainer=con;

            update(this);
        end

        function set.Visible(this,vis)
            set(this.hContainer,'Visible',vis);
        end
        function vis=get.Visible(this)
            vis=get(this.hContainer,'Visible');
        end

        function h=getHeight(this)
            h=this.BOXHEIGHT+this.SPACING*2;
        end

        function update(this)
            bep=this.BirdsEyePlot;
            figpos=get(getFigure(bep),'Position');
            con=this.hContainer;
            bw=this.BOXWIDTH;
            bh=this.BOXHEIGHT;
            sp=this.SPACING;
            h=bh+2*sp;
            set(con,'Position',[0,figpos(4)-h+1,figpos(3)+4,h+2]);

            vis={};

            left=sp;
            swatches=this.hSwatches;
            labels=this.hLabels;
            by=sp;

            allSensors=bep.Application.SensorSpecifications;
            for indx=1:numel(allSensors)
                sensor=allSensors(indx);
                type=sensor.Type;
                if(string(type)=="ins")
                    continue;
                end
                if~isfield(swatches,type)
                    swatches.(type)=uipanel(con,...
                    'Units','pixels',...
                    'AutoResizeChildren','off',...
                    'BorderType','line',...
                    'Tag',[type,'_swatch']);
                    labels.(type)=uicontrol(con,...
                    'Style','text',...
                    'Tag',[type,'_text'],...
                    'String',getString(message(['driving:scenarioApp:',type,'DetectionType'])));
                end

                if any(strcmp(type,vis))
                    continue;
                end
                vis=[vis,{type}];%#ok<AGROW>
                color=sensor.CoverageEdgeColor;
                if useAppContainer(bep.Application)
                    props={};
                else
                    props={'HighlightColor',color};
                end
                set(swatches.(type),'Visible','on',props{:},...
                'BackgroundColor',fadeColor(sensor.CoverageFaceColor,[1,1,1],sensor.CoverageFaceAlpha),...
                'Position',[left,by,bw,bh]);
                left=left+bw+sp;
                ext=get(labels.(type),'Extent');
                set(labels.(type),'Visible','on',...
                'Position',[left,by,ext(3),bh-2]);
                left=left+ext(3)+sp;
            end
            this.hSwatches=swatches;
            this.hLabels=labels;

            swatches=rmfield(swatches,vis);
            labels=rmfield(labels,vis);
            if~isempty(swatches)
                invis=fieldnames(swatches);
                for indx=1:numel(invis)
                    set([swatches.(invis{indx}),labels.(invis{indx})],'Visible','off');
                end
            end
        end
    end
end

function rgb=fadeColor(rgb,targetRgb,alpha)

    rgb=rgb*alpha+targetRgb*(1-alpha);

end


