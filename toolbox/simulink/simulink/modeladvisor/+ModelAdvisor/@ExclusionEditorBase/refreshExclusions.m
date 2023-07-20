function refreshExclusions(this,varargin)



    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if(strcmp(edittime.getAdvisorChecking(this.fModelName),'on')||...
        cp.isInPerspective(this.fModelName))
        edittime.setAdvisorChecking(this.fModelName,'off');
        edittime.setAdvisorChecking(this.fModelName,'on');
    end