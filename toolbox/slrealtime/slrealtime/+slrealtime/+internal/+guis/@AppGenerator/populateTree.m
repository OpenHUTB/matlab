function cancelled=populateTree(this)








    cancelled=false;



    if this.TreeFullyProcessed,return;end



    this.TreeProgressDlg=uiprogressdlg(...
    this.getUIFigure(),...
    'Message',this.TreeProgressDlgMsg_msg,...
    'Title',this.TreeProgressDlgTitle_msg,...
    'Cancelable',true);
    this.TreeNumLeafNodes=0;
    this.TreeTotalLeafNodes=this.SessionSource.NumSigsAndParams;
    if this.TreeTotalLeafNodes==-1
        this.TreeProgressDlg.Indeterminate='on';
    end



    this.populateNodeAndChildren(this.Tree);



    if~this.TreeProgressDlg.CancelRequested
        this.TreeFullyProcessed=true;
    else
        cancelled=true;
    end



    pause(0.5);
    delete(this.TreeProgressDlg);
    this.TreeProgressDlg=[];
end
