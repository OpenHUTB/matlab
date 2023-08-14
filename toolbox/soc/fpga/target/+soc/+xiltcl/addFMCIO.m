function addFMCIO(fid,hbuild)
    if~isempty(hbuild.FMCIO)

        for nn=1:numel(hbuild.FMCIO)
            fprintf(fid,hbuild.FMCIO{nn}.Instance);
        end
    end
end