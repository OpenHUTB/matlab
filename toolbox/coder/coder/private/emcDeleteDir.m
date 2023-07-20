function emcDeleteDir(d)



    if isfolder(d)
        s=rmdir(d,'s');
        if s~=1

            pause(0.1);
            s=rmdir(d,'s');%#ok<NASGU>
        end
    end
end
