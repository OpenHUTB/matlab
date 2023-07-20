function plotOneSignalToFile(obj,filePath,onesig)










    import sltest.internal.TestResultReport.*;
    p=inputParser;
    addRequired(p,'filePath',...
    @(x)validateattributes(x,{'char'},{'nonempty'}));
    addRequired(p,'onesig',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.Signal'},{}));
    p.parse(filePath,onesig);

    if stm.internal.util.getFeatureFlag('STMSnapshotInReport')>0
        sdiEng=Simulink.sdi.Instance.engine;
        comparisonSigId=sdiEng.getSignalParent(onesig.Difference.id);
        diffSigResult=Simulink.sdi.DiffSignalResult(comparisonSigId);
        snap=Simulink.sdi.CustomSnapshot;
        snap.plotComparison(diffSigResult);
        snap.snapshot("to","file","filename",filePath);
    else
        figureH=figure('Visible','off','Renderer','painters');
        needSubPlots=-1;
        if(~isempty(onesig.Baseline)||~isempty(onesig.Compare_to))
            needSubPlots=needSubPlots+1;
        end
        if(~isempty(onesig.Difference)||~isempty(onesig.Tolerance))
            needSubPlots=needSubPlots+1;
        end

        nPlotted=0;
        legendStrs={};
        if(needSubPlots==1)
            subplot(2,1,1);
        end
        if(~isempty(onesig.Baseline))
            plotOneFigure(onesig.Baseline,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ResultsTree:Baseline'));

            if(~isempty(onesig.Compare_to))
                hold on;
            end
        end

        if(~isempty(onesig.Compare_to))
            plotOneFigure(onesig.Compare_to,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=message('stm:CriteriaView:SignalCompare_CompareToLabel').getString;
        end

        if(~isempty(onesig.LowerTolerance))
            plotOneFigure(onesig.LowerTolerance,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_LowerTolerance'));
        end

        if(~isempty(onesig.UpperTolerance))
            plotOneFigure(onesig.UpperTolerance,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_UpperTolerance'));
        end

        if(nPlotted>0)
            lgnd=legend(legendStrs,'Location','NorthEast','Interpreter','none');
            set(lgnd,'color','none','box','off');
        end


        nPlotted=0;
        legendStrs={};
        if(needSubPlots==1)
            subplot(2,1,2);
        end

        diffSig=onesig.ComparedToMinusBaseline;

        if(~isempty(onesig.Difference)&&isempty(diffSig))


            diffSig=onesig.Difference;
        end


        if~isempty(diffSig)
            plotOneFigure(diffSig,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_Difference'));
            if(~isempty(onesig.Tolerance))
                hold on;
            end
        end


        if(isempty(onesig.LowerTolerance)&&~isempty(onesig.Tolerance))
            plotOneFigure(onesig.Tolerance,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_Tolerance'));
        end

        if(~isempty(onesig.DifferenceLowerTol))
            plotOneFigure(onesig.DifferenceLowerTol,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_DiffLowerTolerance'));
        end

        if(~isempty(onesig.DifferenceUpperTol))
            plotOneFigure(onesig.DifferenceUpperTol,onesig.TopSignal.signalLabel);
            nPlotted=nPlotted+1;
            legendStrs{nPlotted}=getString(message('stm:ReportContent:Label_DiffUpperTolerance'));
        end

        if(nPlotted>0)
            lgnd=legend(legendStrs,'Location','NorthEast','Interpreter','none');
            set(lgnd,'color','none','box','off');
        end
        title(getString(message('stm:ReportContent:Label_DifferenceAndTolerance')),'Interpreter','none');

        print(figureH,'-dpng','-r100',filePath);
        close(figureH);
    end
end


