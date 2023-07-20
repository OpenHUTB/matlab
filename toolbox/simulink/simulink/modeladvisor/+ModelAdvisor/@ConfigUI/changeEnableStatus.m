function success=changeEnableStatus(this,newstatus,varargin)





    if nargin<3
        needRefreshTree=true;
    else
        needRefreshTree=varargin{1};
    end



    if this.Visible&&~strcmp(this.Type,'Procedure')
        success=true;

        if strcmp(this.Type,'Group')
            for i=1:length(this.ChildrenObj)
                childsuccess=changeEnableStatus(this.ChildrenObj{i},newstatus,false);
                if~childsuccess
                    success=false;
                end
            end
        end
        this.Enable=newstatus;


        if needRefreshTree
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',this);

            this.updateStates('fastmode');
            modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',this.MAObj.ConfigUIWindow);
        end
    else
        success=false;
    end

