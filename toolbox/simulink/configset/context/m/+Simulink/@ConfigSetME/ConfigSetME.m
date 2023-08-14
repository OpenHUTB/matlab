classdef ConfigSetME<handle




    properties(SetObservable)
        csWSName char='configSetObj';
        saveToFile logical=false;
        fileType int32=1;
        fileName char='';
        sourceLocation int32=0;
        node=[];
    end

    methods
        function out=getPropDataType(obj,varName)

            switch class(obj.(varName))
            case 'logical'
                out='bool';
            case 'char'
                out='ustring';
            case 'int32'
                out='int';
            otherwise
                out='mxArray';
            end
        end
    end

    methods
        dialogCallback(hObj,hDlg,tag,schema)
        dlg=getConfigSetRenameDialogSchema(obj,schema)
        dlg=getDialogSchema(hObj,schema)
    end
end
