function[tableSpan,setSpan]=drawCmdTableTitle(obj)




    fprintf('------------------ Target Interface Table ------------------\n\n');

    if obj.hTurnkey.isCoProcessorMode
        fprintf('   Execution Mode : %s\n\n',obj.hTurnkey.hD.get('ExecutionMode'));
    end

    tablesetting=hdlturnkey.data.interfaceTableInitFormat;


    tableWidth=tablesetting.ColumnCharacterWidth;
    tableSpan=[...
    '%',num2str(tableWidth(1)),'s : ',...
    '%',num2str(tableWidth(2)+3),'s : ',...
    '%',num2str(tableWidth(3)+3),'s : ',...
    '%',num2str(tableWidth(4)+6),'s : ',...
    '%',num2str(tableWidth(5)),'s\n'];


    fprintf(tableSpan,tablesetting.ColHeader{:});


    setSpan=[...
    '%',num2str(tableWidth(1)),'s : ',...
    '%',num2str(tableWidth(2)+3),'s : ',...
    '%',num2str(tableWidth(3)+3),'s : ',...
    '%s\n'];

end
