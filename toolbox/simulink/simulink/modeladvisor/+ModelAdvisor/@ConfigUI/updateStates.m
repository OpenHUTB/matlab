function updateStates(this,varargin)







    if nargin>1&&strcmp(varargin{1},'refreshME')
        this.refreshTree;
        return
    end

    if strcmp(this.Type,'Group')
        update_group_status(this);
    end


    if isa(this.ParentObj,'ModelAdvisor.ConfigUI')&&~strcmp(this.ParentObj.ID,'SysRoot')
        this.ParentObj.updateStates(varargin);
    else


        if nargin<=2
            this.refreshTree;
        end
    end

    function update_group_status(this)
        ch=this.getChildren;
        if~isempty(ch)
            InTriState=0;
            Selected=0;
            Deselected=0;
            for i=1:length(ch)
                if ch(i).Selected
                    Selected=Selected+1;
                else
                    Deselected=Deselected+1;
                end
                if ch(i).InTriState
                    InTriState=InTriState+1;
                end
            end

            if(Selected>0&&Deselected>0)||InTriState>0
                this.InTriState=true;
            else
                this.InTriState=false;
            end




            if Selected>0||InTriState>0
                newSelectStatus=true;
            else
                newSelectStatus=false;
            end
            if newSelectStatus~=this.Selected
                this.Selected=newSelectStatus;
            end
        end
