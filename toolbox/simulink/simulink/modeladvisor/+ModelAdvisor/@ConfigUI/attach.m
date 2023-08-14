function success=attach(this,ParentObj,position)




    success=false;


    newChildrenObj={};
    j=0;
    for i=1:length(ParentObj.ChildrenObj)+1
        if i~=position
            j=j+1;
            newChildrenObj{end+1}=ParentObj.ChildrenObj{j};%#ok<AGROW>        
        else
            newChildrenObj{end+1}=this;%#ok<AGROW>
        end

        if j>0&&strcmp(ParentObj.ChildrenObj{j}.DisplayName,this.DisplayName)
            success=false;
            return
        end
    end
    ParentObj.ChildrenObj=newChildrenObj;


    ParentObj.addChildren(this);
    this.ParentObj=ParentObj;
    this.MAObj=ParentObj.MAObj;
    updateID(this,true,true);
    this.updateStates('fastmode');
    success=true;





















