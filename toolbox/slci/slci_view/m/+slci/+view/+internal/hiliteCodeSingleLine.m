


function hiliteCodeSingleLine(aFileName,aLineNo,aMdlName,aBlockSID)
    try
        title=Simulink.ID.getFullName(get_param(aBlockSID,'Object'));

        data={
        struct('file',aFileName,'line',aLineNo)
        };

        input.title=title;
        input.data=data;
        simulinkcoder.internal.util.highlightInCode(aMdlName,input);
    catch me %#ok

    end
end
