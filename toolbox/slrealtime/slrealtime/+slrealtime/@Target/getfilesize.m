function res=getfilesize(tg,fileName)







    narginchk(2,2);
    validateattributes(fileName,{'string','char'},{},1);
    try
        if~tg.isConnected()
            tg.connect();
        end

        if~tg.isfile(fileName)&&~tg.isfolder(fileName)
            tg.throwError('slrealtime:target:fileNotFound',fileName);
        end
        res=tg.executeCommand(strcat("du -s -p ",fileName));
        sizestr=split(res.Output);
        sizestr=sizestr(~cellfun('isempty',sizestr));
        res=str2num(sizestr{1});%#ok<ST2NM>
    catch ME
        throw(ME);
    end
end
