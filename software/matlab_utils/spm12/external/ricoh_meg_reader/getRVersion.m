
























function out=getRVersion(varargin)

    function_revision=1;
    function_name='getRVersion';




    out=[];




    out.major=1;
    out.minor=0;
    out.revision=2;
    out.build=0;
    out.date='2018.05.31';
    out.version=sprintf('%d.%d',out.major,out.minor);

