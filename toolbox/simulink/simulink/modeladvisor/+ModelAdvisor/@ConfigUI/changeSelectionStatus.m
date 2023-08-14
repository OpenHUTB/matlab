function success=changeSelectionStatus(this,newstatus,varargin)






    if nargin<3
        needRefreshTree=true;
    else
        needRefreshTree=varargin{1};
    end



    needIgnoreVisibleStatusForEditTimeView=false;
    if isa(this.MAObj,'Simulink.ModelAdvisor')&&isfield(this.MAObj.Toolbar,'viewComboBoxWidget')&&isa(this.MAObj.Toolbar.viewComboBoxWidget,'DAStudio.ToolBarComboBox')
        if strcmp(this.MAObj.Toolbar.viewComboBoxWidget.getCurrentText,DAStudio.message('ModelAdvisor:engine:EdittimeView'))
            needIgnoreVisibleStatusForEditTimeView=true;
        end
    end



    if(this.Visible||needIgnoreVisibleStatusForEditTimeView)&&this.Enable&&~strcmp(this.Type,'Procedure')
        success=true;

        if strcmp(this.Type,'Group')
            for i=1:length(this.ChildrenObj)
                childsuccess=changeSelectionStatus(this.ChildrenObj{i},newstatus,false);
                if~childsuccess
                    success=false;
                end
            end
        end
        this.Selected=newstatus;


        if strcmp(this.Type,'Group')
            ch=this.getChildren;
            if~isempty(ch)
                if(~isempty(findobj(ch,'-depth',0,'Selected',true))&&...
                    ~isempty(findobj(ch,'-depth',0,'Selected',false)))||...
                    ~isempty(findobj(ch,'-depth',0,'InTriState',true))
                    this.InTriState=true;
                else
                    this.InTriState=false;
                end




                for i=1:length(ch)
                    if ch(i).Selected
                        this.Selected=true;
                        break;
                    end
                end
            end
        end


        if needRefreshTree
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',this);

            this.updateStates('fastmode');
        end
    else
        success=false;
    end

