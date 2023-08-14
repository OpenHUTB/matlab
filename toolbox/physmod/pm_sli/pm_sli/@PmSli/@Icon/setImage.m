function setImage(this,imName)




    imPath=which(imName);
    imData=imread(imName);

    imEvalStr=['''',imPath,''''];
    if~isempty(findstr([matlabroot,filesep],imPath))
        imEvalStr=['[ matlabroot filesep ''',strrep(imPath,[matlabroot,filesep],''),''' ]'];
    end

    this.Display=sprintf('image(imread(%s), ''center'')',imEvalStr);
    this.ShowFrame=false;
    this.ShowName=true;
    this.Size=[size(imData,2),size(imData,1)];
    this.RequiredFiles={imPath};

end
