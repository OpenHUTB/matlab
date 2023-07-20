classdef FigureData<handle







    properties
        iFigureMetaData matlab.internal.editor.figure.FigureMetaData;
        iFigureInteractionData matlab.internal.editor.figure.FigureInteractionData;
        iFigureUndoRedoData matlab.internal.editor.figure.FigureUndoRedoData;
        iServerID="";
    end

    methods
        function createFigureMetaData(this)
            if isempty(this.iFigureMetaData)
                this.iFigureMetaData=matlab.internal.editor.figure.FigureMetaData;
            end
        end
        function createFigureInteractionData(this)
            if isempty(this.iFigureInteractionData)
                this.iFigureInteractionData=matlab.internal.editor.figure.FigureInteractionData;
            end
        end
        function createFigureUndoRedoData(this)
            if isempty(this.iFigureUndoRedoData)
                this.iFigureUndoRedoData=matlab.internal.editor.figure.FigureUndoRedoData;
            end
        end

        function setServerID(this,serverID)
            this.iServerID=serverID;
        end

        function setEnableFigureToolstrip(this,enableFigureToolstrip)
            this.createFigureMetaData();
            this.iFigureMetaData.setEnableFigureToolstrip(enableFigureToolstrip);
        end

        function setEnableAxesToolbar(this,enableAxesToolbar)
            this.createFigureMetaData();
            this.iFigureMetaData.setEnableAxesToolbar(enableAxesToolbar);
        end

        function setiIsYGridSupported(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsYGridSupported(val);
        end

        function setMode(this,mode)
            this.createFigureMetaData();
            this.iFigureMetaData.setMode(mode);
        end


        function setModeStateData(this,modeStateData)
            this.createFigureMetaData();
            this.iFigureMetaData.setModeStateData(modeStateData);
        end

        function setZoomDirection(this,pDirection)
            this.createFigureMetaData();
            this.iFigureMetaData.setZoomDirection(pDirection);
        end


        function setIs2D(this,pIs2D)
            this.createFigureMetaData();
            this.iFigureMetaData.setIs2D(pIs2D);
        end

        function setChartType(this,chartType)
            this.createFigureMetaData();
            this.iFigureMetaData.setChartType(chartType);
        end


        function setAxesPositions(this,axesPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setAxesPositions(axesPositions);
        end


        function setBackgroundColor(this,pColor)
            this.createFigureMetaData();
            this.iFigureMetaData.setBackgroundColor(pColor);
        end

        function setTitles(this,titles)
            this.createFigureMetaData();
            this.iFigureMetaData.setTitles(titles);
        end

        function setXLabels(this,xlabels)
            this.createFigureMetaData();
            this.iFigureMetaData.setXLabels(xlabels);
        end
        function setYLabels(this,ylabels)
            this.createFigureMetaData();
            this.iFigureMetaData.setYLabels(ylabels);
        end

        function setLegendPositions(this,labelPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setLegendPositions(labelPositions);
        end

        function setXLabelPositions(this,labelPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setXLabelPositions(labelPositions);
        end

        function setYLabelPositions(this,labelPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setYLabelPositions(labelPositions);
        end


        function setTitlePositions(this,labelPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setTitlePositions(labelPositions);
        end

        function setSupportsTitle(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsTitleSupported(val);
        end

        function setSupportsXLabel(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsXlabelSupported(val);
        end

        function setSupportsYLabel(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsYlabelSupported(val);
        end

        function setSupportsZLabel(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsZlabelSupported(val);
        end

        function setSupportsYGrid(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsYGridSupported(val);
        end

        function setSupportsXGrid(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsXGridSupported(val);
        end

        function setSupportsGrid(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsGridSupported(val);
        end


        function setSupportsLegend(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsLegendSupported(val);
        end

        function setSupportsColorbar(this,val)
            this.createFigureMetaData();
            this.iFigureMetaData.setiIsColorbarSupported(val);
        end

        function setAnnotationPositions(this,annotationPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setAnnotationPositions(annotationPositions);
        end

        function setAnnotationTextPositions(this,annotationTextPositions)
            this.createFigureMetaData();
            this.iFigureMetaData.setAnnotationTextPositions(annotationTextPositions);
        end

        function setLegendTextPosition(this,pos)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setLegendTextPosition(pos);
        end

        function setEditedAnnotationType(this,editedAnnotationType)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setEditedAnnotationType(editedAnnotationType);
        end

        function setEditedAnnotationText(this,editedAnnotationText)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setEditedAnnotationText(editedAnnotationText);
        end

        function setEditedAnnotationPosition(this,editedAnnotationPosition)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setEditedAnnotationPosition(editedAnnotationPosition);
        end

        function setiLegendEntryString(this,str)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setLegendEntryString(str);
        end

        function setiLegendEntryIndex(this,index)
            this.createFigureInteractionData;
            this.iFigureInteractionData.setLegendEntryIndex(index);
        end

        function setPZREnabled(this,pzrEnabled)
            this.createFigureMetaData;
            this.iFigureMetaData.setiIsPZREnabled(pzrEnabled);
        end

        function setSubplotCase(this,subplotCase)
            this.createFigureMetaData;
            this.iFigureMetaData.setiIsSubplotCase(subplotCase);
        end

        function setCode(this,code)
            this.createFigureInteractionData();
            this.iFigureInteractionData.setCode(code);
        end




        function setAtomicActionID(this,atomicActionID)
            this.createFigureInteractionData();

            this.iFigureInteractionData.setAtomicActionID(atomicActionID);
        end

        function clearCode(this)
            this.createFigureInteractionData();
            this.iFigureInteractionData.clearCode();
        end

        function showCode(this)
            this.createFigureInteractionData();
            this.iFigureInteractionData.showCode();
        end

        function setFakeCode(this,isFakeCode)
            this.createFigureInteractionData();
            this.iFigureInteractionData.setFakeCode(isFakeCode);
        end

        function setUndoRedo(this,isUndoRedoAction)
            this.createFigureUndoRedoData();
            this.iFigureUndoRedoData.setUndoRedo(isUndoRedoAction);
        end
    end

end