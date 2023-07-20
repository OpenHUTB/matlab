classdef CodeGenerator<handle








    properties(SetAccess=private,GetAccess=private)


        SubplotCase=false

        SubplotSize=[0,0]

PrecisionVector

        BehaviorObjectsHandles={}

        ActionRegistrator matlab.internal.editor.figure.Registrator

PlotYYAxes
DataTipsStruct


DefaultValuesStruct
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)





AxesHandles
    end

    properties(SetAccess=private,GetAccess=protected,Hidden=true)

CurrentFigure
    end

    properties(Constant,GetAccess=private)
        MAX_PRECISION=10;
    end

    events



FigureChanged
    end

    methods

        function this=CodeGenerator(fig,actionRegistrator)
            this.ActionRegistrator=actionRegistrator;
            setFigure(this,fig)
        end









        function[codeStr,isFakeCode]=generateCode(this)
            codeStr={};
            isFakeCode=false;

            [figureCode,isFakeFigureCode]=this.generateFigureCode;




            idx=arrayfun(@(x)~isvalid(x),this.AxesHandles);
            this.AxesHandles(idx)=[];

            if isempty(this.AxesHandles)
                codeStr=figureCode;
                ax=[];
                codeStr=[codeStr;this.getPropertyEditingCode(ax)];
                return
            end





            axesIndex=1;
            if~isempty(this.BehaviorObjectsHandles)
                bh=this.getLEBehavior(this.CurrentFigure.CurrentAxes);
                if~isempty(bh)
                    codeStr=this.generateCodeSingleAxes(this.CurrentFigure.CurrentAxes,axesIndex);


                    if~isempty(codeStr)
                        isFakeCode=true;
                    end
                end
            else

                if numel(this.AxesHandles)==1
                    codeStr=this.generateCodeSingleAxes(this.AxesHandles,axesIndex);
                else
                    for k=1:length(this.AxesHandles)
                        if this.SubplotCase

                            codeStr=[codeStr;this.getCodeMultipleAxesStr(this.AxesHandles(k),...
                            sprintf('subplot(%d,%d,%d)',this.SubplotSize(1),this.SubplotSize(2),k),k)];%#ok<AGROW>
                        else

                            codeStr=[codeStr;this.getCodeMultipleAxesStr(this.AxesHandles(k),...
                            sprintf('%% axes %d',k),k)];%#ok<AGROW>
                            isFakeCode=true;
                        end
                    end
                end
            end

            codeStr=[figureCode;codeStr];


            codeStr=replace(codeStr,'''','"');
            isFakeCode=isFakeCode||isFakeFigureCode;
        end

        function subplotCase=getSubplotCase(this)
            subplotCase=this.SubplotCase;
        end


        function registerAction(this,hObj,action)
            this.ActionRegistrator.put(hObj,action);


            if~isempty(action)&&any(contains(action,'zoom','IgnoreCase',true))
                this.updatePrecisionVector(hObj);
            end
        end


        function ret=isActionRegistered(this,hObj,action)
            ret=this.ActionRegistrator.hasEntry(hObj,action);
        end


        function deRegisterObject(this,hObj)
            this.ActionRegistrator.removeKey(hObj);
        end


        function ret=getActionsForObject(this,hObj)
            ret=this.ActionRegistrator.get(hObj);
        end


        function deregisterAction(this,hObj,action)
            this.ActionRegistrator.removeEntry(hObj,action);
        end
    end

    methods(Access=public,Hidden=true)

        function setFigure(this,fig,forceSet)



            forceSetFigure=false;



            if nargin==3
                forceSetFigure=forceSet;
            end

            if~forceSetFigure&&~isempty(this.CurrentFigure)&&isvalid(fig)&&...
                ishghandle(fig,'figure')&&this.CurrentFigure==fig
                return
            end


            if forceSetFigure
                this.reset();
            end


            this.CurrentFigure=fig;


            this.analyzeFigure();
            eventData=matlab.internal.editor.figure.FigureChangeEventData(fig,forceSetFigure);


            this.notify('FigureChanged',eventData);
        end

        function annotationStruct=getInteractivelyAddedAnnotations(this)
            hFig=this.CurrentFigure;
            annotationStruct=struct('arrows',[],'lines',[],'doublearrows',[],'textarrows',[]);
            scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(hFig);

            arrows=findall(scribeLayer,'-depth',1,'type','arrowshape');
            I=arrayfun(@(harrow)this.isActionRegistered(harrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),arrows);
            annotationStruct.arrows=arrows(I);

            lines=findall(scribeLayer,'-depth',1,'type','lineshape');
            I=arrayfun(@(hline)this.isActionRegistered(hline,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),lines);
            annotationStruct.lines=lines(I);

            doublearrows=findall(scribeLayer,'-depth',1,'type','doubleendarrowshape');
            I=arrayfun(@(hdoublearrow)this.isActionRegistered(hdoublearrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),doublearrows);
            annotationStruct.doublearrows=doublearrows(I);

            textarrows=findall(scribeLayer,'-depth',1,'type','textarrowshape');
            I=arrayfun(@(htextarrow)this.isActionRegistered(htextarrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),textarrows);
            annotationStruct.textarrows=textarrows(I);
        end

        function annotationStruct=getNonInteractivelyEditedAnnotations(this)
            hFig=this.CurrentFigure;
            annotationStruct=struct('arrows',[],'lines',[],'doublearrows',[],'textarrows',[]);
            scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(hFig);

            arrows=findall(scribeLayer,'-depth',1,'type','arrowshape');
            I=arrayfun(@(harrow)~this.isActionRegistered(harrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED)&&...
            this.isActionRegistered(harrow,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),arrows);
            annotationStruct.arrows=arrows(I);

            lines=findall(scribeLayer,'-depth',1,'type','lineshape');
            I=arrayfun(@(hline)~this.isActionRegistered(hline,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED)&&...
            this.isActionRegistered(hline,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),lines);
            annotationStruct.lines=lines(I);

            doublearrows=findall(scribeLayer,'-depth',1,'type','doubleendarrowshape');
            I=arrayfun(@(hdoublearrow)~this.isActionRegistered(hdoublearrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED)&&...
            this.isActionRegistered(hdoublearrow,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),doublearrows);
            annotationStruct.doublearrows=doublearrows(I);

            textarrows=findall(scribeLayer,'-depth',1,'type','textarrowshape');
            I=arrayfun(@(htextarrow)~this.isActionRegistered(htextarrow,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED)&&...
            this.isActionRegistered(htextarrow,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),textarrows);
            annotationStruct.textarrows=textarrows(I);
        end

    end

    methods(Access=private)

        function ret=getLEBehavior(this,hAxes)
            ret=matlab.graphics.internal.LiveEditorCodeGenBehavior.empty;
            if~isempty(this.BehaviorObjectsHandles)
                ret=this.BehaviorObjectsHandles{this.AxesHandles==hAxes};
            end
        end



        function analyzeFigure(this)

            this.AxesHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(this.CurrentFigure);
            subplotGridAxes=getappdata(this.CurrentFigure,'SubplotGrid');



            spIndex=arrayfun(@(x)~isvalid(x),subplotGridAxes);
            subplotGridAxes(spIndex)=[];


            this.PlotYYAxes=[];
            for k=1:length(this.AxesHandles)
                if isappdata(this.AxesHandles(k),'graphicsPlotyyPeer')
                    this.PlotYYAxes(end+1)=getappdata(this.AxesHandles(k),'graphicsPlotyyPeer');
                end
            end

            if~isempty(subplotGridAxes)&&numel(intersect(this.AxesHandles,subplotGridAxes))==numel(this.AxesHandles)

                this.SubplotCase=true;
                this.SubplotSize=size(subplotGridAxes);




















                subplotGridAxes=rot90(subplotGridAxes);

                this.AxesHandles=subplotGridAxes(:);
            end


            this.AxesHandles=flip(this.AxesHandles);


            this.DataTipsStruct.ExistingDatatips={};
            this.DataTipsStruct.DataTipsLabelsStruct=struct;


            existingDataTips=findobj(this.CurrentFigure,'-isa','matlab.graphics.datatip.DataTip');



            for i=1:length(this.AxesHandles)
                bh=hggetbehavior(this.AxesHandles(i),'LiveEditorCodeGeneration','-peek');
                if~isempty(bh)&&~isempty(bh.InteractionCodeFcn)
                    this.BehaviorObjectsHandles{i}=bh;
                else
                    this.BehaviorObjectsHandles{i}=matlab.graphics.internal.LiveEditorCodeGenBehavior.empty;
                end
                if~isempty(existingDataTips)
                    this.updateDatatipStruct(this.AxesHandles(i),i)
                end
            end

            if all(cellfun('isempty',this.BehaviorObjectsHandles))
                this.BehaviorObjectsHandles={};
            end

            this.setPrecisionVector(this.AxesHandles);






            for i=1:numel(existingDataTips)
                dynamicCoord=existingDataTips(i).getDynamicCoordinates();
                this.DataTipsStruct.ExistingDatatips(i).Position={existingDataTips(i).(dynamicCoord{1});...
                existingDataTips(i).(dynamicCoord{2});...
                existingDataTips(i).(dynamicCoord{3})};
                this.DataTipsStruct.ExistingDatatips(i).DataIndex=existingDataTips(i).DataIndex;
                this.DataTipsStruct.ExistingDatatips(i).Location=existingDataTips(i).Location;
                this.DataTipsStruct.ExistingDatatips(i).Object=existingDataTips(i);
            end



            this.DefaultValuesStruct=this.getDefaultValuesStruct(this.CurrentFigure);
        end


        function setPrecisionVector(this,hAxes)


            for i=1:length(hAxes)
                this.PrecisionVector{i}=this.calculatePrecision(hAxes(i));
            end
        end


        function updatePrecisionVector(this,hAxes)
            if any(this.AxesHandles==hAxes)
                this.PrecisionVector{this.AxesHandles==hAxes}=this.calculatePrecision(hAxes);
            end
        end


        function p=calculatePrecision(this,hAxes)

            p.precisionX=this.MAX_PRECISION;
            p.precisionY=this.MAX_PRECISION;
            p.precisionZ=this.MAX_PRECISION;

            if isa(hAxes,'matlab.graphics.axis.Axes')&&isa(hAxes.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')...
                ||matlab.internal.editor.figure.ChartAccessor.isGeoChart(hAxes)



                if isa(hAxes,'matlab.graphics.axis.Axes')
                    if isa(hAxes.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')||...
                        isa(hAxes.XAxis,'matlab.graphics.axis.decorator.DurationRuler')

                        diffX=seconds(diff(hAxes.XLim));
                    else
                        diffX=diff(hAxes.XAxis.NumericLimits);
                    end
                elseif matlab.internal.editor.figure.ChartAccessor.isGeoChart(hAxes)
                    diffX=diff(hAxes.LongitudeLimits);
                end



                if isa(hAxes,'matlab.graphics.axis.Axes')
                    if isa(hAxes.YAxis(hAxes.ActiveDataSpaceIndex),'matlab.graphics.axis.decorator.DatetimeRuler')||...
                        isa(hAxes.YAxis(hAxes.ActiveDataSpaceIndex),'matlab.graphics.axis.decorator.DurationRuler')

                        diffY=seconds(diff(hAxes.YAxis(hAxes.ActiveDataSpaceIndex).Limits));
                    else
                        diffY=diff(hAxes.YAxis(hAxes.ActiveDataSpaceIndex).NumericLimits);
                    end
                elseif matlab.internal.editor.figure.ChartAccessor.isGeoChart(hAxes)
                    diffY=diff(hAxes.LatitudeLimits);
                end


                if isa(hAxes,'matlab.graphics.axis.Axes')
                    if isa(hAxes.ZAxis,'matlab.graphics.axis.decorator.DatetimeRuler')||...
                        isa(hAxes.ZAxis,'matlab.graphics.axis.decorator.DurationRuler')

                        diffZ=seconds(diff(hAxes.ZLim));
                    else
                        diffZ=diff(hAxes.ZAxis.NumericLimits);
                    end
                elseif matlab.internal.editor.figure.ChartAccessor.isGeoChart(hAxes)

                    diffZ=this.MAX_PRECISION;
                end



                li=matlab.internal.editor.figure.ChartAccessor.GetLayoutInformation(hAxes);


                onePixelWidth=li.PlotBox(3)/diffX;
                onePixelHeight=li.PlotBox(4)/diffY;



                p.precisionX=max(round(log10(onePixelWidth)),0);
                p.precisionY=max(round(log10(onePixelHeight)),0);


                p.precisionZ=max(round(log10(max(li.PlotBox(3),li.PlotBox(4))/diffZ)),0);
            end
        end

        function s=getDefaultValuesStruct(~,fig)
            s=struct();

            s.DefaultFontName=get(fig,'DefaultTextFontName');
            s.DefaultLineWidth=get(fig,'DefaultLineLineWidth');
            s.DefaultLineStyle=get(fig,'DefaultLineLineStyle');
        end


        function[codeLines,isFakeCode]=generateFigureCode(this)
            import matlab.internal.editor.figure.*;

            codeLines={};
            isFakeCode=false;

            isAnnotationAdded=this.isActionRegistered(this.CurrentFigure,ActionID.ANNOTATION_ADDED);
            if isAnnotationAdded
                scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(this.CurrentFigure);
                figPos=getpixelposition(this.CurrentFigure);

                annotationStruct=this.getInteractivelyAddedAnnotations;

                arrowCode=cell(length(annotationStruct.arrows),1);
                lineCode=cell(length(annotationStruct.lines),1);
                doublearrowCode=cell(length(annotationStruct.doublearrows),1);
                textArrowCode=cell(length(annotationStruct.textarrows),1);
                for k=1:length(annotationStruct.arrows)
                    arrowCode{k}=sprintf('annotation(''arrow'', %s, %s%s',...
                    mat2str(annotationStruct.arrows(k).X,4),mat2str(annotationStruct.arrows(k).Y,4),...
                    this.generatePropertyEditingNameValuePairCode(annotationStruct.arrows(k)));
                end
                for k=1:length(annotationStruct.doublearrows)
                    doublearrowCode{k}=sprintf('annotation(''doublearrow'', %s, %s%s',...
                    mat2str(annotationStruct.doublearrows(k).X,4),mat2str(annotationStruct.doublearrows(k).Y,4),...
                    this.generatePropertyEditingNameValuePairCode(annotationStruct.doublearrows(k)));
                end
                for k=1:length(annotationStruct.lines)
                    lineCode{k}=sprintf('annotation(''line'', %s, %s%s',...
                    mat2str(annotationStruct.lines(k).X,4),mat2str(annotationStruct.lines(k).Y,4),...
                    this.generatePropertyEditingNameValuePairCode(annotationStruct.lines(k)));
                end
                for k=1:length(annotationStruct.textarrows)

                    testArrowStr=string(annotationStruct.textarrows(k).String);
                    if numel(testArrowStr)>1
                        str='';
                        for index=1:length(testArrowStr)
                            str=[str,char(this.formatLabelCode(testArrowStr(index))),','];%#ok<AGROW>
                        end

                        str=str(1:end-1);
                        textArrowCode{k}=sprintf('annotation(''textarrow'', %s, %s, ''String'',[%s]%s',...
                        mat2str(annotationStruct.textarrows(k).X,4),mat2str(annotationStruct.textarrows(k).Y,4),...
                        str,...
                        this.generatePropertyEditingNameValuePairCode(annotationStruct.textarrows(k)));
                    else


                        textArrowCode{k}=sprintf('annotation(''textarrow'', %s, %s, ''String'', ''%s''%s',...
                        mat2str(annotationStruct.textarrows(k).X,4),mat2str(annotationStruct.textarrows(k).Y,4),...
                        testArrowStr,...
                        this.generatePropertyEditingNameValuePairCode(annotationStruct.textarrows(k)));
                    end
                end

                codeLines=[codeLines;arrowCode];
                codeLines=[codeLines;doublearrowCode];
                codeLines=[codeLines;lineCode];
                codeLines=[codeLines;textArrowCode];
            end


            isAnnotationEdited=this.isActionRegistered(this.CurrentFigure,ActionID.ANNOTATION_EDITED);
            if isAnnotationEdited
                annotationStruct=this.getNonInteractivelyEditedAnnotations;

                arrowCode=cell(length(annotationStruct.arrows),1);
                lineCode=cell(length(annotationStruct.lines),1);
                doublearrowCode=cell(length(annotationStruct.doublearrows),1);
                textArrowCode=cell(length(annotationStruct.textarrows),1);

                if~isempty(annotationStruct.arrows)||~isempty(annotationStruct.doublearrows)...
                    ||~isempty(annotationStruct.lines)||~isempty(annotationStruct.textarrows)
                    isFakeCode=true;


                    editAnnotationComment=['% ',getString(message('MATLAB:codetools:codegen:codeblock:toMCode:EditObjectComment','annotation','annotation'))];
                    codeLines=[codeLines;editAnnotationComment];
                end

                annotationCode='set(h,''X'',%s,''Y'',%s)';

                for k=1:length(annotationStruct.arrows)
                    arrowCode{k}=sprintf(annotationCode,...
                    mat2str(annotationStruct.arrows(k).X,4),mat2str(annotationStruct.arrows(k).Y,4));
                end
                for k=1:length(annotationStruct.doublearrows)
                    doublearrowCode{k}=sprintf(annotationCode,...
                    mat2str(annotationStruct.doublearrows(k).X,4),mat2str(annotationStruct.doublearrows(k).Y,4));
                end
                for k=1:length(annotationStruct.lines)
                    lineCode{k}=sprintf(annotationCode,...
                    mat2str(annotationStruct.lines(k).X,4),mat2str(annotationStruct.lines(k).Y,4));
                end
                for k=1:length(annotationStruct.textarrows)
                    textArrowCode{k}=sprintf('set(h,''X'',%s,''Y'',%s,''String'',''%s'')',...
                    mat2str(annotationStruct.textarrows(k).X,4),mat2str(annotationStruct.textarrows(k).Y,4),...
                    strrep(annotationStruct.textarrows(k).String,'''',''''''));
                end
                codeLines=[codeLines;arrowCode];
                codeLines=[codeLines;doublearrowCode];
                codeLines=[codeLines;lineCode];
                codeLines=[codeLines;textArrowCode];
            end

            if~isAnnotationAdded&&this.isActionRegistered(this.CurrentFigure,ActionID.ANNOTATION_REMOVED)


                removeAnnotationComment=['% ',getString(message('MATLAB:codetools:codegen:codeblock:toMCode:RemoveObjectComment','annotation'))];
                codeLines=[codeLines;removeAnnotationComment];
                isFakeCode=true;
            end

            lineCode=this.getLineEditedCode(this.CurrentFigure);
            if~isempty(lineCode)
                codeLines=[codeLines;lineCode];
            end

            fontCode=this.getFontNameSizeCode(this.CurrentFigure);
            if~isempty(fontCode)
                codeLines=[codeLines;fontCode];
            end

        end



        function codeLines=generateCodeTextObjects(this,ax)
            t=findobj(ax,'type','text');
            codeLines={};
            for i=1:numel(t)
                if this.isActionRegistered(t,matlab.internal.editor.figure.ActionID.TEXT_EDITED)
                    codeLines={'ax = gca;'};
                    if(t.Parent==ax)

                        textObjIndex=find(ax.Children==t);
                        codeLines=[codeLines;sprintf('textObj = ax.Children(%d);',textObjIndex)];
                    else


                        hParent=t.Parent;


                        parentObjIndex=find(ax.Children==ancestor(t,{'hggroup','hgtransform'},'toplevel'));
                        accessCode='';
                        while(hParent~=ax)
                            hParent=hParent.Parent;
                            accessCode=[accessCode,'.Children'];
                        end

                        codeLines=[codeLines;sprintf('textObj = ax.Children(%d)%s;',parentObjIndex,accessCode)];
                    end
                    codeLines=[codeLines;sprintf('textObj.String = ''%s'';',t.String)];
                end
            end
        end




        function codeLines=generateCodeSingleAxes(this,hChart,axIndex)
            codeLines={};

            codeLines=this.generateCodeFromBehaviorObject(hChart);
            if~isempty(codeLines)
                return
            end

            codeLines=[codeLines;this.generateCodeTextObjects(hChart)];



            if isa(hChart,'matlab.graphics.axis.Axes')
                axis={'x','y','z'};
                if this.isActionRegistered(hChart,matlab.internal.editor.figure.ActionID.RESET_LIMITS)

                    for i=1:length(axis)
                        codeLines=[codeLines;this.getLimitsCode(hChart,axis{i})];%#ok<AGROW>
                    end
                else

                    for i=1:length(axis)


                        if axis{i}=='y'&&isYYaxis(hChart)
                            limCode=getYYaxisLimitsCode(this,hChart);
                        else
                            limCode=this.getManualLimitsCode(hChart,axis{i});
                        end
                        codeLines=[codeLines;limCode];%#ok<AGROW>
                    end
                end
            elseif isa(hChart,'matlab.graphics.chart.Chart')||isa(hChart,'matlab.graphics.axis.GeographicAxes')

                codeLines=[codeLines;this.getChartLimitsCode(hChart)];
            end


            codeLines=[codeLines;this.getViewCode(hChart)];


            codeLines=[codeLines;this.getGridCode(hChart)];
            codeLines=[codeLines;this.getGridRemovedCode(hChart)];


            codeLines=[codeLines;this.getLegendCode(hChart)];
            codeLines=[codeLines;this.getLegendRemovedCode(hChart)];


            codeLines=[codeLines;this.getColorbarCode(hChart)];
            codeLines=[codeLines;this.getColorbarRemovedCode(hChart)];


            codeLines=[codeLines;this.getTitleCode(hChart)];


            codeLines=[codeLines;this.getSubTitleCode(hChart)];


            codeLines=[codeLines;this.getXLabelCode(hChart)];


            ylabelCode=this.getYLabelCode(hChart);
            if~isempty(ylabelCode)
                if~any(contains(codeLines,'yyaxis'))
                    codeLines=[codeLines;getYYaxisCode(hChart);ylabelCode];%#ok<AGROW>
                else
                    codeLines=[codeLines;ylabelCode];
                end
            end


            codeLines=[codeLines;this.getZLabelCode(hChart)];


            if isa(hChart,'matlab.graphics.axis.GeographicAxes')

                codeLines=[codeLines;this.getLongitudeLabelCode(hChart,codeLines)];


                codeLines=[codeLines;this.getLatitudeLabelCode(hChart,codeLines)];
            end



            this.updateDatatipStruct(hChart,axIndex);
            codeLines=[codeLines;this.getDataTipCode(hChart,axIndex,codeLines)];

            codeLines=[codeLines;this.getPropertyEditingCode(hChart)];
        end


        function limCode=getYYaxisLimitsCode(this,ax)

            limCode='';
            if~isYYaxis(ax)
                return
            end

            origActiveDataspace=ax.ActiveDataSpaceIndex;


            yyaxis(ax,'right');
            limCodeRight=this.getManualLimitsCode(ax,'y');
            if~isempty(limCodeRight)
                limCodeRight=[getYYaxisCode(ax);limCodeRight];%#ok<AGROW>
            end


            yyaxis(ax,'left');
            limCodeLeft=this.getManualLimitsCode(ax,'y');
            if~isempty(limCodeLeft)
                limCodeLeft=[getYYaxisCode(ax);limCodeLeft];%#ok<AGROW>
            end

            limCode=[limCodeRight;limCodeLeft];


            if origActiveDataspace==1
                yyaxis(ax,'left');
            else
                yyaxis(ax,'right');
            end
        end

        function code=generateCodeFromBehaviorObject(this,ax)
            code={};

            bh=this.getLEBehavior(ax);
            if~isempty(bh)
                if~bh.IgnoreCodeGeneration



                    pzData=this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.PANZOOM);
                    code=feval(bh.InteractionCodeFcn,ax,pzData);






                    drawnow update
                end
            end
        end


        function str=getManualLimitsCode(this,ax,rulerStr)
            str={};

            if strcmpi(ax.([upper(rulerStr),'LimMode']),'manual')
                str=this.getLimitsCode(ax,rulerStr);
            end
        end


        function str=getDataTipCodeImpl(this,ax,axIndex,codeLines)

            hTips=findobj(ax,'-isa','matlab.graphics.datatip.DataTip');


            newTipsInd=arrayfun(@(h)~h.getPointDataTip().IsAddedViaDataTipAPI,hTips);

            hNewTips=hTips(newTipsInd);
            hPreExistingTips=hTips(~newTipsInd);
            str={};
            tempStrCodeLines=codeLines;

            if isYYaxis(ax)

                sideIndNew=arrayfun(@(t)getSideIndex(ax,t),hNewTips);
                sideIndPreExisting=arrayfun(@(t)getSideIndex(ax,t),hPreExistingTips);
                sideIndTips=arrayfun(@(t)getSideIndex(ax,t),hTips);
                tempYYaxisLeftStr={};
                tempYYaxisRightStr={};

                leftNewDatatips=hNewTips(sideIndNew==1);
                yyAxisLeftStr='yyaxis left';
                if~isempty(leftNewDatatips)
                    tempYYaxisLeftStr=[yyAxisLeftStr;this.getNewDataTipsCode(ax,leftNewDatatips,tempYYaxisLeftStr)];
                end


                leftDatatips=hPreExistingTips(sideIndPreExisting==1);
                if~isempty(leftDatatips)
                    code=this.getPreExistingDataTipsCode(ax,leftDatatips,tempYYaxisLeftStr);
                    if~any(contains(tempYYaxisLeftStr,yyAxisLeftStr))&&~isempty(code)
                        tempYYaxisLeftStr=[tempYYaxisLeftStr;yyAxisLeftStr];
                    end
                    tempYYaxisLeftStr=[tempYYaxisLeftStr;code];
                end

                leftDatatipsAll=hTips(sideIndTips==1);
                yaxIndex=1;
                if~isempty(leftDatatipsAll)
                    tempYYaxisLeftStr=this.getDatatipsTextEditingCode(ax,axIndex,yaxIndex,leftDatatipsAll,tempYYaxisLeftStr);
                    if~any(contains(tempYYaxisLeftStr,yyAxisLeftStr))&&~isempty(tempYYaxisLeftStr)
                        tempYYaxisLeftStr=[yyAxisLeftStr;tempYYaxisLeftStr];
                    end
                end


                rightNewDatatips=hNewTips(sideIndNew==2);
                yyAxisRightStr='yyaxis right';
                if~isempty(rightNewDatatips)
                    tempYYaxisRightStr=[tempYYaxisRightStr;yyAxisRightStr;this.getNewDataTipsCode(ax,rightNewDatatips,tempYYaxisRightStr)];
                end


                rightDatatips=hPreExistingTips(sideIndPreExisting==2);
                if~isempty(rightDatatips)
                    code=this.getPreExistingDataTipsCode(ax,rightDatatips,tempYYaxisRightStr);
                    if~any(contains(tempYYaxisRightStr,yyAxisRightStr))&&~isempty(code)
                        tempYYaxisRightStr=[tempYYaxisRightStr;yyAxisRightStr];
                    end
                    tempYYaxisRightStr=[tempYYaxisRightStr;code];
                end

                rightDatatipsAll=hTips(sideIndTips==2);
                yaxIndex=2;
                if~isempty(rightDatatipsAll)
                    tempYYaxisRightStr=this.getDatatipsTextEditingCode(ax,axIndex,yaxIndex,rightDatatipsAll,tempYYaxisRightStr);
                    if~any(contains(tempYYaxisRightStr,yyAxisRightStr))&&~isempty(tempYYaxisRightStr)
                        tempYYaxisRightStr=[yyAxisRightStr;tempYYaxisRightStr];
                    end
                end
                str=[tempYYaxisLeftStr;tempYYaxisRightStr];
            else
                str=[this.getPreExistingDataTipsCode(ax,hPreExistingTips,tempStrCodeLines)];
                tempStrCodeLines=[tempStrCodeLines;str];
                str=[str;this.getNewDataTipsCode(ax,hNewTips,tempStrCodeLines)];
                tempStrCodeLines=[tempStrCodeLines;str];
                yaxIndex=1;
                str=this.getDatatipsTextEditingCode(ax,axIndex,yaxIndex,hTips,str);
            end
        end

        function str=getDataTipCode(this,ax,axIndex,codeLines)
            str={};

            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                str=this.getDataTipCodeImpl(ax,axIndex,codeLines);
            else


                str=[str;this.getGraphicsViewDataTipCode(ax)];
            end
        end



        function str=getGraphicsViewDataTipCode(this,ax)

            str={};

            if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIPS_REMOVED)
                if isempty(this.DataTipsStruct.ExistingDatatips)
                    str={};
                else
                    str={'delete(findobj(gcf,''Type'',''DataTip''));'};
                end
            elseif this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_ADDED)

                dt=findobj(ax,'-isa','matlab.graphics.datatip.DataTip');
                if isempty(dt)
                    return;
                end


                str={'ax = gca;'};
                chartIndex=find(ax.Children==dt.Parent);
                chartObjCode='chart = ax.Children';



                while isempty(chartIndex)
                    axesChildren=ax.Children.Children;
                    chartIndex=find(axesChildren==dt.Parent);
                    chartObjCode=sprintf('%s.Children',chartObjCode);

                    if~isempty(chartIndex)||isempty(axesChildren)
                        break;
                    end
                end

                str=[str;{sprintf('%s(%d);',chartObjCode,chartIndex)}];


                dynamicCoord=dt.getDynamicCoordinates();
                dtPos={dt.(dynamicCoord{1});dt.(dynamicCoord{2});dt.(dynamicCoord{3})};


                x=localGetFormattedValue(dtPos{1},4);
                y=localGetFormattedValue(dtPos{2},4);
                z=localGetFormattedValue(dtPos{3},4);
                dataTipCommand=sprintf('datatip(chart,%s,%s',x,y);

                if strcmpi(dt.LocationMode,'auto')
                    if is2D(ax)
                        str=[str;{sprintf('%s);',dataTipCommand)}];
                    else
                        str=[str;{sprintf('%s,%s);',dataTipCommand,z)}];
                    end
                else
                    dtLocationCommand=sprintf('''Location'',''%s''',dt.Location);
                    if is2D(ax)
                        str=[str;{sprintf('%s,%s);',dataTipCommand,dtLocationCommand)}];
                    else
                        str=[str;{sprintf('%s,%s,%s);',dataTipCommand,z,dtLocationCommand)}];
                    end
                end
            elseif this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_EDITED)

                datatips=findobj(ax,'-isa','matlab.graphics.datatip.DataTip');
                for i=1:numel(datatips)
                    index=i;

                    if this.isActionRegistered(datatips(i).getPointDataTip(),matlab.internal.editor.figure.ActionID.DATATIP_EDITED)
                        dt=datatips(i);
                        existingDT=this.DataTipsStruct.ExistingDatatips(index);

                        dynamicCoord=dt.getDynamicCoordinates();
                        dtPos={dt.(dynamicCoord{1});dt.(dynamicCoord{2});dt.(dynamicCoord{3})};



                        x=localGetFormattedValue(dtPos{1},4);
                        y=localGetFormattedValue(dtPos{2},4);
                        z=localGetFormattedValue(dtPos{3},4);

                        dtCode='dt = findobj(gca,''DataIndex'',%d);';
                        if isYYaxis(ax)


                            dtCode='dt = findobj(get(gca,''Children''),''DataIndex'',%d);';
                        end

                        str=[str;{sprintf(dtCode,existingDT.DataIndex)}];%#ok<AGROW>


                        if strcmpi(dt.LocationMode,'manual')&&...
                            ~strcmpi(existingDT.Location,dt.Location)&&...
                            existingDT.Position{1}==dtPos{1}&&...
                            existingDT.Position{2}==dtPos{2}&&...
                            existingDT.Position{3}==dtPos{3}
                            str=[str;{sprintf('set(dt,''Location'',''%s'');',dt.Location)}];%#ok<AGROW>
                            return;
                        end
                        dataTipCommand=sprintf('set(dt,''%s'',%s,''%s'',%s',dynamicCoord{1},x,dynamicCoord{2},y);
                        if strcmpi(dt.LocationMode,'auto')
                            if is2D(ax)
                                str=[str;{sprintf('%s);',dataTipCommand)}];%#ok<AGROW>
                            else
                                str=[str;{sprintf('%s,''%s'',%s);',dataTipCommand,dynamicCoord{3},z)}];%#ok<AGROW>
                            end
                        else
                            dtLocationCommand=sprintf('''Location'',''%s''',dt.Location);
                            if is2D(ax)
                                str=[str;{sprintf('%s,%s);',dataTipCommand,dtLocationCommand)}];%#ok<AGROW>
                            else
                                str=[str;{sprintf('%s,''%s'',%s,%s);',dataTipCommand,dynamicCoord{3},z,dtLocationCommand)}];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end

        function str=getPreExistingDataTipsCode(this,ax,hPreExistingTips,codeLines)
            str={};
            if~isempty(hPreExistingTips)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_EDITED)

                datatips=hPreExistingTips;


                tempStrCodeLines=codeLines;

                for i=1:numel(datatips)
                    index=i;
                    dt=datatips(i);
                    existingDT=this.DataTipsStruct.ExistingDatatips(index);


                    dynamicCoord=dt.getDynamicCoordinates();

                    if dt.DataIndex==existingDT.DataIndex&&isequal(existingDT.Location,dt.Location)



                        continue
                    end

                    dtPos={dt.(dynamicCoord{1});dt.(dynamicCoord{2});dt.(dynamicCoord{3})};



                    x=localGetFormattedValue(dtPos{1},4);
                    y=localGetFormattedValue(dtPos{2},4);
                    z=localGetFormattedValue(dtPos{3},4);
                    str=[str;{sprintf('dt = findobj(gca,''DataIndex'',%d);',existingDT.DataIndex)}];%#ok<AGROW>


                    if strcmpi(dt.LocationMode,'manual')&&...
                        ~strcmpi(existingDT.Location,dt.Location)&&...
                        existingDT.Position{1}==dtPos{1}&&...
                        existingDT.Position{2}==dtPos{2}&&...
                        existingDT.Position{3}==dtPos{3}
                        str=[str;{sprintf('set(dt,''Location'',''%s'');',dt.Location)}];%#ok<AGROW>
                        return;
                    end
                    dataTipCommand=sprintf('set(dt,''%s'',%s,''%s'',%s',dynamicCoord{1},x,dynamicCoord{2},y);
                    if strcmpi(dt.LocationMode,'auto')
                        if is2D(ax)
                            str=[str;{sprintf('%s);',dataTipCommand)}];%#ok<AGROW>
                        else
                            str=[str;{sprintf('%s,''%s'',%s);',dataTipCommand,dynamicCoord{3},z)}];%#ok<AGROW>
                        end
                    else
                        dtLocationCommand=sprintf('''Location'',''%s''',dt.Location);
                        if is2D(ax)
                            str=[str;{sprintf('%s,%s);',dataTipCommand,dtLocationCommand)}];%#ok<AGROW>
                        else
                            str=[str;{sprintf('%s,''%s'',%s,%s);',dataTipCommand,dynamicCoord{3},z,dtLocationCommand)}];%#ok<AGROW>
                        end
                    end
                end
            end
            if(numel(hPreExistingTips)<numel(this.DataTipsStruct.ExistingDatatips))&&...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_REMOVED)



                for i=1:numel(this.DataTipsStruct.ExistingDatatips)
                    if~isvalid(this.DataTipsStruct.ExistingDatatips(i).Object)
                        str=[str;{sprintf('dt = findobj(gca,''DataIndex'',%d);',this.DataTipsStruct.ExistingDatatips(i).DataIndex)}];%#ok<AGROW>
                        str=[str;'delete(dt)'];%#ok<AGROW>
                    end
                end
            end
        end

        function str=getNewDataTipsCode(this,ax,hNewTips,codeLines)
            str={};
            if~isempty(hNewTips)&&(this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_ADDED)||this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.DATATIP_REMOVED))

                hParents=arrayfun(@(x)x.Parent,hNewTips,'UniformOutput',false);
                hParents=unique([hParents{:}]);



                tempStrCodeLines=codeLines;


                axGcaCodeStr={'ax = gca;'};
                if~ismember(axGcaCodeStr,tempStrCodeLines)
                    str=[str;axGcaCodeStr];
                end

                for par=1:numel(hParents)
                    [chartObjCode,chartIndex]=getChatObjCodeAndIndex(ax,hParents(par));
                    str=[str;{sprintf('%s(%d);',chartObjCode,chartIndex)}];%#ok<AGROW>

                    dt=findobj(hNewTips,'Parent',hParents(par));
                    for i=1:numel(dt)


                        dynamicCoord=dt.getDynamicCoordinates();
                        dtPos={dt(i).(dynamicCoord{1});dt(i).(dynamicCoord{2});dt(i).(dynamicCoord{3})};


                        x=localGetFormattedValue(dtPos{1},4);
                        y=localGetFormattedValue(dtPos{2},4);
                        z=localGetFormattedValue(dtPos{3},4);
                        dataTipCommand=sprintf('datatip(chart,%s,%s',x,y);

                        if strcmpi(dt(i).LocationMode,'auto')
                            if is2D(ax)
                                str=[str;{sprintf('%s);',dataTipCommand)}];%#ok<AGROW>
                            else
                                str=[str;{sprintf('%s,%s);',dataTipCommand,z)}];%#ok<AGROW>
                            end
                        else
                            dtLocationCommand=sprintf('''Location'',''%s''',dt(i).Location);
                            if is2D(ax)
                                str=[str;{sprintf('%s,%s);',dataTipCommand,dtLocationCommand)}];%#ok<AGROW>
                            else
                                str=[str;{sprintf('%s,%s,%s);',dataTipCommand,z,dtLocationCommand)}];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end


        function str=getDatatipsTextEditingCode(this,ax,axIndex,yaxIndex,hDatatips,datatipsCode)
            str=datatipsCode;
            if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.TEXT_EDITED)
                axGcaCodeStr={'ax = gca;'};

                hTips=hDatatips;
                if~isempty(hTips)
                    hParents=arrayfun(@(x)x.Parent,hTips,'UniformOutput',false);
                    hParents=unique([hParents{:}]);
                    for par=1:numel(hParents)
                        [chartObjCode,chartIndex]=getChatObjCodeAndIndex(ax,hParents(par));
                        chartObjCodeStr={sprintf('%s(%d);',chartObjCode,chartIndex)};
                        if~ismember(axGcaCodeStr,str)&&isDatatipsLabelUpdated(this,hParents(par),axIndex,chartIndex,yaxIndex)
                            str=[str;axGcaCodeStr];
                        end
                        if~ismember(chartObjCodeStr,str)&&isDatatipsLabelUpdated(this,hParents(par),axIndex,chartIndex,yaxIndex)
                            str=[str;chartObjCodeStr];
                        end


                        if~strcmpi(hParents(par).DataTipTemplate.DataTipRowsMode,'auto')
                            for j=length(hParents(par).DataTipTemplate.DataTipRows):-1:1
                                if this.checkValueInDatatipsLabelStructExist(axIndex,chartIndex,yaxIndex)&&...
                                    ~strcmp(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart(chartIndex).Label{j},hParents(par).DataTipTemplate.DataTipRows(j).Label)
                                    [~,index]=ismember(chartObjCodeStr,str);
                                    if index>0&&length(str)>index
                                        str=[str(1:index);{sprintf('chart.DataTipTemplate.DataTipRows(%d).Label=''%s'';',j,hParents(par).DataTipTemplate.DataTipRows(j).Label)};str(index+1:end)];
                                    else
                                        str=[str;{sprintf('chart.DataTipTemplate.DataTipRows(%d).Label=''%s'';',j,hParents(par).DataTipTemplate.DataTipRows(j).Label)}];%#ok<AGROW>
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end


        function str=getLimitsCode(this,ax,rulerStr)
            str={};

            isPanZoomActionRegistered=this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.PANZOOM);




            if~isPanZoomActionRegistered&&any(this.PlotYYAxes==ax)
                peerAxes=getappdata(ax,'graphicsPlotyyPeer');
                isPanZoomActionRegistered=this.isActionRegistered(peerAxes,matlab.internal.editor.figure.ActionID.PANZOOM);
            end


            if isPanZoomActionRegistered
                if matlab.internal.editor.FigureManager.useEmbeddedFigures


                    this.updatePrecisionVector(ax);
                end
                precision=this.PrecisionVector{this.AxesHandles==ax};
                str=localGetRulerCode(ax,rulerStr,precision.(['precision',upper(rulerStr)]));
            end
        end


        function str=getViewCode(this,ax)
            str={};
            if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ROTATE)&&strcmp(ax.ViewMode,'manual')
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    this.updatePrecisionVector(ax);
                end
                precision=this.PrecisionVector{this.AxesHandles==ax};
                str={sprintf(['view',localGetNumericFormat(precision.precisionZ)],round(ax.View(1),precision.precisionZ),round(ax.View(2),precision.precisionZ))};
            end
        end


        function str=getGridCode(this,ax)

            str={};

            isGridAdded=this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.GRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_ADDED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_REMOVED);

            if isGridAdded
                grids=ones(1,1);

                if isa(ax,'matlab.graphics.axis.Axes')
                    grids=[strcmp(ax.XGrid,'on'),strcmp(ax.YGrid,'on'),strcmp(ax.ZGrid,'on')];
                    grids=grids.*isGridAdded;
                elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                    grids=[strcmp(ax.RGrid,'on'),strcmp(ax.ThetaGrid,'on')];
                    grids=grids.*isGridAdded;
                elseif isa(ax,'matlab.graphics.chart.Chart')
                    grids=strcmp(ax.GridVisible,'on');
                    grids=grids.*isGridAdded;
                elseif isa(ax,'matlab.graphics.axis.GeographicAxes')
                    grids=strcmp(ax.Grid,'on');
                    grids=grids.*isGridAdded;
                end

                if all(grids)

                    if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.GRID_ADDED)
                        str={'grid on'};
                    end

                elseif grids(1)

                    if isa(ax,'matlab.graphics.axis.Axes')
                        if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_ADDED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_REMOVED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_REMOVED)
                            if is2D(ax)
                                str={'set(gca,''XGrid'',''on'',''YGrid'',''off'')'};
                            else
                                str={'set(gca,''XGrid'',''on'',''YGrid'',''off'',''ZGrid'',''off'')'};
                            end

                        end
                    elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                        if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_ADDED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_REMOVED)
                            str={'set(gca,''RGrid'',''on'',''ThetaGrid'',''off'')'};
                        end
                    end
                elseif numel(grids)>1&&grids(2)
                    if isa(ax,'matlab.graphics.axis.Axes')
                        if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_ADDED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_REMOVED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_REMOVED)
                            if is2D(ax)
                                str={'set(gca,''XGrid'',''off'',''YGrid'',''on'')'};
                            else
                                str={'set(gca,''XGrid'',''off'',''YGrid'',''on'',''ZGrid'',''off'')'};
                            end
                        end
                    elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                        if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_ADDED)||...
                            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_REMOVED)
                            str={'set(gca,''RGrid'',''off'',''ThetaGrid'',''on'')'};
                        end
                    end
                elseif numel(grids)>2&&grids(3)
                    if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_ADDED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_REMOVED)||...
                        this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_REMOVED)
                        str={'set(gca,''XGrid'',''off'',''YGrid'',''off'',''ZGrid'',''on'')'};
                    end
                end
            end
        end

        function str=getGridRemovedCode(this,ax)
            str={};
            isGridRemoved=this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.GRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.THETAGRID_REMOVED)||...
            this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RGRID_REMOVED);

            if isGridRemoved
                grids=1;
                if isa(ax,'matlab.graphics.axis.Axes')
                    grids=[strcmp(ax.XGrid,'off'),strcmp(ax.YGrid,'off'),strcmp(ax.ZGrid,'off')];
                    grids=grids.*isGridRemoved;
                elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                    grids=[strcmp(ax.RGrid,'off'),strcmp(ax.ThetaGrid,'off')];
                    grids=grids.*isGridRemoved;
                elseif isa(ax,'matlab.graphics.chart.Chart')
                    grids=strcmp(ax.GridVisible,'off');
                    grids=grids.*isGridRemoved;
                elseif isa(ax,'matlab.graphics.axis.GeographicAxes')
                    grids=strcmp(ax.Grid,'off');
                    grids=grids.*isGridRemoved;
                end
                if all(grids)
                    str={'grid off'};
                end
            end
        end

        function str=getLegendCode(this,ax)
            import matlab.internal.editor.figure.ActionID;

            str={};

            if(this.isActionRegistered(ax,ActionID.LEGEND_ADDED)||...
                local_hasLagend(ax)&&(this.isActionRegistered(ax,ActionID.LEGEND_EDITED)||...
                this.isActionRegistered(ax.Legend,ActionID.OBJECT_MOVED)||...
                this.isActionRegistered(ax.Legend,ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(ax.Legend,ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(ax.Legend,ActionID.LINE_PROP_EDITED)))
                if isa(ax,'matlab.graphics.axis.AbstractAxes')&&~isempty(ax.Legend)

                    legEntries=[];
                    if this.isActionRegistered(ax,ActionID.LEGEND_EDITED)||this.isActionRegistered(ax.Legend,ActionID.LEGEND_EDITED)


                        for i=1:length(ax.Legend.String)
                            legEntries=[legEntries,char(this.formatLabelCode(ax.Legend.String{i})),','];%#ok<AGROW>
                        end





                        legEntries=legEntries(1:end-1);
                        legEntries=strrep(legEntries,newline,' ');
                    end

                    if isempty(legEntries)&&strcmp(ax.Legend.PositionMode,'auto')

                        legEntries='''show''';
                    end

                    if this.isActionRegistered(ax,ActionID.LEGEND_EDITED)&&numel(ax.Legend.String)>1


                        legEntries=['[',legEntries,']'];
                    end





                    legendInteractivelyMoved=strcmp(ax.Legend.PositionMode,'manual')&&this.isActionRegistered(ax.Legend,ActionID.OBJECT_MOVED);
                    if~isempty(legEntries)
                        if~legendInteractivelyMoved
                            str={['legend(',legEntries,this.generatePropertyEditingNameValuePairCode(ax.Legend)]};
                        else
                            str={['legend(',legEntries,')']};
                        end
                    end
                    if legendInteractivelyMoved
                        posVal=char(join(string(ax.Legend.Position),','));
                        str=[str;{['legend(''Position''',', [',posVal,']',this.generatePropertyEditingNameValuePairCode(ax.Legend)]}];
                    elseif isempty(legEntries)&&(this.isActionRegistered(ax.Colorbar,ActionID.TEXT_PROP_EDITED)||...
                        this.isActionRegistered(ax.Colorbar,ActionID.COLOR_PROP_EDITED)||...
                        this.isActionRegistered(ax.Colorbar,ActionID.LINE_PROP_EDITED))
                        nvpairStr=strip(strip(this.generatePropertyEditingNameValuePairCode(ax.Legend),'left',','),'left',' ');
                        str=[str;{['legend(',nvpairStr]}];
                    end
                elseif isa(ax,'matlab.graphics.chart.Chart')&&matlab.internal.editor.figure.ChartAccessor.hasLegend(ax)



                    str={'legend show'};
                end
            end
        end

        function str=getLegendRemovedCode(this,ax)
            import matlab.internal.editor.figure.FigureUtils;
            str={};
            if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.LEGEND_REMOVED)&&(FigureUtils.isReadableProp(ax,"Legend")&&isempty(ax.Legend)||FigureUtils.isReadableProp(ax,"LegendVisible")&&strcmpi(ax.LegendVisible,'off'))
                str={'legend off'};
            end
        end

        function str=getColorbarRemovedCode(this,ax)
            import matlab.internal.editor.figure.FigureUtils;
            str={};
            if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.COLORBAR_REMOVED)&&(FigureUtils.isReadableProp(ax,"Colorbar")&&isempty(ax.Colorbar)||FigureUtils.isReadableProp(ax,"ColorbarVisible")&&strcmpi(ax.ColorbarVisible,'off'))
                str={'colorbar off'};
            end
        end

        function str=getColorbarCode(this,ax)
            import matlab.internal.editor.figure.FigureUtils;
            str={};
            if matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax)&&...
                (this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.COLORBAR_ADDED)||...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.COLORBAR_EDITED)||...
                (FigureUtils.isReadableProp(ax,"Colorbar")&&(this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))))
                if FigureUtils.isReadableProp(ax,"Colorbar")&&~isempty(ax.Colorbar)
                    if~strcmp(ax.Colorbar.LocationMode,'manual')
                        str={'colorbar'};
                        if this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                            this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                            this.isActionRegistered(ax.Colorbar,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED)
                            nvpairStr=strip(strip(this.generatePropertyEditingNameValuePairCode(ax.Colorbar),'left',','),'left',' ');
                            if~isequal(nvpairStr,')')
                                str={sprintf('colorbar(%s',nvpairStr)};
                            end
                        end
                    else
                        str={['colorbar(''Location'',''',ax.Colorbar.Location,'''',this.generatePropertyEditingNameValuePairCode(ax.Colorbar)]};
                    end
                else

                    str={'colorbar(''Location'',''eastoutside'')'};
                end
            end
        end

        function str=getChartLimitsCode(this,ax)
            str={};
            if matlab.internal.editor.figure.ChartAccessor.isGeoChart(ax)
                if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.PANZOOM)

                    precision=this.PrecisionVector{this.AxesHandles==ax};

                    latVal1=round(ax.LatitudeLimits(1),precision.precisionX);
                    latVal2=round(ax.LatitudeLimits(2),precision.precisionX);

                    longVal1=round(ax.LongitudeLimits(1),precision.precisionY);
                    longVal2=round(ax.LongitudeLimits(2),precision.precisionY);

                    latSrt=sprintf(localGetLimitsFormat(precision.precisionX),latVal1,latVal2);
                    lonSrt=sprintf(localGetLimitsFormat(precision.precisionY),longVal1,longVal2);

                    str={sprintf('geolimits(%s,%s)',latSrt,lonSrt)};

                elseif this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.RESET_CHART)
                    str={'geolimits(''auto'')'};
                end
            elseif isa(ax,'matlab.graphics.chart.HeatmapChart')
                if this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.PANZOOM)
                    str(1)={sprintf('xlim({''%s'',''%s''})',...
                    escapeSingleQuote(ax.xlim{1}),escapeSingleQuote(ax.xlim{2}))};
                    str(2)={sprintf('ylim({''%s'',''%s''})',...
                    escapeSingleQuote(ax.ylim{1}),escapeSingleQuote(ax.ylim{2}))};
                end
            elseif isa(ax,'matlab.graphics.chart.StackedLineChart')
                str=this.getLimitsCode(ax,'x');
            end
        end


        function str=formatLabelCode(~,str)
            str=escapeSingleQuote(str);
            if length(str)>1


                str=str.join(''' , ''');
                str=strcat('[','''',str,'''',']');
            else
                str=strcat('''',str,'''');
            end
        end

        function str=getTitleCode(this,ax)
            str={};
            hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(ax);


            if~isempty(hTitle)&&...
                ((~isempty(hTitle.String)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.TITLE_ADDED))||...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.TITLE_EDITED))
                str={sprintf('title(%s%s',this.formatLabelCode(hTitle.String),...
                this.generatePropertyEditingNameValuePairCode(hTitle))};
            elseif~isempty(hTitle)&&...
                (this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))
                if isempty(str)
                    str={sprintf('title(%s%s',this.formatLabelCode(hTitle.String),...
                    this.generatePropertyEditingNameValuePairCode(hTitle))};
                end
            end
        end

        function str=getSubTitleCode(this,ax)
            str={};
            hTitle=matlab.internal.editor.figure.ChartAccessor.getSubtitleHandle(ax);


            if~isempty(hTitle)&&~isempty(hTitle.String)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.SUBTITLE_EDITED)
                str={sprintf('subtitle(%s%s',this.formatLabelCode(hTitle.String),...
                this.generatePropertyEditingNameValuePairCode(hTitle))};
            elseif~isempty(hTitle)&&...
                (this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(hTitle,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))
                if isempty(str)
                    str={sprintf('subtitle(%s%s',this.formatLabelCode(hTitle.String),...
                    this.generatePropertyEditingNameValuePairCode(hTitle))};
                end
            end
        end

        function str=getXLabelCode(this,ax)
            str={};
            hXlabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(ax);

            if~isempty(hXlabel)&&...
                ((~isempty(hXlabel.String)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XLABEL_ADDED))||...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XLABEL_EDITED))
                str={sprintf('xlabel(%s%s',this.formatLabelCode(hXlabel.String),...
                this.generatePropertyEditingNameValuePairCode(hXlabel))};
            elseif~isempty(hXlabel)&&...
                (this.isActionRegistered(hXlabel,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(hXlabel,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(hXlabel,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))
                if isempty(str)
                    str={sprintf('xlabel(%s%s',this.formatLabelCode(hXlabel.String),...
                    this.generatePropertyEditingNameValuePairCode(hXlabel))};
                end
            end
        end

        function str=getYLabelCode(this,ax)
            str={};
            hYlabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(ax);

            if~isempty(hYlabel)&&...
                ((~isempty(hYlabel.String)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YLABEL_ADDED))||...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YLABEL_EDITED))
                str={sprintf('ylabel(%s%s',this.formatLabelCode(hYlabel.String),...
                this.generatePropertyEditingNameValuePairCode(hYlabel))};
            elseif~isempty(hYlabel)&&...
                (this.isActionRegistered(hYlabel,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(hYlabel,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(hYlabel,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))
                if isempty(str)
                    str={sprintf('ylabel(%s%s',this.formatLabelCode(hYlabel.String),...
                    this.generatePropertyEditingNameValuePairCode(hYlabel))};
                end
            end
        end

        function str=getZLabelCode(this,ax)
            str={};
            hZlabel=matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(ax);
            if~isempty(hZlabel)&&...
                (~isempty(hZlabel.String)&&(this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZLABEL_EDITED)||...
                this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZLABEL_ADDED)))
                str={sprintf('zlabel(%s%s',this.formatLabelCode(hZlabel.String),...
                this.generatePropertyEditingNameValuePairCode(hZlabel))};
            elseif~isempty(hZlabel)&&...
                (this.isActionRegistered(hZlabel,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                this.isActionRegistered(hZlabel,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                this.isActionRegistered(hZlabel,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED))
                if isempty(str)
                    str={sprintf('zlabel(%s%s',this.formatLabelCode(hZlabel.String),...
                    this.generatePropertyEditingNameValuePairCode(hZlabel))};
                end
            end
        end

        function str=getLongitudeLabelCode(this,ax,codeLines)
            str={};
            hLongitudeLabel=matlab.internal.editor.figure.ChartAccessor.getLongitudeLabel(ax);
            if~isempty(hLongitudeLabel)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.LONGITUDELABEL_EDITED)
                if~ismember('ax = gca;',codeLines)
                    str=[str;'ax = gca;'];
                end
                str=[str;{[sprintf('ax.LongitudeLabel.String = %s',this.formatLabelCode(hLongitudeLabel.String)),';']}];
            end
        end

        function str=getLatitudeLabelCode(this,ax,codeLines)
            str={};
            hLatitudeLabel=matlab.internal.editor.figure.ChartAccessor.getLatitudeLabel(ax);
            if~isempty(hLatitudeLabel)&&this.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.LATITUDELABEL_EDITED)
                if~ismember('ax = gca;',codeLines)
                    str=[str;'ax = gca;'];
                end
                str=[str;{[sprintf('ax.LatitudeLabel.String = %s',this.formatLabelCode(hLatitudeLabel.String)),';']}];
            end
        end

        function str=getFontNameSizeCode(this,fig)
            import matlab.internal.editor.figure.*;

            str={};

            fontSizeAction=this.isActionRegistered(fig,ActionID.FONT_INCREASE)||...
            this.isActionRegistered(fig,ActionID.FONT_DECREASE);

            fontNameAction=this.isActionRegistered(fig,ActionID.FONT_NAME);


            textObj=findall(fig,'-property','FontName');

            if fontNameAction

                if~isempty(textObj)
                    names=get(textObj,'FontName');
                    if numel(textObj)>1
                        allSameFont=all(strcmp(names,names{1}));
                    else
                        allSameFont=true;
                    end



                    if allSameFont
                        str=[str;{sprintf('fontname(gcf, "%s")',textObj(1).FontName)}];
                    end
                end
            end

            if fontSizeAction&&~isempty(textObj)
                defaultFontSize=get(fig,'DefaultTextFontSize');
                scale=textObj(1).FontSize/defaultFontSize;



                if scale~=1
                    str=[str;{sprintf('fontsize(gcf, "scale", %.2f)',scale)}];
                end
            end
        end

        function str=getLineEditedCode(this,fig)
            import matlab.internal.editor.figure.*;

            str={};

            lineWidthAction=this.isActionRegistered(fig,ActionID.LINE_WIDTH_EDITED);

            lineStyleAction=this.isActionRegistered(fig,ActionID.LINE_STYLE_EDITED);

            lineColorAction=this.isActionRegistered(fig,ActionID.LINE_COLOR_EDITED);

            if lineWidthAction||lineStyleAction||lineColorAction
                lines=findall(fig,'type','line');
                baseStr='lines = findobj(gcf, "type", "line");';
                str=baseStr;
            else
                return;
            end

            l=lines(1);

            if lineWidthAction&&~isempty(lines)&&...
                l.LineWidth~=this.DefaultValuesStruct.DefaultLineWidth

                str=[str;{sprintf('set(lines, "LineWidth", %g);',l.LineWidth)}];
            end

            if lineStyleAction&&~isempty(lines)&&...
                ~strcmpi(l.LineStyle,this.DefaultValuesStruct.DefaultLineStyle)
                str=[str;{sprintf('set(lines, "LineStyle", %s);',l.LineStyle)}];
            end

            if lineColorAction&&~isempty(lines)
                str=[str;{sprintf('set(lines, "Color", [%.4f, %.4f, %.4f]);',l.Color(1),l.Color(2),l.Color(3))}];
            end



            if strcmpi(str,baseStr)
                str={};
            end
        end


        function codeStr=getCodeMultipleAxesStr(this,ax,axesCommand,axIndex)


            codeStr=axesCommand;



            pzrCode=this.generateCodeSingleAxes(ax,axIndex);


            if~isempty(pzrCode)
                codeStr=[codeStr;pzrCode(:)];%#ok<*NASGU>





            end

            if this.isActionRegistered(this.AxesHandles(1),matlab.internal.editor.figure.ActionID.AXES_ADDED)


                if~isempty(ax.Children)



                    codeStr=string(codeStr);
                    subplotInd=codeStr.contains('subplot');


                    if any(subplotInd)
                        codeStr(subplotInd)=codeStr(subplotInd).insertBefore(')',',gca');






                        codeStr=cellstr(codeStr);
                    end
                end
            elseif isempty(pzrCode)


                codeStr={};
            end
        end


        function updateDatatipStruct(this,ax,axIndex)
            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                hTips=findobj(ax,'-isa','matlab.graphics.datatip.DataTip');
                for i=1:numel(hTips)
                    [~,chartIndex]=getChatObjCodeAndIndex(ax,hTips(i).Parent);
                    yaxIndex=1;
                    if isYYaxis(ax)
                        yaxIndex=getSideIndex(ax,hTips(i));
                    end
                    if~isempty(hTips)
                        if~this.checkValueInDatatipsLabelStructExist(axIndex,chartIndex,yaxIndex)
                            this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart(chartIndex).Label={hTips(i).Parent.DataTipTemplate.DataTipRows.Label};
                        end
                    end
                end
            end
        end

        function ret=isDatatipsLabelUpdated(this,hParent,axIndex,chartIndex,yaxIndex)
            ret=false;
            for j=1:length(hParent.DataTipTemplate.DataTipRows)
                if this.checkValueInDatatipsLabelStructExist(axIndex,chartIndex,yaxIndex)&&...
                    ~strcmp(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart(chartIndex).Label{j},hParent.DataTipTemplate.DataTipRows(j).Label)
                    ret=true;
                    break;
                end
            end
        end

        function ret=checkValueInDatatipsLabelStructExist(this,axIndex,chartIndex,yaxIndex)
            ret=~isempty(this.DataTipsStruct.DataTipsLabelsStruct)&&isfield(this.DataTipsStruct.DataTipsLabelsStruct,'Axes')&&...
            numel(this.DataTipsStruct.DataTipsLabelsStruct.Axes)>=axIndex&&isfield(this.DataTipsStruct.DataTipsLabelsStruct.Axes,'YAxis')&&...
            numel(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis)>=yaxIndex&&isfield(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex),'Chart')&&...
            numel(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart)>=chartIndex&&isfield(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart(chartIndex),'Label')&&...
            ~isempty(this.DataTipsStruct.DataTipsLabelsStruct.Axes(axIndex).YAxis(yaxIndex).Chart(chartIndex).Label);
        end

        function str=generatePropertyEditingNameValuePairCode(this,selectedObject)


            str='';
            supportedPropertyEditingList=[];


            if this.isActionRegistered(this.CurrentFigure,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)&&...
                this.isActionRegistered(selectedObject,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["FontName","FontSize","FontAngle","FontWeight","HorizontalAlignment"]);
            end
            if this.isActionRegistered(this.CurrentFigure,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)&&...
                this.isActionRegistered(selectedObject,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["Color","EdgeColor","BackgroundColor","MarkerFaceColor","MarkerEdgeColor"]);
            end
            if this.isActionRegistered(this.CurrentFigure,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED)&&...
                this.isActionRegistered(selectedObject,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["LineStyle","LineWidth","Marker"]);
            end


            for i=1:numel(supportedPropertyEditingList)
                propertyEditingMode=strcat(supportedPropertyEditingList(i),'Mode');
                isPropertyEdited=isprop(selectedObject,propertyEditingMode)&&isequal(selectedObject.(propertyEditingMode),'manual');



                if strcmpi(supportedPropertyEditingList(i),'MarkerFaceColor')
                    isPropertyEdited=isPropertyEdited&&~isprop(selectedObject,'BackgroundColor');
                elseif strcmpi(supportedPropertyEditingList(i),'MarkerEdgeColor')
                    isPropertyEdited=isPropertyEdited&&~isprop(selectedObject,'EdgeColor');
                end
                if isPropertyEdited
                    if any(strcmpi(supportedPropertyEditingList(i),["FontName","FontAngle","FontWeight","HorizontalAlignment",...
                        "LineStyle","Marker"]))
                        str=strcat(str,sprintf(', "%s", "%s"',supportedPropertyEditingList(i),...
                        selectedObject.(supportedPropertyEditingList(i))));
                    elseif any(strcmpi(supportedPropertyEditingList(i),["Color","EdgeColor","BackgroundColor","MarkerFaceColor","MarkerEdgeColor"]))
                        if~ischar(selectedObject.(supportedPropertyEditingList(i)))
                            str=strcat(str,sprintf(', "%s", [%.4f, %.4f, %.4f]',supportedPropertyEditingList(i),...
                            selectedObject.(supportedPropertyEditingList(i))(1),selectedObject.(supportedPropertyEditingList(i))(2),selectedObject.(supportedPropertyEditingList(i))(3)));
                        else
                            str=strcat(str,sprintf(', "%s", "%s"',supportedPropertyEditingList(i),selectedObject.(supportedPropertyEditingList(i))));
                        end
                    elseif any(strcmpi(supportedPropertyEditingList(i),["FontSize","LineWidth"]))
                        str=strcat(str,sprintf(', "%s", %g',supportedPropertyEditingList(i),selectedObject.(supportedPropertyEditingList(i))));
                    end
                end
            end
            str=strcat(str,')');
        end

        function str=getPropertyEditingCode(this,ax)


            str={};
            supportedPropertyEditingList=[];
            fig=this.CurrentFigure;
            if this.isActionRegistered(fig,matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["FontName","FontSize","FontAngle","FontWeight","HorizontalAlignment"]);
            end
            if this.isActionRegistered(fig,matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["Color","LineColor","EdgeColor","BackgroundColor","MarkerFaceColor","MarkerEdgeColor"]);
            end
            if this.isActionRegistered(fig,matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED)
                supportedPropertyEditingList=horzcat(supportedPropertyEditingList,["LineStyle","LineWidth","Marker"]);
            end

            for n=1:numel(supportedPropertyEditingList)

                propertyObjs=findobj(fig,'-property',supportedPropertyEditingList(n));
                propertyObjMode=strcat(supportedPropertyEditingList(n),'Mode');
                for i=1:numel(propertyObjs)



                    isPropertyEdited=isprop(propertyObjs(i),propertyObjMode)&&...
                    isequal(propertyObjs(i).(propertyObjMode),'manual')&&...
                    (this.isActionRegistered(propertyObjs(i),matlab.internal.editor.figure.ActionID.TEXT_PROP_EDITED)||...
                    this.isActionRegistered(propertyObjs(i),matlab.internal.editor.figure.ActionID.COLOR_PROP_EDITED)||...
                    this.isActionRegistered(propertyObjs(i),matlab.internal.editor.figure.ActionID.LINE_PROP_EDITED));



                    if strcmpi(supportedPropertyEditingList(n),'MarkerFaceColor')
                        isPropertyEdited=isPropertyEdited&&~isprop(propertyObjs(i),'BackgroundColor');
                    elseif strcmpi(supportedPropertyEditingList(n),'MarkerEdgeColor')
                        isPropertyEdited=isPropertyEdited&&~isprop(propertyObjs(i),'EdgeColor');
                    end


                    if isPropertyEdited&&~this.isNameValuePairSupportedByObject(propertyObjs(i),ax)



                        findallCodegenSubstring=sprintf('findobj(gcf, "-property", "%s")',supportedPropertyEditingList(n));
                        if~any(contains(str,findallCodegenSubstring))
                            findallCodegenStr=sprintf('%sPropObjs = %s;',lower(supportedPropertyEditingList(n)),findallCodegenSubstring);
                            str=[str;{findallCodegenStr}];
                        end


                        if strcmpi(supportedPropertyEditingList(n),'FontName')
                            propEditingCodegenStr=sprintf('%s(%sPropObjs(%d), "%s")',lower(supportedPropertyEditingList(n)),lower(supportedPropertyEditingList(n)),...
                            i,propertyObjs(i).(supportedPropertyEditingList(n)));
                        elseif strcmpi(supportedPropertyEditingList(n),'FontSize')
                            propEditingCodegenStr=sprintf('%s(%sPropObjs(%d), %g)',lower(supportedPropertyEditingList(n)),lower(supportedPropertyEditingList(n)),...
                            i,propertyObjs(i).(supportedPropertyEditingList(n)));
                        elseif any(strcmpi(supportedPropertyEditingList(n),["FontAngle","FontWeight","HorizontalAlignment","LineStyle","Marker"]))
                            propEditingCodegenStr=sprintf('%sPropObjs(%d).%s = "%s";',lower(supportedPropertyEditingList(n)),i,...
                            supportedPropertyEditingList(n),propertyObjs(i).(supportedPropertyEditingList(n)));
                        elseif any(strcmpi(supportedPropertyEditingList(n),["Color","LineColor","EdgeColor","BackgroundColor","MarkerFaceColor","MarkerEdgeColor"]))
                            if~ischar(propertyObjs(i).(supportedPropertyEditingList(n)))
                                propEditingCodegenStr=sprintf('%sPropObjs(%d).%s = [%.4f %.4f %.4f];',lower(supportedPropertyEditingList(n)),i,supportedPropertyEditingList(n),...
                                propertyObjs(i).(supportedPropertyEditingList(n))(1),propertyObjs(i).(supportedPropertyEditingList(n))(2),propertyObjs(i).(supportedPropertyEditingList(n))(3));
                            else
                                propEditingCodegenStr=sprintf('%sPropObjs(%d).%s = "%s"',lower(supportedPropertyEditingList(n)),i,supportedPropertyEditingList(n),...
                                propertyObjs(i).(supportedPropertyEditingList(n)));
                            end
                        elseif strcmpi(supportedPropertyEditingList(n),"LineWidth")
                            propEditingCodegenStr=sprintf('%sPropObjs(%d).%s = %g;',lower(supportedPropertyEditingList(n)),i,supportedPropertyEditingList(n),...
                            propertyObjs(i).(supportedPropertyEditingList(n)));
                        end
                        str=[str;{propEditingCodegenStr}];
                    end
                end
            end
        end

        function ret=isNameValuePairSupportedByObject(this,selectedObject,ax)


            ret=this.checkIfObjectIsAnnotation(selectedObject)||...
            this.checkIfObjectIsTextLabelLegendColorbar(selectedObject,ax);
        end

        function ret=checkIfObjectIsAnnotation(this,selectedObject)



            scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(this.CurrentFigure);
            arrows=findall(scribeLayer,'-depth',1,'type','arrowshape');
            lines=findall(scribeLayer,'-depth',1,'type','lineshape');
            doublearrows=findall(scribeLayer,'-depth',1,'type','doubleendarrowshape');
            textarrows=findall(scribeLayer,'-depth',1,'type','textarrowshape');

            ret=(~isempty(arrows)&&any(arrayfun(@(x)isequal(x,selectedObject),arrows)))||...
            (~isempty(lines)&&any(arrayfun(@(x)isequal(x,selectedObject),lines)))||...
            (~isempty(doublearrows)&&any(arrayfun(@(x)isequal(x,selectedObject),doublearrows)))||...
            (~isempty(textarrows)&&any(arrayfun(@(x)isequal(x,selectedObject),textarrows)));
        end

        function ret=checkIfObjectIsTextLabelLegendColorbar(this,selectedObject,ax)


            ret=true;
            if~isempty(ax)
                titleObj=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(ax);
                axesObject=ancestor(selectedObject,{'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart'});
                subTitleObj=matlab.internal.editor.figure.ChartAccessor.getSubtitleHandle(ax);
                xLabelObj=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(ax);
                yLabelObj=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(ax);
                zLabelObj=matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(ax);
                colorbarObj=[];
                if matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax)
                    colorbarObj=ax.Colorbar;
                end
                legendObj=[];
                if local_hasLagend(ax)
                    legendObj=ax.Legend;
                end
                if isequal(ax,axesObject)
                    ret=isequal(selectedObject,titleObj)||...
                    isequal(selectedObject,subTitleObj)||...
                    isequal(selectedObject,xLabelObj)||...
                    isequal(selectedObject,yLabelObj)||...
                    isequal(selectedObject,zLabelObj)||...
                    isequal(selectedObject,colorbarObj)||...
                    isequal(selectedObject,legendObj);
                end
            end
        end

        function reset(this)
            this.SubplotCase=false;
            this.SubplotSize=[];
            this.AxesHandles=[];
            this.PrecisionVector=[];
            this.ActionRegistrator.clear();
        end

    end
end


function[chartObjCode,chartIndex]=getChatObjCodeAndIndex(ax,hParents)


    chartIndex=find(ax.Children==hParents);
    chartObjCode='chart = ax.Children';




    if isempty(chartIndex)
        chartIndex=1;
        hObj=hParents;
        while hObj.Parent~=ax
            hObj=hObj.Parent;
            chartIndex=chartIndex+1;
            chartObjCode=sprintf('%s.Children',chartObjCode);
        end
    end
end

function[rulerLimits,limCommand]=getRulerLimits(ax,rulerName)
    rulerLimits=[upper(rulerName),'Lim'];

    limCommand=lower(rulerLimits);
    if isa(ax,'matlab.graphics.chart.StackedLineChart')
        rulerLimits=[upper(rulerName),'Limits'];
        limCommand='xlim';
    end
end


function codeStr=localGetRulerCode(ax,rulerName,precision)

    codeStr={};

    [rulerLimits,limCommand]=getRulerLimits(ax,rulerName);

    limitVals=ax.(rulerLimits);
    limMode=ax.([rulerLimits,'Mode']);


    if strcmpi(limMode,'auto')

        if~(is2D(ax)&&strcmpi(rulerName,'z'))
            codeStr={[limCommand,'(''auto'')']};
        end
    elseif isnumeric(limitVals)
        codeStr={sprintf([limCommand,localGetNumericFormat(precision)],round(limitVals(1),precision),round(limitVals(2),precision))};
    elseif isdatetime(limitVals)


        dateStr1=localDateVecToString(limitVals(1),precision);
        dateStr2=localDateVecToString(limitVals(2),precision);

        datetimeConstructorArgs='%s';


        tz=limitVals(1).TimeZone;
        if~isempty(tz)

            timeZoneStr=['''TimeZone''',',','''',tz,''''];

            datetimeConstructorArgs=[datetimeConstructorArgs,',',timeZoneStr];
        end


        dateTimeFormatStr1=['([datetime(',datetimeConstructorArgs,')...'];

        dateTimeFormatStr2=['      datetime(',datetimeConstructorArgs,')])'];

        codeStr={sprintf([limCommand,dateTimeFormatStr1],dateStr1)};
        codeStr{end+1}=sprintf(dateTimeFormatStr2,dateStr2);

    elseif isduration(limitVals)


        [H1,M1,S1]=hms(limitVals(1));
        [H2,M2,S2]=hms(limitVals(2));


        df='%.0f';
        ds=['%.',num2str(precision),'f'];


        durationFormatStr1=['([duration(',df,',',df,',',ds,')...'];

        durationFormatStr2=['      duration(',df,',',df,',',ds,')])'];

        codeStr={sprintf([limCommand,durationFormatStr1],H1,M1,round(S1,precision))};
        codeStr{end+1}=sprintf(durationFormatStr2,H2,M2,round(S2,precision));

    elseif iscategorical(limitVals)

        catFormat=[limCommand,'({''%s'',''%s''})'];

        codeStr{end+1}=sprintf(catFormat,escapeSingleQuote(char(limitVals(1))),escapeSingleQuote(char(limitVals(2))));
    end
    codeStr=codeStr(:);
end


function yyaxisCode=getYYaxisCode(ax)
    yyaxisCode='';
    if isYYaxis(ax)
        activeSide='left';
        if ax.ActiveDataSpaceIndex==2
            activeSide='right';
        end


        yyaxisCode={['yyaxis ',activeSide]};
    end
end


function ret=isYYaxis(ax)
    ret=isa(ax,'matlab.graphics.axis.Axes')&&numel(ax.YAxis)>1;
end

function str=escapeSingleQuote(str)
    str=string(strrep(cellstr(str),'''',''''''));
end


function str=localDateVecToString(limitVals,precision)

    v=datevec(limitVals);

    v(end)=round(v(end),precision);
    str=mat2str(v);

    str(str==' ')=',';

    str=str(2:end-1);
end


function str=localGetNumericFormat(precision)
    str=['(',localGetLimitsFormat(precision),')'];
end

function str=localGetLimitsFormat(precision)
    str=['[%.',num2str(precision),'f ','%.',num2str(precision),'f]'];
end

function formattedVal=localGetFormattedValue(val,precision)
    formattedVal={};
    if isnumeric(val)
        formattedVal=mat2str(val,precision);
    elseif isdatetime(val)
        dateStr=localDateVecToString(val,precision);

        tz=val.TimeZone;
        if~isempty(tz)

            timeZoneStr=['''TimeZone''',',','''',tz,''''];

            dateStr=[dateStr,',',timeZoneStr];
        end

        formattedVal=['datetime(',dateStr,')'];
    elseif isduration(val)

        [H,M,S]=hms(val);

        df='%.0f';
        ds=['%.',num2str(precision),'f'];
        durationFormatStr=['duration(',df,',',df,',',ds,')'];
        formattedVal=sprintf(durationFormatStr,H,M,round(S,precision));
    elseif iscategorical(val)

        formattedVal=sprintf('''%s''',val);
    end
    formattedVal=formattedVal(:);
end


function side=getSideIndex(ax,child)
    for i=1:length(ax.TargetManager.Children)
        if any(child==findobj(ax.TargetManager.Children(i).ChildContainer.Children))
            side=i;
            break;
        end
    end
end


function hasLeg=local_hasLagend(ax)
    p=findprop(ax,'Legend');
    hasLeg=~isempty(p)&&~isempty(p.GetAccess)&&strcmpi(p.GetAccess,'public')&&~isempty(ax.Legend);
end