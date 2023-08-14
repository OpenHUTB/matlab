function ret=getClient(this,bComparison)




    ret=[];
    if nargin<2
        bComparison=this.ComparisonSignalID~=0;
    end
    MAX_RETRIES=50;
    for idx=1:MAX_RETRIES
        ret=this.OffscreenUI.getClient(bComparison);
        if~isempty(ret)
            return
        end
        locWait(0.2);
    end
end


function locWait(val)
    pause(val);
drawnow
end
