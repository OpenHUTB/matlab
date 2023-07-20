

function[flag,dim]=resolveDim(ws,input)

    flag=true;
    dim=input;
    if ischar(input)


        try
            dim=slResolve(input,ws);
        catch
            flag=false;
            return;
        end
    end

end