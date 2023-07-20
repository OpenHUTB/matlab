function retVal=getDiagInfo(obj,isNewAPI)
    import mlreportgen.dom.*
    if nargin<2
        isNewAPI=false;
    end
    diagInfo=obj.ReuseDiag;
    retVal=cell(0,4);
    if strncmp(obj.TargetLang,'C++',3)
        ext='_cpp.html';
    else
        ext='_c.html';
    end
    if isNewAPI
        diagInfoHdr={DAStudio.message('RTW:report:CodeMappingTableColumnSubsystem'),DAStudio.message('RTW:report:CodeMappingTableColumnReuseSetting'),DAStudio.message('RTW:report:CodeMappingTableColumnReuseOutcome'),DAStudio.message('RTW:report:CodeMappingTableColumnOutcomeDiagnostic')};
        if~isempty(diagInfo)
            retVal=Table(diagInfoHdr);
            retVal.StyleName='TableStyleAltRow';
        else
            retVal=Paragraph(DAStudio.message('RTW:report:CodeMappingNoNonVirtual'));
            retVal.Style={Bold()};
        end
    end
    isBlockSIDComment=[];
    for i=1:length(diagInfo)
        if isempty(diagInfo(i).BlockSID)
            continue
        end
        [model,sidNumStr]=strtok(diagInfo(i).BlockSID,':');
        if isempty(isBlockSIDComment)
            isBlockSIDComment=strcmp(get_param(model,'BlockCommentType'),'BlockSIDComment');
        end

        if isBlockSIDComment
            name=get_param(diagInfo(i).BlockSID,'Name');
            name=strrep(name,'/','//');
            name=strrep(name,newline,' ');
            ssName=[name,' (''',sidNumStr,''')'];
        else
            ssName=sprintf('<S%d>',diagInfo(i).SystemID);
        end
        userSetCol=diagInfo(i).UserReuseFlag;
        if isNewAPI
            row=TableRow();
            entry=TableEntry(ssName);
            row.append(entry);
            entry=TableEntry(userSetCol);
            row.append(entry);
        else
            nameCol=obj.getHyperlink(diagInfo(i).BlockSID,ssName);
        end
        rSetCol=diagInfo(i).ReuseFlag;
        if(strncmp(rSetCol,'Reus',4)||strncmp(rSetCol,'Func',4))&&~isempty(diagInfo(i).FileName)&&~isempty(diagInfo(i).FcnName)
            fileName=diagInfo(i).FileName;
            if strcmp(diagInfo(i).SharedFcn,'on')&&~strcmp(diagInfo(i).ReusesLibraryCode,'on')
                fileName=[obj.RelativePathToSharedUtilRptFromRpt,'/',fileName];%#ok<*AGROW>
            end
            if~rtw.report.ReportInfo.featureReportV2
                link=['<A HREF="',fileName,ext,'#fcn_',diagInfo(i).FcnName,'" TARGET="rtwreport_document_frame">',rSetCol,'</A>'];
            else

                fcnName=diagInfo(i).FcnName;
                callBackStr=sprintf('postParentWindowMessage({message:''jumpToCode'',location:''%s''})',fcnName);
                link=sprintf('<a href="javascript: void(0)" onclick="%s" class="reportToCode" fcnName="%s">%s</a>',...
                callBackStr,fcnName,rSetCol);
            end
        else
            link=rSetCol;
        end
        if isNewAPI
            entry=TableEntry(rSetCol);
            row.append(entry);
        end
        if~isempty(diagInfo(i).Blockers)
            if isNewAPI
                entry=TableEntry('[exceptions]');
                entry.Style={Color('Red')};
                row.append(entry);
            else
                exStr='<FONT COLOR="red">[exceptions]</FONT>';
                blkerCol=['<A HREF="#S',int2str(diagInfo(i).SystemID),'blker"','TARGET="rtwreport_document_frame">',exStr,'</A>'];
            end
        else
            if isNewAPI
                aText=Text('normal');
                aText.Style={Color('Green')};
                entry=TableEntry(aText);
                row.append(entry);
            else
                blkerCol='<FONT COLOR="green">normal</FONT>';
            end
        end
        if isNewAPI
            retVal.append(row);
        else
            retVal{end+1,1}=nameCol;
            retVal{end,2}=userSetCol;
            retVal{end,3}=link;
            retVal{end,4}=blkerCol;
        end
    end
end
