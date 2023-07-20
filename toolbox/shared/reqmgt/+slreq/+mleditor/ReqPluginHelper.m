classdef ReqPluginHelper<handle



    properties(Constant,Hidden)
        NO_LINKS_TAG='__NOLINKS__';
    end

    methods(Static)
        function out=getInstance()
            persistent instance
            if isempty(instance)
                instance=slreq.mleditor.ReqPluginHelper();
            end
            out=instance;
        end
    end

    properties(Access=private)
editorId
contents
linebreaks
    end

    methods(Access=private)

        function this=ReqPluginHelper()
            this.editorId='';
            this.contents=containers.Map('KeyType','char','ValueType','char');
            this.linebreaks=containers.Map('KeyType','char','ValueType','any');
        end

        function CRs=getCRs(this,editorId)
            if isKey(this.linebreaks,editorId)
                CRs=this.linebreaks(editorId);
            else
                fullText=this.getFullText(editorId);
                CRs=find(fullText==10);
                this.linebreaks(editorId)=CRs;
            end
        end
    end

    methods(Access=public)

        function count=getMaxLineNumber(this,editorId)
            CRs=this.getCRs(editorId);
            count=numel(CRs);
        end

        function reset(this,editorId)
            if isKey(this.linebreaks,editorId)
                this.linebreaks.remove(editorId);
            end
            if isKey(this.contents,editorId)
                this.contents.remove(editorId);
            end
        end

        function out=charPositionToLineNumber(this,editorId,charPositions)



            if iscell(charPositions)
                isCellArg=true;
                charPositions=cell2mat(charPositions);
            else
                isCellArg=false;
            end

            CRs=this.getCRs(editorId);

            if isempty(CRs)

                out=ones(size(charPositions));
            else
                out=zeros(size(charPositions));
                for i=1:numel(charPositions)
                    pos=charPositions(i);
                    if pos<=0
                        out(i)=0;
                        continue;
                    end
                    isBefore=find((CRs<pos));
                    if~isempty(isBefore)
                        out(i)=isBefore(end)+1;
                    else

                        out(i)=1;
                    end
                end
            end
            if isCellArg
                out=num2cell(out);
            end
        end

        function charPos=lineNumberToCharPosition(this,editorId,lineNumber,offset)
            if nargin<4||offset==0
                offset=1;
            end
            CRs=this.getCRs(editorId);

            if lineNumber>numel(CRs)+1
                error(message('Slvnv:rmiml:InvalidLineNumber'));
            end

            if isempty(CRs)
                charsInLine=length(this.contents(editorId));
            elseif lineNumber>numel(CRs)
                charsInLine=length(this.contents(editorId))-CRs(end);
            elseif lineNumber==1
                charsInLine=CRs(1);
            else
                charsInLine=CRs(lineNumber)-CRs(lineNumber-1);
            end
            if offset>charsInLine
                error(message('Slvnv:rmiml:InvalidOffset'));
            end

            if offset>0

                if lineNumber==1
                    charPos=offset;
                else
                    charPos=CRs(lineNumber-1)+offset;
                end
            elseif lineNumber>numel(CRs)

                charPos=length(this.contents(editorId))+offset+1;
            else

                charPos=CRs(lineNumber)+offset+1;
            end
        end

        function fullText=getFullText(this,editorId)
            if isKey(this.contents,editorId)
                fullText=this.contents(editorId);
            else

                try
                    editor=matlab.desktop.editor.findOpenDocument(editorId);
                    if~isempty(editor)
                        fullText=editor.Text;
                    else

                        fullText=this.readFromSource(editorId);
                    end
                catch
                    fullText=this.readFromSource(editorId);
                end
                this.contents(editorId)=fullText;
            end
        end

        function fullText=readFromSource(~,editorId)

            if rmisl.isSidString(editorId)
                fullText=rmiml.mlfbGetCode(editorId);
            elseif exist(editorId,'file')
                in=fopen(editorId);
                fileData=fread(in,'char');
                fclose(in);
                fullText=char(fileData');
            end
        end
    end
end
