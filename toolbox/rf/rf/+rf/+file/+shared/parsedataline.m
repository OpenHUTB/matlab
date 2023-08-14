function[dblN,lenN,nidx]=parsedataline(obj,linestr,nidx)





    [dblN,lenN,err]=sscanf(linestr,'%f');
    nidx=nidx+1;
    if~isempty(err)
        linestr=trimtrailingcomments(obj,linestr);
        [dblN,lenN,err]=sscanf(linestr,'%f');
        if~isempty(err)
            [dblN,lenN,nidx]=reacttostrindataline(obj,linestr,nidx);
        end
    end
    dblN=dblN.';