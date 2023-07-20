function dialog=createErrorDialog(ex)
    dialog.DialogTitle='';
    dialog.EmbeddedButtonSet={''};
    dialog.StandaloneButtonSet={''};
    dialog.DialogMode='Slim';

    errortitle.Name='Error Happens During Creation';
    errortitle.Tag='req_error_info';
    errortitle.Type='text';
    errortitle.RowSpan=[1,1];
    errortitle.ColSpan=[1,1];

    errorid.Name=ex.identifier;
    errorid.Tag='req_error_id';
    errorid.Type='text';
    errorid.RowSpan=[2,2];
    errorid.ColSpan=[1,1];


    errormsg.Name=ex.message;
    errormsg.Tag='req_error_msg';
    errormsg.Type='text';
    errormsg.RowSpan=[3,5];
    errormsg.ColSpan=[1,1];

    if~isempty(ex.stack)
        stack1=ex.stack(1);
        errorStack.Name=sprintf('at: LINE %s, in %s in %s',num2str(stack1.line),stack1.file);
        errorStack.Tag='req_error_stack';
        errorStack.Type='text';
        errorStack.RowSpan=[6,10];
        errorStack.ColSpan=[1,1];
    else
        errorStack.Name='No Stack Info';
        errorStack.Tag='req_error_stack';
        errorStack.Type='text';
        errorStack.RowSpan=[6,10];
        errorStack.ColSpan=[1,1];
    end

    spacer=struct('Type','text','Name','');
    spacer.RowSpan=[11,11];

    dialog.Items={errortitle,errorid,errormsg,errorStack,spacer};
    dialog.LayoutGrid=[11,1];
    dialog.RowStretch=[zeros(1,10),1];

    debugging=exist(fullfile(matlabroot,'toolbox',...
    'slrequirements','slrequirements','+slreq',...
    '+report','OptionDlg.m'),'file');
    if debugging

        for k=1:length(ex.stack)

            [filepath,filename,fileext]=fileparts(ex.stack(k).file);
            if strcmp(fileext,'.p')
                fileext='.m';
            end
            filefullpath=[filepath,filesep,filename,fileext];
            hyperlinkinfo=...
            ['<a href="matlab:opentoline(''',filefullpath,''', ',num2str(ex.stack(k).line),');">',filename,fileext,'</a>'];
            fprintf('[%d] %s:%d\n',k,hyperlinkinfo,ex.stack(k).line);
        end
    end
end