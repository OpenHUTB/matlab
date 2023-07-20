classdef BaseWriter<plccore.common.Object



    methods
        function obj=BaseWriter
            obj.Kind='BaseWriter';
        end

        function str=unix2dos(obj,str)%#ok<INUSL>
            str=regexprep(str,'\r','');
            str=regexprep(str,'\n','\r\n');
        end

        function writeFileStr(obj,file_dir,file_name,str)
            import plccore.common.plcThrowError;
            if(~exist(file_dir,'dir'))
                mkdir(file_dir);
            end
            full_name=fullfile(file_dir,file_name);
            fid=fopen(full_name,'w');
            if fid==-1
                plcThrowError('plccoder:plccore:OpenWriteFileError',...
                plccore.util.Msg(full_name));
            end
            str=obj.unix2dos(str);
            fprintf(fid,'%s',str);
            fclose(fid);
        end
    end
end


