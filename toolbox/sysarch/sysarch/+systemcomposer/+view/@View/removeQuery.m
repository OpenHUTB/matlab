function removeQuery(this,keepContents)









    if nargin<2
        keepContents=true;
    end

    this.getImpl.removeQuery(keepContents);

end

