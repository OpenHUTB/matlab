classdef TrainingOutputFcn<handle

    properties(Access=private)
clientDataQueue
dataHandlerFcn
shouldStop
lastTime
trainingPlotter
runID
trialID
trialData
    end

    properties
workerDataQueue
    end

    methods
        function this=TrainingOutputFcn(input)
            this.clientDataQueue=input.clientDataQueue;
            this.dataHandlerFcn=input.dataHandlerFcn;

            this.trainingPlotter=input.trainingPlotter;
            this.runID=input.runID;
            this.trialID=input.trialID;
            this.trialData=input.trialData;
            this.shouldStop=input.shouldStopTrainingFcn;
            if~isempty(this.clientDataQueue)
                this.workerDataQueue=parallel.pool.PollableDataQueue;
            else
                this.workerDataQueue=[];
            end
            this.lastTime=tic;
        end

        function out=outputFcn(this,info)
            elapsedTime=toc(this.lastTime);
            if elapsedTime<1.0
                out=false;
                return;
            end
            this.lastTime=tic;

            progress=experiments.internal.getProgress(info,this.trainingPlotter.MaxEpochs,this.trainingPlotter.MaxIterations);
            prevProgress=this.trialData{2}.progressPercent;
            this.trialData{2}.progressPercent=progress;
            res.rowInd=this.trialID-1;
            res.rowData=this.trialData;

            if prevProgress<progress
                this.emitToTable(res);
            end

            if this.getShouldStop(info.Epoch)


                this.saveToDisk(res);
                this.trainingPlotter.requestStopTraining();
            else
                updateFreq=2;


                if(prevProgress+updateFreq)<=this.trialData{2}.progressPercent
                    this.saveToDisk(res);
                end

            end
            out=false;

        end
    end

    methods(Access=private)
        function val=getShouldStop(this,curEpoch)
            if~isempty(this.workerDataQueue)
                [~,val]=this.workerDataQueue.poll();
            else
                val=this.shouldStop(curEpoch);
            end
        end
        function emitToTable(this,res)
            if~isempty(this.clientDataQueue)
                this.clientDataQueue.send({'emittotable',...
                this.runID,this.trialID,res});
            else
                this.dataHandlerFcn({'emittotable',...
                this.runID,this.trialID,res});
            end

        end
        function saveToDisk(this,res)
            if~isempty(this.clientDataQueue)
                this.clientDataQueue.send({'savetodisk',...
                this.runID,this.trialID,res});
            else
                this.dataHandlerFcn({'savetodisk',...
                this.runID,this.trialID,res});
            end
        end
    end
end
