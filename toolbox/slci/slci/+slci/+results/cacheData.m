
function varargout=cacheData(routine,varargin)


    switch routine
    case 'get'
        if nargin==5
            [varargout{1},varargout{2}]=...
            get(varargin{1},varargin{2},varargin{3},varargin{4});
        else
            error('Incorrect number of arguments to get method in cacheData');
        end
    case 'update'
        if nargin==4
            varargout{1}=update(varargin{1},varargin{2},varargin{3});
        else
            error('Incorrect number of arguments to update method in cacheData');
        end
    case 'save'
        if nargin==5
            save(varargin{1},varargin{2},varargin{3},varargin{4});
        else
            error('Incorrect number of arguments to save method in cacheData');
        end
    case 'check'
        if nargin==5
            varargout{1}=check(varargin{1},varargin{2},varargin{3},varargin{4});
        else
            error('Incorrect number of arguments to check method in cacheData');
        end
    otherwise
        error(['Unknown routine ',routine]);
    end
end

function[aObject,cacheTable]=get(cacheTable,dataReader,methodName,akey)
    if isKey(cacheTable,akey)
        aObject=cacheTable(akey);
    else
        aObject=feval(methodName,dataReader,akey);
        cacheTable(akey)=aObject;
    end
end

function hasObj=check(cacheTable,dataReader,methodName,akey)
    if isKey(cacheTable,akey)
        hasObj=true;
    else
        hasObj=feval(methodName,dataReader,akey);
    end
end



function cacheTable=update(cacheTable,aKey,aObject)
    cacheTable(aKey)=aObject;
end

function save(cacheTable,datamgr,dataReader,methodName)
    datamgr.beginTransaction();
    try
        cachedKeys=keys(cacheTable);
        for k=1:numel(cachedKeys)
            thisKey=cachedKeys{k};
            feval(methodName,dataReader,thisKey,cacheTable(thisKey));
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end
