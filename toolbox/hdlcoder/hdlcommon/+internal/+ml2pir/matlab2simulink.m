function[mdlName,subsys,messages,constrainerSuccess]=matlab2simulink(report,mdlName,simgenCfg)






    subsys='';

    [fcnInfoRegistry,exprMap,designNames,createFcnInfoMsgs]=...
    internal.mtree.createFunctionInfoRegistry(report);

    if internal.mtree.Message.containErrorMsgs(createFcnInfoMsgs)
        messages=createFcnInfoMsgs;
        constrainerSuccess=false;
        return;
    end



    designFcnIds=designNames;


    fcnInfos=fcnInfoRegistry.getAllFunctionTypeInfos();
    fcnInfos=[fcnInfos{:}];
    if simgenCfg.EnableConstrainer
        constrainerMsgs=cell(1,numel(fcnInfos));
        for ii=1:numel(fcnInfos)
            slConstrainer=internal.ml2pir.constrainer.SimulinkConstrainer(fcnInfos(ii),...
            exprMap,fcnInfoRegistry,simgenCfg);
            constrainerMsgs{ii}=slConstrainer.run;
        end
        constrainerMsgs=[constrainerMsgs{:}];

        constrainerSuccess=~internal.mtree.Message.containErrorMsgs(constrainerMsgs);
    else
        constrainerSuccess=true;
        constrainerMsgs=internal.mtree.Message.empty;
    end

    messages=[createFcnInfoMsgs,constrainerMsgs];

    if~constrainerSuccess
        return;
    end

    conversionSettings=internal.ml2pir.Function2SubsystemConverter.getConversionSettings();

    if nargin==1||isempty(mdlName)
        mdlName=internal.ml2pir.SimGenConfig.buildOutputModelName(designNames{1});
    end

    conversionSettings.SimGenMode=simgenCfg.getSimGenMode;

    bdclose(mdlName);
    builder=internal.ml2pir.SimulinkGraphBuilder(mdlName);


    internal.mtree.Type.setIntegersSaturateOnOverflow(simgenCfg.SaturateOnIntegerOverflow);

    for ii=1:numel(designFcnIds)
        fcnTypeInfo=fcnInfoRegistry.getFunctionTypeInfo(designFcnIds{ii});

        fcn2Sim=internal.ml2pir.Function2SubsystemConverter(...
        fcnInfoRegistry,exprMap,fcnTypeInfo,builder,conversionSettings);
        fcn2Sim.PrintMessages=true;
        fcn2Sim.Debug=simgenCfg.Debug;

        subsys=fcn2Sim.run(fcnTypeInfo.functionName);
    end
end


