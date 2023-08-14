function[descriptions,handles]=maAppendResults(mfunctionsInfo,descriptions,handles,check)




    htmlHeader=[...
    '<br/><b>',DAStudio.message('Slvnv:consistency:InconsistenciesInMatlab'),'</b><br/>',...
    '<blockquote><table>'];
    if length(descriptions)>length(handles)
        descriptions{end}=[descriptions{end},htmlHeader];
    else
        descriptions{end+1}=htmlHeader;
    end
    emptyCell='<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
    for i=1:size(mfunctionsInfo,1)
        descriptions{end}=[descriptions{end},'<tr><td>'];
        srcName=mfunctionsInfo{i,2};
        obj=Simulink.ID.getHandle(srcName);
        if~isa(obj,'double')

            handles{end+1}={obj};%#ok<AGROW> %[obj.Path];
        else
            handles{end+1}=obj;%#ok<AGROW>
        end
        rptFileName=rmiml.mdlAdvRptPath(srcName,check);
        rptCmdLink=['<a href="file:///',rptFileName,'">',DAStudio.message('Slvnv:consistency:SeeReport'),'</a>'];
        descriptions{end+1}=sprintf('</td>%s<td>%s</td>%s<td>%s</td></tr>',...
        emptyCell,DAStudio.message('Slvnv:consistency:IssueCount',num2str(mfunctionsInfo{i,1})),...
        emptyCell,rptCmdLink);%#ok<AGROW>
    end
    descriptions{end}=[descriptions{end},'</table></blockquote>'];
end

