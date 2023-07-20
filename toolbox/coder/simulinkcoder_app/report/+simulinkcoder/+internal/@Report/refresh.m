function refresh(obj,varargin)





    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        input=varargin{1};
        src=simulinkcoder.internal.util.getSource(input);
    end

    mdl=src.modelName;
    data=mdl;

    if nargin==3
        data=varargin{2};
    end


    obj.publish(mdl,'refresh',data);

    studio=src.studio;
    if~isempty(studio)
        dlgs=DAStudio.ToolRoot.getOpenDialogs;
        for i=1:length(dlgs)
            dlg=dlgs(i);
            src=dlg.getDialogSource;
            if isa(src,'simulinkcoder.internal.CodeView')
                if src.studio==studio
                    dlg.refresh();
                end
            end
        end
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        if cp.isInPerspective(studio)
            obj.focus(mdl);
        end
    end
