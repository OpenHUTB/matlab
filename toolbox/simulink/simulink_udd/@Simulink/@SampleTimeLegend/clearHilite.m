function clearHilite(this,mdlName,type)


    assert(nargin==2||nargin==3,'clearHilite must have 2-3 arguments');
    if nargin==3&&isequal(type,'task')
        isTaskHighlighting=true;
    else
        isTaskHighlighting=false;
    end


    if(bdIsLoaded(mdlName))

        tab_cont=find(strcmp(mdlName,this.modelList),1);
        if(~isempty(tab_cont))
            this.modelLegendHighlightState{tab_cont}=[-1000,-1000,-1000];
        end


        if(isTaskHighlighting)
            [stylerId,StylerNameTrigger]=this.getHiliteStyler(mdlName,'task');
            set_param(mdlName,'TaskBasedExecutionOrderTaskID',-100);
        else
            [stylerId,StylerNameTrigger]=this.getHiliteStyler(mdlName);
        end

        StylerName=char(stylerId);

        styler=diagram.style.getStyler(StylerName);
        stylerTrigger=diagram.style.getStyler(StylerNameTrigger);
        if~isempty(styler)
            styler.clearAllClasses();
            styler.destroy;
        end
        if~isempty(stylerTrigger)
            stylerTrigger.clearAllClasses();
            stylerTrigger.destroy;
        end

        if(bdIsLoaded(mdlName))
            set_param(mdlName,'HiliteAncestors','off');
        end

    end

