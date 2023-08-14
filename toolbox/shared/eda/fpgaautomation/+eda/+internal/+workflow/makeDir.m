function makeDir(directory)





    [s,~,messid]=mkdir(directory);
    if s==0
        switch lower(messid)
        case 'matlab:mkdir:directoryexists',
            error(message('EDALink:makeDir:directoryexists',directory));
        otherwise,
            error(message('EDALink:makeDir:directoryfailure',directory));
        end
    end

end

