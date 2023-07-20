function validateTwoPortParameters(newParams,objclass)

    rf.internal.netparams.validateNPortParameters(newParams,objclass)

    if size(newParams,1)~=2

        error(message('rf:shared:ValidateTwoPortNumPortsNotTwo',objclass))
    end