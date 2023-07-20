classdef StyleConfiguration<handle&dsp.webscopes.mixin.PropertyValueValidator




    properties(Dependent)
        Mode;
        BackgroundColor;
        AxesColor;
        LabelsColor;
        LineStyle;
        LineWidth;
        LineColor;
        Marker;
        FontSize;
    end

    properties(Transient,Hidden)

        Specification;
    end
    properties(Constant,Hidden)

        ModeSet={'factory','black-on-white','white-on-black','presentation'};
        LineStyleSet={'-','--',':','-.'};
        MarkerSet={'+','o','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h'};
        FontSizeSet={'small','medium','large','extra-large'};
    end



    methods

        function this=StyleConfiguration(hSpec)
            this.Specification=hSpec;
        end


        function set.Mode(this,value)
            setPropertyValue(this.Specification,'Mode',value);
        end
        function value=get.Mode(this)
            value=getPropertyValue(this.Specification,'Mode');
        end


        function set.BackgroundColor(this,value)
            setPropertyValue(this.Specification,'BackgroundColor',value);
        end
        function value=get.BackgroundColor(this)
            value=getPropertyValue(this.Specification,'BackgroundColor');
        end


        function set.AxesColor(this,value)
            setPropertyValue(this.Specification,'AxesColor',value);
        end
        function value=get.AxesColor(this)
            value=getPropertyValue(this.Specification,'AxesColor');
        end


        function set.LabelsColor(this,value)
            setPropertyValue(this.Specification,'LabelsColor',value);
        end
        function value=get.LabelsColor(this)
            value=getPropertyValue(this.Specification,'LabelsColor');
        end


        function set.LineStyle(this,value)
            setPropertyValue(this.Specification,'LineStyle',value);
        end
        function value=get.LineStyle(this)
            value=getPropertyValue(this.Specification,'LineStyle');
            numChannels=getMinNumChannels(this.Specification);
            if(numChannels~=-1)
                value=value(1:numChannels);
            end
        end


        function set.LineWidth(this,value)
            setPropertyValue(this.Specification,'LineWidth',value);
        end
        function value=get.LineWidth(this)
            value=getPropertyValue(this.Specification,'LineWidth');
            numChannels=getMinNumChannels(this.Specification);
            if(numChannels~=-1)
                value=value(1:numChannels);
            end
        end


        function set.LineColor(this,value)
            setPropertyValue(this.Specification,'LineColor',value);
        end
        function value=get.LineColor(this)
            value=getPropertyValue(this.Specification,'LineColor');
            numChannels=getMinNumChannels(this.Specification);
            if(numChannels~=-1)
                value=value(1:numChannels,:);
            end

        end


        function set.Marker(this,value)
            setPropertyValue(this.Specification,'Marker',value);
        end
        function value=get.Marker(this)
            value=getPropertyValue(this.Specification,'Marker');
            numChannels=getMinNumChannels(this.Specification);
            if(numChannels~=-1)
                value=value(1:numChannels);
            end
        end


        function set.FontSize(this,value)
            setPropertyValue(this.Specification,'FontSize',value);
        end
        function value=get.FontSize(this)
            value=getPropertyValue(this.Specification,'FontSize');
        end
    end
end
