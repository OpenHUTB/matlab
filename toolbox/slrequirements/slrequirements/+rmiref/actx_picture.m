function actx_picture(actxObj,picturePath)






    if exist(picturePath,'file')
        try
            actxObj.Picture=picturePath;
        catch Mex
            errordlg({...
            getString(message('Slvnv:rmiref:actx_picture:FailedToSetPicture_content')),...
            Mex.message},...
            getString(message('Slvnv:rmiref:actx_picture:FailedToSetPicture')));
        end
    else
        warndlg({...
        getString(message('Slvnv:rmiref:actx_picture:UnableToSetBitmap')),...
        getString(message('Slvnv:rmiref:actx_picture:MissingBitmapFile',picturePath))},...
        getString(message('Slvnv:rmiref:actx_picture:ProblemModifyingRefObj')));
    end

end

