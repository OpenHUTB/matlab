function addPS7(fid,hbuild)
    if~isempty(hbuild.PS7)

        fprintf(fid,hbuild.PS7.Instance);
    end
end