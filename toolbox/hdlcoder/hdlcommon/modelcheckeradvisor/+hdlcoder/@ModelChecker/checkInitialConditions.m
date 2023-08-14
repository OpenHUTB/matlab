function flag=checkInitialConditions(this)




    flag=true;

    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,'RegExp','On','Type','Block','InitialCondition','.');
    if~isempty(blocks)
        initialCond=str2double(get_param(blocks,'InitialCondition'));
        [~,idx]=find(initialCond);
        flag=~any(idx);
        this.addCheckForEach(blocks(idx),'warning','Initial condition should be zero',0);
    end
end