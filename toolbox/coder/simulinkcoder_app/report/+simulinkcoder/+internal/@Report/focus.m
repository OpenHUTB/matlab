function focus(obj,varargin)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        input=varargin{1};
        src=simulinkcoder.internal.util.getSource(input);
    end

    studio=src.studio;
    if isempty(studio)
        return;
    end


    id=obj.id;
    cmpName=obj.comp;
    comp=studio.getComponent(cmpName,id);
    if~isempty(comp)&&comp.isVisible
        studio.setActiveComponent(comp);
    end


