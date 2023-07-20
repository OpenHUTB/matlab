function[paramName,path]=parseParameterFQN(paramFQN)






    pieces=split(paramFQN,".");
    paramName=pieces{end};
    path=join(pieces(1:end-1),".");

end