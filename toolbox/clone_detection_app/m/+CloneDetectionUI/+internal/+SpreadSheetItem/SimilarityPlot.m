classdef SimilarityPlot<handle



    properties
        clonegroupId;
        numCloneCandidates;
        maxPlotLength;
        rgbArray;
        paramDiff;
        similarityPlotSSColumn1=DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn1');
        similarityPlotSSColumn2=DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn2');
        similarityPlotSSColumn3=DAStudio.message('sl_pir_cpp:creator:similarityPlotSSColumn3');
    end
    methods(Access=public)

        function this=SimilarityPlot(clonegroupId,numCloneCandidates,maxPlotLength,rgbArray,paramDiff)
            if nargin>0
                this.clonegroupId=clonegroupId;
                this.numCloneCandidates=numCloneCandidates;
                this.maxPlotLength=maxPlotLength;
                this.rgbArray=rgbArray;
                this.paramDiff=paramDiff;
            end
        end

        function label=getDisplayLabel(this)
            label=this.clonegroupId;
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case this.similarityPlotSSColumn1
                propValue=this.clonegroupId;
            case this.similarityPlotSSColumn2
                propValue='';
            case this.similarityPlotSSColumn3
                propValue=int2str(this.numCloneCandidates);
            end
        end


        function getPropertyStyle(this,propname,propertyStyle)
            switch(propname)
            case this.similarityPlotSSColumn2
                if this.numCloneCandidates>100
                    plotLength=100;
                    maxLength=100;
                else
                    plotLength=this.numCloneCandidates;
                    maxLength=this.maxPlotLength;
                end

                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',[plotLength,maxLength-plotLength],'Colors',...
                [[this.rgbArray{1},this.rgbArray{2},this.rgbArray{3},1],[1,1,1,1]]);
                propertyStyle.Tooltip=this.paramDiff;
            end
        end


        function isValid=isValidProperty(this,propName)
            switch propName
            case this.similarityPlotSSColumn1
                isValid=true;
            case this.similarityPlotSSColumn2
                isValid=true;
            case this.similarityPlotSSColumn3
                isValid=true;
            otherwise
                isValid=false;
            end
        end


        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            switch aPropName
            case this.similarityPlotSSColumn2
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end

    end
end

