function refreshExclusions(this,varargin)

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if(strcmp(edittime.getAdvisorChecking(this.model),'on')||...
        cp.isInPerspective(this.model))
        edittime.setAdvisorChecking(this.model,'off');
        edittime.setAdvisorChecking(this.model,'on');

    end
end