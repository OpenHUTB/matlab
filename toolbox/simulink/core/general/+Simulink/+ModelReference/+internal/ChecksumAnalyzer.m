classdef ChecksumAnalyzer<handle
























    properties(GetAccess=public,SetAccess=private)
SourceFile
FileContents
NumRecords
Index
NumSuccess
FileID
ModelInstances
OriginalModel
MasterHtml
    end

    methods(Access=public)

        function this=ChecksumAnalyzer(sourceFile)
            this.SourceFile=sourceFile;
            this.FileContents='';
            this.NumRecords=0;
            this.resetProperties();
        end


        function analyze(this,model)
            this.readFromSource();
            this.resetProperties();
            this.OriginalModel=model;
            this.searchModelInstances();
            this.compare();
        end
    end

    methods(Access=private)
        function resetProperties(this)
            this.Index=1;
            this.FileID=[];
            this.NumSuccess=0;
            this.ModelInstances={};
            this.OriginalModel='';
            this.MasterHtml='';
        end


        function readFromSource(this)
            if this.NumRecords>0
                return;
            end
            fid=fopen(this.SourceFile,'r','native','UTF-8');
            result=textscan(fid,'%s','Delimiter','\n');
            this.FileContents=result{1};
            this.NumRecords=numel(this.FileContents);
            fclose(fid);
        end



        function searchModelInstances(this)
            fprintf('### Searching for %s instances\n',this.OriginalModel);
            stopPattern='';
            currentModel='';
            startPattern=this.getStartPattern(this.OriginalModel);

            while this.Index<this.NumRecords
                aRec=this.FileContents(this.Index);


                if isempty(currentModel)
                    matches=regexp(aRec{1},startPattern,'tokens');
                    if~isempty(matches)
                        currentModel=matches{1}{1};
                        this.writeToFile(currentModel,aRec{1});
                        stopPattern=this.getStopPattern(currentModel);
                        fprintf('### Processing instance: %s\n',currentModel);
                    end
                else
                    this.writeToFile(currentModel,aRec{1});
                    if~isempty(regexp(aRec{1},stopPattern,'once'))
                        this.writeExtraLine(currentModel);
                        this.ModelInstances{end+1}=currentModel;
                        this.closeFile();
                        currentModel='';
                    end
                end

                this.Index=this.Index+1;
            end
        end





        function writeToFile(this,aModel,aRec)
            if isempty(this.FileID)
                this.FileID=fopen([aModel,'.txt'],'w','native','UTF-8');
            end
            recToWrite=aRec;
            if~strcmp(aModel,this.OriginalModel)
                recToWrite=regexprep(aRec,aModel,this.OriginalModel);
            end
            fprintf(this.FileID,'%s\n',recToWrite);
        end


        function writeExtraLine(this,aModel)
            aRec=this.FileContents(this.Index+1);
            this.writeToFile(aModel,aRec{1});
            this.Index=this.Index+1;
        end


        function closeFile(this)
            if~isempty(this.FileID)
                fclose(this.FileID);
                this.FileID=[];
            end
        end


        function result=getStartPattern(~,aModel)
            result=['Generating structural checksum for system ''(',aModel,'\d*)/'];
        end


        function result=getStopPattern(~,aModel)
            result=['Parameter checksum for block diagram: ',aModel];
        end



        function compare(this)
            maxInd=numel(this.ModelInstances);
            fprintf('### Total instances of %s found: %d\n\n',this.OriginalModel,maxInd);
            if maxInd<2
                fprintf('### No instances to compare.\n');
                return;
            end
            if~ismember(this.ModelInstances,this.OriginalModel)
                fprintf('### Original model %s not found in log.\n',this.OriginalModel);
                fprintf('### No instances to compare.\n');
                return;
            end

            modelsToCompare=setxor(this.ModelInstances,this.OriginalModel);
            this.createMasterHtml();
            for i=1:numel(modelsToCompare)
                model=modelsToCompare{i};
                this.compareFiles(model);
            end
            this.closeAndShowMasterHtml();
        end


        function createMasterHtml(this)
            this.MasterHtml=fullfile(pwd,[this.OriginalModel,'_master.html']);
            this.FileID=fopen(this.MasterHtml,'w','native','UTF-8');
            fprintf(this.FileID,...
            '<html>\n<body>\n<h1>Model instance comparisons for %s</h1>\n',...
            this.OriginalModel);
            fprintf(this.FileID,...
            '<h2>Total instances found: %d</h2>\n<ol>',numel(this.ModelInstances));
        end


        function writeToMasterHtml(this,htmlfile,model1,model2)
            fprintf(this.FileID,'<li><a href="%s" target="_blank">%s vs %s</a></li>\n',...
            htmlfile,model1,model2);
        end


        function closeAndShowMasterHtml(this)
            fprintf(this.FileID,'</ol>\n</body>\n</html>\n');
            fclose(this.FileID);
            this.FileID=[];
            web(this.MasterHtml);
        end


        function compareFiles(this,model2)
            model1=this.OriginalModel;
            file1=[model1,'.txt'];
            file2=[model2,'.txt'];


            fprintf('### Comparing %s and %s\n',file1,file2);
            width=60;
            ignoreWhitespace=false;
            showDiffsOnly=true;
            showLineNumbers=true;
            out=comparisons_private('textdiff',file1,file2,width,...
            ignoreWhitespace,showDiffsOnly,showLineNumbers);


            htmlfile=fullfile(pwd,[model1,'_',model2,'.html']);
            fprintf('### Writing comparison report to %s\n\n',htmlfile);
            fid=fopen(htmlfile,'w');
            fprintf(fid,'%s',out);
            fclose(fid);


            this.writeToMasterHtml(htmlfile,model1,model2);
        end
    end
end