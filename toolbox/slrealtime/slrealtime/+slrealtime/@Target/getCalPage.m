function page=getCalPage(this,mode)












    if~this.isConnected()
        this.connect();
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end

        page=this.xcp.getCalPage(mode,this.Segment);
    catch ME
        if mode==1
            modeStr=message('slrealtime:target:ecu').getString;
        elseif mode==2
            modeStr=message('slrealtime:target:xcp').getString;
        elseif mode==3
            modeStr==message('slrealtime:target:ecuAndXcp').getString;
        end

        this.throwError('slrealtime:target:getCalPageError',...
        modeStr,this.TargetSettings.name,ME.message);
    end
end

