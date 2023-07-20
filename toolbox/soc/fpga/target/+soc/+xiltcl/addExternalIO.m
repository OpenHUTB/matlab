function addExternalIO(fid,hbuild)
    for i=1:numel(hbuild.ExternalIO)
        soc.xiltcl.addPort(fid,hbuild.ExternalIO(i).name,hbuild.ExternalIO(i).dir);
    end
end