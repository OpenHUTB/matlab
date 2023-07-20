






classdef HTMLLinkManager<coder.report.HTMLLinkManagerBase

    properties(GetAccess=private,SetAccess=immutable)
IsNewReport
    end

    methods
        function obj=HTMLLinkManager(isNewReport)
            obj.IsNewReport=nargin>0&&isNewReport;
        end

        function show(~,fullReportFileName)
            emlcprivate('emcOpenReport','%s',fullReportFileName);
        end

        function out=getResourceFolder(obj)
            if~obj.IsNewReport
                out=fullfile(matlabroot,'test','tools','eml','oldreport','resources');
            else
                out='';
            end
        end

        function out=getStyleSheet(~)
            out='';
        end

        function out=getHyperlink(obj,id,txt)
            [file,lineNum]=strtok(id,':');
            if~isempty(lineNum)
                lineNum=lineNum(2:end);
            end
            if obj.IsNewReport
                dataAttr=generateDataAttributeForRef(file,lineNum);
            else
                dataAttr='';
            end
            out=['<a href="matlab:emlcprivate(''irOpenToLine'','''...
            ,file,''',''',lineNum,''')" name="code2model" class="code2model" ',dataAttr,'>',txt,'</a>'];
        end

        function out=getLinkToFrontEnd(obj,sid,txt)
            out='';
            if isempty(sid)
                out='';
                return;
            end


            tmp=textscan(sid,'%s','Delimiter','\n');
            sid=tmp{1}{end};

            if~loc_isvalid_trace_id(sid)
                out='';
                return;
            end

            [pathname,filename,ext]=fileparts(sid);
            if nargin<3
                txt=[filename,ext];
            end
            [ext,tmp]=strtok(ext,':');
            codeFile=fullfile(pathname,[filename,ext]);


            tmpSplit=split(tmp,',');
            tmp=tmpSplit{1};

            if obj.IsNewReport
                dataAttr=generateDataAttributeForRef(codeFile,tmp(2:end));
            else
                dataAttr='';
            end

            if~isempty(tmp)
                out=['<a href="matlab:coder.report.HTMLLinkManager.openToCode('''...
                ,codeFile,''',''',tmp(2:end),''')" name="code2model" class="code2model" '...
                ,dataAttr,'>',txt,'</a>'];
            end
        end
    end

    methods(Static)
        function openSourceFile(htmlRoot,src_file_url)

            filepath=coder.report.internal.parseFileURL(src_file_url);
            if isempty(filepath)

                open(urldecode(fullfile(htmlRoot,src_file_url)));
            else

                open(filepath);
            end
        end

        function openToCode(file,code_range)











            if isfile(file)
                [sPos,ePos]=strtok(code_range,'-');
                if isempty(ePos)
                    if ischar(code_range)
                        lineNum=str2double(code_range);
                    else
                        lineNum=code_range;
                    end
                    emlcprivate('irOpenToLine',file,lineNum);
                else
                    sPos=abs(str2double(sPos))+1;
                    ePos=abs(str2double(ePos))+1;

                    editor=matlab.desktop.editor.openDocument(file);

                    [startLine,startPos]=matlab.desktop.editor.indexToPositionInLine(editor,sPos);
                    [endLine,endPos]=matlab.desktop.editor.indexToPositionInLine(editor,ePos);

                    editor.Selection=[startLine,startPos,endLine,endPos];

                    editor.makeActive();
                end
            else
                error(message('CoderFoundation:report:FileNotExist',file));
            end
        end
    end
end

function out=loc_isvalid_trace_id(sid)
    out=true;
    [~,~,ext]=fileparts(sid);
    [~,tmp]=strtok(ext,':');

    if isempty(tmp)
        out=false;
    else
        n=textscan(tmp(2:end),'%d-%d');
        if~isempty(n{2})&&~isnumeric(n{2})
            out=false;
        end
        if isempty(n{1})
            out=false;
        elseif~isnumeric(n{1})
            out=false;
        end
    end
end

function str=generateDataAttributeForRef(file,codeRange)
    if ischar(codeRange)
        location=str2double(strsplit(codeRange,'-'));
    else
        location=codeRange;
    end
    str=codergui.evalprivate('toCustomLinkAttribute','file',file,location);
end


