classdef QueryTable<handle&matlab.mixin.CustomDisplay
    properties(GetAccess=public,SetAccess=private)
        Query=Simulink.loadsave.Query.empty;
        Type={};
        MinVersion=[];
        MaxVersion=[];
        Analyzer=[];
    end

    methods

        function[queries,analyzer]=select(this,type,version)


            idx=(strcmp(this.Type,type)|strcmp(this.Type,'any'))...
            &this.MinVersion<=version...
            &this.MaxVersion>=version;

            queries=this.Query(idx);
            analyzer=this.Analyzer(idx);
        end

        function this=addQueries(this,queries,type,min,max,analyzer)


            num=length(queries);
            if nargin<3
                type=repmat({'any'},num,1);
            end
            if nargin<4
                min=zeros(num,1);
            end
            if nargin<5
                max=Inf(num,1);
            end
            if nargin<6
                analyzer=zeros(num,1);
            end

            this.Query(end+1:end+num)=queries;
            this.Type(end+1:end+num)=type;
            this.MinVersion(end+1:end+num)=min;
            this.MaxVersion(end+1:end+num)=max;
            this.Analyzer(end+1:end+num)=analyzer;
        end

        function this=addTable(this,table,analyzer)


            this.Query=[this.Query,table.Query];
            this.Type=[this.Type,table.Type];
            this.MinVersion=[this.MinVersion,table.MinVersion];
            this.MaxVersion=[this.MaxVersion,table.MaxVersion];
            this.Analyzer=[this.Analyzer,repmat(analyzer,1,length(table.Query))];
        end

    end

    methods(Access=protected)

        function displayScalarObject(this)


            fprintf('    %d Queries:\n\n',length(this.Query));
            fprintf('    Row   Type   MinVer   MaxVer   Analyzer   Query\n');
            fprintf('    ___   ____   ______   ______   ________   _____\n\n');
            for n=1:length(this.Query)
                fprintf('    %3d   %4s   %6.1f   %6.1f   %8d   %s (%s)\n',...
                n,this.Type{n},this.MinVersion(n),this.MaxVersion(n),this.Analyzer(n),this.Query(n).Query,char(this.Query(n).Modifier));
            end
        end

    end

end

