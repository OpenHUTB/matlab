function writeSynthesisFile(this,varargin)





    topname=hdlentitytop;
    hdlnames=this.entityFileNames;

    fname=fullfile(this.CodeGenDirectory,...
    [topname,this.SynthesisFilePostFix]);

    fid=fopen(fname,'w');

    if fid==-1
        error(message('HDLShared:hdlshared:synthopenfile'));
    end

    fprintf(fid,this.HdlSynthInit,topname);

    for n=1:length(hdlnames)
        fprintf(fid,this.HdlSynthCmd,...
        hdlnames{n});
    end

    fprintf(fid,this.Hdlsynthterm);

    fclose(fid);
