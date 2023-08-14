function[off,slpX]=sldveml_lookup1D_util_slope_offset_array(mode,nx,x,table)
%#codegen



    assert(mode==0||mode==1,'Sldv:sldv:EmlAuthoring:FailRecogTableType');

    nxInt=int32(nx);

    if mode==0
        slpX=zeros(nxInt-1,1);
        off=zeros(nxInt-1,1);
        for idx=1:nxInt-1
            if x(idx+1)==x(idx)
                off(idx)=table(idx,1);
                slpX(idx)=0;
            else
                off(idx)=table(idx)-(table(idx+1)-table(idx))/(x(idx+1)-x(idx))*x(idx);
                slpX(idx)=(table(idx+1)-table(idx))/(x(idx+1)-x(idx));
            end
        end
    else
        slpX=zeros(nxInt+1,1);
        off=zeros(nxInt+1,1);
        off(1)=table(1);
        slpX(1)=0;
        off(nxInt+1)=table(nxInt);
        slpX(nxInt+1)=0;
        for idx=1:nxInt-1
            if x(idx+1)==x(idx)
                off(idx+1)=table(idx,1);
                slpX(idx+1)=0;
            else
                off(idx+1)=table(idx)-(table(idx+1)-table(idx))/(x(idx+1)-x(idx))*x(idx);
                slpX(idx+1)=(table(idx+1)-table(idx))/(x(idx+1)-x(idx));
            end
        end
    end
