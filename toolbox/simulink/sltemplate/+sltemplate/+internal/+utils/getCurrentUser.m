



function user=getCurrentUser()
    user=getenv('USER');
    if isempty(user)
        user=getenv('USERNAME');
    end
end