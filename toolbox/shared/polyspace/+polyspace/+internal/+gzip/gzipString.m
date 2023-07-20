

function res=gzipString(str,useUTF8)

    if nargin<2
        useUTF8=false;
    end

    str=convertStringsToChars(str);
    validateattributes(str,{'char'},{'row'},'polyspace.internal.gzip.gzipString','',1);
    res=gzip_mex(1,str,useUTF8);
