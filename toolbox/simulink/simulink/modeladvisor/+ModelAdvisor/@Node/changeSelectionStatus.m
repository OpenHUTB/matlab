function success=changeSelectionStatus(this,newstatus,varargin)






    if nargin<3
        needRefreshTree=true;
    else
        needRefreshTree=varargin{1};
    end


    if this.Visible&&isa(this,'ModelAdvisor.Procedure')&&isa(this.getParent,'ModelAdvisor.Group')...
        &&~isa(this.getParent,'ModelAdvisor.Procedure')&&~isempty(this.getParent.getParent)
        success=true;
        this.Selected=newstatus;

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',this);
        this.updateStates(this.State,'fastmode');
        return
    end



    if this.Visible&&this.Enable&&~isa(this,'ModelAdvisor.Procedure')
        success=true;

        if isa(this,'ModelAdvisor.Task')
            if this.ByTaskMode
                this.MAObj.updateCheckForTask(this.MACIndex,newstatus,this.Check);
            else
                this.MAObj.updateCheck(this.MACIndex,newstatus,this.Check);
            end
        elseif isa(this,'ModelAdvisor.FactoryGroup')
            this.MAObj.updateTask(this.MATIndex,newstatus);
        end

        if isa(this,'ModelAdvisor.Group')
            for i=1:length(this.ChildrenObj)
                childsuccess=changeSelectionStatus(this.ChildrenObj{i},newstatus,false);
                if~childsuccess
                    success=false;
                end
            end
        end
        this.Selected=newstatus;


        if isa(this,'ModelAdvisor.Group')
            ch=this.getChildren;
            if~isempty(ch)







                this.InTriState=IsInTriSate(ch);




                for i=1:length(ch)
                    if ch(i).Selected
                        this.Selected=true;
                        break;
                    end
                end


                ch(1).updateStates(ch(1).State,'fastmode');
            end
        end








        if needRefreshTree
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',this);
            this.updateStates(this.State,'fastmode');
        end
    else
        success=false;
    end

    function InTriState=IsInTriSate(objects)
        InTriState=false;
        SelectedFound=false;
        DeSelectedFound=false;
        for index=1:length(objects)
            if objects(index).InTriState
                InTriState=true;
                break
            else
                if objects(index).Selected
                    SelectedFound=true;
                else
                    DeSelectedFound=true;
                end
            end
            if SelectedFound&&DeSelectedFound
                InTriState=true;
                break
            end
        end
