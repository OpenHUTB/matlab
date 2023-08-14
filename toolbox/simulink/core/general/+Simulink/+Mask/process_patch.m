function svgString=process_patch(obj,params)



    svgString='';



    bufferWidth=3;
    bufferHeight=2;

    if(length(params)~=3)
        colors='';
    else
        colors=params{3};
    end

    x=params{1};
    y=params{2};

    if(numel(x)~=numel(y))

        warning(['Number of arguments to x and y should be equal. '...
        ,'Skipping this command']);
        return;
    end




    minX=obj.MinX;
    minY=obj.MinY;
    maxX=obj.MaxX;
    maxY=obj.MaxY;


    svgX=(obj.Width-2*bufferWidth)*(x-minX)/(maxX-minX);
    svgY=(obj.Height-2*bufferHeight)*(y-minY)/(maxY-minY);



    svgY=obj.Height-svgY;


    svgX=svgX+bufferWidth;
    svgY=svgY-bufferHeight;


    if(~isempty(colors))
        colors=['#',string(dec2hex(int16(colors*255)))'];
    else
        if(isempty(obj.ColorValue))
            colors='black';
        else
            colors=obj.ColorValue;
        end
    end
    flag=0;


    for i=1:numel(x)
        if(isnan(svgX(i))||isnan(svgY(i)))
            if(flag)


                svgString=[svgString,'" style="fill:',strjoin(string(colors),''),';fill-rule:evenodd;"/>'];
                flag=0;
            end
            continue;
        end
        if(flag==0)
            svgString=[svgString,'<polygon points="'];
            flag=1;
        end
        svgString=[svgString,string(svgX(i)),',',string(svgY(i))];
        if(i~=length(x))
            svgString=[svgString,' '];
        end
    end



    svgString=[svgString,'" style="fill:',strjoin(string(colors),''),';fill-rule:evenodd;"/>'];
    svgString=strjoin(svgString,'');
end
