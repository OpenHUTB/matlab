function ret=isPslinkAvailable()




    persistent isAvailable;

    if isempty(isAvailable)
        psbfVersion=ver('psbugfinder');
        if isempty(psbfVersion)
            psbfVersion=ver('psbugfinderserver');
        end

        if isempty(psbfVersion)
            isAvailable=false;
        else



            mVersion=ver('matlab');
            isAvailable=strcmpi(mVersion.Release,psbfVersion.Release);
        end
    end

    ret=isAvailable;


