

function strategy=sldv_get_strategy_name(testcomp)
    opts=testcomp.activeSettings;
    if strcmp(opts.Mode,'TestGeneration')
        strategy=opts.TestSuiteOptimization;
    elseif strcmp(opts.Mode,'DesignErrorDetection')
        if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
            strategy='FxpRangeComputation';
        else
            strategy=getStrategyForDed(opts);
        end
    else
        strategy=opts.ProvingStrategy;
    end
end

function strategy=getStrategyForDed(opts)
    if strcmp(opts.DetectDeadLogic,'on')
        if slfeature('SLDVCombinedDLRTE')&&Sldv.utils.isRunTimeErrors(opts)
            if strcmp(opts.DetectActiveLogic,'on')
                strategy='CombinedActiveLogicErrorDetection';
            else
                strategy='CombinedQuickDeadLogicErrorDetection';
            end
        elseif strcmp(opts.DetectActiveLogic,'on')
            strategy='DeadLogic';
        else
            strategy='QuickDeadLogic';
        end
    else
        strategy=opts.ErrorDetectionStrategy;
    end
end


