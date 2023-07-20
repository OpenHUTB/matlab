function[itemnames,fullnames]=constructItemNames(~,cursig,hidebusroot)
















    itemnames={};
    fullnames={};
    for ct=1:numel(cursig)
        str=cursig{ct}.Name;
        if strcmp(class(cursig{ct}),'Simulink.sigselector.BusItem')





            hier=cursig{ct}.Hierarchy;

            if~hidebusroot
                itemnames{end+1}=str;
                fullnames{end+1}=str;

                [namesinbus,fullnamesinbus]=LocalGetBusItemNames({},{},{str},hier.Children);

                itemnames=[itemnames,namesinbus];
                fullnames=[fullnames,fullnamesinbus];
            else

                [itemnames,fullnames]=LocalGetBusItemNames({},{},{},hier);
            end
        else

            itemnames{end+1}=str;
            fullnames{end+1}=str;
        end
    end
end

function[itemnames,fullnames]=LocalGetBusItemNames(itemnames,fullnames,curloc,bushier)
    for ct=1:numel(bushier)
        str=bushier(ct).SignalName;

        itemnames{end+1}=str;
        if isempty(curloc)
            fullnames{end+1}=str;
        else
            fullnames{end+1}=[LocalFlatCurrentLocation(curloc),'.',str];
        end
        if~isempty(bushier(ct).Children)

            curloc{end+1}=str;

            [itemnames,fullnames]=LocalGetBusItemNames(itemnames,fullnames,curloc,bushier(ct).Children);

            curloc(end)=[];
        end
    end
end





function str=LocalFlatCurrentLocation(curloc)
    str=curloc{1};
    for ct=2:numel(curloc)
        str=[str,'.',curloc{ct}];
    end
end



