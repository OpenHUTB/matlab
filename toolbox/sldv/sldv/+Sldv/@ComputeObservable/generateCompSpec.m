





function composeSpec=generateCompSpec(obj)
    composeSpec=struct([]);


    oc=init();%#ok<NASGU>

    for idx=1:length(obj.CovDependency)
        thisComposeSpec=obj.generateModelCompSpec(idx);
        if isempty(thisComposeSpec)


            continue;
        else
            if isempty(composeSpec)
                composeSpec=thisComposeSpec;
            else
                composeSpec.stmt=[composeSpec.stmt,thisComposeSpec.stmt];
            end
        end
    end



    if isempty(composeSpec)
        return;
    end


    obj.generateNetworkInfo;

    composeSpec.Networks=obj.Networks;



    for i=1:length(composeSpec.stmt)
        composeSpec.stmt(i).NetworkId=1;
    end



    composeSpec.stmt=compressComposeSpec(composeSpec.stmt);

end

function oc=init()

    Sldv.ComputeObservable.logDebugEvt("ComputeObservable","generateCompSpec","Start");


    initialVal=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);

    oc=onCleanup(@()cleanSetUp());

    function cleanSetUp()
        slfeature('EngineInterface',initialVal);

        Sldv.ComputeObservable.logDebugEvt("ComputeObservable","generateCompSpec","End");
    end
end

function netId=getNetworkId(Networks,searchID)
    netId=0;
    for i=1:length(Networks)
        if~isempty(find(strcmp(Networks{i},searchID),1))
            netId=i;
            break;
        end
    end
end

function stmt=compressComposeSpec(initStmts)
    stmt=[];

    for i=1:length(initStmts)
        if(initStmts(i).NetworkId~=0)
            if isempty(stmt)
                stmt=initStmts(i);
            else
                stmt(end+1)=initStmts(i);%#ok<AGROW>
            end
        end
    end
end
