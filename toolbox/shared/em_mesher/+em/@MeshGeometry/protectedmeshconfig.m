function m=protectedmeshconfig(obj,mode)





























    if nargin>1
        mode=convertStringsToChars(mode);
    end

    validateattributes(mode,{'char','string'},{'nonempty','scalartext'},...
    'meshconfig','mode',2);



    if any(strcmpi(mode,{'manual','auto'}))
        obj.MesherStruct.MeshingChoice=mode;
        m=meshinfo(obj);
    else
        error(message('antenna:antennaerrors:IncorrectOption','meshconfig',...
        'auto or manual'));
    end

end
