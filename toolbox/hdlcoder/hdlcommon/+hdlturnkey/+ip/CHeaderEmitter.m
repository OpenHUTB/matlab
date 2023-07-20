


classdef CHeaderEmitter<handle


    properties

        CHeaderFileName='';
        CHeaderFilePath='';


        hIPEmitter=[];

    end

    methods

        function obj=CHeaderEmitter(hIPEmitter)


            obj.hIPEmitter=hIPEmitter;

        end

        function generateCHeaderFile(obj)

            fid=initialCHeaderFile(obj);
            printCHeaderFile(obj,fid);
            fclose(fid);
        end

        function headerFilePath=getHeaderFileRelativePath(obj)

            headerFilePath=fullfile(obj.hIPEmitter.CHeaderFolder,obj.CHeaderFileName);
        end

    end

    methods(Access=protected,Hidden=true)

        function fid=initialCHeaderFile(obj)

            obj.CHeaderFileName=sprintf('%s_addr.h',obj.hIPEmitter.hIP.getIPCoreName);


            obj.CHeaderFilePath=fullfile(obj.hIPEmitter.IPCoreCHeaderPath,obj.CHeaderFileName);


            fid=createFile(obj,obj.CHeaderFilePath);
            printTitle(obj,fid);

        end

        function printCHeaderFile(obj,fid)



            isMinClkEnbl=obj.hIPEmitter.hIP.hD.hTurnkey.hElab.hDUTLayer.MinimizeClkEnableActive;


            hBus=obj.hIPEmitter.hIP.hD.hTurnkey.getDefaultBusInterface;
            info={};
            info=hBus.hBaseAddr.exportAddressList(info,isMinClkEnbl);
            defineVectorStrobe=strcmp('Free running',obj.hIPEmitter.hIP.hD.get('ExecutionMode'));
            info=hBus.hIPCoreAddr.exportAddressList(info,isMinClkEnbl,defineVectorStrobe);


            maxLength=0;
            for ii=1:length(info)
                item=info{ii};
                addrName=item{1};
                nameLength=length(addrName);
                if nameLength>maxLength
                    maxLength=nameLength;
                end
            end


            pcoreName=obj.hIPEmitter.hIP.getIPCoreName;

            fprintf(fid,'#ifndef %s_H_\n',upper(pcoreName));
            fprintf(fid,'#define %s_H_\n\n',upper(pcoreName));

            for ii=1:length(info)
                item=info{ii};
                addrName=item{1};
                addrValue=item{2};
                addrDesc=item{3};


                addrComment='';
                if~isempty(addrDesc)
                    addrComment=sprintf('  //%s',addrDesc);
                end

                addrNameStr=sprintf('%s_%s',addrName,pcoreName);


                formatNum=maxLength+1-length(addrName);
                formatStr=sprintf('#define  %%s %%%ds %%s%%s\\n',formatNum);
                fprintf(fid,formatStr,addrNameStr,' ',addrValue,addrComment);
            end

            fprintf(fid,'\n#endif /* %s_H_ */\n',upper(pcoreName));
        end

        function fid=createFile(~,filePath)

            fid=fopen(filePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateConstrainFile',filePath));
            end
        end

        function printTitle(obj,fid)
            fprintf(fid,'/*\n');
            fprintf(fid,' * File Name:         %s\n',obj.CHeaderFilePath);
            fprintf(fid,' * Description:       C Header File\n');
            fprintf(fid,' * Created:           %s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            fprintf(fid,'*/\n\n');
        end
    end
end


