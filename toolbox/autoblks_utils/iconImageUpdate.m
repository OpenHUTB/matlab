function[im,pos]=iconImageUpdate(varargin)







    switch nargin
    case 1
        imageFile=varargin{1};
        ipScale=1;
        hThk=0;
        wThk=0;
        brdColor='clear';
    case 2
        imageFile=varargin{1};
        ipScale=varargin{2};
        hThk=0;
        wThk=0;
        brdColor='clear';
    case 3
        imageFile=varargin{1};
        ipScale=varargin{2};
        hThk=varargin{2};
        wThk=hThk;
        brdColor='clear';
    case 4
        imageFile=varargin{1};
        ipScale=varargin{2};
        hThk=varargin{3};
        wThk=varargin{4};
        brdColor='clear';
    case 5
        imageFile=varargin{1};
        ipScale=varargin{2};
        hThk=varargin{3};
        wThk=varargin{4};
        brdColor=varargin{5};
    otherwise
        error('Please enter 1-5 arguments.')
    end


    blk=gcb;
    imOrig=imread(imageFile);
    switch brdColor
    case 'clear'
        im=imOrig;
    case 'white'
        colorBorder=[255,255,255];
        im=makeBorder(imOrig,wThk,hThk,colorBorder);
    case 'black'
        colorBorder=[0,0,0];
        im=makeBorder(imOrig,wThk,hThk,colorBorder);
    case 'gray'
        colorBorder=[120,120,120];
        im=makeBorder(imOrig,wThk,hThk,colorBorder);
    otherwise
        colorBorder=[255,255,255];
        im=makeBorder(imOrig,wThk,hThk,colorBorder);
    end
    pos=calcPos(blk,im,ipScale,wThk,hThk,brdColor);
end

function pos=calcPos(blk,im,ipScale,wThk,hThk,brdColor)
    [hi,wi,~]=size(im);
    wp=wi/(wi+2*wThk);
    hp=hi/(hi+2*hThk);
    if wp<hp
        brdScale=wp;
    else
        brdScale=hp;
    end
    if strcmp(brdColor,'clear')
        scale=brdScale*ipScale;
    else
        scale=ipScale;
    end

    ari=wi/hi;
    pos=get_param(blk,'Position');
    ornt=get_param(blk,'Orientation');
    switch ornt
    case 'up'
        hb=pos(3)-pos(1);
        wb=pos(4)-pos(2);
    case 'down'
        hb=pos(3)-pos(1);
        wb=pos(4)-pos(2);
    case 'left'
        wb=pos(3)-pos(1);
        hb=pos(4)-pos(2);
    case 'right'
        wb=pos(3)-pos(1);
        hb=pos(4)-pos(2);
    otherwise
    end
    arb=wb/hb;
    if arb>ari
        h=hb;
        w=h*ari;
    else
        w=wb;
        h=w/ari;
    end
    x_pos=(wb-(w*scale))/2;
    y_pos=(hb-(h*scale))/2;
    w_siz=w*scale;
    h_siz=h*scale;
    pos=[x_pos,y_pos,w_siz,h_siz];
end

function imgNew=makeBorder(img,wo,ho,color)



    if nargin<4
        error('Please specify four inputs.');
    end

    if numel(color)~=size(img,3)
        error('''color'' does not match the color format of the image.');
    end


    color=cast(color,class(img));
    color=reshape(color,1,1,numel(color));

    [hi,wi,~]=size(img);
    hr=hi+2*ho;
    wr=wi+2*wo;

    imgNew=repmat(color,[hr,wr,1]);
    imgNew((ho+1):(hr-ho),(wo+1):(wr-wo),:)=img;
end