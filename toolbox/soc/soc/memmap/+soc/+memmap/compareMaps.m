function[areCompatible,areEqual]=compareMaps(map1,map2)


    if(isempty(map1)||isempty(map2))...
        ||(isempty(map1.controllerInfo)||isempty(map2.controllerInfo))...
        ||(length(map1.map)~=length(map2.map))...
        ||(~isequal(map1.controllerInfo,map2.controllerInfo))...
        ||(map1.isFixedMemMap~=map2.isFixedMemMap)
        areCompatible=false;
        areEqual=false;
    else
        numEntries=length(map1.map);
        eCheck=zeros([numEntries,2],'logical');
        for ii=1:numEntries
            mentry1=map1.map(ii);
            mentry2=findobj(map2.map,'name',mentry1.name);
            if isempty(mentry2)
                eCheck(ii,1)=false;
                eCheck(ii,2)=false;
                break;
            else
                [eCheck(ii,1),eCheck(ii,2)]=mentry1.compare(mentry2);
            end
        end
        areCompatible=all(eCheck(:,1));
        areEqual=all(eCheck(:,2));
    end

end
