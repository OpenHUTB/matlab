classdef TextControl<matlab.graphics.interaction.graphicscontrol.GenericControl




    properties
Text
    end

    methods
        function this=TextControl(text)
            this=this@matlab.graphics.interaction.graphicscontrol.GenericControl();
            this.Text=text;
            this.Type='text';
        end

        function response=process(this,message)
            response=struct;
            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case 'setString'
                    if isfield(message,'data')
                        this.Text.String=message.data;
                    end

                    this.Text.Editing='off';
                case 'setVisibilityOff'
                    this.Text.Visible='off';
                    p=findprop(this.Text,'VisibilityCache');
                    if(~isempty(p))
                        delete(p);
                    end
                case 'setVisibilityOn'
                    this.Text.Visible='on';
                    p=findprop(this.Text,'VisibilityCache');
                    if(~isempty(p))
                        delete(p);
                    end
                case 'getStringInfo'
                    response.String=this.Text.String;
                    response.VerticalAlignment=this.Text.VerticalAlignment;
                    response.HorizontalAlignment=this.Text.HorizontalAlignment;
                case 'getEditingValue'
                    textObject=this.Text;
                    response.EditingValue=textObject.Editing;
                case 'getPosition'
                    textPositionUnits=this.Text.Units;
                    this.Text.Units='pixels';


                    currentNode=this.Text;
                    while(~(isprop(currentNode,'Camera')))
                        currentNode=currentNode.NodeParent;
                    end

                    if(isa(currentNode,'matlab.graphics.axis.AbstractAxes'))
                        layout=currentNode.GetLayoutInformation();
                        plotBox=layout.PlotBox;
                        offset=plotBox(1:2);
                    else
                        viewport=currentNode.Camera.Viewport;

                        fig=ancestor(this.Text,'figure');
                        viewport_pixel_position=hgconvertunits(...
                        fig,viewport.Position,viewport.Units,'pixels',currentNode.Parent);

                        offset=viewport_pixel_position(1:2);
                    end



                    response.Position=this.Text.Position(1:2)+offset;

                    this.Text.Units=textPositionUnits;



                    response.VerticalAlignment=this.Text.VerticalAlignment;
                    response.HorizontalAlignment=this.Text.HorizontalAlignment;


                    fontUnits=this.Text.FontUnits;
                    this.Text.FontUnits='points';
                    response.FontName=this.Text.FontName;
                    response.FontSize=this.Text.FontSize;
                    response.FontWeight=this.Text.FontWeight;
                    response.FontAngle=this.Text.FontAngle;
                    this.Text.FontUnits=fontUnits;






                    if(~isprop(this.Text,'VisibilityCache'))
                        p=addprop(this.Text,'VisibilityCache');
                        p.Transient=true;
                        p.Hidden=true;
                        this.Text.VisibilityCache=this.Text.Visible;
                    end



                    response.Visibility=this.Text.VisibilityCache;


                    response.String=this.Text.String;


                    this.Text.Visible='off';
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.GenericControl(this,message);
                end
            end
        end

    end
end
