function actionPerformed=cbkCopy(this,justTesting,currSelect)




    actionPerformed=false;
    if~isa(this.Editor,'DAStudio.Explorer')
        return;
    end

    if nargin<2
        justTesting=false;
    end

    if nargin<3
        ime=DAStudio.imExplorer;
        ime.setHandle(this.Editor);
        currSelect=ime.getCurrentTreeNode;
    end

    try
        actionPerformed=isCopyable(currSelect);
    catch ME
        warning(ME.message);
        actionPerformed=false;
    end

    if~actionPerformed||justTesting
        return;
    end

    try
        this.HandleClipboard=doCopy(currSelect);
    catch ME
        warning(ME.message);
        actionPerformed=false;
    end

    if actionPerformed

        set([this.Actions.Paste
        this.Actions.Paste2],...
        'Enabled',locOnOff(cbkPaste(this,true,currSelect)));
    end


    function oo=locOnOff(tf)

        if tf
            oo='on';
        else
            oo='off';
        end

