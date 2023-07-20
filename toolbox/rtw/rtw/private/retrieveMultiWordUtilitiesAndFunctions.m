function isMultiword=retrieveMultiWordUtilitiesAndFunctions(scmFile,rtwCtx,fcn)



    persistent map

    if isempty(fcn)
        map=[];
        isMultiword=true;
    else
        if isempty(map)
            result=[];
            map=containers.Map('KeyType','char','ValueType','logical');
            try
                sfInterface=SharedCodeManager.SharedCodeManagerInterface(scmFile);
                ident=SharedCodeManager.GenericIdentity('SCM_OTHER','MultiWordUtilitiesOnly');


                rtwprivate('rtwcgtlc','FinalizeUtilities',rtwCtx)
                object=sfInterface.retrieveData(ident);
                if isa(object,'SharedCodeManager.MultiWordFcnData')
                    result=object.MultiWordFunctions;
                end
            catch
            end
            if~isempty(result)
                for i=1:numel(result)
                    map(result{i})=true;
                end
            end
        end
        isMultiword=map.isKey(fcn);
    end
end
