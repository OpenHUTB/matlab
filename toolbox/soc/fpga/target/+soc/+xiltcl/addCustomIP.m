function addCustomIP(fid,hbuild)
    if~isempty(hbuild.CustomIP)

        for nn=1:numel(hbuild.CustomIP)
            fprintf(fid,hbuild.CustomIP{nn}.Instance);
        end
    end
end