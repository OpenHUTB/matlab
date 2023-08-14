function[styleClass,triggeredStyleClass]=getHiliteStyleClass(this,mdlName,rateName)


    [stylerId,~]=this.getHiliteStyler(mdlName);

    if iscell(rateName)
        rateName=rateName{1};
    end

    rateStr=[stylerId,'_',rateName];
    styleClass=['stylefun_',rateStr];
    triggeredStyleClass=['trigger_stylefun_',rateStr];
