function setupFromTopModel(topModelH,varargin)




    try
        if numel(varargin)<2
            simMode=[];
        else
            simMode=varargin{2};
        end
        [coveng,topModelcovId]=cvi.TopModelCov.setup(topModelH,[],simMode);
        setupHarnessInfo(coveng);
        if~isempty(coveng.harnessModel)&&isempty(coveng.unitUnderTestName)

            set_param(topModelH,'RecordCoverage','off');



            if~isempty(coveng)
                cvi.TopModelCov.storeHarnessInfo(coveng,topModelcovId);
            end
        end

        if isempty(varargin)||isempty(varargin{1})
            coveng.covModelRefData=cv.ModelRefData;
            coveng.covModelRefData.init(topModelH);
        else
            coveng.covModelRefData=varargin{1};
        end

        topModelName=get_param(topModelH,'Name');
        for rm=coveng.covModelRefData.recordingModels(:)'
            if~strcmp(topModelName,rm{1})
                modelH=get_param(rm{1},'handle');
                cvi.TopModelCov.setup(modelH,topModelcovId);
            end
        end
        if~isempty(coveng.covModelRefData)
            coveng.covModelRefData.mdlBlkToCopyMdlMap=containers.Map('keytype','char','valuetype','char');
        end
    catch MEx
        rethrow(MEx);
    end

