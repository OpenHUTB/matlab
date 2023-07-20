function out=getCodeFromFile(h,fullfilename,line)




    out='';

    e=h.getFileLineIndex(fullfilename);
    l=e.FileLineIndex;
    c=e.CommentBlockLineIndex;
    ci=e.CommentBlockIndent;
    numLine=length(l);

    if line>numLine
        return;
    end

    for i=1:length(c)
        if c(i)>line
            break;
        end
    end
    if c(i)>line
        start_line=c(i-1);


        j=i;
        while ci(j)>ci(i-1)&&j<length(ci)
            j=j+1;
        end
        if j<length(ci)
            end_line=c(j)-1;
        else
            end_line=numLine;
        end


    else

        start_line=c(i);
        end_line=numLine;
    end
    if start_line>end_line
        return;
    end
    if start_line>numLine

        return;
    end
    if end_line>numLine

        end_line=numLine;
    end
    if(start_line==1)
        begin_idx=0;
    else
        begin_idx=l(start_line-1);
    end
    size=l(end_line)-begin_idx;
    fid=fopen(fullfilename,'r');
    fseek(fid,begin_idx,-1);
    code=fread(fid,size,'uint8=>char')';
    code=strrep(code,char([13,10]),char(10));
    fclose(fid);
    [~,name,ext]=fileparts(fullfilename);
    out=struct('File',[name,ext],...
    'BeginLine',start_line,...
    'EndLine',end_line,...
    'Code',code,...
    'AnchorLine',line);
