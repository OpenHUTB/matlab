classdef InteractionOptions<matlab.graphics.general.InteractionOptionsBase





    properties(Dependent,Transient)
        LimitsDimensions char;

        OuterXLimits(1,2);
        OuterYLimits(1,2);
        OuterZLimits(1,2);
    end

    properties
        LimitsDimensionsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';

        OuterXLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        OuterYLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        OuterZLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden)
        LimitsDimensions_I char='xyz';

        OuterXLimits_I;
        OuterYLimits_I;
        OuterZLimits_I;
    end

    methods

        function this=set.LimitsDimensions(this,val)
            this.LimitsDimensions_I=val;
            this.LimitsDimensionsMode='manual';
        end

        function val=get.LimitsDimensions(this)
            val=this.LimitsDimensions_I;
        end


        function this=set.OuterXLimits(this,val)
            this=this.SetBounds('OuterXLimits',val);
        end

        function val=get.OuterXLimits(this)
            val=this.OuterXLimits_I;
        end

        function this=set.OuterYLimits(this,val)
            this=this.SetBounds('OuterYLimits',val);
        end

        function val=get.OuterYLimits(this)
            val=this.OuterYLimits_I;
        end

        function this=set.OuterZLimits(this,val)
            this=this.SetBounds('OuterZLimits',val);
        end
        function val=get.OuterZLimits(this)
            val=this.OuterZLimits_I;
        end
    end

    methods(Hidden)

        function this=SetBounds(this,key,value)
            this.([key,'_I'])=value;
            this.([key,'Mode'])='manual';
        end

        function val=GetBounds(this,key)
            modeValue=this.([key,'Mode']);
            if(strcmp(modeValue,'auto'))
                val=this.GraphicsExtentsBounds(key);
            else
                val=this.([key,'_I']);
                if(isempty(val))
                    val=this.GraphicsExtentsBounds(key);
                    this.([key,'_I'])=val;
                end
            end
        end

        function this=UpdateOuterBoundsAuto(this,hAxes)
            bounds=matlab.graphics.interaction.internal.getBounds(hAxes,false);
            if(strcmp(this.OuterXLimitsMode,'auto'))
                this.OuterXLimits_I=bounds(1:2);
            end
            if(strcmp(this.OuterYLimitsMode,'auto'))
                this.OuterYLimits_I=bounds(3:4);
            end
            if(strcmp(this.OuterZLimitsMode,'auto'))
                this.OuterZLimits_I=bounds(5:6);
            end
        end

        function this=updateInteractionOptions(this,hAxes)
            this=this.UpdateOuterBoundsAuto(hAxes);
        end

        function[props,vals]=addOption(~,props,vals,newProperty,newValue)
            props{end+1}=newProperty;
            vals{end+1}=newValue;
        end

        function sendOptionsToClient(this,canvas,hAxes)
            if isprop(canvas,'ControlManager')
                KEY="interactionoptions";
                props=[];
                vals=[];


                [props,vals]=this.addOption(props,vals,'LimitsDimensions',this.LimitsDimensions);

                [props,vals]=this.addOption(props,vals,'LimitsDimensionsMode',this.LimitsDimensionsMode);


                bounds=[this.OuterXLimits,this.OuterYLimits,this.OuterZLimits];
                [props,vals]=this.addOption(props,vals,'graphicsBounds',bounds);

                PVPairs=[props;vals];
                canvas.ControlManager.sendMessageToClient(hAxes,KEY,PVPairs);
            end
        end
    end
end
