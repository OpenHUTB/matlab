function s=extractMetaInfo(filename)


    s=struct;

    try
        pkg=slreq.opc.Package(filename);
        xmlStr=pkg.readFile;

        r=xmldecode(xmlStr);

        if isfield(r,'datamodel_RequirementSet')
            s=r.datamodel_RequirementSet;
        elseif isfield(r,'datamodel_LinkSet')
            s=r.datamodel_LinkSet;
        end

        fs=fieldnames(s);
        ks=cellfun(@(c)isstruct(s.(c)),fs);
        s=rmfield(s,fs(ks));

    catch
    end

end

function s=xmldecode(xmlStr)


    fname=tempname;
    s=struct;
    try
        fid=fopen(fname,"wt");
        if fid==-1
            return;
        end

        delfile=onCleanup(@()delete(fname));

        fprintf(fid,'%s',xmlStr);
        fclose(fid);

        s=readstruct(fname,'FileType','xml');
    catch
    end
end
