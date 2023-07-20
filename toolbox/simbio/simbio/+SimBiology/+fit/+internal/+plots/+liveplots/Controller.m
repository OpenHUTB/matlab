










classdef Controller<handle

    properties
        DataQueue={};
        DataTimeOut=0.01;
        LikelihoodConverters={};


FunctionName
HybridFunctionName
FitType
EstimatedParameters


Transformer
Parallel

NumGroups
    end

    properties(Access=public)
DataSource
HybridDataSource
CleanupFunction
SingleFit
    end
    properties(Transient)
        DashboardCreated=false;
Dashboard
    end
    properties(Dependent,SetAccess=immutable)
StopEstimation
    end

    methods
        function obj=saveobj(obj)



            if~obj.DashboardCreated
                obj.DataQueue={};
            end
        end
    end
    methods

        function obj=Controller(funcName,hybridFunctionName,fitType,params,numGroups)
            obj.FunctionName=funcName;
            obj.HybridFunctionName=hybridFunctionName;
            obj.FitType=fitType;
            obj.EstimatedParameters=params;
            obj.NumGroups=numGroups;
            obj.SingleFit=obj.FitType==SimBiology.fit.internal.FitType.Pooled||obj.FitType==SimBiology.fit.internal.FitType.Hierarchical||obj.NumGroups==1;
        end


        function createDashboard(obj,bounds)
            obj.Dashboard=SimBiology.fit.internal.plots.liveplots.Dashboard(obj,obj.FunctionName,obj.HybridFunctionName,obj.EstimatedParameters,bounds,obj.NumGroups);
            obj.DashboardCreated=true;
        end


        function initController(obj,transformer,parallel)
            obj.Transformer=transformer;
            if obj.DashboardCreated
                obj.Dashboard.init(parallel);
            end
        end

        function storeLikelihoodConverter(obj,index,func)
            if ischar(index)
                obj.LikelihoodConverters{1}=func;
            else
                obj.LikelihoodConverters{index}=func;
            end
        end


        function out=getOutputFunction(obj,groupIndex,options,functionName)
            maxIter=obj.getMaxIterations(options,functionName);
            if strcmp(functionName,'particleswarm')


                out=@(optimValues,state)batchUpdate(obj,groupIndex,maxIter,functionName,{optimValues,state});
            else
                out=@(varargin)batchUpdate(obj,groupIndex,maxIter,functionName,varargin);
            end
        end


        function updateExitCondition(obj,index,resultObj,functionName)
            exitCondition='';

            if isempty(resultObj)
                exitFlag=SimBiology.fit.internal.plots.liveplots.DashboardHelper.FitErrorFlag;
            else
                exitFlag=resultObj.ExitFlag;
                exitCondition=resultObj.Output.message;
            end

            key=obj.getKey(index);
            dataSource=getDataSourceObject(obj,functionName,key);
            dataSource.ExitCondition=exitCondition;
            dataSource.ExitFlag=exitFlag;


            if obj.DashboardCreated
                obj.Dashboard.setExitFlag(key,exitFlag);
            end
        end


        function finishPlotting(obj)
            if obj.DashboardCreated
                obj.Dashboard.finishPlotting();
            end
            obj.DataQueue={};
        end


        function update(obj,groupIndex,maxIter,functionName,data)
            obj.updateDataSource(groupIndex,maxIter,functionName,data);
        end


        function createDataQueue(obj)
            if isempty(obj.DataQueue)
                obj.DataQueue=SimBiology.internal.BiDirectionalDataQueue;
            end
        end


        function dataReceived=pollDataQueue(obj)


            maxBufferSize=50;
            numReceived=0;
            dataCell=cell(maxBufferSize,1);
            while numReceived<maxBufferSize


                [data1,dataReceived]=obj.DataQueue.poll();
                if dataReceived
                    numReceived=numReceived+1;
                    dataCell{numReceived}=data1;
                else
                    break
                end
            end


            for i=1:numReceived
                [groupIndex,maxIter,functionName,likelihoodConverter,varargin]=deal(dataCell{i}{:});
                obj.LikelihoodConverters{groupIndex}=likelihoodConverter;
                obj.update(groupIndex,maxIter,functionName,varargin);
            end
        end


        function flushDataQueue(obj)
            while true
                dataReceived=obj.pollDataQueue();
                if~dataReceived
                    break
                end
            end
        end

        function indices=getFailedIndices(obj)
            dataSource=[obj.DataSource{:}];
            exitFlags=[dataSource.ExitFlag];
            failedDataSrc=dataSource(exitFlags<=0&arrayfun(@(s)~isempty(s.Tag),dataSource));
            indices=[failedDataSrc.Tag];
        end

        function figureClosed(obj)
            obj.DashboardCreated=false;

            if~isempty(obj.CleanupFunction)
                obj.CleanupFunction();
            end
        end

        function stopEstimation=get.StopEstimation(obj)
            if obj.DashboardCreated

                stopEstimation=obj.Dashboard.StopEstimation;
            elseif~isempty(obj.DataQueue)

                stopEstimation=obj.DataQueue.shouldStop();
            else

                stopEstimation=false;
            end
        end

        function stop(obj)

            if~isempty(obj.DataQueue)
                stop(obj.DataQueue);
            end
        end


        function notifyFitStarted(obj)
            if obj.DashboardCreated
                obj.Dashboard.notifyFitStarted();
            end
        end


        function notifyFitComplete(obj)
            if obj.DashboardCreated
                obj.Dashboard.notifyFitComplete();
            end
        end

        function fitErrored(obj,index,functionName)
            switch functionName
            case{'particleswarm','scattersearch'}
                data={[],'done',[]};
            otherwise
                data={[],[],'done'};
            end

            obj.batchUpdate(index,[],functionName,data);
        end
    end



    methods(Access=private)

        function key=getKey(obj,key)
            if obj.SingleFit
                key=1;
            end
        end



        function[state,options,changed]=batchUpdate(obj,groupIndex,maxIter,functionName,data)
            if strcmp(functionName,'ga')


                obj.sendData(groupIndex,maxIter,functionName,data(2:end));
            else
                obj.sendData(groupIndex,maxIter,functionName,data);
            end


            [state,options,changed]=obj.getReturnVals(data,functionName);

        end


        function sendData(obj,groupIndex,maxIter,functionName,batchData)
            if~isempty(obj.DataQueue)

                obj.DataQueue.send({groupIndex,maxIter,functionName,obj.LikelihoodConverters{groupIndex},batchData});
            else

                obj.update(groupIndex,maxIter,functionName,batchData);
            end
        end

        function out=getFlag(~,data,functionName)
            switch functionName
            case 'particleswarm'
                out=data{2};
            otherwise
                out=data{3};
            end
        end


        function[state,options,changed]=getReturnVals(obj,batchData,functionName)

            switch functionName
            case 'ga'
                options=batchData{1};
                state=batchData{2};
                changed=false;
                if obj.StopEstimation
                    state.StopFlag='stop';
                end
            otherwise
                options=[];
                changed=[];
                state=obj.StopEstimation;
            end
        end



        function maxIter=getMaxIterations(obj,options,functionName)
            switch functionName
            case 'ga'
                maxIter=options.MaxGenerations;
                if ischar(maxIter)
                    maxIter=100*numel(obj.EstimatedParameters);
                end

            case 'patternsearch'
                maxIter=options.MaxIterations;
                if ischar(maxIter)
                    maxIter=100*numel(obj.EstimatedParameters);
                end

            case 'particleswarm'
                maxIter=options.MaxIterations;
                if ischar(maxIter)
                    maxIter=200*numel(obj.EstimatedParameters);
                end

            case 'fminsearch'
                maxIter=options.MaxIter;
                if isempty(maxIter)
                    maxIter=200*numel(obj.EstimatedParameters);
                end

            case{'lsqnonlin','lsqcurvefit','fminunc','fmincon'}
                if isempty(options)
                    defaultOptions=SimBiology.fit.internal.constructEmptyOptions(functionName);
                    maxIter=defaultOptions.MaxIterations;
                else
                    maxIter=options.MaxIterations;
                end

            case 'scattersearch'
                if ischar(options.MaxIterations)
                    options=options.replaceAuto(numel(obj.EstimatedParameters));
                    maxIter=options.MaxIterations;
                else
                    maxIter=options.MaxIterations;
                end
            end
        end



        function updateDataSource(obj,index,maxIter,functionName,batchData)
            key=obj.getKey(index);
            dataSource=obj.getDataSourceObject(functionName,key);

            batchSize=size(batchData,1);
            for i=1:batchSize
                likelihoodConverter=obj.LikelihoodConverters{key};
                dataSource.update(key,maxIter,obj.Transformer,likelihoodConverter,batchData(i,:));

                if obj.DashboardCreated
                    isHybridFunction=strcmp(functionName,obj.HybridFunctionName);
                    obj.Dashboard.updatePlots(dataSource,isHybridFunction);
                end
            end
        end


        function dataSource=getDataSourceObject(obj,functionName,key)

            if strcmp(functionName,obj.HybridFunctionName)
                dataSourceCell=obj.HybridDataSource;
                isHybridFunction=true;
            else
                dataSourceCell=obj.DataSource;
                isHybridFunction=false;
            end


            if numel(dataSourceCell)<key||isempty(dataSourceCell{key})
                dataSource=getDataSourceObjectHelper(obj,functionName);
                if~isHybridFunction
                    obj.DataSource{key}=dataSource;
                else
                    obj.HybridDataSource{key}=dataSource;
                end
            else
                dataSource=dataSourceCell{key};
            end
        end

        function out=getDataSourceObjectHelper(obj,functionName)
            switch functionName
            case{'fmincon','fminunc','fminsearch','lsqcurvefit','lsqnonlin'}
                out=SimBiology.fit.internal.plots.liveplots.DataSource(obj.SingleFit);
            case 'patternsearch'
                out=SimBiology.fit.internal.plots.liveplots.DataSourcePatternSearch(obj.SingleFit);
            case 'ga'
                out=SimBiology.fit.internal.plots.liveplots.DataSourceGA(obj.SingleFit);
            case 'particleswarm'
                out=SimBiology.fit.internal.plots.liveplots.DataSourceParticleSwarm(obj.SingleFit);
            case 'scattersearch'
                out=SimBiology.fit.internal.plots.liveplots.DataSourceScatterSearch(obj.SingleFit);
            otherwise
                out=SimBiology.fit.internal.plots.liveplots.DataSource(obj.SingleFit);
            end
        end
    end
end

