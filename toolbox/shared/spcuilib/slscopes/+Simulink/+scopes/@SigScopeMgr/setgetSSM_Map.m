function out=setgetSSM_Map(createMap,varargin)
    mlock;
    persistent SSMgrMap;

    if nargin>1
        handleToKey=Simulink.scopes.SigScopeMgr.handleToKey(varargin{1});
        SSMgrMap(handleToKey)=varargin{2};
    end
    if nargin>0&&createMap
        SSMgrMap=containers.Map('KeyType','char','ValueType','any');
    end
    out=SSMgrMap;
end