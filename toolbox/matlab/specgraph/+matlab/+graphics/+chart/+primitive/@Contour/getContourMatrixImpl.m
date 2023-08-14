function contourMatrix=getContourMatrixImpl(hObj)


    contourLines=computeContourLines(hObj,[],true);
    contourMatrix=deriveContourMatrix(contourLines);
end
