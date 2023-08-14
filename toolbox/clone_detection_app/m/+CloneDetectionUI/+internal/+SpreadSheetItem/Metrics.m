classdef Metrics<handle



    properties
        percentage;
        category;
        metricsSSColumn1=DAStudio.message('sl_pir_cpp:creator:metricsSSColumn1');
        metricsSSColumn2=DAStudio.message('sl_pir_cpp:creator:metricsSSColumn2');
        metricsSSColumn3=DAStudio.message('sl_pir_cpp:creator:metricsSSColumn3');
    end
    methods(Access=public)

        function this=Metrics(category,percentage)
            if nargin>0
                this.category=category;
                this.percentage=percentage;
            end
        end

        function label=getDisplayLabel(this)
            label=this.category;
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case this.metricsSSColumn1
                propValue=this.category;
            case this.metricsSSColumn2
                propValue='';
            case this.metricsSSColumn3
                propValue=num2str(this.percentage);
            end
        end


        function getPropertyStyle(this,propname,propertyStyle)
            switch(propname)
            case this.metricsSSColumn2
                if strcmp(this.category,'Exact')
                    color=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
                elseif strcmp(this.category,'Similar')
                    color=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
                else
                    color=CloneDetectionUI.internal.util.getOverallColorCodeNumerical;
                end
                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',[this.percentage,100-this.percentage],...
                'Colors',[[color,1],[1,1,1,1]]);
                propertyStyle.Tooltip=[num2str(this.percentage),'%'];
            end
        end


        function isValid=isValidProperty(this,propName)
            switch propName
            case this.metricsSSColumn1
                isValid=true;
            case this.metricsSSColumn2
                isValid=true;
            case this.metricsSSColumn3
                isValid=true;
            otherwise
                isValid=false;
            end
        end


        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            switch aPropName
            case this.metricsSSColumn2
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end

    end
end

