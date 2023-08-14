function rmicodenavigate(fPath,locationId,opt)





















    noLocation=false;
    if nargin<2||isempty(locationId)


        noLocation=true;
        [mPath,id]=rmiml.getBookmark(fPath,1);
    elseif any(locationId=='.')

        mPath=fPath;
        id=locationId;
    else

        [mPath,id]=rmiml.getBookmark(fPath,locationId);
    end
    if nargin==3&&strcmp(opt,'_suppress_browser')
        suppress_browser=true;
    else
        suppress_browser=false;
    end

    if isempty(mPath)
        errordlg(...
        getString(message('Slvnv:rmiml:FileNotFound',fPath)),...
        getString(message('Slvnv:rmiml:NavigationError')));
        return;
    end

    rPath=mPath;
    if rmisl.isSidString(mPath)
        open_system(strtok(mPath,':'));
        mPath=rmiml.openMFunctionCode(mPath);
    else
        edit(mPath);
    end

    if noLocation
        rmiut.RangeUtils.setSelection(mPath,[1,1]);
        return;
    end

    if any(id=='-')


        range=sscanf(id,'%d-%d');
        warndlg(...
        getString(message('Slvnv:rmiml:NoStoredBookmark',mPath,id)),...
        getString(message('Slvnv:rmiml:NavigationProblem')));
        range=range';

    elseif id(1)=='?'

        rmiml.findInFile(mPath,id(2:end),true);
        return;

    else

        pause(0.5);
        range=rmiml.idToRange(rPath,id);
    end

    if isempty(range)






        if nargin<3||~strcmp(opt,'_timer_relay')
            t=timer('TimerFcn',@delayed_navigation,'StartDelay',1);
            userData.mPath=rPath;
            userData.id=id;
            t.UserData=userData;
            start(t);
            return;
        else


            showNavigationFailureDialog(id,mPath);
        end

    elseif range(end)==0

        showNavigationFailureDialog(id,mPath);

    else

        rmiut.RangeUtils.setSelection(mPath,range);
    end

    if suppress_browser&&ispc
        reqmgt('winClose','(?:localhost|127\.0\.0\.1):\d+\/matlab\/feval/rmicodenavigate');
    end
end

function showNavigationFailureDialog(id,mPath)
    rmiut.RangeUtils.setSelection(mPath,[1,1]);
    if length(mPath)>50
        mPath=[' ... ',mPath(end-50:end)];
    end
    errordlg(...
    getString(message('Slvnv:rmiml:InvalidBookmark',id,mPath)),...
    getString(message('Slvnv:rmiml:NavigationProblem')));
end

function delayed_navigation(timerobj,varargin)
    userData=timerobj.UserData;
    mPath=userData.mPath;
    id=userData.id;
    stop(timerobj);
    delete(timerobj);
    rmicodenavigate(mPath,id,'_timer_relay');
end
