function out=simplifypath(in,sep)

    if nargin<2
        sep='/';
    end

    upDirStr=[sep,'..',sep];
    currDirStr=[sep,'.',sep];

    out=strrep(in,currDirStr,sep);

    if((length(out)>=2)&&(strcmp(out(1:2),['.',sep])))
        out(1:2)=[];
    end

    prefix='';
    if((length(out)>=3)&&(strcmp(out(2:3),[':',sep])))
        prefix=out(1:3);
        out(1:3)=[];
    end
    while((length(out)>=3)&&(strcmp(out(1:3),['..',sep])))
        prefix=[prefix,'..',sep];%#ok<AGROW>
        out(1:3)=[];
    end

    updirIdx=strfind(out,upDirStr);

    while~isempty(updirIdx)
        sepIdx=find(out==sep);
        remove=false(size(out));

        upIdx=updirIdx(1);
        startAt=sepIdx(sepIdx<upIdx);
        if isempty(startAt)

            if(strcmp(out(1:upIdx),['..',sep]))
                break;
            else
                startAt=1;
            end
        else
            startAt=startAt(end)+1;
        end

        endAt=upIdx+3;
        remove(startAt:endAt)=true;
        out(remove)=[];
        updirIdx=strfind(out,upDirStr);
    end

    out=[prefix,out];
