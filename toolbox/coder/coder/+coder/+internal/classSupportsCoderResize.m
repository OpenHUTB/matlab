function p=classSupportsCoderResize(className)






    switch(className)
    case{'categorical','duration','table','datetime','timetable'}
        p=true;
    otherwise
        p=false;
    end
end
