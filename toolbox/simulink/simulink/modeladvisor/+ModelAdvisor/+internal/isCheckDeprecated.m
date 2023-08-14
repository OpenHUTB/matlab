function[bResult,newCheckIds,typeOfCheck]=isCheckDeprecated(checkID)

    bResult=false;
    newCheckIds={};
    typeOfCheck='';

    persistent deprecationMap;
    if isempty(deprecationMap)
        deprecationMap=containers.Map('KeyType','char','ValueType','any');

        deprecationMap('mathworks.do178.LogicBlockUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0016',...
        'mathworks.hism.hisl_0017',...
        'mathworks.hism.hisl_0018'});

        deprecationMap('mathworks.do178.MathOperationsBlocksUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0001',...
        'mathworks.hism.hisl_0002',...
        'mathworks.hism.hisl_0004',...
        'mathworks.hism.hisl_0029'});

        deprecationMap('mathworks.do178.PortsSubsystemsUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0006',...
        'mathworks.hism.hisl_0008',...
        'mathworks.hism.hisl_0010',...
        'mathworks.hism.hisl_0011'});

        deprecationMap('mathworks.iec61508.LogicBlockUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0016',...
        'mathworks.hism.hisl_0017',...
        'mathworks.hism.hisl_0018'});

        deprecationMap('mathworks.iec61508.MathOperationsBlocksUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0001',...
        'mathworks.hism.hisl_0002',...
        'mathworks.hism.hisl_0004',...
        'mathworks.hism.hisl_0029'});

        deprecationMap('mathworks.iec61508.PortsSubsystemsUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0006',...
        'mathworks.hism.hisl_0008',...
        'mathworks.hism.hisl_0010',...
        'mathworks.hism.hisl_0011'});

        deprecationMap('mathworks.do178.CodeSet')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0038',...
        'mathworks.hism.hisl_0039',...
        'mathworks.hism.hisl_0047',...
        'mathworks.hism.hisl_0049'});


        deprecationMap('mathworks.do178.OptionSet')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0045',...
        'mathworks.hism.hisl_0046',...
        'mathworks.hism.hisl_0048',...
        'mathworks.hism.hisl_0052',...
        'mathworks.hism.hisl_0053',...
        'mathworks.hism.hisl_0054'});


        deprecationMap('mathworks.iec61508.StateflowProperUsage')=struct('type','highintegrity','newids',{'mathworks.hism.hisf_0002',...
        'mathworks.hism.hisf_0009',...
        'mathworks.hism.hisf_0011',...
        'mathworks.hism.hisl_0061'});

        deprecationMap('mathworks.maab.db_0151')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jc_0111')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jc_0221')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jc_0521')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jm_0001')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0005')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jm_0010')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0013')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0027')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0030')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0032')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0038')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.na_0040')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.jc_0491')=struct('type','maab','newids',[]);
        deprecationMap('mathworks.maab.db_0081')=struct('type','maab','newids',{'mathworks.jmaab.db_0081'});

        deprecationMap('mathworks.hism.hisl_0002')=struct('type','highintegrity','newids',[]);
        deprecationMap('mathworks.hism.hisl_0004')=struct('type','highintegrity','newids',[]);
        deprecationMap('mathworks.maab.himl_0003')=struct('type','maab','newids',{'mathworks.maab.na_0016','mathworks.maab.na_0018'});
        deprecationMap('mathworks.hism.himl_0009')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0016'});
        deprecationMap('mathworks.hism.hisf_0064')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0073'});
        deprecationMap('mathworks.hism.hisf_0003')=struct('type','highintegrity','newids',{'mathworks.hism.hisl_0019'});
        deprecationMap('mathworks.hism.hisf_0009')=struct('type','highintegrity','newids',[]);
        deprecationMap('mathworks.jmaab.db_0122')=struct('type','jmaab','newids',[]);

    end


    if deprecationMap.isKey(checkID)
        bResult=true;
        val=deprecationMap(checkID);
        newCheckIds=val.newids;
        typeOfCheck=val.type;
    end

end