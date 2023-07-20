function passStr=osFileSep(passStr)
    if ispc&&any(passStr=='/')
        passStr=strrep(passStr,'/',filesep);
    elseif~ispc&&any(passStr=='\')
        passStr=strrep(passStr,'\',filesep);
    end
end

