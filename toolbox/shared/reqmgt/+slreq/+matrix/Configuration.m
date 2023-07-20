classdef Configuration<handle
















































































    properties
        LeftArtifacts={};
        TopArtifacts={};
LeftScope
TopScope
LeftFilters
TopFilters
    end

    properties(Hidden)
Advanced
History
        RawConfiguration;
        queryOtherDataInMemory;
showArtifactSelector
    end

    methods
        function this=Configuration(filePathOrVarName)
            this.LeftFilters=slreq.matrix.Filter.empty();
            this.TopFilters=slreq.matrix.Filter.empty();
            if nargin<1
                filePathOrVarName='';
            end

            if ischar(filePathOrVarName)&&strcmp(filePathOrVarName,'current')
                configObj=slreq.report.rtmx.utils.MatrixWindow.getCurrentConfig();
                this.RawConfiguration=configObj;
                this.LeftArtifacts=configObj.leftArtifacts;
                this.TopArtifacts=configObj.topArtifacts;
            elseif isstruct(filePathOrVarName)
                configObj=filePathOrVarName;
                this.RawConfiguration=configObj.configuration;
            elseif exist(filePathOrVarName,'var')==1
                configObj=filePathOrVarName;
                this.RawConfiguration=configObj;
            elseif exist(filePathOrVarName,'file')==1
                configObj=load(filePathOrVarName);
                this.RawConfiguration=configObj.configuration;
            else
                defaultOpt=slreq.report.rtmx.utils.getDefaultOptions();
                this.RawConfiguration=defaultOpt.configuration;
            end
            this.convertConfiguration();
        end

        function convertConfiguration(this)
            if isfield(this.RawConfiguration,'top')
                topFilter=this.RawConfiguration.top;
            else
                topFilter=this.RawConfiguration.col;
            end

            if isfield(this.RawConfiguration,'left')
                leftFilter=this.RawConfiguration.left;
            else
                leftFilter=this.RawConfiguration.row;
            end

            for index=1:length(topFilter)
                filterObj=slreq.matrix.Filter(topFilter(index));
                this.addFilterToTop(filterObj);
            end

            for index=1:length(leftFilter)
                filterObj=slreq.matrix.Filter(leftFilter(index));
                this.addFilterToLeft(filterObj);
            end

        end

        function out=getRawConfiguration(this)
            out.leftArtifacts=this.LeftArtifacts;
            out.topArtifacts=this.TopArtifacts;
            if isempty(this.TopFilters)
                out.top=struct;
            else
                for index=1:length(this.TopFilters)
                    out.top(index)=this.TopFilters(index).getFilterStruct;
                end

            end
            if isempty(this.LeftFilters)
                out.left=struct;
            else

                for index=1:length(this.LeftFilters)
                    out.left(index)=this.LeftFilters(index).getFilterStruct;
                end
            end



            out.cell=struct;
            out.highlight=struct;
            out.matrix=struct;
            out.scope.row={};
            out.scope.col={};
            out.history=[];
        end

        function index=addFilterToLeft(this,filterObj)
            filterObj.location='Row';
            this.LeftFilters(end+1)=filterObj;
            index=length(this.LeftFilters);
        end

        function index=addFilterToTop(this,filterObj)
            filterObj.location='Col';
            this.TopFilters(end+1)=filterObj;
            index=length(this.TopFilters);
        end

        function applyFilters(this)
            for index=1:length(this.LeftFilters)
                this.LeftFilters(index).addFilterToCurrentDoc();
            end

            for index=1:length(this.TopFilters)
                this.TopFilters(index).addFilterToCurrentDoc();
            end
        end

        function removeFilterFromLeft(this,index)
        end

        function removeFilterFromTop(this,index)
        end

        function saveConfig()
        end

        function generateMatrix(this)
            opts.leftArtifacts=this.LeftArtifacts;
            opts.topArtifacts=this.TopArtifacts;
            opts.options=this.RawConfiguration;
            slreq.generateTraceabilityMatrix(opts)

        end

        function scriptStr=exportToScript(this,fileName)

            scriptStr=sprintf('%% Create options \n');
            scriptStr=sprintf('%s%s;\n',scriptStr,'options = slreq.matrix.Configuration');

            scriptStr=sprintf('%s %%%%  Add Artifacts \n',scriptStr);
            leftArtiStr=sprintf('');
            for index=1:length(this.LeftArtifacts)
                leftArtiStr=sprintf('%s''%s'', ...\n\t',leftArtiStr,this.LeftArtifacts{index});
            end

            topArtiStr=sprintf('');
            for index=1:length(this.TopArtifacts)
                topArtiStr=sprintf('%s''%s'', ...\n\t',topArtiStr,this.TopArtifacts{index});
            end


            scriptStr=sprintf('%s%s;\n',scriptStr,['options.LeftArtfacts = {',leftArtiStr,'}']);
            scriptStr=sprintf('%s%s;\n',scriptStr,['options.TopArtfacts = {',topArtiStr,'}']);

            scriptStr=sprintf('%s %%%%  Add Filters \n',scriptStr);
            for index=1:length(this.LeftFilters)
                cFilter=this.LeftFilters(index);

                scriptStr=sprintf('%s%s;\n',scriptStr,'filter = slreq.matrix.Filter');

                scriptStr=sprintf('%s%s''%s'';\n',scriptStr,'filter.ConfigName = ',cFilter.ConfigName);
                scriptStr=sprintf('%s%s''%s'';\n',scriptStr,'filter.PropName = ',cFilter.PropName);
                scriptStr=sprintf('%s%s;\n',scriptStr,'filter.PropValue = true');
                scriptStr=sprintf('%s%s;\n',scriptStr,'options.addFilterToLeft(filter)');
                scriptStr=sprintf('%s\n',scriptStr);
            end



            for index=1:length(this.TopFilters)
                cFilter=this.TopFilters(index);
                scriptStr=sprintf('%s%s\n',scriptStr,'filter = slreq.matrix.Filter;');
                scriptStr=sprintf('%s%s''%s'';\n',scriptStr,'filter.ConfigName = ',cFilter.ConfigName);
                scriptStr=sprintf('%s%s''%s'';\n',scriptStr,'filter.PropName = ',cFilter.PropName);
                scriptStr=sprintf('%s%s;\n',scriptStr,'filter.PropValue = true');
                scriptStr=sprintf('%s%s;\n',scriptStr,'options.addFilterToTop(filter)');
                scriptStr=sprintf('%s\n',scriptStr);
            end


            scriptStr=sprintf('%s %%%%  Generate Matrix \n',scriptStr);
            scriptStr=sprintf('%s%s\n',scriptStr,'slreq.generateTraceablityMatrix(options);');

            fid=fopen(fileName,'w');
            fprintf(fid,'%s',scriptStr);
            fclose(fid);
            edit(fileName);
        end

    end


    methods(Static)
        function out=LoadFromFile(filePath)

        end
    end


end
