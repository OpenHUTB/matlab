function text=compareTruthTable(action,source1,source2,width,ignore_whitespace,show_diffs_only,report_id)










    text=comparisons_private(action,source1,source2,width,ignore_whitespace,show_diffs_only,report_id);






    actions_heading=slxmlcomp.internal.message('report:TruthTableActions');
    if any(regexp(text,[actions_heading,'(?=(\s\d))'],'once'))==0
        text=strrep(text,actions_heading,wrapInBoldTags(actions_heading));
    end

    i=1;
    while true
        start_text=text;
        desc_heading=slxmlcomp.internal.message('report:TruthTableDescription',i);
        cond_heading=slxmlcomp.internal.message('report:TruthTableCondition',i);
        data_heading=slxmlcomp.internal.message('report:TruthTableData',i);
        action_heading=slxmlcomp.internal.message('report:TruthTableAction',i);
        text=strrep(text,desc_heading,wrapInBoldTags(desc_heading));
        text=strrep(text,cond_heading,wrapInBoldTags(cond_heading));
        text=strrep(text,data_heading,wrapInBoldTags(data_heading));
        text=strrep(text,action_heading,wrapInBoldTags(action_heading));
        if strcmp(text,start_text)

            break;
        else
            i=i+1;
        end
    end
end

function wrappedText=wrapInBoldTags(text)
    wrappedText=['<span style="font-weight:bold">',text,'</span>'];
end
