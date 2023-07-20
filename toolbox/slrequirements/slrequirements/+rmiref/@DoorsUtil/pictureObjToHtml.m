function html=pictureObjToHtml(moduleId,item)
    html='';
    pictureFile=pictureFileName(moduleId,item);
    picture=rmidoors.getObjAttribute(moduleId,item,'picture',pictureFile);
    if~isempty(picture)
        if exist(picture,'file')==2
            html=htmlPicture(picture);
        else





        end
    end

end

function filePathName=pictureFileName(moduleId,item)
    baseName=rmiref.DoorsUtil.cacheFileBaseName(moduleId,item);
    filePathName=[baseName,'.png'];
end

function html=htmlPicture(picture)
    imdata=imread(picture);
    imsize=max(size(imdata));
    picture=strrep(picture,filesep,'/');
    if imsize>300
        html=['<a href="file:///',picture,'"><img src="file:///',picture,'" width=300></a>'];
    else
        html=['<a href="file:///',picture,'"><img src="file:///',picture,'"></a>'];
    end
end
