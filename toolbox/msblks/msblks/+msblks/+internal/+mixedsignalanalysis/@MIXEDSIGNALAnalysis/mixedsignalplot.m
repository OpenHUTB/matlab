function mixedsignalplot(obj,fld)




    if length(fld)==6
        tag=fld{1};
        view=fld{2};
        wfNames=fld{3};
        wfValues=fld{4};
        wfTables=fld{5};
        wfDbIndices=fld{6};

        str=validatestring(tag,{...
        'DirtyState',...
        'Update',...
        'AnalysisBtn_DisplayWaveform',...
        });


        if isempty(view)
            fig=uifigure;
            set(fig,'Name',str);
        else
            try
                view.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyPlotting')));
                [figHandle,docHandle]=view.getSelectedPlot();
                if isempty(figHandle)||~isempty(figHandle.UserData)&&~view.isWaveformPlot(figHandle)

                    view.addNewPlot();
                    drawnow;
                    pause(1.0);
                    [figHandle,docHandle]=view.getSelectedPlot();
                end

                plotTag=char(docHandle.Tag);
                switch tag
                case 'DirtyState'
                case 'Update'
                case 'AnalysisBtn_DisplayWaveform'
                    docHandle.Selected=true;
                    if isempty(figHandle.CurrentAxes)
                        figHandle.CurrentAxes=axes('Parent',figHandle);
                    end
                    figAxes=figHandle.CurrentAxes;
                    showGrid=figAxes.XGrid;
                    if isempty(figHandle.UserData)
                        hold(figAxes,'off');
                    else
                        hold(figAxes,'on');
                    end
                    uniqueWfTables={};
                    unplottedCount=0;
                    for i=1:length(wfValues)

                        plotHandle=plotWaveform(figHandle,...
                        wfValues{i}.x,wfValues{i}.xlabel,wfValues{i}.xscale,...
                        wfValues{i}.y,wfValues{i}.ylabel,wfValues{i}.yscale,...
                        wfTables{i});
                        if isempty(plotHandle)
                            unplottedCount=unplottedCount+1;
                            continue;
                        end
                        if~ishold(figAxes)
                            hold(figAxes,'on');
                        end

                        if isempty(uniqueWfTables)
                            uniqueWfTables{1}=wfTables{i};
                        else
                            isUnique=true;
                            for j=1:length(uniqueWfTables)
                                if uniqueWfTables{j}==wfTables{i}
                                    isUnique=false;
                                    break;
                                end
                            end
                            if isUnique
                                uniqueWfTables{end+1}=wfTables{i};%#ok<AGROW> % Append corner table to list.
                            end
                        end

                        if isempty(wfTables{i}.UserData{6})||isempty(wfTables{i}.UserData{7})||isempty(wfTables{i}.UserData{8})

                            wfTables{i}.UserData{6}=plotHandle;
                            wfTables{i}.UserData{8}={plotTag};
                            if iscell(wfNames{i})
                                wfTables{i}.UserData{7}=wfNames{i};
                            else
                                wfTables{i}.UserData{7}=wfNames(i);
                            end
                        else

                            wfTables{i}.UserData{6}(end+1)=plotHandle;
                            wfTables{i}.UserData{8}{end+1}=plotTag;
                            if iscell(wfNames{i})
                                wfTables{i}.UserData{7}(end+1,:)=wfNames{i};
                            else
                                wfTables{i}.UserData{7}(end+1,:)=wfNames(i);
                            end
                        end
                    end
                    if unplottedCount>0
                        ttl=getString(message('msblks:mixedsignalanalyzer:MixedUnitsPlotTitle'));
                        msg=getString(message('msblks:mixedsignalanalyzer:MixedUnitsPlotMessage',unplottedCount));
                        h=errordlg(msg,ttl,'modal');
                        uiwait(h)
                    end
                    hold(figAxes,'off');
                    if showGrid~=figAxes.XGrid
                        view.togglePlotGrid();
                    end
                    for i=1:length(uniqueWfTables)
                        uniqueWfTables{i}.UserData{9}{end+1}={figHandle,view.DataTreeWaveformCheckedNodes};%#ok<AGROW>
                    end
                end
            catch ex
                view.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            view.MixedSignalAnalyzerTool.setStatus('');
        end
    end
end

function plotHandle=plotWaveform(figHandle,x,xLabel,xScale,y,yLabel,yScale,plotOptionsTable)
    figAxes=figHandle.CurrentAxes;
    if isempty(figAxes.XLabel.String)||isempty(figAxes.YLabel.String)

        figAxes.XLabel.String=removeScriptChars(xLabel);
        figAxes.YLabel.String=removeScriptChars(yLabel);
    elseif~strcmpi(figAxes.XLabel.String,'data')&&...
        (~strcmpi(figAxes.XLabel.String,xLabel)||~strcmpi(figAxes.YLabel.String,yLabel))

        plotHandle=[];
        return;
    end
    if length(figAxes.Children)==1&&...
        length(figAxes.Children(1).XData)==1&&figAxes.Children(1).XData(1)==0&&...
        length(figAxes.Children(1).YData)==1&&figAxes.Children(1).YData(1)==0

        isLinearX=strcmpi(xScale,'linear');
        isLinearY=strcmpi(yScale,'linear');
    else

        isLinearX=strcmpi(figAxes.XScale,'linear');
        isLinearY=strcmpi(figAxes.YScale,'linear');
    end
    if isreal(y)
        yReal=y;
    else
        yReal=abs(y);
    end
    if isLinearX&&isLinearY
        plotHandle=plot(figAxes,x,yReal);
    elseif isLinearY
        plotHandle=semilogx(figAxes,x,yReal);
    elseif isLinearX
        plotHandle=semilogy(figAxes,x,yReal);
    else
        plotHandle=loglog(figAxes,x,yReal);
    end
    if isempty(figAxes.XLabel.String)||isempty(figAxes.YLabel.String)

        figAxes.XLabel.String=removeScriptChars(xLabel);
        figAxes.YLabel.String=removeScriptChars(yLabel);
    end
    for i=1:length(figHandle.UserData)
        if~iscell(figHandle.UserData{i})&&figHandle.UserData{i}==plotOptionsTable
            return;
        end
    end
    figHandle.UserData{end+1}=plotOptionsTable;
end
function fixedLabelText=removeScriptChars(originalLabelText)
    scriptChars='_';
    fixedLabelText=erase(originalLabelText,scriptChars);
end

