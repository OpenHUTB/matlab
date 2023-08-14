function out=isSupportedFile(in)




    in=convertStringsToChars(in);


    [isMatlabInSl,mdlName]=rmisl.isSidString(in);
    if isMatlabInSl
        try

            mdlH=get_param(mdlName,'Handle');

            out=rmidata.isExternal(mdlH);
        catch ex %#ok<NASGU>
            out=false;
        end
    else


        if exist(in,'file')==2
            fPath=rmiut.absolute_path(in);
            [~,~,ext]=fileparts(fPath);
            out=~any(strcmpi(ext,{'.xml','.json'}));
        else

            fPath=rmiut.cmdToPath(in);
            if isempty(fPath)
                out=false;
            else
                [~,~,ext]=fileparts(fPath);
                out=strcmp(ext,'.m');
            end
        end
    end
end
