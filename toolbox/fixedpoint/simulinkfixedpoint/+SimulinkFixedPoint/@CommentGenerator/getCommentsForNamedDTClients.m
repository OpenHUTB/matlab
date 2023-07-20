function comments=getCommentsForNamedDTClients(this,DTConInfo)











    comments=cell(2,1);


    comments{1}=getString(message([this.stringIDPrefix,'NamedDTResolution'],...
    DTConInfo.evaluatedDTString,...
    DTConInfo.getResolutionChain));

    comments{2}=getString(message([this.stringIDPrefix,'NamedDTParent'],...
    getTailNamedType(DTConInfo)));

end
