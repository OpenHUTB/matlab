classdef TLCNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer





    properties(Constant)
        Type='TLC';
        Extensions=".tlc";
        IncludeString='%include';
        AddIncludePathString='%addincludepath';
    end

    methods

        function rawText=readTLCFile(~,filepath)
            fid=fopen(filepath);
            c1=onCleanup(@()fclose(fid));
            rawText=textscan(fid,'%s','delimiter',newline);
            rawText=rawText{1};
            delete(c1);
        end


        function commentFreeText=removeCommentedLines(~,rawText)
            commentFreeText=rawText;
            for jj=1:numel(commentFreeText)
                thisLine=commentFreeText{jj};
                commentIndices=strfind(thisLine,'%%');
                if~isempty(commentIndices)
                    commentFreeText{jj}=thisLine(1:(commentIndices(1)-1));
                end
            end
        end


        function linesToAnalyze=findLinesToAnalyze(this,text)
            ind=contains(text,{this.IncludeString,this.AddIncludePathString});
            linesToAnalyze=text(ind);
        end

        function deps=analyze(this,handler,node)
            deps=dependencies.internal.graph.Dependency.empty;

            rawText=this.readTLCFile(node.Location{1});





            commentFreeText=this.removeCommentedLines(rawText);
            linesToAnalyze=this.findLinesToAnalyze(commentFreeText);
            localIncludePaths={};


            for jj=1:numel(linesToAnalyze)
                thisLine=linesToAnalyze{jj};
                if contains(thisLine,this.AddIncludePathString)

                    folderCandidate=this.getStringInQuotes(thisLine);
                    if exist(folderCandidate,'dir')
                        localIncludePaths{end+1}=folderCandidate;%#ok<AGROW>
                    end
                end

                if contains(thisLine,this.IncludeString)

                    fileCandidate=this.getStringInQuotes(thisLine);
                    if~isempty(fileCandidate)
                        tlcFile=handler.Resolver.findFile(node,fileCandidate,".tlc");
                        if~tlcFile.Resolved
                            localCandidate=this.searchLocalPath(localIncludePaths,fileCandidate);
                            if~isempty(localCandidate)
                                tlcFile=localCandidate;
                            end
                        end
                        deps(end+1)=dependencies.internal.graph.Dependency(...
                        node,'',tlcFile,'',this.Type);%#ok<AGROW>
                    end
                end
            end
        end

        function localCandidate=searchLocalPath(~,localIncludePaths,fileCandidate)
            localCandidate='';
            for jj=1:numel(localIncludePaths)
                candidate=fullfile(localIncludePaths{jj},fileCandidate);
                node=dependencies.internal.graph.Node.createFileNode(candidate);
                if node.Resolved
                    localCandidate=node;
                    return
                end
            end
        end

        function fileCandidate=getStringInQuotes(~,thisLine)
            quotesInd=strfind(thisLine,'"');
            if numel(quotesInd)==2
                fileCandidate=thisLine(quotesInd(1)+1:quotesInd(2)-1);
            else
                fileCandidate='';
            end
        end

    end

end
