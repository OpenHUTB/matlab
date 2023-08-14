function varargout=info(this)







    topstr=['Filter Group for ',this.FilterStructure];
    uline=['-'*ones(1,length(topstr))];
    rxtop='Receiver Filter Chain:';
    txtop='Transmitter Filter Chain:';
    infostrs=char(topstr,uline,' ',rxtop,this.RxChain.info,' ',txtop,this.TxChain.info);
    if nargout
        varargout={infostrs};
    else
        disp(infostrs);
    end


