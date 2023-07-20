function[code,msg]=variableEditorSetDataCode(~,varname,row,column,newValue)













    if row==1&&column==1&&contains(varname,"(")

        code=varname+" = "+newValue+";";
    else
        code=varname+"("+row+","+column+") = "+newValue+";";
    end
    code=char(code);
    msg='';
end
