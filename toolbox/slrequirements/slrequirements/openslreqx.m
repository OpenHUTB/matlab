function openslreqx(slreqxFile)







    if~rmiut.isCompletePath(slreqxFile)
        resolved=which(slreqxFile);
        if isempty(resolved)
            error(message('Slvnv:rmiml:FileNotFound',slreqxFile));
        end
    else
        resolved=slreqxFile;
    end

    slreq.open(resolved);

end
