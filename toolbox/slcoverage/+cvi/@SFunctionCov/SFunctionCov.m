classdef SFunctionCov<handle






    properties


sfcnName2Info


modelName2SFcnBlkH


sfcnBlkH2CovId


incompSFcnSet


filteredSFcnSet
    end

    methods



        function this=SFunctionCov()
            this.reset();
        end




        function reset(this)
            this.sfcnName2Info=containers.Map('KeyType','char','ValueType','any');
            this.modelName2SFcnBlkH=containers.Map('KeyType','char','ValueType','any');
            this.sfcnBlkH2CovId=containers.Map('KeyType','double','ValueType','any');
            this.incompSFcnSet=containers.Map('KeyType','char','ValueType','any');
            this.filteredSFcnSet=containers.Map('KeyType','char','ValueType','any');
        end

    end

    methods(Static)


        sfcnBlkH=setupModel(coveng,modelH)
        setup(coveng)
        pause(coveng)
        term(coveng)
        fastRestart(coveng)
        addResults(coveng,modelCovId)
        addMetrics(coveng,sfcnBlkH)
        sfcnCovRes=extractResultsInfo(allTests,blockCvIds)

    end

    methods(Static,Hidden)




        function status=isSFcnCodeCovOn(modelH)
            status=strcmpi(get_param(modelH,'CovSFcnEnable'),'on');
        end

    end

end
