function updateReference(this,linkDataObj,srcPath)






    if nargin<3
        linkSet=linkDataObj.getLinkSet();
        srcPath=linkSet.artifact;
    end
    linkObj=this.getModelObj(linkDataObj);
    this.resolveReference(linkObj.dest,srcPath);
end
