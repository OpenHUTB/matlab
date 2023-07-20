function out=emlCovIdx(sfStateId,emlEnum,typeSpcfIdx,sfunctionBlockHandle)

























    try



        emlCovMap=sf('get',sfStateId,'.eml.cvMapInfo');

        if isempty(emlCovMap)
            error(message('Sldv:CvApi:emlCovIdx:NoEMLCoverage',sfStateId));
        end


        if sf('get',sfStateId,'.isa')==sf('get','default','script.isa')
            emlEnum=emlEnum-26;
        end






























        allLengths=[...
        length(emlCovMap.fcnInfo)...
        ,length(emlCovMap.ifInfo)...
        ,0...
        ,0...
        ,length(emlCovMap.switchInfo)...
        ,length(emlCovMap.forInfo)...
        ,length(emlCovMap.whileInfo)...
        ,length(emlCovMap.relationalInfo)...
        ,length(emlCovMap.testobjectiveInfo)...
        ,length(emlCovMap.saturationInfo)];



        offsets=cumsum([0,allLengths(1:(end-1))]);
        offsets([3,4])=0;
        offsets(8)=0;

        if emlEnum>8
            error(message('Sldv:CvApi:emlCovIdx:UnexpectedEnum'));
        end

        out=offsets(emlEnum+1)+typeSpcfIdx;

        chartId=sfprivate('getChartOf',sfStateId);

        if Stateflow.MALUtils.isMalChart(chartId)


            slsfCvId=Sldv.CvApi.slsfId('',sfunctionBlockHandle,sfStateId);
            array=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('decision'),'.baseObjs');

            totalNumOfDecs=numel(array);
            code=cv('get',slsfCvId,'.code');
            numOfEmlDecs=cv('get',code,'.totalNumOfObjs.numOfDecs');

            CV_EML_COND_CHECK=2;
            CV_EML_MCDC_CHECK=3;

            isCondOrMcdc=emlEnum==CV_EML_COND_CHECK||emlEnum==CV_EML_MCDC_CHECK;

            if~isCondOrMcdc&&totalNumOfDecs>numOfEmlDecs



                out=out+(totalNumOfDecs-numOfEmlDecs);
            end
        end
    catch MEx
        rethrow(MEx);
    end

