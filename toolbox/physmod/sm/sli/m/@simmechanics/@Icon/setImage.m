function setImage(this,imName)




    mlRoot=strrep(matlabroot,'\','/');
    imEvalStr=['[ matlabroot filesep ''',strrep(imName,[mlRoot,'/'],''),''' ]'];
    imData=imread(imName);

    this.Display=sprintf('image(imread(%s), ''center'')',imEvalStr);
    this.ShowFrame=false;
    this.ShowName=true;
    this.Size=[size(imData,2),size(imData,1)];
    this.RequiredFiles={imName};

end
