function result=iswritable(h,address,datatype,count)








































































    narginchk(3,4);
    linkfoundation.util.errorIfArray(h);


    address=ide_getCompleteAddress(h,address);

    if(nargin==3)
        count=1;
    end


    usercount=count;
    count=linkfoundation.util.convertSizeTo1xN(count);

    sampledata=zeros(1,count,datatype);
    result=h.mIdeModule.IsWritable(address(1),address(2),sampledata,count);



