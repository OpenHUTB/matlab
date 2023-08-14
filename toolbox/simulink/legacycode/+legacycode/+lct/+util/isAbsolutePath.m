function bool=isAbsolutePath(aPath)






    narginchk(1,1);

    aPath=convertStringsToChars(aPath);

    if isempty(aPath)
        bool=false;
        return
    else
        validateattributes(aPath,...
        {'char','string'},{'scalartext'},'legacycode.lct.util.isAbsolutePath','',1);
    end

    if numel(aPath)<1||aPath(1)=='.'

        bool=false;
    else
        if ispc

            bool=(numel(aPath)>=2)&&((isletter(aPath(1))&&aPath(2)==':')||(aPath(1)=='\'&&aPath(2)=='\'));
        else

            bool=aPath(1)=='/';
        end
    end


