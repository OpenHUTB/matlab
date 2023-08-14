classdef(Sealed=false)Info<hgsetget






    properties
        Data;
    end

    properties(Constant)
    end


    methods
        function h=Info()
            h.Data=[];
        end

        function h=serialize(h,fileName)%#ok<INUSD>
        end

        function deserialize(h,fileName,varargin)
            deserializeM(h,fileName,varargin{:});
        end

        function set(h,property,value)
            h.(property)=value;
        end
    end


    methods(Access='private')
        function deserializeCS(h,fileName)
            if~exist(fullfile(fileName),'file')
                return
            end
            fid=fopen(fileName);
            info=textscan(fid,'%q%q','Delimiter','#','CommentStyle','%');
            fclose(fid);
            h.Data=info;
        end

        function deserializeM(h,fileName,varargin)
            try
                info=feval(fileName,varargin{:});
                infofields=fields(info);
                for i=1:length(infofields)
                    set(h,(infofields{i}),info.(infofields{i}));
                end
            catch ME %#ok<NASGU>

            end
        end
    end
end
