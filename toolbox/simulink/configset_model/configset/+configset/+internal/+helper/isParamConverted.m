function out=isParamConverted(name,varargin)

    persistent map
    if isempty(map)
        map=containers.Map('KeyType','char','ValueType','logical');
    end

    if nargin==1
        out=map.isKey(name);
    else
        map(name)=true;
    end
