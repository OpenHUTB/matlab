function name=getUserName




    if ispc
        name=getenv('username');
    else
        name=getenv('USER');
    end
