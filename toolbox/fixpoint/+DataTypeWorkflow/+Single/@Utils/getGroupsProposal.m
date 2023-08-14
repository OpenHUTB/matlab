function getGroupsProposal(resultsScope,groups)










    for index=1:numel(groups)


        isProposable=DataTypeWorkflow.Single.Utils.isGroupProposable(groups{index});

        if isProposable


            cellfun(@(x)(...
            DataTypeWorkflow.Single.Utils.getProposedDT(x,resultsScope,'single')),...
            groups{index}.getGroupMembers());

        else


            cellfun(@(x)(x.setProposedDT('n/a')),groups{index}.getGroupMembers());
        end
    end
end


