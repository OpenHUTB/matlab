function result=openImpl(reporter,impl,varargin)





    if isempty(varargin)
        key=['E2C5pMaURgVPiNCaA6yCASfaAM7QY+M8btMyab3HEkp5c/36nudBTpJJ5fl9'...
        ,'STNd3eYLGk+gdkI348uLnA889W/4OIu7ftkhe9JDg0P9pmacRjtJ7N+TyvI3'...
        ,'fJmEXByKZfpfsQjcPyG8hJPjd2fCvl9h5NiD4k5arlUhHc5r23kX66ngvbmc'...
        ,'ujpuE4aWURPGYfHzZEJ8G63r2sBpoB8vdmATXXiM6GWNhuIHCUW0u1tby+oy'...
        ,'6+CD15JXxb42be4vrrnlPC9zC5X+BOKhuH4KYz0R'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end



