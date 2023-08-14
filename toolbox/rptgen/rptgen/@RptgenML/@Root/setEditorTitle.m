function setEditorTitle(this,input)





    if~isa(this.Editor,'DAStudio.Explorer')
        return;
    end

    if(nargin<2)
        currTree=this.getCurrentTreeNode;
        input=this.getCurrentDoc(currTree);
    end

    if isa(input,'rptgen.DAObject')
        eTitle=[getString(message('rptgen:RptgenML_Root:ReportExplorerLabel')),' - ',getDisplayLabel(input)];

    elseif ischar(input)
        eTitle=input;

    else
        eTitle=getString(message('rptgen:RptgenML_Root:ReportExplorerLabel'));
    end

    this.Editor.Title=eTitle;
