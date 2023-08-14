function vec=createEmptyTypeVector(obj)




    vec=eval(sprintf('%s.empty(0,1)',obj.FiType));
