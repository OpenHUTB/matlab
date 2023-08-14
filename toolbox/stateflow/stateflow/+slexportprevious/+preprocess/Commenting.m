function Commenting(obj)

    machine=getStateflowMachine(obj);

    if isempty(machine)
        return;
    end

    if isR2014aOrEarlier(obj.ver)

        charts=sf('ChartsOf',machine.Id);









        for chart=charts(:)'
            states=sf('AllSubstatesIn',chart);

            commentedStates=sf('find',states,'state.comment.xplicit',true);




            if(~isempty(commentedStates))
                sf('UpdateCommentedStatus',commentedStates,false);
            end
        end

        obj.appendRule('<state<comment:remove>>');
        obj.appendRule('<transition<comment:remove>>');
        obj.appendRule('<junction<comment:remove>>');
    end

end
