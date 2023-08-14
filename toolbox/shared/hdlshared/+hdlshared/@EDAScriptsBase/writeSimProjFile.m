function writeSimProjFile(this,varargin)





    topname=this.TopLevelName;
    hdlnames=this.entityFileNames;

    fname=fullfile(this.CodeGenDirectory,...
    [topname,this.SimProjectFilePostFix]);

    fid=fopen(fname,'w');

    if fid==-1
        error(message('HDLShared:hdlshared:simprojectopenfile'));
    end

    fprintf(fid,this.HdlSimProjectInit,topname);

    for n=1:length(hdlnames)
        fprintf(fid,this.HdlSimProjectCmd,...
        hdlnames{n});
    end

    fprintf(fid,this.HdlSimProjectTerm);

    fclose(fid);
