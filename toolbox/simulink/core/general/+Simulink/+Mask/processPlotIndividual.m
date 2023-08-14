function svgString=processPlotIndividual(obj,params,plotDetails)



    svgString='';


    x=params{1};
    y=params{2};



    if(numel(size(x))==2&&~(size(x,1)==1||size(x,2)==1))
        if(all(size(x)==size(y)))
            for i=1:size(x,2)


                svgString=[svgString,Simulink.Mask.processPlotIndividual(obj,{x(:,i),y(:,i)},plotDetails)];
            end
        else
            warning('X anf Y dimensions should match!');
        end
        return;
    end



    bufferWidth=3;
    bufferHeight=2;


    if(isempty(x))
        return;
    end


    t=num2cell(plotDetails);
    [minX,maxX,minY,maxY]=deal(t{:});



    if(maxX-minX==0)
        svgX=zeros(1,numel(x));


    else
        svgX=(obj.Width-2*bufferWidth)*(x-minX)/(maxX-minX);
    end



    if(maxY-minY==0)
        svgY=zeros(1,numel(x));



    else
        svgY=(obj.Height-2*bufferHeight)*(y-minY)/(maxY-minY);
    end



    svgY=obj.Height-svgY;



    svgX=svgX+bufferWidth;
    svgY=svgY-bufferHeight;

    i=1;
    flag=0;


    while(i<=numel(svgX))



        if(isnan(svgX(i))||isnan(svgY(i))||isinf(svgX(i))||isinf(svgY(i)))

            while(i<=numel(svgX)&&...
                (isnan(svgX(i))||isnan(svgY(i))||isinf(svgX(i))||isinf(svgY(i))))
                i=i+1;
            end

            if(flag)

                if(isempty(obj.ColorValue))
                    svgString=[svgString,'" style="fill:none;"/>'];
                else
                    svgString=[svgString,'" style="fill:none;stroke:',string(obj.ColorValue),'"/>'];
                end
            end

            if(i>numel(svgX))

                if(~isempty(svgString))
                    svgString=strjoin(string(svgString),'');
                end
                return;
            end

            svgString=[svgString,sprintf('\n')];


            flag=0;
        end


        if(~flag)
            svgString=[svgString,'<polyline points="'];
            flag=1;
        else
            svgString=[svgString,' '];
        end

        svgString=[svgString,string(svgX(i)),',',string(svgY(i))];
        i=i+1;
    end


    if(isempty(obj.ColorValue))
        svgString=[svgString,'" style="fill:none;stroke:black"/>'];
    else
        svgString=[svgString,'" style="fill:none;stroke:',string(obj.ColorValue),'"/>'];
    end


    svgString=strjoin(svgString,'');
end