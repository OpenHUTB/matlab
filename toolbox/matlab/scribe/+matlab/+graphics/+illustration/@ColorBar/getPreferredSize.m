function size=getPreferredSize(~,varargin)



    narginchk(3,3);

    axes_pos=varargin{2};
    axes_width=axes_pos(1);
    axes_height=axes_pos(2);

    width=axes_width*.10;
    height=axes_height*.10;
    width=min(max(width,4),16);
    height=min(max(height,4),16);

    size=[width,height];