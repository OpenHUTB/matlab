function newYLim=calculateYLim(this)






    if~isempty(this.TimeSpan)
        minLim=-1*min(this.TimeSpan,abs(this.TimeVector(1)));
    else
        minLim=this.TimeVector(1);
    end
    newYLim=[minLim,0];
end
