


classdef PAOEmitter<handle


    properties

        PAOFileName='';
        PAOFilePath='';


        hIPEmitter=[];

    end

    methods

        function obj=PAOEmitter(hIPEmitter)


            obj.hIPEmitter=hIPEmitter;

        end

        function generatePAOFile(obj)

            fid=initialPAOFile(obj);
            printPAOItems(obj,fid);
            fclose(fid);
        end

    end

    methods(Access=protected,Hidden=true)

        function fid=initialPAOFile(obj)

            obj.PAOFileName=sprintf('%s_%s.pao',obj.hIPEmitter.hIP.getIPCoreName,...
            obj.hIPEmitter.PCorePostfix);


            obj.PAOFilePath=fullfile(obj.hIPEmitter.IPCoreDataPath,obj.PAOFileName);


            fid=createFile(obj,obj.PAOFilePath);
            printTitle(obj,fid);

        end

        function printPAOItems(obj,fid)


            srcFileList=obj.hIPEmitter.IPCoreSrcFileList;
            hCodeGen=obj.hIPEmitter.hIP.hD.hCodeGen;
            for ii=1:length(srcFileList)
                srcFileStruct=srcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);

                libName=obj.hIPEmitter.getIPCoreFolderName;
                if strcmpi(extName,hCodeGen.getVHDLExt)
                    hdlName='vhdl';
                elseif strcmpi(extName,hCodeGen.getVerilogExt)
                    hdlName='verilog';
                else

                    continue;
                end


                fprintf(fid,'lib %s %s %s\n',libName,fileName,hdlName);
            end
        end

        function fid=createFile(~,filePath)

            fid=fopen(filePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateConstrainFile',filePath));
            end
        end

        function printTitle(obj,fid)
            fprintf(fid,'##############################################################################\n');
            fprintf(fid,'## File Name:         %s\n',obj.PAOFilePath);
            fprintf(fid,'## Description:       Peripheral Analysis Order\n');
            fprintf(fid,'## Created:           %s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            fprintf(fid,'##############################################################################\n\n');
        end

    end


end


