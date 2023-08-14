classdef conv5Processor<dnnfpga.processorbase.conv4Processor



    methods(Access=public,Hidden=true)
        function obj=conv5Processor(bcc)
            obj@dnnfpga.processorbase.conv4Processor(bcc);
        end
    end

    methods(Access=public)

        function[output,notRunActivationTilePosition]=backend(this,params,weightBaseAddrOffset,verbose,tileActivation,hasFC)

            if nargin<4
                verbose=1;
            end

            if nargin<5
                tileActivation=[];
            end





            layerData=struct('seqOp',[],'seqLC',[],'syncIR',[]);


            if~iscell(params)&&(length(params)==1)
                params={params};
            end
            notRunTiledPosition=[];

            for i=1:length(params)

                if~isfield(params{i},'outputStationary')
                    params{i}.outputStationary=true;
                end





                param=params{i};

                param.weightBaseAddrOffset=weightBaseAddrOffset;

                if i==1
                    param.firstLayer=true;
                else
                    param.firstLayer=false;
                end
                if i==length(params)
                    param.lastLayer=true;



                    if nargin<6
                        hasFC=true;
                    end
                    param.hasFC=hasFC;
                else
                    param.lastLayer=false;
                end





                if(i==length(params))
                    [layerData(i),notRunTiledPosition]=this.getSeqLCAndOpPerLayer(param,verbose,tileActivation);
                else
                    layerData(i)=this.getSeqLCAndOpPerLayer(param,verbose,[]);
                end

            end

            output.seqOp=this.flattenLayerData(layerData,'seqOp');
            output.seqLC=this.flattenLayerData(layerData,'seqLC');
            output.NC=this.resolveNC(params);

            output.syncSeqLC=this.getSyncSeqLC([layerData.syncIR],params);
            if nargout>1
                notRunActivationTilePosition=notRunTiledPosition;
            end


            output.weightBaseAddrOffset=weightBaseAddrOffset+4*numel(output.seqOp.conv);
        end

    end

    methods(Access=protected)

        function syncSeqLC=getSyncSeqLC(this,syncIR,params)


            maxPCNum=2^(this.getCC().syncInstFormat.newPCMax-this.getCC().syncInstFormat.newPCMin);
            sa=dnnfpga.processorbase.syncAssembler(this.getCC().syncInstFormat,maxPCNum);


            syncSeqLC.stringConv=this.emitConvSyncScript({syncIR.conv});


            syncSeqLC.stringIP0=this.emitIP0SyncScript({syncIR.ip0});


            syncSeqLC.stringIP1=this.emitIP1SyncScript({syncIR.ip1},params);


            syncSeqLC.stringOP0=this.emitOP0SyncScript({syncIR.op0});

        end


        function script=emitConvSyncScript(this,syncIR)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','convsynchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','convsynctail_dag.s'));
            body=sprintf('st:	Set(''id'', ''0'', ''limit'', ''1'')\n');
            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);

            for i=1:length(syncIR)
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i);

                for j=1:syncIR{i}
                    body=sprintf('%sst%d_%d:SW(''s'',''0'',''w'',''%%OpR'',''wlogic'',''OR'') \\\\ wait opReady\n',body,i,j);
                    body=sprintf('%s\tSW(''s'',''%%R0'',''w'',''%%V0'',''wlogic'',''AND'') \\\\ send R0,R1 to IP0,IP1 and wait\n',body);







                    tileNumStr=sprintf('tiles_%d',i-1);
                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'') \\\\%s = %d\n',body,syncIR{i},tileNumStr,syncIR{i});
                    body=sprintf('%s\tCall(''func'', ''%%foo'')\n',body);
                end
                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i);
            end








            script.head=head;
            script.body=body;
            script.tail=tail;
        end

        function script=emitIP0SyncScript(this,syncIRs)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip0synchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip0synctail_dag.s'));
            body=sprintf('');
            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);
            body=sprintf('%s\tSW(''s'', ''%%ProcessorStart'', ''w'', ''0'')  \\\\ send processor start signal\n',body);
            for i=1:length(syncIRs)
                syncIR=syncIRs{i};
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i-1);
                body=sprintf('%s\tSW(''s'', ''%%LayerStart'', ''w'', ''0'')  \\\\ send layer start signal\n',body);
                for j=1:length(syncIR)









                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'')  \\\\ tile_%d_%d\n',body,syncIR(j),i-1,j-1);
                    body=sprintf('%s\tCall(''func'', ''%%foo'')\n',body);
                end

                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i-1);
            end









            script.head=head;
            script.body=body;
            script.tail=tail;
        end



        function script=emitOP0SyncScript(this,syncIRs)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','op0synchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','op0synctail_dag.s'));
            body=[];
            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);
            for i=1:length(syncIRs)

                syncIR=syncIRs{i};
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i-1);
                if i==length(syncIRs)
                    body=sprintf('%sst%d:SW(''s'',''0'',''w'',''%%FcR'') \\\\ wait ready FcR\n',body,i);
                end
                for j=1:length(syncIR)











                    body=sprintf('%s\tSW(''s'', ''%%R'', ''w'',''%%ConvV'') \\\\ send ready to conv and wait\n',body);
                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'')  \\\\ tile_%d_%d\n',body,syncIR(j),i-1,j-1);


                    if(j==length(syncIR)&&i==length(syncIRs))

                        body=sprintf('%s\tCall(''func'', ''%%foo2'')\n',body);
                    elseif j==length(syncIR)

                        body=sprintf('%s\tCall(''func'', ''%%foo3'')\n',body);
                    else
                        body=sprintf('%s\tCall(''func'', ''%%foo1'')\n',body);
                    end
                end
                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i-1);
            end











            script.head=head;
            script.body=body;
            script.tail=tail;
        end

    end


end





