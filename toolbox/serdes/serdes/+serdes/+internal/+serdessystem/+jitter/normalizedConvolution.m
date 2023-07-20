function pdf=normalizedConvolution(varargin)













    narginchk(1,inf)
    nargoutchk(0,1)


    for ii=1:length(varargin)
        val=varargin{ii};
        if ii==1
            validateattributes(val,{'numeric'},{'vector','finite'})
            sz1=size(val);
        end
        validateattributes(val,{'numeric'},{'vector','finite','size',sz1})
    end

    pdf=zeros(sz1);

    ii=1;
    while ii<=length(varargin)
        val=varargin{ii};
        if sum(val(:))~=0
            if sum(pdf)==0
                pdf=val/sum(val(:));
            else
                pdf=conv(pdf,val/sum(val(:)),'same');
            end
        end
        ii=ii+1;
    end