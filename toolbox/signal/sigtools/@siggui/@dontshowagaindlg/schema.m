function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'dontshowagaindlg',pk.findclass('siggui'));

    schema.prop(c,'Name','ustring');
    p=schema.prop(c,'Text','string vector');
    set(p,'SetFunction',@settext);

    schema.prop(c,'NoHelpButton','bool');
    schema.prop(c,'Icon','ustring');
    schema.prop(c,'HelpLocation','ustring');
    schema.prop(c,'PrefTag','ustring');
    schema.prop(c,'DontShowAgain','on/off');


    function text=settext(this,text)



        indx=1;
        while indx<=length(text)
            idx=strfind(text{indx},newline);
            if~isempty(idx)
                text={text{1:indx-1},text{indx}(1:idx-1),text{indx}(idx+1:end),text{indx+1:end}};
            end
            indx=indx+1;
        end


