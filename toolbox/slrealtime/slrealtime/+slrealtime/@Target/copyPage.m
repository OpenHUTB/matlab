function copyPage(this,srcPage,dstPage)













    validateattributes(srcPage,{'numeric'},{'scalar'});
    if srcPage<0||srcPage>=this.getNumPages()||(floor(srcPage)~=srcPage)
        this.throwError('slrealtime:target:invalidPageNum',num2str(srcPage));
    end

    validateattributes(dstPage,{'numeric'},{'scalar'});
    if dstPage<0||dstPage>=this.getNumPages()||(floor(dstPage)~=dstPage)
        this.throwError('slrealtime:target:invalidPageNum',num2str(dstPage));
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end


        res=this.xcp.getPageProcessorInfo();
        numOfSegments=res.MAX_SEGMENTS;


        for segIdx=0:(numOfSegments-1)
            this.xcp.copyCalPage(segIdx,srcPage,dstPage);
        end

    catch ME
        this.throwError('slrealtime:target:copyCalPageError',...
        srcPage,dstPage,this.TargetSettings.name,ME.message);
    end

    notify(this,'CalPageChanged');
end
