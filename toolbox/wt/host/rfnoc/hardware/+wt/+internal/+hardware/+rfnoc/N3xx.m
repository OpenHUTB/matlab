classdef N3xx<wt.internal.hardware.rfnoc.Device




    properties(Hidden,SetAccess=immutable)
        Type="n3xx"
        ConnectionProperties=["ManagementIPAddress","SFP0IPAddress","SFP1IPAddress"]
        AvailableHardwareMemory=1024*1024*2048;
    end

    properties(Hidden)
ManagementIPAddress
SFP0IPAddress
SFP1IPAddress
SerialNum
        Username="root"
        Password=""
        Port=22
        Timeout=90
    end

    properties(Hidden)
        ClockSource="internal"
        TimeSource="internal"
        CustomDeviceArgs=[]
    end


    methods(Hidden)
        function rates=calculateAvailableSampleRates(obj)


            listOfFactors=unique([(1:3),(4:2:128),(128:2:256),(256:4:512),(512:8:1020)]);
            rates=calculateAvailableSampleRatesHelper(obj,listOfFactors);
        end
        function address=getIPAddress(obj)

            if~isempty(obj.ManagementIPAddress)
                address=obj.ManagementIPAddress;
            elseif~isempty(obj.SFP0IPAddress)
                address=obj.SFP0IPAddress;
            elseif~isempty(obj.SFP1IPAddress)
                address=obj.SFP1IPAddress;
            else
                address=[];
            end
        end

        function success=setupHardware(obj,handoff)

            if~isfile(handoff.bitstream)
                error(message("wt:rfnoc:hardware:BitstreamNotFound",handoff.bitstream));
            end
            bitFile=char(handoff.bitstream);

            address=getIPAddress(obj);

            checkNetworkConnection(obj,address);

            sshObj=i_sshConnection(address,obj.Port,obj.Username,obj.Password,2);


            sshObj.execute('mkdir -p /tmp/bitstream');
            result=sshObj.waitForResult;
            if result.ExitCode~=0
                error(message("wt:rfnoc:hardware:MkdirError","/tmp/bitstream",result.ErrorOutput));
            end


            disp(message("wt:rfnoc:hardware:BitstreamLoadStart").getString);
            for k=1:3


                [~,n,ext]=fileparts(bitFile);
                bitFileOnDevice=strcat('/tmp/bitstream/',n,ext);
                sshObj.scpSend(bitFile,bitFileOnDevice);
                result=sshObj.waitForResult;
                if isfield(result,'ExitCode')
                    if result.ExitCode~=0
                        error(message("wt:rfnoc:hardware:BitstreamDownloadError",result.ErrorOutput));
                    end
                else

                    error(message("wt:rfnoc:hardware:BitstreamDownloadError",result.ErrorMessage));
                end


                dd=dir(bitFile);
                bitFileSize=dd.bytes;
                sshObj.execute(['du -b ',bitFileOnDevice]);
                result=sshObj.waitForResult;
                if result.ExitCode==0



                    bitFileSizeOnDevice=str2double(regexp(result.Output,'^\d+','match','once'));
                    if bitFileSizeOnDevice==bitFileSize

                        break;
                    end
                end
            end




            command=strcat('nohup uhd_image_loader --args type=',obj.Type,...
            ' --fpga-path="',bitFileOnDevice,'" &> /tmp/bitstream/update.log &');
            sshObj.execute(command);
            sshObj.waitForResult;


            command='pidof uhd_image_loader';
            ts=tic;
            while(toc(ts)<obj.Timeout)
                sshObj.execute(command);
                result=sshObj.waitForResult;
                if isfield(result,'ErrorID')

                    pause(3);
                    sshObj=i_sshConnection(address,...
                    obj.Port,obj.Username,obj.Password,5);
                end

                if isfield(result,'ExitCode')&&(result.ExitCode~=0)

                    break;
                end
            end


            command='cat /tmp/bitstream/update.log';
            sshObj.execute(command);
            result=sshObj.waitForResult;
            if isfield(result,'ExitCode')&&(result.ExitCode==0)&&...
                contains(result.Output,'Update component function succeeded')
                success=true;
            else

                success=false;
                if isfield(result,'ExitCode')
                    disp(result.Output);
                else
                    disp(result.ErrorMessage);
                end
            end
            disp(message("wt:rfnoc:hardware:BitstreamLoadEnd").getString);
        end

        function args=getDeviceArgs(obj)

            if isempty(obj.CustomDeviceArgs)
                args=strcat("type=",obj.Type);
                args=strcat(args,",product=",obj.Product);

                args=strcat(args,",clock_source=",obj.ClockSource);
                args=strcat(args,",time_source=",obj.TimeSource);

                if~isempty(obj.ManagementIPAddress)
                    args=strcat(args,",mgmt_addr=",obj.ManagementIPAddress);
                end
                if~isempty(obj.SFP1IPAddress)
                    args=strcat(args,",addr=",obj.SFP1IPAddress);
                elseif~isempty(obj.SFP0IPAddress)
                    args=strcat(args,",addr=",obj.SFP0IPAddress);
                end
                if~isempty(obj.SerialNum)
                    args=strcat(args,",serial=",obj.SerialNum);
                end
                args=strcat(args,",master_clock_rate=",num2str(obj.MasterClockRate));
            else
                args=obj.CustomDeviceArgs;
            end
        end
    end
end

function sshObj=i_sshConnection(address,port,username,password,numAttempts)
    sshObj=[];
    for k=1:numAttempts
        try
            sshObj=matlabshared.network.internal.SSH(address,port,username,password);
            break;
        catch EX
            if k~=numAttempts
                pause(3);
            end
        end
    end
    if isempty(sshObj)
        rethrow(EX);
    end
end
