function tb=createtoolbar_edit(h,varargin)




    if(nargin>1)
        tb=varargin{1};
    else
        am=DAStudio.ActionManager;
        tb=am.createToolBar(h);
    end


    action=handle(h.actions('ADD_TASK'));
    tb.addAction(action);
    tb.addSeparator;


    action=handle(h.actions('ADD_PERIODIC_TRIGGER'));
    tb.addAction(action);
    tb.addSeparator;


    action=handle(h.actions('ADD_APERIODIC_TASKG'));
    tb.addAction(action);
    tb.addSeparator;


    action=handle(h.actions('ADD_MAPPED_TASK'));
    tb.addAction(action);
    tb.addSeparator;



    action=h.getaction('EDIT_DELETE');
    tb.addAction(action);
    tb.addSeparator;


