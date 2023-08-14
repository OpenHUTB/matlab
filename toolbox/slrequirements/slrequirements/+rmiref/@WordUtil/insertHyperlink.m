function insertHyperlink(thisDoc,thisSelection,bitmap,url,dispstr)
    if~isempty(bitmap)&&exist(bitmap,'file')==2
        pictureFile=bitmap;
        customBitmap=true;
    else
        if~isempty(bitmap)
            warndlg({...
            getString(message('Slvnv:rmiref:actx_picture:MissingBitmapFile',bitmap)),...
            getString(message('Slvnv:rmiref:actx_picture:UsingDefaultImage'))},...
            getString(message('Slvnv:rmiref:actx_picture:FailedToSetPicture')));
        end
        pictureFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink.bmp');
        customBitmap=false;
    end
    try
        newPicture=thisSelection.InlineShapes.AddPicture(pictureFile);
    catch Mex
        if~isempty(strfind(Mex.message,'Unspecified error'))


            myMex=MException(Mex.identifier,...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:InlineShapeInsertFailed')));
            throw(myMex);
        else
            rethrow(Mex);
        end
    end

    if~customBitmap
        newPicture.Width=20;
        newPicture.Height=20;
    end

    thisDoc.Hyperlinks.Add(newPicture,url,'',dispstr);
end
