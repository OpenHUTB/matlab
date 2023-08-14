function validate2NPortParameters(newParams,objclass)

    rf.internal.netparams.validateNPortParameters(newParams,objclass)

    if rem(size(newParams,1),2)~=0

        error(message('rf:abcdparameters:validatenewparams:MustBe2Nby2NbyK',objclass))
    end