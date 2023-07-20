function c=conv(a,b,shape)




















    if~isvector(a)||~isvector(b)
        error(message('MATLAB:conv:AorBNotVector'));
    end

    if nargin<3
        shape='full';
    end

    if~ischar(shape)&&~(isstring(shape)&&isscalar(shape))
        error(message('MATLAB:conv:unknownShapeParameter'));
    end
    if isstring(shape)
        shape=char(shape);
    end

    if~strcmp(class(a),class(b))
        if~isa(a,'half')
            if isa(a,'single')

                c=half(conv2(a(:),single(b(:)),shape));
            else

                c=half(conv2(a(:),double(b(:)),shape));
            end
        else
            if isa(b,'single')

                c=half(conv2(single(a(:)),b(:),shape));
            else

                c=half(conv2(double(a(:)),b(:),shape));
            end
        end
    else
        c=half(conv2(single(a(:)),single(b(:)),shape));
    end


    if shape(1)=='f'||shape(1)=='F'
        if length(a)>length(b)
            if size(a,1)==1
                c=c.';
            end
        else
            if size(b,1)==1
                c=c.';
            end
        end
    else
        if size(a,1)==1
            c=c.';
        end
    end
