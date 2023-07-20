function childObj=viewChild(this,childObj)




    if nargin<2
        childObj=this;
    end


    if~ischar(childObj)&&strcmpi(class(childObj),'double')
        try
            [rptName,ok]=rptgen.findSlRptName(childObj);
            if ok
                childObj=rptName;
            else
                childObj=[];
            end
        catch
            childObj=[];
        end
    end

    if ischar(childObj)

        childObj=this.findRptByName(childObj,true);
    end


    e=this.getEditor;

    if isempty(childObj)

    elseif isa(childObj,'RptgenML.LibraryRpt')
        e.view(this);
        ime=DAStudio.imExplorer(e);
        ime.selectTreeViewNode(this);
        ime.selectListViewNode(childObj);
    else
        e.view(childObj);
    end
