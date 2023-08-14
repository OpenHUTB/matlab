classdef BuildLogWriter<handle






    properties(GetAccess=private,SetAccess=immutable)
CreateDVStages
TopModel
    end

    properties(GetAccess=private,SetAccess=private)
Buffer
    end

    methods



        function this=BuildLogWriter(parMdlRefs,createDVStages,topModel)
            this.Buffer=this.createEmptyBuffer(parMdlRefs);
            this.CreateDVStages=createDVStages;
            this.TopModel=topModel;
        end




        function printMdlRefBuildLog(this,mdlName,log)

            if~isempty(log)
                mdlIdx=strcmp({this.Buffer.modelName},mdlName);
                this.Buffer(mdlIdx).log=strtrim(log);
                this.printPendingLogs();
            end
        end




        function delete(this)

            logs=this.Buffer(~cellfun(@isempty,{this.Buffer.log}));
            this.printLogs(logs);
        end
    end

    methods(Access=private)



        function printPendingLogs(this)




            logsToPrint=this.Buffer;
            emptyLogs=cellfun(@isempty,{logsToPrint.log});
            if any(emptyLogs)
                emptyLogIdx=find(emptyLogs);
                firstEmptyLogIdx=emptyLogIdx(1);
                logsToPrint=this.Buffer(1:firstEmptyLogIdx-1);
            end

            if~isempty(logsToPrint)
                this.printLogs(logsToPrint);

                this.Buffer(1:length(logsToPrint))=[];
            end
        end




        function printLogs(this,logEntries)
            for i=1:length(logEntries)

                if this.CreateDVStages
                    model_name_mv_hdr_stage=Simulink.output.Stage(...
                    DAStudio.message('Simulink:modelReference:MessageViewer_BuildingTarget',...
                    logEntries(i).modelName),...
                    'ModelName',this.TopModel,'UIMode',true);
                end


                Simulink.output.info(logEntries(i).log);

                if this.CreateDVStages


                    delete(model_name_mv_hdr_stage);
                end
            end
        end
    end

    methods(Static,Access=private)



        function buffer=createEmptyBuffer(parMdlRefs)


            buffer=[parMdlRefs{:}];
            buffer={buffer(:).modelName};
            buffer(2,:)={''};
            buffer=cell2struct(buffer,{'modelName','log'});
        end
    end
end
