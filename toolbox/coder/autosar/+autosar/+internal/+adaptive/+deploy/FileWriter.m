classdef FileWriter<autosar.internal.adaptive.deploy.Writer






    properties
        fid=-1;
    end

    methods
        function h=FileWriter(filename)
            [h.fid,errormsg]=fopen(filename,"w");
            if h.fid==-1
                throw(MSLException(errormsg));
            end
        end

        function write(h,msg,varargin)

            narginchk(3,inf);
            fprintf(h.fid,msg,varargin{:});
        end

        function writeln(h,msg,varargin)

            fprintf(h.fid,msg+"\n",varargin{:});
        end

        function delete(h)
            if h.fid~=-1
                fclose(h.fid);
            end
        end
    end
end
