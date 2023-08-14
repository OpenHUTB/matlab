
classdef ReportUtil
    methods(Static)





        function css=genCSS(config)
            css='<style type="text/css">\n';
            css=[css,'body {color:black;}\n'];
            tableCSS=slci.internal.ReportUtil.tableCSS();
            css=[css,tableCSS];

            css=[css,'.indented {margin-left:25px;}'];
            ks=config.getSpanList();
            for i=1:numel(ks)
                k=ks{i};
                css=[css,'span.',k,' {',config.getHtmlColor(k),'}\n'];
            end

            css=[css,'span.CODE { white-space: pre;  }\n'];
            css=[css,'span.FORMATTED_MSG { white-space: pre;  }\n'];
            css=[css,'</style>\n'];
        end

        function CSS=tableCSS()
            CSS=['table.T1 {'...
            ,'border-style:solid ;'...
            ,'border-color:#EEEEFF;'...
            ,'border-width:1px; '...
            ,'border-spacing:0;'...
            ,'padding:2px;'...
            ,'border-collapse:collapse;'...
            ,'}'];
            CSS=[CSS,'table.T0 {'...
            ,'border-style:hidden; '...
            ,'}'];


            CSS=[CSS,'TH.th1 { '...
            ,'background-color:#EEEEFF;'...
            ,'text-align:left;'...
            ,'border-style:solid ;'...
            ,'border-color:#EEEEFF;'...
            ,'border-width:1px; '...
            ,'padding:2px;'...
            ,'}'];
            CSS=[CSS,'TD.d1 {'...
            ,'border-style:solid ;'...
            ,'border-color:#EEEEFF;'...
            ,'border-width:1px; '...
            ,'text-align:left;'...
            ,'padding:2px;'...
            ,'}'];
            CSS=[CSS,'TD.d0 {'...
            ,'text-align: left;'...
            ,'border-style:none;'...
            ,'padding:2px;'...
            ,'}'];


        end


        function SCRIPT=genScript()

            cssHeader='<link rel="stylesheet" type="text/css" href="rtwreport.css" />';
            SCRIPT=[cssHeader,'<script language="JavaScript" type="text/javascript"> '...
            ,'\n function rtwTableShrink(o, category)'...
            ,'\n {'...
            ,'\n    var indent = document.getElementById(category + "_indent");'...
            ,'\n    var fileTable = document.getElementById(category + "_table");'...
            ,'\n    if (fileTable.style.display == "none") {'...
            ,'\n        fileTable.style.display = "";'...
            ,'\n        indent.style.display = "";'...
            ,'\n        o.innerHTML = ''<span style="font-family:monospace" id = "'' + category + ''_button">[-] </span>'';'...
            ,'\n    } else {'...
            ,'\n        fileTable.style.display = "none";'...
            ,'\n        indent.style.display = "none";'...
            ,'\n        o.innerHTML = ''<span style="font-family:monospace" id = "'' + category + ''_button">[+] </span>'';'...
            ,'\n    } '...
            ,'\n }'...
            ,'\n </script>'];


        end

        function text=appendCallBack(content,model,handle)
            text='<a href="matlab:slci.internal.ReportConfig.traceCallBack(''';
            text=[text,model,''',''',handle,''''];
            text=[text,')','">'];
            text=[text,content];
            text=[text,'</a>\n'];
        end



        function text=appendColorAndTip(content,status,tip)
            text=['<span class="',status,'"'];
            if(exist('tip','var'))
                if(~isempty(tip))
                    text=[text,' title="',tip,'"'];
                end
            end
            text=[text,'>'];
            text=[text,content];
            text=[text,'</span>'];
        end

        function text=formatStatus(status)
            text=slci.internal.ReportUtil.appendColorAndTip(status,status);
        end

        function text=makeBold(content)
            text=['<b>',content,'</b>'];
        end

        function text=indentSection(content)
            text=['<div class="indented">',content,'</div>'];
        end

        function text=makeHeader4(content)
            text=['<h4>',content,'</h4>'];
        end

        function text=makeHeader3(content)
            text=['<h3>',content,'</h3>'];
        end

        function text=makeHeader2(content)
            text=['<h2>',content,'</h2>'];
        end

        function text=addLineBreak(content)
            text=[content,'<br/>'];
        end

        function table=genExpandableHtmlTable(TABLE_ID,caption,caption_status,items,extra,extra_link)

            BUTTON=[TABLE_ID,'_button'];
            INDENT=[TABLE_ID,'_indent'];
            TABLE=[TABLE_ID,'_table'];

            table='<table class="T0" id="';

            table=[table,TABLE_ID];

            table=[table,'">'...
            ,'\n  <tr> '...
            ,'\n    <td style="text-align:left;">'...
            ,'\n    <span style="background-color:#ffffff;cursor:pointer;white-space:nowrap" title="Click to shrink or expand category" '...
            ,'       onclick="rtwTableShrink(this,''',TABLE_ID,''')"> '...
            ,'\n     <span style="font-family:monospace" id = "',BUTTON,'">'];


            table=[table,'[-]'];

            table=[table,'\n</span>'...
            ,'\n    </span>'...
            ,'\n    </td>'...
            ,'\n    <td class="d0">'...
            ,'\n    <b>',caption,'</b>'...
            ,'\n    </td>'];

            if(exist('extra','var'))
                if(~isempty(extra))
                    table=[table,'<td class="d0">'];
                    table=[table,'<a href="matlab:edit(''',extra_link,''')">'];
                    table=[table,extra];
                    table=[table,'</a>'];
                    table=[table,' : '];
                    table=[table,'</td>'];
                end
            end

            table=[table,'<td class="d0">'];
            if(~isempty(caption_status))
                caption_status=slci.internal.ReportUtil.appendColorAndTip(caption_status,caption_status);
            end
            table=[table,caption_status];
            table=[table,'</td>'...
            ,'\n  </tr>'...
            ,'\n  <tr>'...
            ,'\n  <td class="d0">'...
            ,'\n  <span id="',INDENT,'"></span>'...
            ,'\n  </td>'...
            ,'\n  <td class="d0">'];


            if(~isempty(items))
                table=[table,'\n <table style="display:all; border-style:none;" id="',TABLE,'">'];
                table=[table,items...
                ,'\n </table>'];
            end

            table=[table...
            ,'\n </td>'...
            ,'\n </tr>'...
            ,'\n </table>'];

        end


        function items=genExpandableHtmlTableItem(texts)
            items=[];
            for i=1:numel(texts)
                items=[items...
                ,'\n <tr>'...
                ,'\n <td class="d0">'];



                t=texts{i};

                items=[items,t...
                ,'\n </td>'...
                ,'\n </tr>'];

            end
        end


        function htmlTable=genTable(header,data,border)
            nheaders=numel(header);
            [ndatarows,ndatacols]=size(data);
            if(ndatacols==0)||(ndatarows==0)
                error('Improper table data for html table');
            end

            if border
                rowTagS='<TR >\n';
                rowTagE='</TR>\n';
                colTagS='<TD class="d1">\n';
                colTagE='</TD>\n';
            else
                rowTagS='<TR>\n';
                rowTagE='</TR>\n';
                colTagS='<TD class="d0">\n';
                colTagE='</TD>\n';
            end
            thTagS='<TH class="th1">\n';
            thTagE='</TH>\n';

            if nheaders>0
                headerTable=rowTagS;
                for ncol=1:nheaders
                    headerTable=[headerTable,thTagS,header{ncol},thTagE];%#ok<*AGROW>
                end
                headerTable=[headerTable,rowTagE];
            else
                headerTable=[];
            end


            dataTable=[];
            for nr=1:ndatarows
                dataTable=[dataTable,rowTagS];
                for nc=1:ndatacols
                    dataTable=[dataTable,colTagS,data{nr,nc},colTagE];
                end
                dataTable=[dataTable,rowTagE];
            end

            if border
                htmlTable=['<table class="T1">',headerTable,dataTable,'</table>'];
            else
                htmlTable=['<table class="T0">',headerTable,dataTable,'</table>'];
            end
        end

        function key=getUniqueKey()
            persistent UniqueKey;
            if isempty(UniqueKey)
                UniqueKey=0;
            else
                UniqueKey=UniqueKey+1;
            end
            key=num2str(UniqueKey);
        end

        function sortedCell=sortCell(arrayToSort,inputCell)
            if iscellstr(arrayToSort)
                [~,sortedIndx]=sort(arrayToSort);
                sortedCell=inputCell(sortedIndx,:);
            else
                sortedCell=inputCell;
            end

        end

        function sortedStruct=sortStruct(structToSort,fieldName)
            if~isfield(structToSort,fieldName)
                m='Slci:report:NoFieldInStructure';
                ex=slci.internal.ReportUtil.createExceptionFromID(m,structToSort,fieldName);
                throw(ex);
            end
            fieldValues=cell(numel(structToSort),1);

            [fieldValues{:}]=deal(structToSort.(fieldName));
            if isnumeric(fieldValues{1})
                fieldValue=cell2mat(fieldValues);
                [~,sortedIndx]=sort(fieldValue);
            else
                [~,sortedIndx]=sort(fieldValues);
            end
            sortedStruct=structToSort(sortedIndx);
        end

        function text=addHorizontalBar(text)
            text=[text,'<hr>'];
        end

        function text=formatCode(text)
            text=['<span class="CODE">',text,'</span>'];
        end

        function text=formatMessage(text)
            text=['<span class="FORMATTED_MSG">',text,'</span>'];
        end



        function colorSystem(block_color_table,config)
            if(config.isPreColored())
                blks=keys(block_color_table);
                for i=1:numel(blks)
                    blk_property=block_color_table(blks{i});
                    sid=blk_property.sid;
                    status=blk_property.status;
                    updateColor(sid,status,config);
                end
            end
        end


        function updateColor(sid,status,config)

            [parents,schemes]=slci.internal.ReportConfig.getParents(sid);
            hilite_system(sid,config.getHiliteScheme(status));

            for i=2:numel(parents)

                hilite_system(parents{i},schemes{i});
            end
        end


















        function map_table=categorize(KEY,struct_array,FIELD)
            map_table=containers.Map;
            if(~isfield(struct_array,KEY))
                exception=MException('ReportUtil:Categorize',...
                ['Structure ',inputname(2)...
                ,' does not contain any field called ',KEY]);
                throw(exception);
            end
            for i=1:numel(struct_array)
                item=struct_array(i).(KEY);
                if exist('FIELD','var')
                    value=struct_array(i).(FIELD);
                else
                    value=struct_array(i);
                end

                if(isKey(map_table,item))
                    map_table(item)=[map_table(item),value];
                else
                    map_table(item)=value;
                end
            end
        end

        function optext=abbreviateText(text,name_numel,begin)
            if(numel(text)>name_numel)
                if(begin)
                    optext=[text(1:name_numel),'...'];
                else
                    optext=['...',text(numel(text)-name_numel:numel(text))];
                end
            else
                optext=text;
            end
        end



        function aggStatus=aggregateSubstatus(subStatusArray)

            persistent rconfig;
            if isempty(rconfig)
                rconfig=slci.internal.ReportConfig;
            end
            num=numel(subStatusArray);
            statusArray=cell(num,1);
            for i=1:num
                statusArray{i}=rconfig.getStatus(subStatusArray{i});
            end
            aggStatus=rconfig.getHeaviest(statusArray);
        end

        function aggStatus=getHeaviestSubstatus(statusArray,severityList)


            statusArray=statusArray(~cellfun('isempty',statusArray));
            if numel(statusArray)>1
                for k=1:numel(severityList)
                    if any(strcmpi(statusArray,severityList{k}))
                        aggStatus=severityList{k};
                        return;
                    end
                end
                assert(false);
            else
                assert(numel(statusArray)==1);
                aggStatus=statusArray{1};
            end
        end




        function statusMap=getStatusCounts(objectList,statusList)

            if isempty(statusList)
                statusMap=containers.Map;
                return;
            end
            initialCounts=cell(size(statusList));
            [initialCounts{:}]=deal(0);
            statusMap=containers.Map(statusList,initialCounts);
            for p=1:numel(objectList)
                dataObject=objectList{p};
                thisStatus=dataObject.getStatus();


                statusMap(thisStatus)=statusMap(thisStatus)+1;
            end
        end




        function statusMap=getTraceCounts(objectList,statusList)

            if isempty(statusList)
                statusMap=containers.Map;
                return;
            end
            initialCounts=cell(size(statusList));
            [initialCounts{:}]=deal(0);
            statusMap=containers.Map(statusList,initialCounts);
            for p=1:numel(objectList)
                dataObject=objectList{p};
                thisStatus=dataObject.getTraceStatus();


                statusMap(thisStatus)=statusMap(thisStatus)+1;
            end
        end




        function[countMap,statusMap]=getStatusObjectAndCountMap(objectList,...
            statusList)

            statusMap=containers.Map;
            countMap=containers.Map;
            numStatuses=numel(statusList);
            if numStatuses==0
                return;
            end


            objectStatuses=cellfun(@getTraceStatus,objectList,...
            'UniformOutput',false);
            for p=1:numStatuses
                thisStatus=statusList{p};
                indxs=find(strcmpi(objectStatuses,thisStatus));
                if~isempty(indxs)
                    statusMap(thisStatus)=objectList(indxs);
                    countMap(thisStatus)=numel(indxs);
                else
                    statusMap(thisStatus)={};
                    countMap(thisStatus)=0;
                end
            end
        end





        function codeLocations=parseCode(fileName)
            if~exist(fileName,'file')
                error(['Unable to find code file ',fileName]);
            end

            fid=fopen(fileName);
            linenum=1;
            codeLocations=cell(0);
            while~feof(fid)
                codeStr=fgets(fid);
                codeLocations{linenum,1}=linenum;
                codeLocations{linenum,2}=codeStr;

                linenum=linenum+1;
            end
            fclose(fid);
        end

        function commentFlag=isComment(codeLine)

            persistent commentBlock;
            if isempty(commentBlock)
                commentBlock=false;
            end

            commentFlag=false;
            if commentBlock
                commentFlag=true;
            else

                startIndex=regexp(codeLine,'^(\s*)/\*','once');
                if~isempty(startIndex)
                    commentFlag=true;
                    commentBlock=true;
                else


                    startIndex=regexp(codeLine,'^(\s*)//','once');
                    if~isempty(startIndex)
                        commentFlag=true;
                        return;
                    end
                end
            end

            if commentBlock

                idx=regexp(codeLine,'\*/(\s*)$','once');
                if~isempty(idx)
                    commentBlock=false;
                end
            end

        end

        function isInclude=isIncludes(codeLine)

            startIndex=regexp(codeLine,'^(\s*)#include','once');
            if~isempty(startIndex)
                isInclude=true;
            else
                isInclude=false;
            end
        end

        function isPreprocessor=isPreprocessor(codeLine)

            startIndex=regexp(codeLine,'^(\s*)#\w+','once');
            if~isempty(startIndex)
                isPreprocessor=true;
            else
                isPreprocessor=false;
            end
        end

        function openBraces=isOpenBraces(codeLine)

            startIndex=regexp(codeLine,'^(\s*)(\)*\s*){+(\s*)$','once');

            startIndex1=regexp(codeLine,'^(\s*)\(+(\s*)$','once');
            if~isempty(startIndex)||~isempty(startIndex1)
                openBraces=true;
            else
                openBraces=false;
            end
        end

        function closeBraces=isCloseBraces(codeLine)

            startIndex1=regexp(codeLine,'^(\s*)}+(\s*);?(\s*)$','once');

            startIndex2=regexp(codeLine,'^(\s*)\)+(\s*);?(\s*)$','once');
            closeBraces=~isempty(startIndex1)||~isempty(startIndex2);
        end


        function semiColon=isSemiColon(codeLine)
            startIndex=regexp(codeLine,'^(\s*);(\s*)$','once');
            semiColon=~isempty(startIndex);
        end


        function isKeyWord=isKeyword(codeLine)


            KeyWordIndex=regexp(codeLine,'^(\s*)case(\s*)$','once');
            if~isempty(KeyWordIndex)
                isKeyWord=true;
                return;
            end


            KeyWordIndex=regexp(codeLine,'^\s*default\s*$','once');
            if~isempty(KeyWordIndex)
                isKeyWord=true;
                return;
            end


            KeyWordIndex=regexp(codeLine,'^(\s*)if(\s\()*(\s*)$','once');
            if~isempty(KeyWordIndex)
                isKeyWord=true;
                return;
            end



            KeyWordIndex=regexp(codeLine,'^(\s)*(}\s)*else(\s{)*(\s)*$','once');
            if~isempty(KeyWordIndex)
                isKeyWord=true;
                return;
            end


            KeyWordIndex=regexp(codeLine,'^\s*for\s*$','once');
            if~isempty(KeyWordIndex)
                isKeyWord=true;
                return;
            end

            isKeyWord=false;
        end


        function isEmpty=isEmpty(codeLine)
            codeNum=double(codeLine);

            isNLOrCR=all((codeNum==13)|(codeNum==10)|(codeNum==32)|(codeNum==9));
            if isNLOrCR
                isEmpty=true;
            else
                isEmpty=false;
            end
        end

        function ex=createExceptionFromID(s,varargin)
            msg=message(s,varargin{:});
            ex=MException(s,msg.getString());
        end

        function modelLink=createModelLink(modelName,dispModelName)
            encodedModelName=slci.internal.encodeString(modelName,'all','encode');
            dispModelName=slci.internal.encodeString(dispModelName,'all','encode');
            modelLink=...
            ['<a href="matlab:open_system('...
            ,'slci.internal.encodeString(''',encodedModelName,''',''html'',''decode'')'...
            ,')">',dispModelName,'</a>'];
        end

        function urlLink=createFileLink(linkstr,dispstr)

            linkstr=regexprep(linkstr,'\','/');

            linkstr=slci.internal.encodeString(linkstr,'all','encode');
            dispstr=slci.internal.encodeString(dispstr,'all','encode');
            urlLink=['<a href ="file:///',linkstr,'">',dispstr,'</a>'];
        end

        function urlLink=createRelativeFileLink(linkstr,dispstr)

            linkstr=regexprep(linkstr,'\','/');

            linkstr=slci.internal.encodeString(linkstr,'all','encode');
            dispstr=slci.internal.encodeString(dispstr,'all','encode');
            urlLink=['<a href ="',linkstr,'">',dispstr,'</a>'];
        end

        function fFileName=convertRelativeToAbsolute(fFileName)


            if~slci.internal.isAbsolutePath(fFileName)
                fFileName=fullfile(pwd,fFileName);
            end
        end

        function fDir=convertRelativeDirToAbsolute(fDir)


            if~slci.internal.isAbsoluteDir(fDir)
                fDir=fullfile(pwd,fDir);
            end
        end

        function OpDate=setToDefaultFormat(inDateNum)
            defaultFormat='dd-mmm-yyyy HH:MM:SS';
            OpDate=datestr(inDateNum,defaultFormat);
        end


    end

end
