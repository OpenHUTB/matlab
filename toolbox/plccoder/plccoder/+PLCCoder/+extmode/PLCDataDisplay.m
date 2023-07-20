classdef PLCDataDisplay<handle

    properties(Constant)
        fSDI_ROW_SZ=8;
        fSDI_COL_SZ=8;
    end

    properties
        fSig;
        fSigSrc;
        fDataType;
        fQueue;
        fDBClient;
        fWebClient;
    end

    methods(Static)
        function show
            Simulink.sdi.view;
        end

        function refresh
            Simulink.sdi.loadSDIEvent;
        end

        function clear
            Simulink.sdi.clear;
            Simulink.sdi.setSubPlotLayout(1,1);
        end

        function setupSDI(num_sig)
            import PLCCoder.extmode.PLCDataDisplay;

            num_row=get_row(num_sig);
            num_col=get_col(num_sig);

            sdiClient=[];
            while isempty(sdiClient)
                sdiClient=Simulink.sdi.WebClient.getAllClients('sdi');
                pause(1);
            end


            Simulink.sdi.setSubPlotLayout(num_row,num_col);

            for idx=1:num_sig
                sdiClient.Axes(idx).TimeSpan=[0,10];
                pause(0.1);
            end
        end
    end

    methods
        function obj=PLCDataDisplay(sig_type,sig_name,sig_path,sig_id,sig_index,subplot)
            obj.fSigSrc=Simulink.AsyncQueue.SignalSource;
            obj.fSigSrc.Path=sig_path;
            obj.fSigSrc.ID=sig_id;
            obj.fSigSrc.Name=sig_name;
            obj.fSigSrc.Index=sig_index;
            obj.fDataType=sig_type;
            obj.fDataType=Simulink.AsyncQueue.DataType(sig_type);
            obj.fSig=Simulink.AsyncQueue.Signal.create(obj.fDataType,int32(1),false,false);
            obj.fSig.setSource(obj.fSigSrc);
            obj.fDBClient=Simulink.AsyncQueue.SignalClient;
            obj.fDBClient.ObserverType='database_observer';

            obj.fWebClient=Simulink.AsyncQueue.SignalClient;
            obj.fWebClient.ObserverType='webclient_observer';
            obj.fWebClient.ObserverParams=...
            Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(...
            obj.fWebClient.ObserverType);
            obj.fWebClient.ObserverParams.LineSettings.Axes=uint32(subplot);

            obj.fQueue=Simulink.AsyncQueue.Queue(obj.fSig);
            obj.fQueue.bindClient(obj.fDBClient);
            obj.fQueue.bindClient(obj.fWebClient);

            Simulink.AsyncQueue.Queue.configureQueuesAndLaunchThreads(...
            obj.fQueue);
        end

        function delete(obj)
            delete(obj.fQueue);
        end

        function addData(obj,data_time,data_val)
            obj.fQueue.write(data_time,data_val);
        end

    end
end

function num_row=get_row(num_sig)
    import PLCCoder.extmode.PLCDataDisplay;
    num_row=PLCDataDisplay.fSDI_ROW_SZ;
    if(num_sig<PLCDataDisplay.fSDI_ROW_SZ)
        num_row=num_sig;
    end
end

function num_col=get_col(num_sig)
    import PLCCoder.extmode.*;

    if(num_sig>PLCDataDisplay.fSDI_ROW_SZ*PLCDataDisplay.fSDI_COL_SZ)
        throwError(message('plccoder:extmode:ExceedSignalCountLimit',num_sig));
    end

    mod_col=mod(num_sig,PLCDataDisplay.fSDI_ROW_SZ);
    if(mod_col==0)
        num_col=num_sig/PLCDataDisplay.fSDI_ROW_SZ;
    else
        num_col=(num_sig-mod_col)/PLCDataDisplay.fSDI_ROW_SZ+1;
    end
end


