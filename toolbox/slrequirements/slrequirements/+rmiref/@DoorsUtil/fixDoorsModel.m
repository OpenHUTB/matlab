function newModelPath=fixDoorsModel(doc,item,args)




    originalModelPath=args{1};
    reply=questdlg({[rmiref.DocChecker.UNRESOLVED_MODEL,': ',originalModelPath,'.'],...
    getString(message('Slvnv:rmiref:DocCheckDoors:FixByChoosingModel')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:ClickResetToKeep'))},...
    getString(message('Slvnv:rmiref:DocCheckDoors:ProblemWithLinkFromDocument')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:Fix')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:Reset')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:Cancel')),...
    getString(message('Slvnv:rmiref:DocCheckDoors:Fix')));
    if isempty(reply)
        reply=getString(message('Slvnv:rmiref:DocCheckDoors:Cancel'));
    end
    switch reply
    case getString(message('Slvnv:rmiref:DocCheckDoors:Fix'))
        newModelPath=rmiref.DocChecker.promptModel();
        if~isempty(newModelPath)
            try
                data=rmidoors.getObjAttribute(doc,item,'Object Short Text');
                [origCommand,origLabel]=rmiref.SLReference.parseData(data);

                newCommand=regexprep(origCommand,originalModelPath,newModelPath);
                rmidoors.setObjAttribute(doc,item,'DmiSlNavCmd',newCommand);

                [~,mName,~]=fileparts(newModelPath);
                [~,oName,~]=fileparts(originalModelPath);
                newLabel=regexprep(origLabel,oName,mName);
                rmidoors.setObjAttribute(doc,item,'Object Text',newLabel);
                rmidoors.setObjAttribute(doc,item,'Object Short Text','');

                newBitmap=rmiref.SLReference.fullIconPathName('normal');
                rmidoors.setObjAttribute(doc,item,'picture',newBitmap);
            catch Mex
                warning(message('Slvnv:rmiref:SLRefDoors:ModelFixFailed',item,doc,Mex.message));
            end
        end
    case getString(message('Slvnv:rmiref:DocCheckDoors:Reset'))
        rmiref.DocCheckDoors.restore(doc,item);
    end
end
