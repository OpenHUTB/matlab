function out=simplifytip(h,in)

    out=strtok(in,'(');
    out=strrep(out,'_{','');
    out=strrep(out,'}','');
    out=strrep(out,'\','#');