function[myOrder,baseOrder,theirOrder]=threeWayMatchClones(positionsInMyModel,...
    matchingExpressionsFromMyModel,...
    positionsInBaseModel,...
    expressionsInBaseModel,...
    positionsInTheirModel,...
    matchingExpressionsFromTheirModel)



































    [myOrder,baseOrder]=matchClonesHelper(positionsInMyModel,...
    matchingExpressionsFromMyModel,...
    positionsInBaseModel,...
    expressionsInBaseModel);
    [baseOrderToTheirOrder,theirOrder]=matchClonesHelper(positionsInBaseModel,...
    expressionsInBaseModel,...
    positionsInTheirModel,...
    matchingExpressionsFromTheirModel);





    [~,reorderIdx]=ismember(baseOrder,baseOrderToTheirOrder);
    theirOrder=theirOrder(reorderIdx);

end