classdef FigureMetaData<handle






    properties
        iMode string;
        iModeStateData cell;
        iZoomDirection string;
        iLegendPositions cell={};
        iXLabelPositions cell={};
        iYLabelPositions cell={};
        iTitlePositions cell={};
        iAxesPositions cell={};
        iIs2D cell={};
        iChartType cell={};
        iBackgroundColor string;
        iIsPZREnabled cell={};
        iIsSubplotCase double;
        iTitles cell={};
        iXLabels cell={};
        iYLabels cell={};
        iEnableFigureToolstrip double;
        iEnableAxesToolbar cell={};
        iEnableMOLFigureToolstrip=com.mathworks.mde.liveeditor.figure.LiveEditorFigureToolSetFactory.getShowMOLFigureToolstripTab();%#ok<JAPIMATHWORKS> 
        iAnnotationPositions cell={};
        iAnnotationTextPositions cell={};

        iIsXlabelSupported logical;
        iIsYlabelSupported logical;
        iIsZlabelSupported logical;
        iIsTitleSupported logical;
        iIsGridSupported logical;
        iIsXGridSupported logical;
        iIsYGridSupported logical;
        iIsColorbarSupported logical;
        iIsLegendSupported logical;

    end

    methods

        function setiIsYGridSupported(this,iIsYGridSupported)
            this.iIsYGridSupported=iIsYGridSupported;
        end

        function setiIsXGridSupported(this,iIsXGridSupported)
            this.iIsXGridSupported=iIsXGridSupported;
        end

        function setiIsXlabelSupported(this,iIsXlabelSupported)
            this.iIsXlabelSupported=iIsXlabelSupported;
        end

        function setiIsYlabelSupported(this,iIsYlabelSupported)
            this.iIsYlabelSupported=iIsYlabelSupported;
        end

        function setiIsZlabelSupported(this,iIsZlabelSupported)
            this.iIsZlabelSupported=iIsZlabelSupported;
        end

        function setiIsTitleSupported(this,iIsTitleSupported)
            this.iIsTitleSupported=iIsTitleSupported;
        end

        function setiIsGridSupported(this,iIsGridSupported)
            this.iIsGridSupported=iIsGridSupported;
        end

        function setiIsColorbarSupported(this,iIsColorbarSupported)
            this.iIsColorbarSupported=iIsColorbarSupported;
        end

        function setiIsLegendSupported(this,iIsLegendSupported)
            this.iIsLegendSupported=iIsLegendSupported;
        end

        function state=getiEnableFigureToolstrip(this)
            state=this.iEnableFigureToolstrip;
        end

        function setEnableFigureToolstrip(this,iEnableFigureToolstrip)
            this.iEnableFigureToolstrip=iEnableFigureToolstrip;
        end

        function setEnableAxesToolbar(this,iEnableAxesToolbar)
            this.iEnableAxesToolbar=num2cell(iEnableAxesToolbar);
        end

        function setMode(this,mode)
            this.iMode=mode;
        end

        function setChartType(this,chartType)
            if iscell(chartType)
                this.iChartType=chartType;
            else
                this.iChartType=cellstr(string(chartType));
            end
        end

        function setModeStateData(this,modeStateData)
            if iscell(modeStateData)
                this.iModeStateData=modeStateData;
            else
                this.iModeStateData=num2cell(modeStateData,2);
            end
        end

        function setXLabelPositions(this,iXLabelPositions)
            if iscell(iXLabelPositions)
                this.iXLabelPositions=iXLabelPositions;
            else
                this.iXLabelPositions=num2cell(iXLabelPositions,2);
            end
        end

        function setYLabelPositions(this,iYLabelPositions)
            if iscell(iYLabelPositions)
                this.iYLabelPositions=iYLabelPositions;
            else
                this.iYLabelPositions=num2cell(iYLabelPositions,2);
            end
        end

        function setTitlePositions(this,iTitlePositions)
            if iscell(iTitlePositions)
                this.iTitlePositions=iTitlePositions;
            else
                this.iTitlePositions=num2cell(iTitlePositions,2);
            end
        end

        function setZoomDirection(this,pDirection)
            this.iZoomDirection=pDirection;
        end

        function setIs2D(this,pIs2D)
            if iscell(pIs2D)
                this.iIs2D=pIs2D;
            else
                this.iIs2D=num2cell(pIs2D);
            end
        end

        function setAxesPositions(this,axesPositions)
            if iscell(axesPositions)
                this.iAxesPositions=axesPositions;
            else
                this.iAxesPositions=num2cell(axesPositions,2);
            end
        end

        function setTitles(this,titles)
            this.iTitles=titles;
        end

        function setXLabels(this,xlabels)
            this.iXLabels=xlabels;
        end

        function setYLabels(this,ylabels)
            this.iYLabels=ylabels;
        end

        function setBackgroundColor(this,pColor)
            this.iBackgroundColor=pColor;
        end

        function setiIsPZREnabled(this,PZREnabled)
            this.iIsPZREnabled=num2cell(PZREnabled);
        end

        function setLegendPositions(this,legendPositions)
            if iscell(legendPositions)
                this.iLegendPositions=legendPositions;
            else
                this.iLegendPositions=num2cell(legendPositions,2);
            end
        end

        function setiIsSubplotCase(this,iIsSubplotCase)
            this.iIsSubplotCase=iIsSubplotCase;
        end

        function setAnnotationPositions(this,iAnnotationPositions)
            this.iAnnotationPositions=num2cell(iAnnotationPositions,2);
        end

        function setAnnotationTextPositions(this,annotationTextPositions)
            this.iAnnotationTextPositions=num2cell(annotationTextPositions,2);
        end
    end
end
