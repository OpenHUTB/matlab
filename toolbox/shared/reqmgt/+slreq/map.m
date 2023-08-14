









































function result=map(source,varargin)

    source=convertStringsToChars(source);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if isempty(source)

        if isempty(varargin)
            rmiut.warnNoBacktrace('Slvnv:reqmgt:rmi:InvalidArgumentNumber');
        elseif strcmp(varargin{1},'clear')
            rmimap.StorageMapper.clearAll();
            result=true;
        elseif strcmpi(varargin{1},'list')
            result=rmimap.StorageMapper.listAll();
        else
            rmiut.warnNoBacktrace('Slvnv:rmide:UnsupportedOption',varargin{1})
            result=false;
        end
        return;

    elseif ischar(source)
        if rmiut.isCompletePath(source)
            srcPath=source;
        else
            srcPath=rmiut.full_path(source);
        end
        if isempty(srcPath)||contains(srcPath,' not found')
            rmiut.warnNoBacktrace('Slvnv:rmidata:map:ModelNotFound',source);
            return;
        elseif~isfile(srcPath)
            rmiut.warnNoBacktrace('Slvnv:reqmgt:StorageMapper:FileNotExist',source);
        end
    else
        srcPath=get_param(source,'FileName');
    end

    storedValue=rmimap.StorageMapper.getInstance.get(srcPath);
    if isempty(varargin)

        if isempty(storedValue)

            result=rmimap.StorageMapper.getInstance.getStorageFor(srcPath);
        else
            result=storedValue{1};
        end
    else
        secondArg=varargin{1};
        newReqPath='';
        switch secondArg
        case 'clear'
            shorterPath=rmiut.shorterPath(srcPath);
            if isempty(storedValue)
                disp(['Nothing to clear for ',shorterPath]);
                result=false;
            else
                disp(['Removing all mapping for ',shorterPath]);
                rmimap.StorageMapper.getInstance.forget(srcPath,true);
                result=true;
            end
        case 'undo'
            shorterPath=rmiut.shorterPath(srcPath);
            if isempty(storedValue)
                disp(['Nothing to undo for ',shorterPath]);
                result=false;
            else
                disp(['Removing ',storedValue{1},' for ',shorterPath]);
                rmimap.StorageMapper.getInstance.forget(srcPath,false);
                result=true;
            end
        otherwise
            newReqPath=rmiut.absolute_path(secondArg,pwd);
            if~isempty(storedValue)&&strcmp(storedValue{1},newReqPath)
                result=false;
            else
                shorterSrc=rmiut.shorterPath(srcPath);
                shorterReq=rmiut.shorterPath(newReqPath);
                disp(getString(message('Slvnv:rmidata:map:MappingSrcToLinkset',shorterSrc,shorterReq)));
                rmimap.StorageMapper.getInstance.set(srcPath,newReqPath);
                result=true;

                if exist(newReqPath,'file')==2


                    [~,mdlName,ext]=fileparts(srcPath);
                    if any(strcmp(ext,{'.slx','.mdl'}))
                        try
                            modelH=get_param(mdlName,'Handle');
                            rmidata.discard(modelH);
                            result=rmidata.loadIfExists(modelH);
                            if~result

                                slreq.map(srcPath,'undo');
                            end
                        catch ex %#ok<NASGU>


                        end
                    end

                else
                    rmiut.warnNoBacktrace('Slvnv:rmidata:map:NoReqFile',newReqPath);
                end
            end
        end
        if result&&rmi.isInstalled()




            slreq.utils.updateLinkFilePath(srcPath,newReqPath);
        end
    end
end

