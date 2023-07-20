function hide(obj,varargin)


    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(varargin{1});
    end

    studio=src.studio;
    if isempty(studio)
        return;
    end

    cmpName=obj.comp;
    id=obj.id;
    comp=studio.getComponent(cmpName,id);
    if~isempty(comp)
        studio.destroyComponent(comp);
    end
