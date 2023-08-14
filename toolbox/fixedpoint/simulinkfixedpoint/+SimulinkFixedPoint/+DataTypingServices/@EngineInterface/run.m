function run(~,context)










    switch context.action
    case SimulinkFixedPoint.DataTypingServices.EngineActions.Collect

        collectionObj=SimulinkFixedPoint.DataTypingServices.Collection(...
        context.topModel,...
        context.topModelModelReferences,...
        context.proposalSettings,...
        context.simIn);
        collectionObj.execute();

    case SimulinkFixedPoint.DataTypingServices.EngineActions.Propose







        collectionObj=SimulinkFixedPoint.DataTypingServices.Collection(...
        context.topModel,...
        context.topModelModelReferences,...
        context.proposalSettings,...
        context.simIn);
        collectionObj.execute();


        proposalObj=SimulinkFixedPoint.DataTypingServices.GroupProposal(...
        context.systemUnderDesign,...
        context.systemUnderDesignModelReferences,...
        context.proposalSettings);
        proposalObj.execute();

    case SimulinkFixedPoint.DataTypingServices.EngineActions.ConditionalProposal

        collectionObj=SimulinkFixedPoint.DataTypingServices.ConditionalCollection(...
        context.topModel,...
        context.topModelModelReferences,...
        context.proposalSettings);
        collectionObj.execute();


        proposalObj=SimulinkFixedPoint.DataTypingServices.GroupProposal(...
        context.systemUnderDesign,...
        context.systemUnderDesignModelReferences,...
        context.proposalSettings);
        proposalObj.execute();

    case SimulinkFixedPoint.DataTypingServices.EngineActions.Apply


        applicationObj=SimulinkFixedPoint.DataTypingServices.Application(...
        context.systemUnderDesign,...
        context.systemUnderDesignModelReferences,...
        context.proposalSettings);
        applicationObj.execute();
    end
end