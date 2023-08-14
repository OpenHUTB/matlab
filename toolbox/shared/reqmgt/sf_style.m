



function style=sf_style(style_name,fgColor,bgColor,fontColor)




    if strcmp(style_name,'off')
        style=0;
        return;
    end


    style=sf('find','all','style.name',style_name);


    if isempty(style)


        if strcmp(style_name,'req')||strcmp(style_name,'on')
            fgColor=[1.0,0.2,0];
            bgColor=[1,1,1];
            fontColor=[1.0,0.2,0];









        elseif strcmp(style_name,'fade')
            fgColor=0.7*[1,1,1];
            bgColor=[1,1,1];
            fontColor=0.7*[1,1,1];


        elseif nargin<4
            if ischar(style_name)
                warning(message('Slvnv:sf_style:ProvideColor',style_name));
            else
                warning(message('Slvnv:sf_style:StyleName'));
            end
            style=0;
            return;
        end


        style=sf('new','style');
        sf('set',style,...
        'style.name',style_name,...
        'style.blockEdgeColor',fgColor,...
        'style.wireColor',fgColor,...
        'style.fontColor',fontColor,...
        'style.bgColor',bgColor);

    end
