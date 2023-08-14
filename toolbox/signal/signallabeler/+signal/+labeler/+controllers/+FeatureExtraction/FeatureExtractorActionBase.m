

classdef FeatureExtractorActionBase<handle

    properties
        featureExtractor;
        Model;
        features;
        featureDefinitionIDs;


        NeedCleanUp;
    end
    methods(Abstract)


        name=getFeatureExtractorNameForDefinitionDescription(this)
    end
    methods(Access=protected,Abstract)


        y=getFeatureExtractorConstructor(this)
    end

    methods(Access=private)

        function[successFlag,exceptionInfo,axesFeatureData]=generateFeaturesAndLabelsImpl(this,memberID,featDefIDs,features,cleanUpHandle)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());
            signalData=this.Model.getSelectedSignalData(memberID);
            [successFlag,exceptionInfo,featureMatrix,featureInfo,timeLimits]=this.extractFeatures(signalData);
            axesFeatureData=[];
            if successFlag
                this.Model.addFeatureLabelInstance(memberID,featDefIDs,features,featureMatrix,featureInfo,timeLimits,this.Model.getLabelDataStruct());
                if this.Model.isMemberPlotted(memberID)
                    axesFeatureData=this.Model.getLabelDataForAxesForPlot(memberID,featDefIDs);
                end
            end


            this.NeedCleanUp=false;
        end
    end

    methods(Access=protected)



        function[successFlag,exceptionInfo,featrueMatrix,info,timeLimits]=extractFeatures(this,signalData)
            successFlag=true;
            exceptionInfo=struct(...
            "exceptionID","",...
            "exceptionMsg","");



            try
                [featrueMatrix,info,timeLimits]=this.featureExtractor.extract(signalData);
                sampleRate=this.featureExtractor.("SampleRate");

                if~isempty(sampleRate)
                    timeLimits=timeLimits/sampleRate;
                end
            catch ex
                successFlag=false;
                exceptionInfo.exceptionID=ex.identifier;
                exceptionInfo.exceptionMsg=ex.message;
                featrueMatrix=[];
                info=[];
                timeLimits=[];
            end
        end

        function[isTurnOnFeatures,featureNames]=getFeatureNamesAndStatusFlag(~,features,~)
            isTurnOnFeatures=true(numel(features),1);
            featureNames=features;
        end

        function featureParams=getFeatureParameters(~,featureName,parameters)
            featureParams=parameters.(featureName);
        end
    end

    methods(Hidden)

        function this=FeatureExtractorActionBase(model)

            this.Model=model;
        end

        function[successFlag,exceptionInfo]=setupAndValidateFeatureExtractor(this,features,featureData)
            successFlag=true;
            this.featureExtractor=this.getFeatureExtractorConstructor();
            exceptionInfo=struct(...
            "exceptionID","",...
            "exceptionMsg","");
            modeSampleRate=this.Model.getModeSampleRate();
            isFrameBased=featureData.mode=="frameBased";
            if modeSampleRate>0
                this.featureExtractor.SampleRate=modeSampleRate;
                if isFrameBased

                    featureData.framePolicyData.frameSize=floor(featureData.framePolicyData.frameSize*modeSampleRate);
                    if featureData.framePolicyData.frameSize==0



                        featureData.framePolicyData.frameSize=1;
                    end
                    if isfield(featureData.framePolicyData,'frameRate')
                        featureData.framePolicyData.frameRate=floor(featureData.framePolicyData.frameRate*modeSampleRate);
                        if featureData.framePolicyData.frameRate==0



                            featureData.framePolicyData.frameRate=1;
                        end
                    else
                        featureData.framePolicyData.frameOverlapLength=floor(featureData.framePolicyData.frameOverlapLength*modeSampleRate);
                        if featureData.framePolicyData.frameSize==featureData.framePolicyData.frameOverlapLength



                            featureData.framePolicyData.frameSize=featureData.framePolicyData.frameSize+1;
                        end
                    end
                end
            end
            this.Model.setIsFullSignalMode(true);
            if isFrameBased
                this.Model.setIsFullSignalMode(false);
                this.featureExtractor.FrameSize=featureData.framePolicyData.frameSize;
                this.featureExtractor.IncompleteFrameRule=featureData.framePolicyData.incompleteFrameRule;
                if isfield(featureData.framePolicyData,'frameRate')
                    this.featureExtractor.FrameRate=featureData.framePolicyData.frameRate;
                else
                    this.featureExtractor.FrameOverlapLength=featureData.framePolicyData.frameOverlapLength;
                end
            end
            parameters=featureData.params;
            [isTurnOnFeatures,featureNames]=this.getFeatureNamesAndStatusFlag(features,parameters);
            for idx=1:numel(featureNames)
                this.featureExtractor.(featureNames(idx))=isTurnOnFeatures(idx);
                featureParameter=this.getFeatureParameters(featureNames(idx),parameters);
                try
                    if~isempty(fields(featureParameter))
                        this.featureExtractor.setExtractorParameters(featureNames(idx),featureParameter);
                    end
                catch ex
                    successFlag=false;
                    exceptionInfo.exceptionID=ex.identifier;
                    exceptionInfo.exceptionMsg=ex.message;
                end
            end
        end


        function[successFlag,exceptionInfo,axesFeatureData]=generateFeaturesAndLabels(this,memberID,featDefIDs,features,cleanUpHandle)
            [successFlag,exceptionInfo,axesFeatureData]=generateFeaturesAndLabelsImpl(this,memberID,featDefIDs,features,cleanUpHandle);
        end
    end
end

