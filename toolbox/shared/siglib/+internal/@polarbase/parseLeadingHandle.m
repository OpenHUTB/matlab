function args=parseLeadingHandle(p,args)



















    if numel(args)>0
        anyParent=find(strcmp(args,'Parent'),1);
        if anyParent
            h=args{anyParent+1};
            args(anyParent:anyParent+1)=[];
            if~isempty(args)&&isscalar(args{1})&&ishghandle(args{1})
                args=args(2:end);
            end
        else
            h=args{1};
        end
        if isscalar(h)&&ishghandle(h)
            if isempty(anyParent)
                args=args(2:end);
            end
            if~isnumeric(h)&&isprop(h,'Type')
                switch h.Type
                case{'figure','uicontainer','uipanel'}
                    p.Parent=h;
                    p.hAxes=[];
                    p.hFigure=ancestor(h,'figure');
                case 'axes'
                    p.Parent=h.Parent;
                    p.hAxes=h;
                    p.hFigure=ancestor(h,'figure');
                otherwise
                    error(message('siglib:polarpattern:HandleInput'));
                end
            else
                p.Parent=ancestor(h,'figure');
                p.hAxes=[];
                p.hFigure=ancestor(h,'figure');
            end
        end
    end