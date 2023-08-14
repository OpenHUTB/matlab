classdef StyleSpecification<handle&matlab.mixin.SetGet





    properties(AbortSet)
        Mode="factory";
        BackgroundColor=[40,40,40]/255;
        AxesColor=[0,0,0];
        LabelsColor=[175,175,175]/255;
        LineStyle="-";
        LineWidth=1.5;
        LineColor=utils.getColorOrder([0,0,0]);
        Marker="none";
        FontSize="small";
    end

    properties(Transient,Hidden)

        Specification;
    end



    methods

        function this=StyleSpecification(hSpec)
            this.Specification=hSpec;

            setupDefaultStyleValues(this);
        end


        function set.Mode(this,value)
            this.Mode=value;
            setupDefaultStyleValues(this);
        end


        function set.LineStyle(this,value)
            numChannels=min(numel(value),getMaxNumChannels(this));
            this.LineStyle(1:numChannels)=convertCharsToStrings(value(1:numChannels));
        end


        function set.LineWidth(this,value)
            numChannels=min(numel(value),getMaxNumChannels(this));
            this.LineWidth(1:numChannels)=value(1:numChannels);
        end


        function set.LineColor(this,value)
            numChannels=min(size(value,1),getMaxNumChannels(this));
            this.LineColor(1:numChannels,:)=value(1:numChannels,:);
        end


        function set.Marker(this,value)
            numChannels=min(numel(value),getMaxNumChannels(this));
            this.Marker(1:numChannels)=convertCharsToStrings(value(1:numChannels));
        end


        function setPropertyValue(this,propName,propValue)
            if(~isequal(this.(propName),propValue))
                hMessage=this.Specification.MessageHandler;
                this.(propName)=propValue;
                hMessage.GraphicalSettingsStale=true;
                hMessage.publishPropertyValue('PropertyChanged','Style',propName,propValue);
            end
        end


        function propValue=getPropertyValue(this,propName)
            propValue=this.(propName);
        end


        function settings=getSettings(this)
            import dsp.webscopes.style.*;
            settings=struct('BackgroundColor',this.BackgroundColor,...
            'AxesColor',this.AxesColor,...
            'LabelsColor',this.LabelsColor,...
            'LineStyle',this.LineStyle,...
            'LineWidth',this.LineWidth,...
            'LineColor',this.LineColor,...
            'Marker',this.Marker,...
            'FontSize',this.FontSize);
        end


        function setSettings(this,S)

            this.BackgroundColor=S.BackgroundColor.';
            this.AxesColor=S.AxesColor.';
            this.LabelsColor=S.LabelsColor.';

            this.LineStyle=string(S.LineStyle).';
            this.LineColor=S.LineColor;
            this.LineWidth=S.LineWidth;
            this.Marker=string(S.Marker).';
            this.FontSize=S.FontSize;
        end


        function S=toStruct(this)
            S.BackgroundColor=this.BackgroundColor;
            S.AxesColor=this.AxesColor;
            S.LabelsColor=this.LabelsColor;
            S.LineStyle=this.LineStyle;
            S.LineWidth=this.LineWidth;
            S.LineColor=this.LineColor;
            S.Marker=this.Marker;
            S.FontSize=this.FontSize;
        end


        function fromStruct(this,S)
            if(isfield(S,'BackgroundColor'))
                this.BackgroundColor=S.BackgroundColor;
            end
            if(isfield(S,'AxesColor'))
                this.AxesColor=S.AxesColor;
            end
            if(isfield(S,'LabelsColor'))
                this.LabelsColor=S.LabelsColor;
            end
            if(isfield(S,'LineStyle'))
                this.LineStyle=S.LineStyle;
            end
            if(isfield(S,'LineWidth'))
                this.LineWidth=S.LineWidth;
            end
            if(isfield(S,'LineColor'))
                this.LineColor=S.LineColor;
            end
            if(isfield(S,'Marker'))
                this.Marker=S.Marker;
            end
            if(isfield(S,'FontSize'))
                this.FontSize=S.FontSize;
            end
        end
    end



    methods(Access=protected)

        function setupDefaultStyleValues(this)
            import dsp.webscopes.style.*;
            maxNumChannels=getMaxNumChannels(this);
            this.BackgroundColor=getDefaultBackgroundColor(this);
            this.AxesColor=getDefaultAxesColor(this);
            this.LabelsColor=getDefaultLabelsColor(this);
            this.LineStyle=repmat(getDefaultLineStyle(this),1,maxNumChannels);
            this.LineWidth=getDefaultLineWidth(this).*ones(1,maxNumChannels);
            this.LineColor=repmat(getDefaultLineColor(this),ceil(maxNumChannels/7),1);
            this.Marker=repmat(getDefaultMarker(this),1,maxNumChannels);
            this.FontSize=getDefaultFontSize(this);
        end

        function backgroundColor=getDefaultBackgroundColor(this)
            switch this.Mode
            case 'factory'
                backgroundColor=[40,40,40]/255;
            case 'black-on-white'
                backgroundColor=[255,255,255]/255;
            case{'white-on-black','presentation'}
                backgroundColor=[0,0,0]/255;
            end
        end

        function axesColor=getDefaultAxesColor(this)
            axesColor=[0,0,0]/255;
            switch this.Mode
            case{'factory','white-on-black','presentation'}
                axesColor=[0,0,0]/255;
            case 'black-on-white'
                axesColor=[255,255,255]/255;
            end
        end

        function labelsColor=getDefaultLabelsColor(this)
            switch this.Mode
            case 'factory'
                labelsColor=[175,175,175]/255;
            case 'black-on-white'
                labelsColor=[0,0,0]/255;
            case{'white-on-black','presentation'}
                labelsColor=[255,255,255]/255;
            end
        end

        function lineColor=getDefaultLineColor(this)
            switch this.Mode
            case{'factory','white-on-black','presentation'}
                lineColor=utils.getColorOrder([0,0,0]);
            case 'black-on-white'
                lineColor=utils.getColorOrder([1,1,1]);
            end
        end

        function marker=getDefaultMarker(~)
            marker="none";
        end

        function lineStyle=getDefaultLineStyle(~)
            lineStyle="-";
        end

        function lineWidth=getDefaultLineWidth(this)
            lineWidth=1.5;
            if this.Mode=="presentation"
                lineWidth=2.5;
            end
        end

        function fontSize=getDefaultFontSize(this)
            fontSize="medium";
            if this.Mode=="factory"
                fontSize="small";
            end
        end
    end



    methods(Hidden)

        function n=getMaxNumChannels(this)
            n=this.Specification.MaxNumChannels;
        end

        function n=getNumChannels(this)
            n=this.Specification.getNumChannels();
        end

        function n=getMinNumChannels(this)
            n=min(getNumChannels(this),getMaxNumChannels(this));
        end
    end
end


