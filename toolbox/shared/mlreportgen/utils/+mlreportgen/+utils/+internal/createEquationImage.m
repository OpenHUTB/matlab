function texWarning=createEquationImage(filename,equationText,formattype,fontSize,varargin)

















    color=[];
    backgroundColor=[];

    len=length(varargin);
    if len>0
        color=varargin{1};
    end
    if len>1
        backgroundColor=varargin{2};
    end


    [tempfigure,temptext]=getRenderingFigure(fontSize,color,backgroundColor);



    texWarning=renderTex(['$',equationText,'$'],temptext);



    set(temptext,'Units','pixels');
    set(tempfigure,'Units','pixels');



    textposition=[0,2,0];

    set(temptext,'Position',textposition);



    extend=get(temptext,'Extent');
    width=extend(3)+extend(1);
    height=extend(4)+extend(2);


    position=get(tempfigure,'Position');
    position(3)=width;
    position(4)=height;
    set(tempfigure,'Position',position);

    print(tempfigure,filename,formattype);

    [~,~,fileExt]=fileparts(filename);


    if(round(tempfigure.Position(3),2)~=round(position(3),2))
        if strcmp(fileExt,'.svg')


            fixSVGImageSize(filename,position);
        end
    end


    if~isempty(tempfigure)
        close(tempfigure)
    end

end


function texWarning=renderTex(equationText,temptext)


    set(temptext,'string','');
    drawnow;
    [lastMsg,lastId]=lastwarn('');












    text=regexprep(equationText,'\s+','\\;');

    set(temptext,'string',text);
    drawnow;


    texWarning=lastwarn;



    if~isempty(texWarning)
        set(temptext,'Interpreter','none');
        set(temptext,'string',equationText);
    end
    lastwarn(lastMsg,lastId)
end


function[tempfigure,temptext,tempaxes]=getRenderingFigure(fontSize,color,backgroundColor)


    tag=['helper figure for ',mfilename];
    tempfigure=findall(0,'type','figure','tag',tag);
    tempaxes=[];
    temptext=[];
    if isempty(tempfigure)
        figurePos=get(0,'ScreenSize');
        if ispc


            figurePos(1:2)=figurePos(3:4)+100;
        end

        tempfigure=figure(...
        'HandleVisibility','off',...
        'IntegerHandle','off',...
        'Visible','off',...
        'PaperPositionMode','auto',...
        'PaperOrientation','portrait',...
        'Color','w',...
        'Position',figurePos,...
        'Tag',tag);
    else

        tempaxes=findobj(tempfigure,'type','axes');
        if~isempty(tempaxes)
            temptext=findobj(tempaxes,'type','text');
        end
    end
    if isempty(tempaxes)
        tempaxes=axes('position',[0,0,1,1],...
        'Parent',tempfigure,...
        'XTick',[],'ytick',[],...
        'XLim',[0,1],'ylim',[0,1],...
        'Visible','off');
    end
    if isempty(temptext)
        temptext=text('Parent',tempaxes,'Position',[.5,.5],...
        'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',fontSize,...
        'Interpreter','latex');
    end
    if~isempty(color)
        temptext.Color=color;
    end
    if~isempty(backgroundColor)
        temptext.BackgroundColor=backgroundColor;
    end
end

function fixSVGImageSize(filename,position)




    txt=fileread(filename);


    formatWidth='width="%s"';


    if ispc()
        SCALE=mlreportgen.utils.internal.getDPIScale();
    else
        SCALE=1;
    end

    replaceWidth=compose(formatWidth,num2str(position(3)*SCALE));
    txt=regexprep(txt,'width\s*=\s*\"\s*\d*\s*"',replaceWidth,'once');


    fileId=fopen(filename,'w');
    fprintf(fileId,'%s',txt);
    fclose(fileId);
end