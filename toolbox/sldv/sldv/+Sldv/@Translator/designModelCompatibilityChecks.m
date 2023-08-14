


function compatStatus=designModelCompatibilityChecks(obj)

    compatStatus=obj.mCompatStatus.char;

    compatStatus=checkForFixPointAnalysisWithObservers(compatStatus,obj.mModelToCheckCompatH,obj.mCompatObserverModelHs);
end

function compatStatus=checkForFixPointAnalysisWithObservers(compatStatus,modelH,obsMdlHs)
    if strcmp('DV_COMPAT_INCOMPATIBLE',compatStatus)
        return;
    end

    if~isempty(obsMdlHs)
        if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
            errMsg=getString(message('Sldv:Observer:UnsupObsFixPtAnalysis',get_param(modelH,'name')));
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv',errMsg,...
            'Sldv:Observer:UnsupObsFixPtAnalysis');

            compatStatus='DV_COMPAT_INCOMPATIBLE';
            return;
        end
    end
end
