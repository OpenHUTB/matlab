function this=setupDir(this,Value)




    cwd=pwd;
    try
        cd(Value);
    catch
        mkdir(Value);
        cd(Value);
    end

    cd(cwd);
    fileattrib(Value,'+w');

end
