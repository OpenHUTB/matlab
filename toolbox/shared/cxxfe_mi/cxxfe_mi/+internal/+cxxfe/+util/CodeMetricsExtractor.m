


classdef CodeMetricsExtractor<handle

    properties(SetAccess=private)
DbFile
    end

    methods



        function this=CodeMetricsExtractor(dbFile)
            this.DbFile=dbFile;
        end




        function varargout=extract(this,fileName,varargin)
            [varargout{1:nargout}]=internal.cxxfe.util.CodeMetricsExtractor.invoke(this,fileName,varargin{:});
        end




        function varargout=retrieve(this)
            [varargout{1:nargout}]=internal.cxxfe.util.CodeMetricsExtractor.get_tables(this);
        end




        function varargout=query(this,sql_query,varargin)
            [varargout{1:nargout}]=internal.cxxfe.util.CodeMetricsExtractor.query_db(this,sql_query,varargin{:});
        end
    end

    methods(Static,Access=private)



        function[msgs,out]=invoke(obj,fileName,feOpts)

            if nargin<3||isempty(feOpts)
                opts=internal.cxxfe.FrontEndOptions();
            else
                opts=deepCopy(feOpts);
            end



            io.cmDat=internal.cxxfe.util.CodeMetricsExtractor.iofile();
            io.cifile=internal.cxxfe.util.CodeMetricsExtractor.iofile();
            rmFiles=onCleanup(@()internal.cxxfe.util.CodeMetricsExtractor.deleteTempFiles(io));

            opts.ExtraOptions{end+1}='--ec_code_metrics';
            opts.ExtraOptions{end+1}='--code_metrics';
            opts.ExtraOptions{end+1}=io.cmDat.name;

            try

                cb={@code_metrics_extractor_mex,'--writeDb',obj.DbFile,'%options',io};
                msgs=internal.cxxfe.FrontEnd.parseFile(fileName,opts,cb);
            catch me
                rethrow(me);
            end
            out=~any(strcmp({msgs.kind},'fatal'))&&~any(strcmp({msgs.kind},'error'));

        end




        function out=get_tables(obj)

            try
                out=code_metrics_extractor_mex('--readDb',obj.DbFile);
            catch me
                rethrow(me);
            end
        end




        function out=query_db(obj,sql_query,varargin)

            try
                out=code_metrics_extractor_mex('--queryDb',obj.DbFile,sql_query,varargin{:});
            catch me
                rethrow(me);
            end
        end

        function f=iofile(varargin)
            f=[];
            if nargin>1&&~isempty(varargin{1})
                f.name=varargin{1};
                f.is_temp=false;
            else
                f.name=tempname;
                f.is_temp=true;
            end
        end

        function deleteTempFiles(io)

            fields=fieldnames(io);
            for f=1:length(fields)
                field=fields{f};
                if io.(field).is_temp
                    fd=fopen(io.(field).name);
                    if fd>=0
                        fclose(fd);
                        delete(io.(field).name);
                    end
                end
            end
        end
    end
end

