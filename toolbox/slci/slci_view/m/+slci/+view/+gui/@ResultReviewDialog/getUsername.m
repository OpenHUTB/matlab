function user=getUsername()




    if isunix()
        user=getenv('USER');
    else
        user=getenv('username');
    end
end
