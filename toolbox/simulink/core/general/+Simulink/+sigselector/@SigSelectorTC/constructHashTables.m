function[parenthash,childrenhash]=constructHashTables(~,sigs)











    parenthash={};
    childrenhash={};
    for ct=1:numel(sigs)
        if strcmp(class(sigs{ct}),'Simulink.sigselector.SignalItem')

            thisid=sigs{ct}.TreeID;
            parenthash{thisid}=thisid;
            childrenhash{thisid}=thisid;
        else

            hier=sigs{ct}.Hierarchy;

            for ctc=1:numel(hier)

                thisid=hier(ctc).TreeID;

                parenthash{thisid}=thisid;

                parenthash=LocalConstructParentHashForBus(parenthash,hier(ctc).Children,hier(ctc).TreeID);

                childrenhash{thisid}=thisid;
                childrenhash=LocalConstructChildrenHasForBus(childrenhash,hier(ctc));
            end
        end
    end

end

function childrenhash=LocalConstructChildrenHasForBus(childrenhash,hier)
    for ct=1:numel(hier.Children)

        thisid=hier.Children(ct).TreeID;
        childrenhash{thisid}=thisid;

        childrenhash=LocalConstructChildrenHasForBus(childrenhash,hier.Children(ct));

        childrenhash{hier.TreeID}=[childrenhash{hier.TreeID},childrenhash{thisid}];
    end

end






function parenthash=LocalConstructParentHashForBus(parenthash,hier,parentids)
    for ct=1:numel(hier)

        parenthash{hier(ct).TreeID}=[parentids,hier(ct).TreeID];

        if~isempty(hier(ct).Children)
            parenthash=LocalConstructParentHashForBus(parenthash,hier(ct).Children,[parentids,hier(ct).TreeID]);
        end
    end
end




