function insertDescCommentsForComp(~,hC)
    shandle=hC.SimulinkHandle;
    if shandle~=-1
        hC.addComment(get_param(shandle,'Description'));
    end
end