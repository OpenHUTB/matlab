function thisBase=TransformerBase(SRated,FRated,varargin)%#codegen





    coder.allowpcode('plain');


    thisBase.SRated=SRated;
    thisBase.FRated=FRated;
    thisBase.winding=ee.internal.perunit.createEmptyBase();

    nWindings=length(varargin)/2;

    for idx=1:nWindings
        thisBase.winding(idx)=ee.internal.perunit.Base(SRated,varargin{2*idx-1},FRated,varargin{2*idx});
    end