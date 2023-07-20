function[ydata,ynames,xdata]=putincell(h,ydata,ynames,xdata)




    if numel(ydata)==0
        return
    end
    if isnumeric(xdata)
        xdata={xdata};
        xdata=repmat(xdata,1,numel(ydata));
    end