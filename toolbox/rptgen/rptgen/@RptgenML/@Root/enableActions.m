function enableActions(this,isEnable)





    if~isa(this.Editor,'DAStudio.Explorer')||~ishandle(this.Actions.New)


    elseif nargin<2||isEnable

        ime=DAStudio.imExplorer;
        ime.setHandle(this.Editor);
        currTree=ime.getCurrentTreeNode;
        isTreeDAO=isa(currTree,'rptgen.DAObject');
        isTreeRptcomponent=isa(currTree,'rptgen.rptcomponent');
        currDoc=this.getCurrentDoc(currTree);


        this.setEditorTitle(currDoc);


        set([this.Actions.New
        this.Actions.NewForm
        this.Actions.Open
        this.Actions.Exit
        this.Actions.Undo
        this.Actions.Redo
        this.Actions.Preferences
        this.Actions.ConvertFile
        this.Actions.EditStylesheet
        this.Actions.CreateComponent
        this.Actions.CreateComponentV2],...
        'Enabled','on');

        if isa(currDoc,'rptgen.DAObject')
            try
                enableSave=canSave(currDoc);
            catch
                enableSave=false;
            end
            enableClose=true;
        else
            enableSave=false;
            enableClose=false;
        end

        set(this.Actions.Close,...
        'Enabled',locOnOff(enableClose));

        set([this.Actions.Save,this.Actions.SaveAs],...
        'Enabled',locOnOff(enableSave));


        set([this.Actions.Log,this.Actions.Script],...
        'Enabled',locOnOff(isTreeRptcomponent));


        set(this.Actions.Activate,...
        'Enabled',locOnOff(isTreeRptcomponent&&~isa(currTree,'rptgen.coutline')));


        set(this.Actions.Report,...
        'Enabled',locOnOff(isTreeRptcomponent));

        isSlWritable=false;
        isSlAvailable=false;
        if rptgen.isSimulinkLoaded
            isSlAvailable=true;
            try
                currSys=get_param(0,'CurrentSystem');
                if~isempty(currSys)
                    isSlWritable=strcmp(get_param(bdroot(currSys),'lock'),'off');
                end
            catch %#ok

            end
        end


        set([this.Actions.AssociateSimulink
        this.Actions.UnAssociateSimulink],...
        'Visible',locOnOff(isSlAvailable),...
        'Enabled',locOnOff(isTreeRptcomponent&&isSlWritable));








        set([this.Actions.Cut
        this.Actions.Cut2],...
        'Enabled',locOnOff(isTreeDAO&&cbkCut(this,true,currTree)));

        set([this.Actions.Copy
        this.Actions.Copy2],...
        'Enabled',locOnOff(isTreeDAO&&cbkCopy(this,true,currTree)));

        set([this.Actions.Paste
        this.Actions.Paste2],...
        'Enabled',locOnOff(isTreeDAO&&cbkPaste(this,true,currTree)));

        set([this.Actions.Delete],...
        'Enabled',locOnOff(isTreeDAO&&cbkDelete(this,true,currTree)));


        set([this.Actions.MoveUp],...
        'Enabled',locOnOff(isTreeDAO&&moveUp(currTree,true)));

        set([this.Actions.MoveDown],...
        'Enabled',locOnOff(isTreeDAO&&moveDown(currTree,true)));

        set([this.Actions.MoveLeft],...
        'Enabled',locOnOff(isTreeDAO&&moveLeft(currTree,true)));

        set([this.Actions.MoveRight],...
        'Enabled',locOnOff(isTreeDAO&&moveRight(currTree,true)));

    else
        set([this.Actions.New
        this.Actions.NewForm
        this.Actions.Open
        this.Actions.Save
        this.Actions.SaveAs
        this.Actions.Script
        this.Actions.Preferences
        this.Actions.CreateComponent
        this.Actions.CreateComponentV2
        this.Actions.ConvertFile
        this.Actions.EditStylesheet
        this.Actions.Log
        this.Actions.Report
        this.Actions.Close
        this.Actions.Exit
        this.Actions.Undo
        this.Actions.Redo
        this.Actions.Cut
        this.Actions.Cut2
        this.Actions.Copy
        this.Actions.Copy2
        this.Actions.Paste
        this.Actions.Paste2
        this.Actions.Delete
        this.Actions.Activate
        this.Actions.AssociateSimulink
        this.Actions.UnAssociateSimulink
        this.Actions.MoveUp
        this.Actions.MoveDown
        this.Actions.MoveLeft
        this.Actions.MoveRight],...
        'Enabled','off');
    end




    function oo=locOnOff(tf)

        if tf
            oo='on';
        else
            oo='off';
        end
