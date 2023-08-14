function hNIC=matlab2pir(fcnInfoRegistry,exprMap,designNames,nicName,intsSaturate,builderFuncHandle,varargin)





    [options,builderArgs]=parseInputs(varargin{:});

    assert(numel(designNames)==1);
    fcnName=designNames{1};
    builder=builderFuncHandle(builderArgs{:});

    fcnTypeInfo=fcnInfoRegistry.getFunctionTypeInfo(fcnName);


    internal.mtree.Type.setIntegersSaturateOnOverflow(intsSaturate);

    fcn2pir=internal.ml2pir.Function2SubsystemConverter(...
    fcnInfoRegistry,exprMap,fcnTypeInfo,builder);


    hNIC=fcn2pir.run(nicName);



    if options.MapPersistentVarsToRAM
        hN=hNIC.ReferenceNetwork;
        persistentVarComps=fcn2pir.getPersistentNodes;
        if~isempty(persistentVarComps)&&~hN.isInResettableHierarchy


            hN.doML2PIRRamMapping(persistentVarComps,options.RAMMappingThreshold);
        end
    end
end

function[options,builderArgs]=parseInputs(varargin)

    persistent p;
    if isempty(p)
        p=inputParser;
        p.KeepUnmatched=true;
        p.addParameter('MapPersistentVarsToRAM',false,@islogical);
        p.addParameter('RAMMappingThreshold',Inf,@isnumeric);
    end

    p.parse(varargin{:});

    options=p.Results;
    builderArgs=namedargs2cell(p.Unmatched);

    if options.MapPersistentVarsToRAM&&isinf(options.RAMMappingThreshold)&&...
        options.RAMMappingThreshold>0
        options.MapPersistentVarsToRAM=false;
    end
end
