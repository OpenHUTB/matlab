function fixed=fixDoorsObject(doc,item,args)




    fixed=false;
    model=args{1};
    slObj=args{2};
    if length(slObj)>10
        object_info=['Stored ID ends with ...',slObj(end-10:end),'.'];
    else
        object_info=['Stored ID: ',slObj,'.'];
    end
    label=rmidoors.getObjAttribute(doc,item,'Object Text');
    separator=strfind(label,': ');
    if isempty(separator)
        origLabel=label;
    else
        origLabel=label(separator(1)+2:end);
    end
    reply=questdlg({...
    getString(message('Slvnv:rmiref:DocCheckDoors:ObjectNotFoundInModel',model)),...
    getString(message('Slvnv:rmiref:DocCheckDoors:LinkLabelIs',origLabel)),...
    object_info,...
    ' ',...
    getString(message('Slvnv:rmiref:DocCheckDoors:DeleteThisReference')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:ClickResetToKeep'))},...
    getString(message('Slvnv:rmiref:DocCheckDoors:ProblemWithLinkFromDocument')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:OK')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:Reset')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:OK')));

    if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmiref:DocCheckDoors:Reset')))
        fixed=rmiref.DocCheckDoors.restore(doc,item);
    end
end
