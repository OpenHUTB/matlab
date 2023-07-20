




function activeBlks=i_pruneOutInvalidBlks(activeBlks)



    for ii=numel(activeBlks):-1:1
        try
            get_param(activeBlks{ii},'Handle');
        catch



            activeBlks(ii)=[];
        end
    end
end


