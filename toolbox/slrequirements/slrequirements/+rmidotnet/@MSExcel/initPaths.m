

function initPaths(this)

    if isempty(this.htmlFileDir)&&isempty(this.resourcePath)
        [this.htmlFileDir,this.resourcePath]=slreq.import.resourceCachePaths('MSEXCEL');
    end

end
