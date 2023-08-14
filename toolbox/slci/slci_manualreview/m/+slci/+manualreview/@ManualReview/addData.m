


function addData(obj,file,start_line_no,end_line_no)
    if(start_line_no==end_line_no)
        codeLine=num2str(start_line_no);
    else
        codeLine=[num2str(start_line_no),'-',num2str(end_line_no)];
    end

    codeLine=[file,':',codeLine];
    obj.getDialog.insertData(codeLine);
end