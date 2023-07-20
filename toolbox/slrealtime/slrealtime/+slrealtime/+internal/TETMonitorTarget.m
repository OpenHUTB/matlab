classdef TETMonitorTarget<handle












    methods(Access=public)



        function obj=TETMonitorTarget(targetName)
            obj.targetName=targetName;
            obj.targetUUID=char(matlab.lang.internal.uuid);
            obj.dataChannel=strcat('/',obj.targetUUID,'/Data');
            obj.statusChannel=strcat('/',obj.targetUUID,'/Status');
            obj.dataReady=false;



            obj.commReady=false;
            obj.subscription=message.subscribe(obj.statusChannel,@(msg)obj.handleMessage(msg));
        end

        function handleMessage(this,msg)
            if strcmp(msg,'started')


                this.commReady=true;




                if this.activated
                    message.publish(this.dataChannel,{'activate',this.tetInfo});
                end
            elseif strcmp(msg,'ready')


                this.dataReady=true;
            end
        end

        function activate(this,modelName,tetInfo)



            this.activated=true;
            this.modelName=modelName;
            this.tetInfo=tetInfo;

            if this.commReady


                message.publish(this.dataChannel,{'activate',this.tetInfo});
            end
        end

        function deactivate(this)



            this.activated=false;
            this.dataReady=false;
            this.tetInfo=[];

            if this.commReady
                message.publish(this.dataChannel,{'deactivate',[]});
            end
        end

        function runOnce(this,tg)
            if~this.dataReady||isempty(this.modelName)
                return;
            end

            data=[];
            tc=tg.get('tc');
            for i=1:length(tc.ModelExecProperties.TETInfo)

                data(end+1)=tc.ModelExecProperties.TETInfo(i).TETMin;%#ok
                data(end+1)=tc.ModelExecProperties.TETInfo(i).TETMax;%#ok
                data(end+1)=tc.ModelExecProperties.TETInfo(i).TETAvg;%#ok
            end

            message.publish(this.dataChannel,{'tetdata',data});
        end


        function delete(this)
            message.unsubscribe(this.subscription);
        end
    end


    properties(Hidden)
        targetUUID;
        targetName;
        modelName;
        commReady;
        dataReady;
        subscription;
        dataChannel;
        statusChannel;
        activated;
        tetInfo;
    end

end
