function r=getRtiostreamLibraryPath(RTIOStreamLibName)
    if(length(RTIOStreamLibName)>7)&&strcmpi(RTIOStreamLibName(1:7),'matlab:')
        r=eval(RTIOStreamLibName(8:end));
    else
        r=RTIOStreamLibName;
    end
end
