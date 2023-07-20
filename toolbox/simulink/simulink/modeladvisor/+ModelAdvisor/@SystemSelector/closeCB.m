function closeCB(this,closeAction)




    UserData=get(this.StartDialog,'UserData');

    switch lower(closeAction)
    case 'ok'

        rootStr='^Simulink Root/';
        this.SelectedSystem=regexprep(this.SelectedSystem,rootStr,'');
    case{'cancel','close'}
        this.SelectedSystem='';
    end

    set(this.StartDialog,'Position',[1,1,1,1]);
