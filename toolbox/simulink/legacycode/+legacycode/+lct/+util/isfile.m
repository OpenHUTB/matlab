





function status=isfile(fileName)

    narginchk(1,1);
    fileName=convertStringsToChars(fileName);


    info=dir(fileName);
    status=(numel(info)==1)&&(info.isdir==0);




