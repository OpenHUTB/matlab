
function result=hasATG(sys)
    TrafficGenerator=find_system(sys,'searchdepth',1,'ReferenceBlock','socmemlib/Memory Traffic Generator');
    if isempty(TrafficGenerator)
        result=false;
    else
        result=true;
    end
end
