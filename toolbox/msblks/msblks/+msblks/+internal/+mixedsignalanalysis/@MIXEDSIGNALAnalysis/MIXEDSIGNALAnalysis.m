classdef MIXEDSIGNALAnalysis<handle




    properties

        VersionWhenSaved=[];


DataDB


Plots
    end

    properties(Dependent)
View
    end

    properties(Access=private)
        PrivateView=[]
    end

    properties(Constant,Hidden)
        Version=1.0
    end

    methods
        function obj=MIXEDSIGNALAnalysis(varargin)



            obj.View=[];
        end

        function val=get.VersionWhenSaved(obj)
            val=obj.VersionWhenSaved;
        end
        function set.VersionWhenSaved(obj,val)
            obj.VersionWhenSaved=val;
        end

        function val=get.View(obj)
            val=obj.PrivateView;
        end
        function set.View(obj,val)
            if~isempty(val)
                obj.PrivateView=val;
            end
        end
    end

    methods
        hDoc=exportScript(obj)
        hDoc=exportReport(obj,plotDocs,plotFigs)
        hDoc=exportWorkSpace(obj)
        mixedsignalplot(obj,txt)
    end

    methods
        function disp(obj)
            f=fields(obj);
            if~isscalar(obj)
                [M,N]=size(obj);
                fprintf('  %dx%d <a href="matlab:helpPopup mixedsignalanalysis">mixedsignalanalysis</a> array with properties:\n\n',...
                M,N);
                cellfun(@(s)fprintf('    %s\n',s),f)
            else
                fprintf('  <a href="matlab:helpPopup mixedsignalanalysis">mixedsignalanalysis</a> with properties:\n\n')
            end
            fprintf('\n')
        end

        function out=clone(obj)
            out=mixedSignalAnalysis;
            if~isempty(obj.View)&&~isempty(obj.View.DataDB)

                out.VersionWhenSaved=obj.VersionWhenSaved;


                dataDB=obj.View.DataDB;
                out.DataDB=[];
                for i=1:length(dataDB)
                    if i==1
                        out.DataDB=msblks.internal.mixedsignalanalysis.SimulationsDB;
                    else
                        out.DataDB(i)=msblks.internal.mixedsignalanalysis.SimulationsDB;
                    end
                    out.DataDB(i).sourceType=dataDB(i).sourceType;
                    out.DataDB(i).matFileName=dataDB(i).matFileName;
                    out.DataDB(i).fullPathMatFileName=dataDB(i).fullPathMatFileName;
                    out.DataDB(i).SimulationResultsNames=dataDB(i).SimulationResultsNames;
                    out.DataDB(i).SimulationResultsObjects=dataDB(i).SimulationResultsObjects;
                    out.DataDB(i).analysisNodeNames=dataDB(i).analysisNodeNames;
                    out.DataDB(i).analysisMetricNames=dataDB(i).analysisMetricNames;
                    out.DataDB(i).analysisMetricData=dataDB(i).analysisMetricData;
                    out.DataDB(i).analysisMetricCorners=dataDB(i).analysisMetricCorners;
                    out.DataDB(i).analysisMetricValues=dataDB(i).analysisMetricValues;
                    for j=1:length(dataDB(i).analysisWaveforms)
                        out.DataDB(i).analysisWaveforms{j}.x=dataDB(i).analysisWaveforms{j}.x;
                        out.DataDB(i).analysisWaveforms{j}.y=dataDB(i).analysisWaveforms{j}.y;
                        out.DataDB(i).analysisWaveforms{j}.xunit=dataDB(i).analysisWaveforms{j}.xunit;
                        out.DataDB(i).analysisWaveforms{j}.yunit=dataDB(i).analysisWaveforms{j}.yunit;
                        out.DataDB(i).analysisWaveforms{j}.xlabel=dataDB(i).analysisWaveforms{j}.xlabel;
                        out.DataDB(i).analysisWaveforms{j}.ylabel=dataDB(i).analysisWaveforms{j}.ylabel;
                        out.DataDB(i).analysisWaveforms{j}.xscale=dataDB(i).analysisWaveforms{j}.xscale;
                        out.DataDB(i).analysisWaveforms{j}.yscale=dataDB(i).analysisWaveforms{j}.yscale;
                        out.DataDB(i).analysisWaveforms{j}.type=dataDB(i).analysisWaveforms{j}.type;
                        out.DataDB(i).analysisWaveforms{j}.function=dataDB(i).analysisWaveforms{j}.function;
                        out.DataDB(i).analysisWaveforms{j}.wfName=dataDB(i).analysisWaveforms{j}.wfName;

                        out.DataDB(i).analysisWaveforms{j}.wfDBIndex=dataDB(i).analysisWaveforms{j}.wfDBIndex;
                        for k=1:length(dataDB(i).analysisWaveforms{j}.wfTable)

                            wfTableID{3}=[];
                            for m=1:3
                                wfTableID{m}=dataDB(i).analysisWaveforms{j}.wfTable{k}.UserData{m};
                            end
                            out.DataDB(i).analysisWaveforms{j}.wfTable{k}=wfTableID;
                        end
                    end
                end


                plotDocs=obj.View.PlotDocs;
                plotFigs=obj.View.PlotFigs;
                plots{length(plotDocs)}=[];
                for i=1:length(plotDocs)
                    plotTag=plotDocs{i}.Tag;
                    plots{i}.Title=plotDocs{i}.Title;
                    if isempty(plotFigs{i}.UserData)
                        continue;
                    end
                    if length(plotFigs{i}.UserData{1})==3
                        userDataStart=2;
                    else
                        userDataStart=1;
                    end
                    switch plotFigs{i}.UserData{userDataStart}.Type
                    case 'uitable'

                        plots{i}.Tables{length(plotFigs{i}.UserData)-userDataStart+1}=[];
                        for j=1:length(plots{i}.Tables)

                            cornerTable=plotFigs{i}.UserData{j+userDataStart-1};


                            plots{i}.Tables{j}.dbIndex=cornerTable.UserData{1};
                            plots{i}.Tables{j}.tableName=cornerTable.UserData{2};


                            wfCount=0;
                            wfNames=cornerTable.UserData{7};
                            wfPlotTags=cornerTable.UserData{8};
                            plots{i}.Tables{j}.wfNames{length(wfPlotTags)}=[];
                            for k=1:length(wfPlotTags)
                                if strcmp(wfPlotTags{k},plotTag)
                                    wfCount=wfCount+1;
                                    plots{i}.Tables{j}.wfNames{wfCount}=wfNames{k};
                                end
                            end
                            plots{i}.Tables{j}.wfNames(wfCount+1:end)=[];
                        end
                    case 'uipanel'


                        plots{i}.T=plotFigs{i}.UserData{2};
                        plots{i}.tableData=plotFigs{i}.UserData{3};
                        plots{i}.tableColumnName=plotFigs{i}.UserData{4};
                        plots{i}.symRunNames=plotFigs{i}.UserData{5};
                        plots{i}.cornerParams=plotFigs{i}.UserData{6};
                        plots{i}.metricParams=plotFigs{i}.UserData{7};
                        plots{i}.xAxisParams=plotFigs{i}.UserData{8};
                        plots{i}.yAxisParams=plotFigs{i}.UserData{9};
                        plots{i}.legendParams=plotFigs{i}.UserData{10};
                        plots{i}.checkedNodes=plotFigs{i}.UserData{11};
                    end
                end
                out.Plots=plots;


                out.View=[];
            end
        end
    end

end
