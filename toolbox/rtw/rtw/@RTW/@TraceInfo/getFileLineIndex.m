function out=getFileLineIndex(h,aFilename)



    [filepath,name,ext]=fileparts(aFilename);
    filename=[name,ext];
    index=h.FileLineIndex;
    if~isempty(index)
        f={index.FileName};

        idx=ismember(f,filename);
        if any(idx)
            out=index(idx);
            return;
        end
    else



        h.FileLineIndex=struct('FileName',{},'Path',{},'FileLineIndex',{},...
        'CommentBlockLineIndex',{},'CommentBlockIndent',{});
    end

    l_idx=[];
    c_idx=[];
    ci_idx=[];
    nline=0;
    isLastLineComment=false;
    if~exist(aFilename,'file')
        DAStudio.error('CoderFoundation:report:FileNotExist',aFilename);
    end
    fid=fopen(aFilename,'r');
    try
        while 1
            nline=nline+1;
            tline=fgetl(fid);
            if~ischar(tline),break,end
            nchar=ftell(fid);
            if isLineComment(tline,isLastLineComment)
                if~isLastLineComment
                    c_idx=[c_idx,nline];%#ok<*AGROW>
                    nIndent=length(tline)-length(deblank(fliplr(tline)));

                    ci_idx=[ci_idx,nIndent];
                end
                isLastLineComment=true;
            else
                isLastLineComment=false;
            end
            l_idx=[l_idx,nchar];
        end
    catch
        fclose(fid);
    end
    fclose(fid);
    fileLineIndex=struct('FileName',filename,...
    'Path',filepath,...
    'FileLineIndex',l_idx,...
    'CommentBlockLineIndex',c_idx,...
    'CommentBlockIndent',ci_idx);
    h.FileLineIndex=[h.FileLineIndex,fileLineIndex];
    out=fileLineIndex;

    function out=isLineComment(tline,isLastLineComment)
        out=false;
        tmp=strtrim(tline);
        nlen=length(tmp);
        if nlen>0&&tmp(1)=='*'&&isLastLineComment
            out=true;
        elseif nlen>1&&(strcmp(tmp(1:2),'/*')||strcmp(tmp(1:2),'//'))
            out=true;
        end
