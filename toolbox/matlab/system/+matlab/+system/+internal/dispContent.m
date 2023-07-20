function varargout=dispContent(hobj,maxlevel,props)

















    narginchk(1,3);

    if nargin<3||isempty(props)
        props=fieldnames(hobj);
    end

    if~iscell(props)
        validateattributes(props,{'cell'},{},'matlab.system.internal.dispContent','PROPS');
    end

    if nargin<2
        maxlevel=1;
    end
    validateattributes(maxlevel,{'numeric'},{'integer','positive','scalar'},...
    'sigutils.dispContent','maxLevel');



    rpbuffer='';


    defaultpadding=4;


    frontspacing=repmat(' ',1,defaultpadding);



    colonstring=': ';

    startDisp='';

    if strcmpi(get(0,'formatspacing'),'loose')
        looseFormat=true;
    else
        looseFormat=false;
    end

    if~isempty(startDisp)
        rpbuffer=sprintf('%s%s%s\n',rpbuffer,frontspacing,startDisp);
        if looseFormat
            rpbuffer=sprintf('%s\n',rpbuffer);
        end
    end


    lvl=1;




    rpbuffer=updatereport(hobj,props,rpbuffer,colonstring,...
    defaultpadding+length(startDisp),lvl,maxlevel,looseFormat);

    displaystring1=rpbuffer;
    crs=[0,regexp(displaystring1,char(10))];
    displaystring=displaystring1(crs(1)+1:crs(2)-1);
    for ii=2:length(crs)-1
        displaystring=char(displaystring,displaystring1(crs(ii)+1:crs(ii+1)-1));
    end

    displaystring=char(displaystring,' ');
    if nargout
        varargout{1}=displaystring;
    else
        disp(displaystring);
    end

end

function strbuf=updatereport(sys,props,strbuf,delimiter,frontspacenum,lvl,maxlvl,looseFormat)

    props=sortpropsfordisp(props);

    maxspace=getspacing(props);


    emptylinelevelmax=0;

    for m=1:length(props)
        tempprop=props(m);
        tempval=sys.(tempprop{1});

        frontspacing=repmat(' ',1,frontspacenum);


        padding=repmat(' ',1,maxspace-length(tempprop{1}));

        if ischar(tempval)



            if size(tempval,1)>1||...
                length(tempval)>maxwidth(length(frontspacing)+maxspace)
                tempvaldisp=shortdescription(tempval);
            else
                tempvaldisp=sprintf('''%s''',tempval);
            end
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval,'embedded.fi')

            tempvaldisp=shortdescription(tempval);
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval,'embedded.numerictype')
            tempvaldisp=tempval.tostring;
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval,'strel')
            tempvaldisp='[1x1 strel]';
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval,'function_handle')
            tempvaldisp=func2str(tempval);
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isstruct(tempval)||isobject(tempval)||...
            isa(tempval,'handle.handle')
            if lvl<maxlvl




                tempvaldisp='';
            else

                tempvaldisp=shortdescription(tempval);
            end

            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

            if lvl<maxlvl
                strbuf=updatereport(tempval,fieldnames(tempval),strbuf,delimiter,...
                frontspacenum+maxspace+length(delimiter),lvl+1,maxlvl,looseFormat);
            end

            if lvl<=emptylinelevelmax


                strbuf=sprintf('%s\n',strbuf);
            end

        elseif iscellstr(tempval)




            [cellstrrows,cellstrcols]=size(tempval);
            tempvaldisp=sprintf('%s','{');

            if(cellstrrows==0)||(cellstrcols==0)
                tempvaldisp=sprintf('%s}',tempvaldisp);

            elseif cellstrrows==1

                for cidx=1:cellstrcols
                    tempvaldisp=sprintf('%s''%s'' ',tempvaldisp,tempval{cidx});
                end
                tempvaldisp(end)='}';

            elseif cellstrcols==1

                for ridx=1:cellstrrows
                    tempvaldisp=sprintf('%s''%s'';',tempvaldisp,tempval{ridx});
                end
                tempvaldisp(end)='}';

            else

                for ridx=1:cellstrrows
                    for cidx=1:cellstrcols
                        tempvaldisp=sprintf('%s''%s'' ',tempvaldisp,tempval{ridx,cidx});
                    end
                    tempvaldisp(end)=';';
                end
                tempvaldisp(end)='}';
            end

            if length(tempvaldisp)>maxwidth(length(frontspacing)+maxspace)
                tempvaldisp=shortdescription(tempval);
            end
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        else


            if iscell(tempval)||isempty(tempval)||~ismatrix(tempval)
                tempvaldisp=shortdescription(tempval);
            elseif 2*numel(tempval)+1>maxwidth(length(frontspacing)+maxspace)





                tempvaldisp=shortdescription(tempval);
            else
                tempvaldisp=mat2str(tempval);
            end

            if length(tempvaldisp)>maxwidth(length(frontspacing)+maxspace)
                tempvaldisp=shortdescription(tempval);
            end
            strbuf=writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        end

        if looseFormat



        end
    end
end


function valuestr=shortdescription(value)

    sz=size(value);

    if sum(sz)==0
        valuestr='[]';
        return;
    end

    if iscell(value)
        valuestr='{';
    else
        valuestr='[';
    end

    for kndx=1:length(sz)-1
        valuestr=sprintf('%s%dx',valuestr,sz(kndx));
    end

    valuestr=sprintf('%s%d %s',valuestr,sz(end),class(value));

    if iscell(value)
        valuestr=sprintf('%s}',valuestr);
    else
        valuestr=sprintf('%s]',valuestr);
    end

end

function spacing=getspacing(props)

    if~iscell(props{1})
        props={props};
    end

    spacing=0;

    for indx=1:length(props)
        for jndx=1:length(props{indx})
            spacing=max(length(props{indx}{jndx}),spacing);
        end
    end

end

function maxw=maxwidth(padding)
    cmdwinsize=matlab.desktop.commandwindow.size;
    maxw=max(60,cmdwinsize(1)-padding-2);
end

function strbuf=writestr(strbuf,frontspacing,prop,padding,delimiter,propvalstr)
    strbuf=sprintf('%s%s%s%s%s%s\n',strbuf,frontspacing,padding,prop,...
    delimiter,propvalstr);
end

function sortedprops=sortpropsfordisp(props)

    descriptionProps={'Description'};
    descriptionPresent=ismember(descriptionProps,props);
    [~,sortedpropsidx]=setdiff(props,descriptionProps);
    otherprops=props(sort(sortedpropsidx));
    sortedprops=[descriptionProps{descriptionPresent};otherprops(:)];
end


