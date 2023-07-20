classdef MixedSignalAnalyzerTool<handle



    properties
Model
View
Controller

        appContainer;
    end

    properties(SetAccess=protected,Hidden)
toolStrip

        StatusWidget;
        isAppOpening=false;
        isAppClosing=false;
    end

    methods
        function obj=MixedSignalAnalyzerTool(varargin)




            obj.isAppOpening=true;
            obj.View=msblks.internal.apps.mixedsignalanalyzer.View();
            obj.Model=msblks.internal.apps.mixedsignalanalyzer.Model(obj);
            obj.Controller=msblks.internal.apps.mixedsignalanalyzer.Controller(obj.Model,obj.View);
            obj.isAppOpening=false;

            drawnow;

            obj.Model.View=obj.View;
            obj.Model.MixedSignalAnalysis.View=obj.View;
            obj.Model.MixedSignalAnalyzerTool=obj;
            obj.View.MixedSignalAnalyzerTool=obj;

            obj.toolStrip=obj.View.Toolstrip;
            obj.appContainer=obj.View.Toolstrip.appContainer;

            if nargin>0
                openedExistingDesign=initialModel(obj.Model,varargin);
            else
                openedExistingDesign=false;
            end


            set(obj.appContainer,'CanCloseFcn',@(h,e)appCloseRequestFcn(obj));


            if~openedExistingDesign
                obj.Model.newAction();
                obj.View.defaultLayoutAction();
            end
        end

        function clearMixedSignalAnalyzer(obj,isClosingMixedSignalAnalyzer)
            if obj.isAppClosing||obj.isAppOpening


                return;
            end
            obj.isAppClosing=isClosingMixedSignalAnalyzer;

            if~isClosingMixedSignalAnalyzer



                obj.Model.Database=[];
                obj.Model.Database_Type=[];
                obj.Model.IsChanged=false;


                obj.View.DataDB=[];

                obj.View.DataTree.SelectedNodes=[];
                for index=length(obj.View.DataTree.Children):-1:1
                    delete(obj.View.DataTree.Children(index));
                end
                obj.View.DataTreeAnalysisMetricsRootNodes=[];
                obj.View.DataTreeAnalysisWaveformsRootNodes=[];
                obj.View.DataTreeCheckedNodes=[];
                obj.View.DataTreeMetricCheckedNodes=[];
                obj.View.DataTreeWaveformCheckedNodes=[];
                obj.View.DataTree_SelectedTablesAndNodes=[];

                if~isempty(obj.View.PlotFigs)

                    for index=length(obj.View.PlotDocs):-1:1
                        if~isempty(obj.View.PlotDocs{index})
                            if length(obj.View.PlotDocs)<=1
                                obj.View.BlankPlotDoc.Phantom=false;
                                drawnow limitrate;
                            end
                            obj.View.Toolstrip.removePlotFromLayout(obj.View.PlotDocs{index}.Title);
                            obj.View.PlotDocs{index}.Selected=false;
                            close(obj.View.PlotDocs{index});
                            drawnow limitrate;
                        end
                    end
                end
                if isempty(obj.View.PlotFigs)

                    obj.View.addNewPlot();
                    drawnow limitrate;
                end

                plotOptionsPanels_MinIndex=4;
            else


                if~isempty(obj.View.PlotsGroupListener)

                    delete(obj.View.PlotsGroupListener);
                end
                if~isempty(obj.View.PlotDocs)

                    for index=1:length(obj.View.PlotDocs)
                        if~isempty(obj.View.PlotDocs{index})&&isvalid(obj.View.PlotDocs{index})&&~isempty(obj.View.PlotDocs{index}.CanCloseFcn)
                            obj.View.PlotDocs{index}.CanCloseFcn=[];
                        end
                    end
                end
                if~isempty(obj.View.AllFigures)








                    delete(obj.View.ToolstripFilterFigure);
                    obj.View.ToolstripFilterFigure=[];
                end
                if~isempty(obj.toolStrip)

                    delete(obj.toolStrip.AnalysisGallery);
                    delete(obj.toolStrip.MetricsGallery);
                    if~isempty(obj.toolStrip.AnalysisButtons)

                        for index=length(obj.toolStrip.AnalysisButtons):-1:1
                            delete(obj.toolStrip.AnalysisButtons{index});
                            obj.toolStrip.AnalysisButtons(index)=[];
                        end
                        obj.toolStrip.AnalysisButtons=[];
                        delete(obj.toolStrip.AnalysisTabGroup);
                        obj.toolStrip.AnalysisTabGroup=[];
                    end
                    if~isempty(obj.toolStrip.MetricsButtons)

                        for index=length(obj.toolStrip.MetricsButtons):-1:1
                            delete(obj.toolStrip.MetricsButtons{index});
                            obj.toolStrip.MetricsButtons(index)=[];
                        end
                        obj.toolStrip.MetricsButtons=[];
                    end
                end


                plotOptionsPanels_MinIndex=1;
            end
            if~isempty(obj.Model.figUpdateSession)

                delete(obj.Model.figUpdateSession);
            end
            if~isempty(obj.Model.figWorkspaceVariable)

                delete(obj.Model.figWorkspaceVariable);
            end
            if~isempty(obj.View.oldFilterFigure)

                delete(obj.View.oldFilterFigure);
            end
            if~isempty(obj.View.setPlotScalesFigure)

                delete(obj.View.setPlotScalesFigure);
            end
            if~isempty(obj.View.PlotOptionsPanels)


                for index=length(obj.View.PlotOptionsPanels):-1:plotOptionsPanels_MinIndex








                    if~isempty(obj.View.PlotOptionsFilterFigures)&&length(obj.View.PlotOptionsFilterFigures)>=index
                        delete(obj.View.PlotOptionsFilterFigures{index});
                    end
                    if~isempty(obj.View.OptionsFigLayout)&&isvalid(obj.View.OptionsFigLayout)&&...
                        ~isempty(obj.View.OptionsFigLayout.Children)&&length(obj.View.OptionsFigLayout.Children)>=index
                        delete(obj.View.OptionsFigLayout.Children(index));
                    end


                    obj.View.PlotOptionsTables(index)=[];
                    obj.View.PlotOptionsPanels(index)=[];
                    obj.View.PlotOptionsTitleLabels(index)=[];
                    obj.View.PlotOptionsFilters(index)=[];

                    obj.View.PlotOptionsFilterFigures(index)=[];
                    obj.View.PlotOptionsFilterButtons(index)=[];
                    obj.View.PlotOptionsFilterCheckboxes(index)=[];
                end
                if~isClosingMixedSignalAnalyzer





                    obj.View.defaultLayoutAction();
                    obj.View.OptionsFigLayout.RowHeight={0,0,0};
                else

                    obj.View.PlotOptionsTables=[];
                    obj.View.PlotOptionsPanels=[];
                    obj.View.PlotOptionsTitleLabels=[];
                    obj.View.PlotOptionsFilters=[];

                    obj.View.PlotOptionsFilterFigures=[];
                    obj.View.PlotOptionsFilterButtons=[];
                    obj.View.PlotOptionsFilterCheckboxes=[];
                end
            end
        end

        function result=appCloseRequestFcn(obj)






            if~isvalid(obj)||~isvalid(obj.Model)



                result=true;
                return;
            end
            if~isempty(obj.Model)&&obj.Model.IsChanged

                if obj.Model.processMixedSignalAnalysisSaving()
                    result=false;
                    return;
                end
            end
            s=settings;
            if~isempty(s)&&...
                isprop(s,'msblks')&&...
                isprop(s.msblks,'MixedSignalAnalyzer')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'X')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Y')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Width')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Height')
                windowBounds=obj.appContainer.WindowBounds;
                s.msblks.MixedSignalAnalyzer.X.PersonalValue=windowBounds(1);
                s.msblks.MixedSignalAnalyzer.Y.PersonalValue=windowBounds(2);
                s.msblks.MixedSignalAnalyzer.Width.PersonalValue=windowBounds(3);
                s.msblks.MixedSignalAnalyzer.Height.PersonalValue=windowBounds(4);
            end


            obj.appContainer.Visible=false;
            obj.View.ClosingAppContainer=true;
            obj.clearMixedSignalAnalyzer(true);





            result=true;
        end

        function setStatus(obj,statusText)
            if~isempty(obj.StatusWidget)
                delete(obj.StatusWidget);
            end
            if~isempty(statusText)&&obj.View.DataFig.Visible
                obj.StatusWidget=uiprogressdlg(obj.View.DataFig,'Message',statusText,'Title','Please Wait','Indeterminate','on');
            end
        end
    end
end
