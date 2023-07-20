function addPostTcl(fid,hbuild)
    if~isempty(hbuild.PS7)

        fprintf(fid,hbuild.PS7.InstancePost);
    end
    if~isempty(hbuild.FMCIO)

        for nn=numel(hbuild.FMCIO)
            fprintf(fid,hbuild.FMCIO{nn}.InstancePost);
        end
    end
end