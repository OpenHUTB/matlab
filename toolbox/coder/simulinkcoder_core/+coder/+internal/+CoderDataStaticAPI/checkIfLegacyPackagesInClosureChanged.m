function cdefSourcesNeedingUpdate=checkIfLegacyPackagesInClosureChanged(sourceDD)




    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    cdefSourcesNeedingUpdate={};


    cdef=hlp.openDD(sourceDD);
    container=cdef.owner;
    if container.isEmpty()
        return;
    end
    if strcmp(container.context,'model')
        containers=coderdictionary.data.SlCoderDataClient.getEmbeddedCoderDictionariesInModelClosure(hex2num(container.ID));
    else
        containers=container;
    end


    j=1;
    for i=1:length(containers)
        if strcmp(containers(i).context,'model')
            if checkIfLegacyPackagesChanged(hex2num(containers(i).ID))
                cdefSourcesNeedingUpdate{j}=hex2num(containers(i).ID);%#ok<AGROW>
                j=j+1;
            end
        elseif strcmp(containers(i).context,'dictionary')
            [~,~,fExt]=fileparts(containers(i).ID);

            if strcmp(fExt,'.sldd')
                if checkIfLegacyPackagesChanged(containers(i).ID)
                    cdefSourcesNeedingUpdate{j}=containers(i).ID;%#ok<AGROW>
                    j=j+1;
                end
            end
        elseif strcmp(containers(i).context,'none')||strcmp(containers(i).context,'shipping_dictionary')

            continue;
        else
            assert(false,'Incorrectly configured coder dictionary');
        end
    end
end


