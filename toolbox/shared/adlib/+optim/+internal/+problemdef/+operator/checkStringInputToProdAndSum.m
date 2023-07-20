function thisDim=checkStringInputToProdAndSum(stringInput)








    invalidNaNFlagStrings=["includenan","omitnan"];
    invalidTypeStrings=["default","double","native"];
    stringsToMatchTo=["all",invalidNaNFlagStrings,invalidTypeStrings];
    thisDim=validatestring(stringInput,stringsToMatchTo);
    if any(strcmp(thisDim,invalidNaNFlagStrings))
        throwAsCaller(MException(message('shared_adlib:operators:ProdSumNaNFlagNotSupported')));
    end
    if any(strcmp(thisDim,invalidTypeStrings))
        throwAsCaller(MException(message('shared_adlib:operators:ProdSumTypeNotSupported')));
    end
