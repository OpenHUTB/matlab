
function ret=getSetFMUSetting
mlock
    persistent varMap

    if~isa(varMap,'containers.Map')
        varMap=containers.Map('KeyType','char','ValueType','any');
    end
    ret=varMap;
end
