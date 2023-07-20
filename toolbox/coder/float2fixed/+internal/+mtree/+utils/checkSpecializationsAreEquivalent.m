function msgs=checkSpecializationsAreEquivalent(fcnInfoRegistry,exprMap)

    msgs=internal.mtree.Message.empty;

    equivalentMap=containers.Map;
    nonEquivalentMap=containers.Map;

    functionIDs=fcnInfoRegistry.registry.keys;

    for ii=1:numel(functionIDs)
        fcnTypeInfo=fcnInfoRegistry.registry(functionIDs{ii});


        callsites=fcnTypeInfo.callSites;
        for jj=1:numel(callsites)
            csNode=callsites{jj}{1};
            allCalledFcns=fcnTypeInfo.treeAttributes(csNode).AllCalledFunctions;



            for kk=2:numel(allCalledFcns)
                if~isEquivalent(allCalledFcns(1),allCalledFcns(kk))
                    msgs(end+1)=internal.mtree.Message(...
                    fcnTypeInfo,...
                    csNode,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:NonEquivFcnSpecsCalledAtSamePlace',...
                    csNode.tree2str,...
                    allCalledFcns(1).functionName);%#ok<AGROW>



                    break;
                end
            end
        end
    end

    function isit=isEquivalent(fcnInfo1,fcnInfo2)
        fcnID1=fcnInfo1.uniqueId;
        fcnID2=fcnInfo2.uniqueId;

        assert(exprMap.isKey(fcnID1)&&exprMap.isKey(fcnID2));

        [isInMaps,isit]=checkEquivalenceMaps(fcnID1,fcnID2);

        if~isInMaps
            isit=checkEquivalence(exprMap(fcnID1),exprMap(fcnID2));


            if isit
                mapToUpdate=equivalentMap;
            else
                mapToUpdate=nonEquivalentMap;
            end

            updateMap(mapToUpdate,fcnID1,fcnID2);
            updateMap(mapToUpdate,fcnID2,fcnID1);
        end
    end

    function[isInMaps,isit]=checkEquivalenceMaps(fcnID1,fcnID2)
        isInMaps=false;
        isit=false;

        if equivalentMap.isKey(fcnID1)&&ismember(fcnID2,equivalentMap(fcnID1))
            isInMaps=true;
            isit=true;
        elseif nonEquivalentMap.isKey(fcnID1)&&ismember(fcnID2,nonEquivalentMap(fcnID1))
            isInMaps=true;
            isit=false;
        end
    end
end

function isit=checkEquivalence(exprMap1,exprMap2)
    isit=true;



    if~isequal(exprMap1.keys,exprMap2.keys)
        isit=false;
    else
        locs=exprMap1.keys;

        for i=1:numel(locs)
            type1=exprMap1(locs{i});
            type2=exprMap2(locs{i});

            if type1.MxInfoID~=type2.MxInfoID
                isit=false;
                break;
            end
        end
    end
end

function updateMap(map,fcnIDA,fcnIDB)
    if map.isKey(fcnIDA)
        fcnIDsBefore=map(fcnIDA);
        map(fcnIDA)=[fcnIDsBefore,{fcnIDB}];%#ok<NASGU>
    else
        map(fcnIDA)={fcnIDB};%#ok<NASGU>
    end
end
