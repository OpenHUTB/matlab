function fixed=fixActxObject(btnobj,args)




    fixed=false;
    model=args{1};
    slObj=args{2};
    if length(slObj)>10
        object_info=['Stored ID ends with ...',slObj(end-10:end),'.'];
    else
        object_info=['Stored ID: ',slObj,'.'];
    end
    label=btnobj.ToolTipString;
    separator=strfind(label,': ');
    if isempty(separator)
        origLabel=label;
    else
        origLabel=label(separator(1)+2:end);
    end
    reply=questdlg({...
    getString(message('Slvnv:rmiref:DocCheckWord:ObjectIdNotFound',model)),...
    getString(message('Slvnv:rmiref:DocCheckWord:LinkLabelIs',origLabel)),...
    object_info,...
    ' ',...
    getString(message('Slvnv:rmiref:DocCheckWord:DeleteThisReference')),...
    getString(message('Slvnv:rmiref:DocCheckWord:ClickResetToKeep'))},...
    getString(message('Slvnv:rmiref:DocCheckWord:ProblemWithLinkFromDoc')),...
    getString(message('Slvnv:rmiref:DocCheckWord:OK')),...
    getString(message('Slvnv:rmiref:DocCheckWord:Reset')),...
    getString(message('Slvnv:rmiref:DocCheckWord:OK')));

    if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmiref:DocCheckWord:Reset')))
        fixed=rmiref.DocCheckWord.restore('',btnobj,args);
    end
end
