

function str=gunzipString(arr,useUTF8)

    if nargin<2
        useUTF8=false;
    end

    validateattributes(arr,{'int8'},{'vector'},'polyspace.internal.gzip.gunzipString','',1);
    str=gzip_mex(0,arr,useUTF8);
