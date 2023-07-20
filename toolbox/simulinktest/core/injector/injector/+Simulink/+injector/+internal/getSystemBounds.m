function[leftBound,topBound,rightBound,botBound]=getSystemBounds(system,varargin)



























    if nargin==1

        B=find_system(system,'FindAll','on','SearchDepth',1,'type','block');
        A=find_system(system,'FindAll','on','SearchDepth',1,'type','annotation');
        L=find_system(system,'FindAll','on','SearchDepth',1,'type','line');
    else
        assert(nargin==1|nargin==4,['Error: There should be 1 or 4 inputs to ',mfilename,'.m.']);
        B=varargin{1};
        A=varargin{2};
        L=varargin{3};
    end


    [lb,tb,rb,bb]=blocksBounds(B);
    [la,ta,ra,ba]=annotationsBounds(A);
    [ll,tl,rl,bl]=linesBounds(L);


    leftBound=min([lb,ll,la]);
    topBound=min([tb,tl,ta]);
    rightBound=max([rb,rl,ra]);
    botBound=max([bb,bl,ba]);
end





function[leftBound,topBound,rightBound,botBound]=blocksBounds(blocks)




















    rightBound=-1073741823;
    leftBound=1073741823;
    botBound=-1073741823;
    topBound=1073741823;


    for i=1:length(blocks)
        if iscell(blocks(i))
            itemBounds=get_param(blocks{i},'Position');
        else
            itemBounds=get_param(blocks(i),'Position');
        end



        if itemBounds(3)>rightBound

            rightBound=itemBounds(3);
        end
        if itemBounds(1)<leftBound

            leftBound=itemBounds(1);
        end

        if itemBounds(4)>botBound

            botBound=itemBounds(4);
        end
        if itemBounds(2)<topBound

            topBound=itemBounds(2);
        end
    end
end

function[leftBound,topBound,rightBound,botBound]=annotationsBounds(annotations)
















    rightBound=-32767;
    leftBound=32767;
    botBound=-32767;
    topBound=32767;


    for i=1:length(annotations)
        if iscell(annotations(i))
            itemBounds=get_param(annotations{i},'Position');
        else
            itemBounds=get_param(annotations(i),'Position');
        end



        if itemBounds(3)>rightBound

            rightBound=itemBounds(3);
        end
        if itemBounds(1)<leftBound

            leftBound=itemBounds(1);
        end

        if itemBounds(4)>botBound

            botBound=itemBounds(4);
        end
        if itemBounds(2)<topBound

            topBound=itemBounds(2);
        end
    end
end

function[leftBound,topBound,rightBound,botBound]=linesBounds(lines)
















    rightBound=-32767;
    leftBound=32767;
    botBound=-32767;
    topBound=32767;


    for i=1:length(lines)
        if iscell(lines(i))
            points=get_param(lines{i},'Points');
            itemBounds=[min(points(:,1)),min(points(:,2)),max(points(:,1)),max(points(:,2))];
        else
            points=get_param(lines(i),'Points');
            itemBounds=[min(points(:,1)),min(points(:,2)),max(points(:,1)),max(points(:,2))];
        end



        if itemBounds(3)>rightBound

            rightBound=itemBounds(3);
        end
        if itemBounds(1)<leftBound

            leftBound=itemBounds(1);
        end

        if itemBounds(4)>botBound

            botBound=itemBounds(4);
        end
        if itemBounds(2)<topBound

            topBound=itemBounds(2);
        end
    end
end