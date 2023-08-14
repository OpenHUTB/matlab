function add(h,filename,fileType)%#ok<INUSD>


















    narginchk(2,3);
    linkfoundation.util.errorIfArray(h);

    ofile=linkfoundation.util.filenameParser(h,filename);

    h.mIdeModule.AddFileToProject(ofile);

