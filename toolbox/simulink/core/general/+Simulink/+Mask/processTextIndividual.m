function svgString=processTextIndividual(obj,cmd,params)



    svgString='';

    if(length(params)<3)
        return;
    end



    marginHeight=0;
    marginWidth=0;


    x=params{1};
    y=params{2};



    if(strcmpi(obj.Units,'normalized'))
        x=x*(obj.Width-2*marginWidth);
        y=y*(obj.Height-2*marginHeight);
    elseif(strcmpi(obj.Units,'autoscale')&&strcmpi(cmd,'text'))
        if((isinf(obj.MaxX)||isnan(obj.MaxX))||(isinf(obj.MaxY)||isnan(obj.MaxY))||(isinf(obj.MinX)||isnan(obj.MinX))||(isinf(obj.MinY)||isnan(obj.MinY)))
            if(x<1&&y<1)
                maxx=1;
                maxy=1;
                minx=0;
                miny=0;
            else
                maxx=100;
                maxy=100;
                minx=0;
                miny=0;
            end
        else
            maxx=obj.MaxX;
            maxy=obj.MaxY;
            minx=obj.MinX;
            miny=obj.MinY;
        end

        x=(x-minx)*(obj.Width-2*marginWidth)/(maxx-minx);
        y=(y-miny)*(obj.Height-2*marginHeight)/(maxy-miny);
    end


    y=obj.Height-y;







    x=x+marginWidth;
    y=y-marginWidth;


    text=params{3};


    halign='';
    valign='';
    if(length(params)>3)

        if(strcmpi(params{4},'texmode'))


            text=Simulink.Mask.cleanMath(string(text));
            if(~isempty(obj.ColorValue))
                svgString=[svgString,'<math x="',string(x),'" y="',string(y),'" style="fill:',string(obj.ColorValue),'">',string(text),'</math>'];
            else
                svgString=[svgString,'<math x="',string(x),'" y="',string(y),'" >',string(text),'</math>'];
            end
            svgString=strjoin(svgString,'');
            return;
        end


        if(length(params)>=5)
            if(strcmpi(params{4},'horizontalAlignment')||~isempty(regexp('horizontalAlignment',['^',params{4}],'once')))
                halign=Simulink.Mask.textHprocess(params{5});
            end
            if(strcmpi(params{4},'verticalAlignment')||~isempty(regexp('verticalAlignment',['^',params{4}],'once')))
                valign=Simulink.Mask.textVprocess(params{5});
            end
        end
        if(length(params)>6)
            if(strcmpi(params{6},'horizontalAlignment')||~isempty(regexp('horizontalAlignment',['^',params{6}],'once')))
                halign=Simulink.Mask.textHprocess(params{7});
            end
            if(strcmpi(params{6},'verticalAlignment')||~isempty(regexp('verticalAlignment',['^',params{6}],'once')))
                valign=Simulink.Mask.textVprocess(params{7});
            end
        end
    end


    if(~isempty(obj.ColorValue))
        svgString=[svgString,'<text x="',string(x),'" y="',string(y),'" style="fill:',string(obj.ColorValue),'" '];
    else
        svgString=[svgString,'<text x="',string(x),'" y="',string(y),'" '];
    end


    hOptions='';
    if(~isempty(halign))
        svgString=[svgString,'text-anchor="',string(halign),'" '];
        if(strcmpi(halign,'start'))
            hOptions='AnchorX:Left;';
        end
        if(strcmpi(halign,'end'))
            hOptions='AnchorX:Right;';
        end
        if(strcmpi(halign,'middle'))
            hOptions='AnchorX:Center;';
        end
    else
        svgString=[svgString,'text-anchor="start" '];
        hOptions='AnchorX:Left;';
    end


    vOptions='';
    if(~isempty(valign))
        if(strcmp(valign,'base')||strcmp(valign,'cap'))
            warning('Unsupported commands! DVG does not have support for these commands yet!');
        end
        if(strcmpi(valign,'base'))
            svgString=[svgString,'alignment-baseline="base" '];
        end
        if(strcmpi(valign,'top'))
            svgString=[svgString,'alignment-baseline="text-before-edge" '];
            vOptions='AnchorY:Top';
        end
        if(strcmpi(valign,'bottom'))
            vOptions='AnchorY:Bottom';
            svgString=[svgString,'alignment-baseline="text-after-edge" '];
        end
        if(strcmpi(valign,'middle'))
            svgString=[svgString,'alignment-baseline="middle" '];
            vOptions='AnchorY:Center';
        end

    else
        svgString=[svgString,'alignment-baseline="center" '];
        vOptions='AnchorY:Center';
    end


    parts=regexp(string(text),'(\n|\\n)','split');
    svgSubString='';

    svgString=[svgString,'d:options="',string(hOptions),string(vOptions),'"','>'];
    if(isempty(parts{length(parts)}))
        parts=parts(1:length(parts)-1);
    end




    num=length(parts);


    if(num==1)
        if(strcmp(cmd,'text'))
            svgString=[svgString,'<tspan dy="0.45em">',Simulink.Mask.stringEncode(parts(1)),'</tspan></text>'];
        else
            svgString=[svgString,Simulink.Mask.stringEncode(parts(1)),'</text>'];
        end
        svgString=strjoin(svgString,'');
        return;
    end






    if(mod(num,2)==0)
        initDy=-0.1*(num-2)/2-0.05;
        initDy=initDy-(num-2)/2;
    else
        initDy=-(num-3)/2-0.5;
        initDy=initDy-0.1*(num-1)/2;
    end

    initDy=initDy-0.2;
    dySpace=1.1;

    for i=1:length(parts)
        if(~isempty(parts{i}))
            parts(i)=Simulink.Mask.stringEncode(parts(i));
        else
        end
        if(i==1)
            svgSubString=[svgSubString,'<tspan x="',string(x),'" dy="',string(initDy),'em">',parts(i),'</tspan>'];
            continue;
        end
        svgSubString=[svgSubString,'<tspan x="',string(x),'" dy="',string(dySpace),'em">',parts(i),'</tspan>'];
        dySpace=1.1;
    end


    svgString=[svgString,svgSubString];
    svgString=[svgString,'</text>\n'];


    svgString=strjoin(svgString,'');
end