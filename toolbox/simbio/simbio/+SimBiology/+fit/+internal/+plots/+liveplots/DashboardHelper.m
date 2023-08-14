








classdef DashboardHelper<handle

    properties(Constant)
        LineColor=[0,0.4470,0.7410];
        FailedLineColor=[1,0,0,0.3];
        HistogramColor=[0.1801,0.7177,0.6424];
        FailedBarColor=[0.8,0.1,0];
        FitErrorFlag=-6;
        LongestTickWidth=115;
        OverlayBarColor=[0.5294,0.5137,0.3804];
    end

    methods(Static)
        function out=getExitConditionString(numFits,functionName,exitFlag,singleFit)
            label=SimBiology.fit.internal.plots.liveplots.DashboardHelper.getExitConditionSummary(functionName,exitFlag);

            numFitsStr=num2str(numFits);

            if~singleFit
                if numFits>1
                    if exitFlag<=0
                        out=message('SimBiology:fitplots:LivePlots_Fits_Failed',numFitsStr,label);
                    else
                        out=message('SimBiology:fitplots:LivePlots_Fits_Converged',numFitsStr,label);
                    end
                else
                    if exitFlag<=0
                        out=message('SimBiology:fitplots:LivePlots_Fit_Failed',numFitsStr,label);
                    else
                        out=message('SimBiology:fitplots:LivePlots_Fit_Converged',numFitsStr,label);
                    end
                end
            else
                if exitFlag<=0
                    out=message('SimBiology:fitplots:LivePlots_Single_Fit_Failed',label);
                else
                    out=message('SimBiology:fitplots:LivePlots_Single_Fit_Converged',label);
                end
            end

            out=getString(out);
        end


        function out=getExitConditionSummary(functionName,exitFlag)
            switch exitFlag
            case SimBiology.fit.internal.plots.liveplots.DashboardHelper.FitErrorFlag
                out=message('SimBiology:fitplots:LivePlots_ExitCondition_Fit_Error');
            otherwise
                out=SimBiology.fit.internal.plots.liveplots.DashboardHelper.getExitConditionResourceKey(functionName,exitFlag);
            end

            out=getString(out);
        end

        function out=getExitConditionResourceKey(functionName,exitFlag)
            if strcmp(functionName,'lsqcurvefit')
                functionName='lsqnonlin';
            end

            if exitFlag<0
                out=sprintf('SimBiology:fitplots:LivePlots_ExitCondition_%s_Neg_%d',functionName,abs(exitFlag));
            else
                out=sprintf('SimBiology:fitplots:LivePlots_ExitCondition_%s_%d',functionName,exitFlag);
            end

            out=message(out);
        end
    end
end

