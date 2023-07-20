










classdef UIPlot<hgsetget

    properties(Access=public)
        AxesColor=[1,1,1]
        Grid='off';
        GridColor=[0.1500,0.1500,0.1500];
        PlotLines=SimBiology.simviewer.AppPlotLine.empty;
        ExternalData=[];
        Title='';
        Name='';
        LegendLocation='northeast';
        PlotStyle='line';
        XDir='normal';
        XLabel='';
        XLimMode='auto';
        XMax=10;
        XMin=1;
        XScale='linear';
        YDir='normal';
        YLabel='';
        YLimMode='auto';
        YMax=10;
        YMin=1;
        YScale='linear';
        MathLinePQNMap=[];
    end

    methods
        function obj=UIPlot(model)
            obj.AxesColor=model.AxesColor;
            obj.Grid=model.Grid;
            obj.GridColor=model.GridColor;
            obj.PlotLines=model.PlotLines;
            obj.Name=model.Name;
            obj.LegendLocation=model.LegendLocation;
            obj.PlotStyle=model.PlotStyle;
            obj.Title=model.Name;
            obj.XDir=model.XDir;
            obj.XLimMode=model.XLimMode;
            obj.XMax=model.XMax;
            obj.XMin=model.XMin;
            obj.XScale=model.XScale;
            obj.YDir=model.YDir;
            obj.YLimMode=model.YLimMode;
            obj.YMax=model.YMax;
            obj.YMin=model.YMin;
            obj.YScale=model.YScale;
            obj.MathLinePQNMap=model.MathLinePQNMap;
        end

        function compileMathExpressions(obj)
            for i=1:length(obj.PlotLines)
                plotLine=obj.PlotLines(i);
                if plotLine.Type==SimBiology.simviewer.LineTypes.MATH
                    tokens=SimBiology.internal.parseExpression(plotLine.Expression,{});

                    replacement=cell(1,length(tokens));
                    for j=1:length(tokens)
                        nextToken=tokens{j};
                        if strcmp(nextToken,'time')
                            next='time';
                            replacement{j}=next;
                        else
                            next=['x',num2str(j)];
                            replacement{j}=next;
                        end
                    end

                    plotLine.MathExpression=SimBiology.internal.Utils.Parser.traverseSubstitute(plotLine.Expression,tokens,replacement);
                    plotLine.MathTokens=tokens;
                    if~isempty(obj.MathLinePQNMap)
                        try




                            plotLine.MathTokenPQN=values(obj.MathLinePQNMap,tokens);
                        catch
                        end
                    end
                end
            end
        end

        function out=getLegendNames(obj)
            out=cell(1,length(obj.PlotLines)+length(obj.ExternalData));

            for i=1:length(obj.PlotLines)
                out{i}=obj.PlotLines(i).Name;
            end

            for i=1:length(obj.ExternalData)
                out{i+length(obj.PlotLines)}=obj.ExternalData(i).Name;
            end
        end

        function p=addExternalData(obj,name)
            p=SimBiology.simviewer.UIExternalData(name);

            if isempty(obj.ExternalData)
                obj.ExternalData=p;
            else
                obj.ExternalData(end+1)=p;
            end
        end

        function removeExternalData(obj,line)
            index=find(line==obj.ExternalData);
            if~isempty(index)
                obj.ExternalData(index)=[];
            end
        end

        function line=getLine(obj,selectedLineIndex)
            if selectedLineIndex<=length(obj.PlotLines)
                line=obj.PlotLines(selectedLineIndex);
            else
                line=obj.ExternalData(selectedLineIndex-length(obj.PlotLines));
            end
        end

        function out=isLineExternal(obj,line)
            out=any(line==obj.ExternalData);
        end




        function out=getAllStates(obj)
            out={};

            for i=1:numel(obj.PlotLines)
                plotLine=obj.PlotLines(i);
                if plotLine.Type==SimBiology.simviewer.LineTypes.MATH
                    out=[out,plotLine.MathTokenPQN];%#ok<AGROW>
                else
                    out{end+1}=plotLine.Name;%#ok<AGROW>
                end
            end

            out=unique(out);
        end
    end
end