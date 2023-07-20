function isxpc=isxpcinstalled









    isxpc=license('test','XPC_Target')&&...
    exist('slrealtime.tlc','file');


