function[stylerId,triggeredStylerId]=getHiliteStyler(this,mdlName,type)


    assert(nargin==2||nargin==3,'getHiliteStyler must have 2-3 arguments');
    if nargin==3&&isequal(type,'task')
        isTaskHighlighting=true;
    else
        isTaskHighlighting=false;
    end

    mdlHandle=num2str(get_param(mdlName,'Handle'),'%.15f');
    stylerId=['TimingHilite',mdlHandle];
    triggeredStylerId=['TriggeredTimingHilite',mdlHandle];

    if(isTaskHighlighting)
        stylerId=['Task',stylerId];
    end
