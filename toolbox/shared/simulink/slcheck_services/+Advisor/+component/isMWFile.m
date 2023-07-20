function state=isMWFile(file)


    if nargin>0
        file=convertStringsToChars(file);
    end

    state=false;

    persistent testroot;
    if isempty(testroot)
        testroot=fullfile(matlabroot,'test');
    end

    if strncmp(file,matlabroot,length(matlabroot))
        if~strncmp(file,testroot,length(testroot))
            state=true;
        end
    end
end