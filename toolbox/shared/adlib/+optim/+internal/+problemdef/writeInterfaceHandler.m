function fid=writeInterfaceHandler(defaultFilename,filename)







    try

        if nargin<2
            filename=sprintf('%s.txt',defaultFilename);
        end


        fid=fopen(filename,'w');
        if fid==-1
            throwAsCaller(MException(message('shared_adlib:writeInterfaceHandler:FileOpenError',filename)));
        end
    catch E
        throwAsCaller(E);
    end
