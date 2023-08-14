function varargout=mllinkMgr(varargin)


    mlock;
    persistent mlKeys currentIdx sortedKeys
    if isempty(currentIdx)
        mlKeys=containers.Map('KeyType','char','ValueType','char');
        currentIdx=0;
        sortedKeys={};
    end

    if nargout>0
        varargout{1}=false;
    end

    if nargin==2&&strcmp(varargin{1},'check')
        obj=varargin{2};
        isSf=strncmp(class(obj),'Stateflow.',length('Stateflow.'));
        if isa(obj,'char')

            mdlName=strtok(obj,'/');
        elseif isSf

            mdlName=strtok(obj.Path,'/');
        else
            disp(['RptgenRMI.mllinkMgr() failed to handle object of class ',class(obj)]);
            return;
        end
        if~rmidata.isExternal(mdlName)
            return;
        end
        if isempty(slreq.utils.getLinkSet(mdlName))
            return;
        end
        sid=Simulink.ID.getSID(obj);
        if rmiml.hasLinks(sid)
            if isSf
                key=[obj.Path,'/',obj.Name];
            else
                key=obj;
            end
            if~isKey(mlKeys,key)
                mlKeys(key)=sid;
                varargout{1}=true;
            end
        end

    elseif nargin==2&&strcmp(varargin{1},'mfile')
        fPath=varargin{2};
        edit(fPath);
        if rmiml.hasLinks(fPath)
            key=rmiut.pathToCmd(fPath);
            if~isKey(mlKeys,key)
                mlKeys(key)=fPath;
                varargout{1}=true;
            end
        end

    elseif nargin==2&&strcmp(varargin{1},'ddfile')
        ddPath=varargin{2};
        if~rmide.hasData(ddPath)
            rmide.load(ddPath);
        end
        if rmide.hasLinks(ddPath)
            [~,ddName,ddExt]=fileparts(ddPath);
            if~isKey(mlKeys,[ddName,ddExt])
                mlKeys([ddName,ddExt])=ddPath;
                varargout{1}=true;
            end
        end

    elseif nargin==2&&strcmp(varargin{1},'tmfile')
        tmPath=varargin{2};
        if~rmitm.hasData(tmPath)
            rmitm.load(tmPath);
        end
        hasLinks=slreq.hasLinks(tmPath);
        if hasLinks
            [~,tmName,tmExt]=fileparts(tmPath);
            if~isKey(mlKeys,[tmName,tmExt])
                mlKeys([tmName,tmExt])=tmPath;
                varargout{1}=true;
            end
        end

    elseif nargin==1&&strcmp(varargin{1},'hasNext')
        if mlKeys.Count==0

            varargout{1}=false;
        else
            if isempty(sortedKeys)
                sortedKeys=sort(keys(mlKeys));
            end
            if currentIdx==length(sortedKeys)

                mlKeys=containers.Map('KeyType','char','ValueType','char');
                currentIdx=0;
                sortedKeys={};
                varargout{1}=false;
            else

                varargout{1}=true;
            end
        end

    elseif nargin==1&&strcmp(varargin{1},'getNext')
        currentIdx=currentIdx+1;
        if currentIdx>length(sortedKeys)
            error('RptgenRMI.mllinkMgr(): no more items');
        end
        nextKey=sortedKeys{currentIdx};
        varargout{1}=nextKey;
        varargout{2}=mlKeys(nextKey);

    elseif nargin==1&&strcmp(varargin{1},'getCurrent')
        if currentIdx>0&&currentIdx<=length(sortedKeys)
            currentKey=sortedKeys{currentIdx};
            varargout{1}=currentKey;
            varargout{2}=mlKeys(currentKey);
        else
            error('Invalid index in a call to RptgenRMI.mllinkMgr');
        end

    elseif nargin==1&&strcmp(varargin{1},'clear')
        mlKeys=containers.Map('KeyType','char','ValueType','char');
        currentIdx=0;
        sortedKeys={};

    else
        error('Invalid argument in a call to RptgenRMI.mllinkMgr');
    end

end
