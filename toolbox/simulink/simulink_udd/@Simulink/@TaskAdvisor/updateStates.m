function updateStates(this,state,varargin)







    if strcmp(state,'refreshME')
        loc_refreshME(this);
        return
    end


    oldstate=this.State;
    this.State=state;

    if strcmp(this.State,'WaivedPass')
        this.InternalState=oldstate;
    end



    if~strcmp(state,oldstate)
        if strcmp(state,'Pass')||strcmp(state,'WaivedPass')
            for i=1:length(this.ReverseDependencyObj)
                if~this.ReverseDependencyObj{i}.Selected
                    canEnable=true;
                    for j=1:length(this.ReverseDependencyObj{i}.DependencyObj)
                        if~strcmp(this.ReverseDependencyObj{i}.DependencyObj{j}.State,'Pass')&&...
                            ~strcmp(this.ReverseDependencyObj{i}.DependencyObj{j}.State,'WaivedPass')
                            canEnable=false;
                            break
                        end
                    end
                    if canEnable
                        this.ReverseDependencyObj{i}.changeSelectionStatus(true);
                    end
                end
            end
        elseif strcmp(state,'Fail')
            for i=1:length(this.ReverseDependencyObj)
                this.ReverseDependencyObj{i}.changeSelectionStatus(false);
            end
        end
    end











    if isa(this.up,'Simulink.TaskAdvisor')&&~strcmp(this.up.ID,'SysRoot')

        ch=this.up.getChildren;
        active_children=find(ch,'-depth',0,'Selected',true);

        if~isempty(find(active_children,'-depth',0,'State','Fail'))

            parent_state='Fail';
        elseif~isempty(find(active_children,'-depth',0,'State','None'))

            parent_state='None';
        elseif~isempty(find(active_children,'-depth',0,'State','Pass'))||~isempty(find(active_children,'-depth',0,'State','WaivedPass'))

            parent_state='Pass';



        else

            parent_state='None';
        end

        this.up.updateStates(parent_state,varargin);
    else


        if nargin<=2
            loc_refreshME(this);
        end
    end


    function loc_refreshME(this)
        fptme_WF=this.MAObj.MAExplorer;


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',fptme_WF.getRoot);
        ed.broadcastEvent('PropertyChangedEvent',fptme_WF.getRoot);


        if~isempty(fptme_WF)
            if~isempty(fptme_WF.getDialog)
                fptme_WF.getDialog.refresh;
            end
        end
