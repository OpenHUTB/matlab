




function[coveng,modelcovId]=getInstance(modelH)

    coveng=[];

    try
        modelcovId=get_param(modelH,'CoverageId');
    catch

        modelcovId=0;
    end

    if modelcovId==0
        return;
    end

    if~SlCov.CoverageAPI.isaValidCvId(modelcovId,'modelcov.isa')
        set_param(modelH,'CoverageId',0);
        return;
    end

    topModelcovId=cv('get',modelcovId,'.topModelcovId');

    if cv('ishandle',topModelcovId)
        coveng=cv('get',topModelcovId,'.topModelCov');

        if~isempty(coveng)&&~ishandle(coveng.topModelH)
            coveng=[];
        end
    end


