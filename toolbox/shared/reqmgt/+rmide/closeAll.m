function result=closeAll(isForce)




    if nargin<1
        isForce=false;
    end

    result={};

    if slreq.data.ReqData.exists()
        linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
        isDD=strcmp({linkSets.domain},'linktype_rmi_data');
        ddSets=linkSets(isDD);
        for i=1:numel(ddSets)
            result{end+1}=ddSets(i).artifact;%#ok<AGROW>
            if ddSets(i).dirty
                rmide.close(ddSets(i).artifact,isForce);
            end
        end
    end
end

