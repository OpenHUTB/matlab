function activity(h)




    if~isempty(h.testComp)&&~h.closed
        h.browserparam1(2)=h.testComp.getGoalCount('DV_GOAL_TOTAL');
        h.progressHTML;
    end
