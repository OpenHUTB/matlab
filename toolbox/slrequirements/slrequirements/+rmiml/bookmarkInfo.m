function[navcmd,dispStr,bitmap]=bookmarkInfo(destination,locationId)





    if nargin==1

        [srcName,remainder]=strtok(destination,'|');
        locationId=remainder(2:end);
    else

        srcName=destination;
    end

    isSid=rmisl.isSidString(srcName);
    if isSid&&rmisl.isComponentHarness(srcName)

        srcName=rmiml.harnessToModelRemap(srcName);
    end


    if any(locationId=='-')
        range=sscanf(locationId,'%d-%d',2);
        [srcName,locationId]=rmiml.ensureBookmark(srcName,range');
    end



    linkSettings=rmi.settings_mgr('get','linkSettings');
    if isSid
        destination=srcName;
    else
        if strcmp(linkSettings.modelPathStorage,'none')
            srcName=rmiut.pathToCmd(srcName);
        end
        [~,fName,ext]=fileparts(srcName);
        destination=[fName,ext];
    end

    navcmd=sprintf('rmicodenavigate(''%s'',''%s'');',srcName,locationId);
    dispStr=getString(message('Slvnv:rmiml:NamedRangeIn',locationId,destination));

    bitmap='';
    if nargout==3
        if linkSettings.slrefCustomized
            bitmap=linkSettings.slrefUserBitmap;
        elseif linkSettings.useActiveX||~isSid
            bitmap=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink_24.bmp');
        end
    end
end

