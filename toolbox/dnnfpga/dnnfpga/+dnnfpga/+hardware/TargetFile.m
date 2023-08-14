classdef TargetFile<dnnfpga.hardware.Target




    properties(Constant)

        Interface=dlhdl.TargetInterface.File
    end

    properties(Access=protected)

        DefaultProgrammingMethod=hdlcoder.ProgrammingMethod.empty;
    end

    properties
        Path='./'
    end

    properties(SetAccess=private)
        FileHandle=-1;
        CR=sprintf('\r\n');
    end

    properties(SetAccess=protected)
Filename
IsConnected
        hConn=[]
    end

    methods(Access=public)
        function obj=TargetFile(vendor,varargin)

            obj=obj@dnnfpga.hardware.Target(vendor);


            [varargin{:}]=convertStringsToChars(varargin{:});


            p=inputParser;
            if~isempty(varargin)
                defaultFileName=['dlhdl_',obj.Vendor,'.dln'];
                p.addParameter('Filename',defaultFileName,@(s)ischar(s));
                parse(p,varargin{:});
                obj.Filename=p.Results.Filename;
            end



        end

        function validateConnection(obj)
            [isValid,errorMsg]=obj.isConnectionValid;
            if~isValid
                msg=message('dnnfpga:workflow:InvalidBitstreamConnection',errorMsg);
                throw(MException(msg));
            end
        end
    end


    methods
        function isConn=get.IsConnected(obj)
            isConn=~isempty(obj.hConn);
        end
    end


    methods(Access=public,Hidden=true)

        function programBitstream(obj,hBitstream,programMethod)

        end


        function connectToBitstream(obj,hBitstream)


            if obj.IsConnected


            else






                [~,defaultfilename]=fileparts(hBitstream.Name);
                if isempty(obj.Filename)
                    obj.Filename=defaultfilename;
                else
                    [~,~,fe]=fileparts(obj.Filename);
                    if~strcmp(fe,'.dln')
                        error(message('dnnfpga:workflow:TargetWrongFileExtension',obj.Filename));
                    end
                end


                obj.validateVendor(hBitstream);
                try
                    obj.hConn=obj.DeploymentFile(obj.Filename,hBitstream);
                catch ME
                    msg=MException(message('dnnfpga:workflow:BitstreamConnectionFailure'));
                    msg=msg.addCause(ME);
                    throw(msg);
                end


                try
                    obj.validateConnection;
                catch ME

                    obj.release;
                    rethrow(ME);
                end
            end
        end

        function hConn=DeploymentFile(obj,filename,hBitstream)


            p=inputParser;
            addParameter(p,'Filename',filename,@(x)(ischar(x)||isstring(x))&&~isempty(x));
            addParameter(p,'Path','./',@(x)(ischar(x)||isstring(x))&&~isempty(x));



            hConn=obj.openFile();


            obj.writeHeader(hBitstream);
            obj.writeStartOfData();
        end

        function rb=isFileOpen(obj)
            rb=(obj.FileHandle~=-1);
        end

        function isfileopen=openFile(obj)

            obj.closeFile();
            [fp,fn]=fileparts(obj.Filename);

            filename=fullfile(fp,[fn,'.dln']);
            if isempty(fp)
                filename=fullfile(obj.Path,filename);
            end
            try
                obj.FileHandle=fopen(filename,'wb');
            catch ME
                throwAsCaller(ME);
            end
            isfileopen=true;
        end

        function writeHeader(obj,hBitstream)
            mlStrVer='MWDLNV02';
            fwrite(obj.FileHandle,mlStrVer);
            fwrite(obj.FileHandle,uint8(0));

            tm=datestr(now);
            fwrite(obj.FileHandle,tm);
            fwrite(obj.FileHandle,uint8(0));
            v=ver;
            idx=find(arrayfun(@(x)(strcmp('Deep Learning HDL Toolbox',x.Name)),v));
            fwrite(obj.FileHandle,v(idx).Name);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,v(idx).Version);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,v(idx).Release);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,v(idx).Date);
            fwrite(obj.FileHandle,uint8(0));


            [dlbaseAddr,dladdrRange]=getDLProcessorAddressSpace(hBitstream);
            [ddrbaseAddr,ddraddrRange]=getDLMemoryAddressSpace(hBitstream);

            [dldevNameTx,dldevNameRx]=getDLProcessorDeviceNames(hBitstream);
            [ddrdevNameTx,ddrdevNameRx]=getDLMemoryDeviceNames(hBitstream);


            fwrite(obj.FileHandle,dlbaseAddr,'uint32');
            fwrite(obj.FileHandle,dladdrRange,'uint32');
            fwrite(obj.FileHandle,ddrbaseAddr,'uint32');
            fwrite(obj.FileHandle,ddraddrRange,'uint32');
            fwrite(obj.FileHandle,hBitstream.getVendorName());
            fwrite(obj.FileHandle,uint8(0));

            fwrite(obj.FileHandle,dldevNameTx);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,dldevNameRx);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,ddrdevNameTx);
            fwrite(obj.FileHandle,uint8(0));
            fwrite(obj.FileHandle,ddrdevNameRx);
            fwrite(obj.FileHandle,uint8(0));
        end

        function writeStartOfData(obj)
            fwrite(obj.FileHandle,'SOD');
            fwrite(obj.FileHandle,uint8(0));
        end

        function writeEndOfData(obj)
            fwrite(obj.FileHandle,'EOD');
            fwrite(obj.FileHandle,uint8(0));
        end

        function rb=closeFile(obj)
            rb=false;
            if obj.FileHandle~=-1
                obj.writeEndOfData();
                fclose(obj.FileHandle);
                obj.FileHandle=-1;
                rb=true;
            end
        end

        function[isConnected,errorMsg]=testConnection(obj)
            isConnected=(obj.FileHandle~=-1);
            errorMsg='';
            if~isConnected
                errorMsg=sprintf('DL File %s is not open for writing\n',obj.Filename);
            end
        end

        function writetxt(obj,data)
            if obj.FileHandle==-1
                error('Please connect to a file before writing.');
            end
            txt=sprintf('%s',data);
            if obj.FileHandle~=-1
                fwrite(obj.FileHandle,'TXT');
                fwrite(obj.FileHandle,uint8(0));
                fwrite(obj.FileHandle,txt);
                fwrite(obj.FileHandle,uint8(0));
            end

        end


        function writeMemory(obj,addr,data)

            obj.writememory(addr,data);
        end

        function data=readMemory(obj,addr,len,varargin)

            data=obj.readmemory(addr,len,varargin{:});
        end

        function rb=zeromemory(obj,addr,dataLength,data)
            rb=true;
            if obj.FileHandle==-1
                error('Please connect to a file before writing.');
            end

            zrAddr=hex2dec(addr);
            dataName=sprintf('ZR@ADDR: 0x%s, Len: %u, Value: %u',addr,dataLength,data);
            dataAddr=uint32(zrAddr);
            dataSave=typecast(data,'uint32');

            fwrite(obj.FileHandle,'ZRO');
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataName);
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataAddr,'uint32');
            fwrite(obj.FileHandle,dataLength,'uint32');
            fwrite(obj.FileHandle,dataSave,'uint32');

        end

        function rb=writememory(obj,addr,data)
            rb=true;
            if obj.FileHandle==-1
                error('Please connect to a file before writing.');
            end

            wrAddr=hex2dec(addr);
            dataName=sprintf('WR@ADDR: 0x%s Len: %u',addr,uint32(numel(data)));
            dataAddr=uint32(wrAddr);
            dataSize=uint32(numel(data));

            if~isfloat(data)
                data=uint32(data);
            end


            switch class(data)
            case{'uint32','single','int32'}
                dataSave=typecast(data,'uint32');
            case 'double'

                data=int32(data);
                dataSave=typecast(data,'uint32');

            otherwise

                error(message('dnnfpga:workflow:InvalidDatatype'));
            end


            if dnnfpgafeature('Verbose')==1
                fprintf('%s: 0x%08X\n',dataName,dataSave(1));
            end

            fwrite(obj.FileHandle,'WRD');
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataName);
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataAddr,'uint32');
            fwrite(obj.FileHandle,dataSize,'uint32');
            fwrite(obj.FileHandle,dataSave','uint32');


        end

        function data=readmemory(obj,addr,dataLength,varargin)
            if obj.FileHandle==-1
                error('Please connect to a file before writing.');
            end




            data=uint32(1);

            rdAddr=hex2dec(addr);
            dataName=sprintf('RD@ADDR: 0x%s, Length: %u',addr,dataLength);
            dataAddr=uint32(rdAddr);

            if dnnfpgafeature('Verbose')==1
                fprintf('%s\n',dataName);
            end

            fwrite(obj.FileHandle,'RDD');
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataName);
            fwrite(obj.FileHandle,uint8(0),'uint8');
            fwrite(obj.FileHandle,dataAddr,'uint32');
            fwrite(obj.FileHandle,uint32(1),'uint32');
            fwrite(obj.FileHandle,data,'uint32');

        end

        function[isValid,errorMsg]=isConnectionValid(obj)




            [isValid,errorMsg]=obj.isDLNFileConnectionValid;
        end

        function[isValid,errorMsg]=isDLNFileConnectionValid(obj)
            isValid=true;
            errorMsg='';

            try
                isValid=obj.isFileOpen();
            catch ME
                isValid=false;
                errorMsg=ME.message;
            end
        end

        function release(obj)

            obj.closeFile();
        end

        function delete(obj)
            release(obj);
        end
    end


    methods(Access=protected)

        function configureFPGAObjectForBitstream(~,~)

        end
    end

end
