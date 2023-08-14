classdef SnapshotWithFrameAndCallouts<SLPrint.SnapshotWithFrame
    properties
        AddCallouts=false;
        CalloutObjectList={'%<all>'};
        CalloutLabelList={'%<number>'};
    end

    properties(Hidden)
        CalloutPadding=[48,48,48,48];
        CalloutProperties=struct(...
        'TextColor',[0,0.3,0,1],...
        'TextWeight','Bold',...
        'LineColor',[0.6,0.6,0.6,1],...
        'ArrowShape',[0,0;-10,-3;-8,0;-10,3]);
    end

    methods
        function this=SnapshotWithFrameAndCallouts(varargin)
            this=this@SLPrint.SnapshotWithFrame(varargin{:});
        end

        function set.CalloutPadding(this,value)
            if(length(value)==1)
                value=repmat(value,1,4);
            end
            if(isnumeric(value)&&(length(value)==4))
                this.CalloutPadding=value;
            else
                error('Simulink:Snapshot:InvalidCalloutPadding','Invalid callout padding');
            end
        end

        function bounds=getCalloutBounds(this,obj)
            obj=SLPrint.Resolver.resolveToUDD(obj);
            bounds=[0,0,0,0];
            if isprop(obj,'calloutBounds')
                bounds=obj.calloutBounds;
            end
        end

    end

    methods(Access=protected)
        function render(this)
            this.render@SLPrint.SnapshotWithFrame();

            if(this.AddCallouts&&~isempty(this.getCalloutTargets))
                outputTrgBounds=this.getObjectBounds(this.Target);


                calloutRect=outputTrgBounds+...
                2/3*[-this.CalloutPadding(1)...
                ,-this.CalloutPadding(2)...
                ,this.CalloutPadding(1)+this.CalloutPadding(3)...
                ,this.CalloutPadding(2)+this.CalloutPadding(4)];







                this.drawCallouts(calloutRect);
            end
        end

        function padding=getOutputPadding(this)
            if(this.AddCallouts&&~isempty(this.getCalloutTargets))
                padding=this.CalloutPadding;
            else
                padding=this.Padding;
            end
        end

        function drawCallouts(this,calloutRect)
            overlayRootNode=this.OverlayRootNode;
            h=this.getCalloutTargets();
            labels=this.getCalloutLabels(h);

            layout=SLPrint.CalloutsLayoutManager(calloutRect);

            for i=1:length(h)
                textNode=MG2.TextNode;
                textNode.Text=labels{i};
                textNode.Color=this.CalloutProperties.TextColor;
                textNode.Font.Weight=this.CalloutProperties.TextWeight;

                if isa(h(i),'Stateflow.Transition')
                    point=this.getTargetPoint(h(i).MidPoint);
                    objBounds=[point-1,2,2];
                else
                    objBounds=this.getObjectBounds(h(i));
                end

                calloutRect=layout.getCalloutRect(...
                textNode.BoundingRect(3:4),...
                objBounds);

                if isempty(calloutRect)
                    continue;
                end
                if~isprop(h(i),'calloutBounds')
                    if isa(h(i),'handle.handle')
                        schema.prop(h(i),'calloutBounds','mxArray');
                    else
                        addprop(h(i),'calloutBounds');
                    end
                end

                h(i).calloutBounds=calloutRect;

                targetPoint=layout.getTargetPoint(...
                calloutRect,...
                objBounds);

                calloutTopLeft=calloutRect(1:2);
                textNode.Position=calloutTopLeft;
                textNode.Parent=overlayRootNode;

                diameter=min([textNode.Width,textNode.Height]);

                ellipseNode=MG2.EllipseNode();
                ellipseNode.Center=calloutTopLeft;
                ellipseNode.Size=[diameter,diameter];
                ellipseNode.DrawStyle.IsAntiAliased=true;
                ellipseNode.DrawStyle.Fill.Style='Solid';
                ellipseNode.DrawStyle.Fill.Color=[1,1,1,1];


                ellipseNode.DrawStyle.Stroke.Color=[1,1,1,1];

                ellipseNode.Parent=overlayRootNode;

                lineNode=MG2.LineNode();
                lineNode.Start=calloutTopLeft+[textNode.Width,textNode.Height]/2;
                lineNode.End=targetPoint;
                lineNode.DrawStyle.IsAntiAliased=true;
                lineNode.DrawStyle.Stroke.Color=this.CalloutProperties.LineColor;

                shape=MG2.Shape;
                shape.addPolygon(this.CalloutProperties.ArrowShape);
                shape.closeSubpath();
                arrowHead=MG2.ShapeNode(shape);
                arrowHead.DrawStyle.IsAntiAliased=true;
                arrowHead.DrawStyle.Fill.Style='Solid';
                arrowHead.DrawStyle.Fill.Color=this.CalloutProperties.LineColor;
                arrowHead.DrawStyle.Stroke.Color=this.CalloutProperties.LineColor;
                lineNode.EndDecoration.ForwardDirection=[1,0];
                lineNode.EndDecoration.Node=arrowHead;

                calloutContainer=MG2.ContainerNode();
                lineNode.Parent=calloutContainer;
                ellipseNode.Parent=calloutContainer;
                textNode.Parent=calloutContainer;
                calloutContainer.Parent=overlayRootNode;
            end
        end

        function labels=getCalloutLabels(this,h)
            if strcmpi(this.CalloutLabelList,'%<number>')
                labels=cell(1,length(h));
                for i=1:length(h)
                    labels{i}=num2str(i);
                end
            else
                if ischar(this.CalloutLabelList)
                    labels={this.CalloutLabelList};
                else
                    labels=this.CalloutLabelList;
                end
            end
        end

        function h=getCalloutTargets(this)
            if iscell(this.CalloutObjectList)&&strcmp(this.CalloutObjectList{1},'%<all>')
                h=this.getAllCalloutTargets();
            else
                h=SLPrint.Resolver.resolveToUDD(this.CalloutObjectList);
            end
        end

        function h=getAllCalloutTargets(this)
            if SLPrint.Resolver.isSimulink(this.Target)
                d=SLM3I.SLDomain.handle2Diagram(this.Target);
                h=zeros(1,d.block.size());
                for i=1:d.block.size()
                    h(i)=d.block.at(i).handle;
                end

            else
                h=this.Target.find('-depth',1,...
                '-not','-isa','Stateflow.Data',...
                '-not','Id',this.Target.Id);
            end


            func=@(x)ismember(class(x),...
            {'Stateflow.Junction','Stateflow.Transition',...
            'Stateflow.Note','Simulink.Annotation','Stateflow.Annotation','Stateflow.Event'});
            filter=arrayfun(func,h);
            h(filter)=[];

        end
    end
end
