function setCalPage(this,mode,pageNum)













    validateattributes(pageNum,{'numeric'},{'scalar'});
    if pageNum<0||pageNum>=this.getNumPages()||(floor(pageNum)~=pageNum)
        this.throwError('slrealtime:target:invalidPageNum',num2str(pageNum));
    end

    if~this.isConnected()
        this.connect();
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end


        this.xcp.setCalPage(mode,this.Segment,pageNum,true);
    catch ME
        if mode==1
            modeStr=message('slrealtime:target:ecu').getString;
        elseif mode==2
            modeStr=message('slrealtime:target:xcp').getString;
        elseif mode==3
            modeStr=message('slrealtime:target:ecuAndXcp').getString;
        end
        this.throwError('slrealtime:target:setCalPageError',...
        modeStr,this.TargetSettings.name,ME.message);
    end
end
