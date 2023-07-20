function location=selectShortcutIcon()



    iconSelection=i_getMessage("MATLAB:project:view_file:ShortcutIconFilesDescription");
    allFilesSelection=i_getMessage("MATLAB:project:view_file:ShortcutAllFilesDescription");
    selectionTitle=i_getMessage("MATLAB:project:view_file:ShortcutIconSelectionTitle");
    [name,path]=uigetfile({"*.png; *.gif",iconSelection;"*.*",allFilesSelection},selectionTitle);

    if isnumeric(name)
        location="";
        return;
    end

    file=tempname+".png";
    try
        [originalImage,~,origAlpha]=imread(fullfile(path,name));
    catch
        error(i_getMessage("MATLAB:project:view_file:ShortcutInvalidIcon",fullfile(path,name)));
    end

    scaledImage=imresize(originalImage,[NaN,16]);
    scaledAlpha=imresize(origAlpha,[NaN,16]);
    imwrite(scaledImage,file,'Alpha',scaledAlpha);
    [imagePath,imageName,imageExt]=fileparts(file);

    connector.ensureServiceOn();
    contentUrlPath=connector.addStaticContentOnPath('projectShortcutIcons',imagePath+"/");
    urlToLoad=contentUrlPath+"/"+imageName+imageExt;



    location=[urlToLoad;file];
end

function value=i_getMessage(resource,varargin)
    value=string(message(resource,varargin{:}));
end
