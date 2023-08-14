function qout=multiply(q,varargin)%#codegen





    narginchk(1,2);

    if any(~isreal(q(:)))
        error(message('aerospace:quatnorm:isNotReal1'));
    end

    if(size(q,2)~=4)
        error(message('aerospace:quatnorm:wrongDimension1'));
    end

    if nargin==1
        r=q;
    else
        r=varargin{1};
        if any(~isreal(r(:)))
            error(message('aerospace:quatnorm:isNotReal2'));
        end
        if(size(r,2)~=4)
            error(message('aerospace:quatnorm:wrongDimension2'));
        end
        if(size(r,1)~=size(q,1)&&~(size(r,1)==1||size(q,1)==1))
            error(message('aerospace:quatnorm:wrongDimension3'));
        end
    end



    vec=[q(:,1).*r(:,2),q(:,1).*r(:,3),q(:,1).*r(:,4)]+...
    [r(:,1).*q(:,2),r(:,1).*q(:,3),r(:,1).*q(:,4)]+...
    [q(:,3).*r(:,4)-q(:,4).*r(:,3)...
    ,q(:,4).*r(:,2)-q(:,2).*r(:,4)...
    ,q(:,2).*r(:,3)-q(:,3).*r(:,2)];



    scalar=q(:,1).*r(:,1)-q(:,2).*r(:,2)-...
    q(:,3).*r(:,3)-q(:,4).*r(:,4);

    qout=[scalar,vec];

end

