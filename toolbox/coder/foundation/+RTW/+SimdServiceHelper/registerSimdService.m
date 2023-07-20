function registerSimdService(aSimdService)


    api=aSimdService.API;
    RTW.SimdServiceHelper.internal.validateSimdApi(api);



    targetrepository.create().restore();


    aInstructionSet=aSimdService.For;
    aInstructionSet.Instructions=...
    RTW.SimdServiceHelper.internal.getInstructionsFromService(aSimdService);


    target.internal.add(aSimdService);

end