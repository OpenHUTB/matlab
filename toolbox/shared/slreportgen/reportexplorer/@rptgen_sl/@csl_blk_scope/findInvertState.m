function iState=findInvertState(c,fig,ihc)




    if(nargin<3)
        ihc=c.InvertHardcopy;
    end

    switch ihc
    case 'auto'
        iState=locAutoInvertHardcopy(fig);
    case{'on','off'}
        iState=ihc;
    case 'none'
        iState='off';
    otherwise
        iState=get(fig,'InvertHardcopy');
    end


    function result=locAutoInvertHardcopy(figHandle)


        axHandles=findall(double(figHandle),'Type','axes');
        figColor=get(figHandle,'Color');
        if~isnumeric(figColor)

            figColor=[1,1,1];
        end


        axTextHandles=false(1,length(axHandles));
        for i=1:length(axHandles)
            axChildrenTypes=get(get(axHandles(i),'Children'),'Type');


            if ischar(axChildrenTypes)&&strcmpi(axChildrenTypes,'Text')
                axTextHandles(i)=true;
            end
        end
        axHandles(axTextHandles)=[];

        axColor=get(axHandles,'Color');
        if~isempty(axColor)
            if iscell(axColor)
                stringIdx=find(cellfun('isclass',axColor,'char'));
                if~isempty(stringIdx)
                    [axColor{stringIdx}]=deal(figColor);
                end
                colorMatrix=cat(1,axColor{:});
            else
                if~isnumeric(axColor)

                    colorMatrix=figColor;
                else
                    colorMatrix=axColor;
                end
            end
            colorMatrix=rgb2hsv(colorMatrix);
            colorMatrix=mean(colorMatrix(:,3));

            if(colorMatrix<0.5)
                result='on';
            else
                result='off';
            end
        else
            result='off';
        end
