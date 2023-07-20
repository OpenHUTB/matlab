



function res=toStruct(this,idx)

    if(nargin<2)||isempty(idx)
        newObj=this;

    else

        newObj=this.extractInstance(idx);
    end

    res=struct();
    res.config=struct();
    res.config.filterCtx=newObj.FilterCtx;
    res.htmlFiles=newObj.HtmlFiles;
    res.codeCovDataObj=newObj.CodeCovDataImpl;


