function[strout,finalPos]=resizeText(hObj,updateState,str)
    strout=str;
    finalPos=hObj.Position;


    hFig=ancestor(hObj,'figure');

    if strcmpi(hObj.FitHeightToText,'off')
        doresize=false;
    else
        doresize=true;
    end

    hText=hObj.Text;

    if nargin<1
        str=cellstr(hText.String);
    else
        str=cellstr(str);
    end

    if isempty(str)||(isscalar(str)&&isempty(str{1}))
        return;
    end


    onecharspace=double(localGetStrSize(hText,updateState,{'A'}));
    twocharspace=double(localGetStrSize(hText,updateState,{'AA'}));
    xspace=((2*onecharspace(1))-twocharspace(1))/2;

    dstr=cell(1,1);
    line_count=0;
    needxresize=false;
    hRef=hFig;
    pos=hgconvertunits(hFig,get(hObj,'Position'),get(hObj,'Units'),...
    'points',hRef);
    NewPX=pos(1)+pos(3)/2;
    NewPWidth=pos(3);





    if strcmpi(hObj.FitBoxToText,'on')

        maxDims=localGetStrSize(hText,updateState,str);

        tempSize=localGetStrSize(hText,updateState,{'m'});
        maxDims(1)=maxDims(1)+xspace+tempSize(1);
        maxDims=hgconvertunits(hFig,[0,0,maxDims],'Points','Pixels',hRef);
        maxDims=maxDims(3:4);
        maxDims=maxDims+2*hObj.Margin;
        maxDims=hgconvertunits(hFig,[0,0,maxDims],'Pixels',hObj.Units,hRef);
        maxDims=maxDims(3:4);
        currPos=hObj.Position;
        sizeChange=currPos(3:4)-maxDims;


        currPos(3)=maxDims(1);
        currPos(4)=maxDims(2);



        if isempty(hObj.Pin)
            switch hObj.HorizontalAlignment
            case 'center'
                currPos(1)=currPos(1)+sizeChange(1)/2;
            case 'right'
                currPos(1)=currPos(1)+sizeChange(1);
            end
            switch hObj.VerticalAlignment
            case{'top','cap'}
                currPos(2)=currPos(2)+sizeChange(2);
            case 'middle'
                currPos(2)=currPos(2)+sizeChange(2)/2;
            end
        end
        finalPos=currPos;
    else

        sizes=localGetStrCellSizes(hText,updateState,str);
        dims=size(sizes);
        for i=1:dims(1);
            tystr=dstr;
            tystr{line_count+1}=str{i};
            tysize=localGetStrSize(hText,updateState,tystr);
            if sizes(i,1)<(pos(3)-2*hObj.Margin+xspace)


                line_count=line_count+1;
                dstr{line_count}=str{i,:};
            else


                [nwords,words,delim]=matlab.graphics.shape.TextBox.splitString(str{i},hText,updateState);
                w=1;
                line_word_count=1;
                line_length=0;
                line_string='';
                newysize=false;
                while w<=nwords

                    if line_word_count==1
                        test_string=[line_string,words{w}];
                    else
                        test_string=[line_string,delim{w-1},words{w}];
                    end
                    test_string_size=localGetStrSize(hText,updateState,test_string);

                    if newysize
                        tystr=dstr;
                        tystr{line_count+1}=test_string;
                        tysize=localGetStrSize(hText,updateState,tystr);
                        newysize=false;
                    end
                    if test_string_size(1)>pos(3)-2*hObj.Margin

                        if line_length==0


                            needxresize=true;
                            NewPX=max(NewPX,pos(1)+test_string_size(1)/2+hObj.Margin);
                            NewPWidth=max(NewPWidth,test_string_size(1)+2*hObj.Margin);


                            line_string=test_string;
                            w=w+1;
                        end

                        line_count=line_count+1;
                        cline_string=line_string;
                        dstr{line_count}=cline_string;
                        line_string='';
                        line_length=0;
                        line_word_count=1;
                        newysize=true;
                    else



                        line_string=test_string;
                        line_length=test_string_size(1);
                        if w==nwords

                            line_count=line_count+1;
                            cline_string=line_string;
                            dstr{line_count}=cline_string;
                            line_string='';
                            line_length=0;
                            line_word_count=1;
                            newysize=true;
                        else
                            line_word_count=line_word_count+1;
                        end
                        w=w+1;
                    end
                end
            end
        end

        ysize=max(tysize(2),onecharspace(2))+2*hObj.Margin;

        if doresize


            if isempty(hObj.Pin)
                pos(2)=pos(2)+pos(4)-ysize;
            end
            pos(4)=ysize;


            if needxresize
                pos(1)=NewPX-NewPWidth/2;
                pos(3)=NewPWidth;
            end
            finalPos=hgconvertunits(hFig,pos,'points',get(hObj,'Units'),hRef);
        end



        if(numel(dstr)==1)
            strout=dstr{1};
        else
            strout=dstr;
        end
    end

    function sizes=localGetStrCellSizes(hText,updateState,str)



        if isempty(str)
            sizes=[];
            return;
        end

        dims=size(str);
        ncells=dims(1);

        sizes=zeros(ncells,2);
        for i=1:ncells



            if~isempty(str{i})
                currSize=localGetStrSize(hText,updateState,str(i));
            else
                currSize=localGetStrSize(hText,updateState,{'m'});
            end
            sizes(i,1)=currSize(1);
            sizes(i,2)=currSize(2);
        end

        function size=localGetStrSize(hText,updateState,str)


            if~iscell(str)
                str={str};
            end
            size=[0,0];

            if~isempty(str)


                fontsize=hText.FontSize;
                if~strcmpi(hText.FontUnits,'Points')
                    up=matlab.graphics.general.UnitPosition;
                    up.ScreenResolution=get(groot,'ScreenPixelsPerInch');
                    up.RefFrame=updateState.ViewerPosition;
                    up.Units=hText.FontUnits;
                    up.Position(4)=hText.FontSize;
                    up.Units='Points';
                    fontsize=up.Position(4);
                end





                hFont=matlab.graphics.general.Font;
                hFont.Name=hText.FontName;
                hFont.Size=fontsize;
                hFont.Angle=hText.FontAngle;
                hFont.Weight=hText.FontWeight;
                smoothing='on';
                try
                    size=updateState.getStringBounds(str,hFont,hText.Interpreter,smoothing);
                catch


                    size=updateState.getStringBounds(str,hFont,'none',smoothing);




                end
            end

            if all(size==0)
                size=[1,1];
            end
