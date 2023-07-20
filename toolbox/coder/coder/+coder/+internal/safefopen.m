


classdef safefopen<handle
    properties(Access=private)
        fid;
explicitly_fclosed
    end

    methods(Access=public)
        function this=safefopen(fileName,varargin)
            this.explicitly_fclosed=false;
            this.fid=fopen(fileName,varargin{:});
        end

        function varargout=fread(this,varargin)
            [varargout{1:nargout}]=fread(this.fid,varargin{:});
        end

        function fwrite(this,varargin)
            fwrite(this.fid,varargin{:});
        end

        function fprintf(this,varargin)
            fprintf(this.fid,varargin{:});
        end

        function fclose(this)
            this.explicitly_fclosed=true;
            fclose(this.fid);
        end

        function delete(this)
            if~this.explicitly_fclosed
                if this.fid~=-1
                    fclose(this.fid);
                end
            end
        end

        function r=eq(this,val)
            r=this.fid==val;
        end

        function r=ne(this,val)
            r=this.fid~=val;
        end
    end
end

