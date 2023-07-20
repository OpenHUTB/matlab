function newModelPath=fixActxModel(btnobj,args)




    originalModelPath=args{1};
    reply=questdlg({[rmiref.DocChecker.UNRESOLVED_MODEL,': ',originalModelPath,'.'],...
    getString(message('Slvnv:rmiref:DocCheckWord:FixByChoosingModel')),...
    getString(message('Slvnv:rmiref:DocCheckWord:ClickResetToKeep'))},...
    getString(message('Slvnv:rmiref:DocCheckWord:ProblemWithLinkFromDoc')),...
    getString(message('Slvnv:rmiref:DocCheckWord:Fix')),...
    getString(message('Slvnv:rmiref:DocCheckWord:Reset')),...
    getString(message('Slvnv:rmiref:DocCheckWord:Cancel')),...
    getString(message('Slvnv:rmiref:DocCheckWord:Fix')));
    if isempty(reply)
        reply=getString(message('Slvnv:rmiref:DocCheckWord:Cancel'));
    end
    switch reply
    case getString(message('Slvnv:rmiref:DocCheckWord:Fix'))
        newModelPath=rmiref.DocChecker.promptModel();
        if~isempty(newModelPath)
            try
                [origCommand,origLabel]=rmiref.SLReference.parseData(btnobj.MLDataString);

                newCommand=regexprep(origCommand,originalModelPath,newModelPath);
                btnobj.MLEvalString=newCommand;

                [~,mName,~]=fileparts(newModelPath);
                [~,oName,~]=fileparts(originalModelPath);
                newLabel=regexprep(origLabel,oName,mName);
                btnobj.ToolTipString=newLabel;
                btnobj.MLDataString='';

                normalIcon=rmiref.SLReference.fullIconPathName('normal');
                if~isempty(normalIcon)
                    btnobj.Picture=normalIcon;
                end
            catch Mex
                warning(message('Slvnv:rmiref:DocCheckWord:FailToModifyLink',Mex.message));
                newModelPath=originalModelPath;
            end
        end
    case getString(message('Slvnv:rmiref:DocCheckWord:Reset'))
        rmiref.DocCheckWord.restore('',btnobj,args);
    end
end
