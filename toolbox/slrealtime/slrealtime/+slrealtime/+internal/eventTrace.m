classdef eventTrace





    properties(Constant,GetAccess=private)
        decoder=slrealtime.internal.binReader(...
        'uint32','uint32','uint32','uint32','uint32','uint32','single');
    end
    properties
        etData;
    end
    methods
        function et=eventTrace(binFile,cpuFreq)





            if nargin<1
                binFile='EventTrace.bin';
            else
                validateattributes(binFile,{'string','char'},{'nonempty','row'},...
                '','binFile');
            end


            RECORD_SIZE=et.decoder.bytesPerRec;
            dInfo=dir(binFile);
            if isempty(dInfo)
                error(message('slrealtime:profiling:FileNotFound',binFile));
            end
            nBytes=dInfo.bytes;
            nRec=fix(nBytes/RECORD_SIZE);
            [fid,msg]=fopen(binFile,'rb');
            if(fid<0)
                error(message('slrealtime:profiling:ProfilingFileError',binFile,msg));
            end
            data=fread(fid,nRec*RECORD_SIZE,'*uint8');
            fclose(fid);
            [channel,tsH,tsL,logval1,logval2,cpu,mt]=et.decoder.decode(data);
            et.etData=table(channel,(bitshift(uint64(tsH),32)+uint64(tsL))*1e3/(cpuFreq*1e-6),...
            logval1,logval2,cpu,mt,...
            'VariableNames',...
            {'Channel','Timestamp','Event','Value','CPU','ModelTime'});
        end

        function t=byChannel(et,channel,logval)





            t=et.etData(et.etData.Channel==channel,:);
            if nargin==3
                t=t(t.Event==logval,:);
            end
        end

        function disp(et)
            d=et.etData;
            ch=unique(d.Channel)';
            if isempty(ch)
                fprintf(1,'    <No events>\n');
            end
            dashes=@(n)repmat('-',1,n);
            for c=ch
                dSub=d(d.Channel==c,:);
                len=fprintf('\nChannel %d, %d events\n',c,height(dSub));
                fprintf([dashes(len-1),'\n']);
                ev=unique(dSub.Event)';
                for e=ev
                    fprintf('    %5d: %d events\n',e,numel(find(dSub.Event==e)));
                end
            end

        end
    end
end
