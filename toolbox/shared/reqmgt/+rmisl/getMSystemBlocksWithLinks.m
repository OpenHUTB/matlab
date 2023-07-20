function msystemsWithLinks=getMSystemBlocksWithLinks(modelH,filterSettings)


    if nargin<2
        filterSettings=rmi.settings_mgr('get','filterSettings');
    end

    msystemsWithLinks=[];

    modelObj=get_param(modelH,'Object');
    mlObjs=find(modelObj,'-isa','Simulink.MATLABSystem');
    for i=1:length(mlObjs)
        msPath=which(mlObjs(i).System);
        if isempty(msPath)
            continue;
        end
        if rmiml.hasData(msPath)
            if rmiml.hasLinks(msPath,filterSettings)
                msystemsWithLinks=[msystemsWithLinks;mlObjs(i).Handle];%#ok<AGROW>
            end
        else

            reqPath=rmimap.StorageMapper.getInstance.getStorageFor(msPath);
            if exist(reqPath,'file')==2
                msystemsWithLinks=[msystemsWithLinks;mlObjs(i).Handle];%#ok<AGROW>
            else


                reqPath=regexprep(reqPath,'.slmx','.req');
                if exist(reqPath,'file')==2
                    msystemsWithLinks=[msystemsWithLinks;mlObjs(i).Handle];%#ok<AGROW>
                end
            end
        end
    end
end
