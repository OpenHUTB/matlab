function buseditor(varargin)










    narginchk(0,3);

    closeEditor=false;

    if(nargin>0)
        args=varargin(2:end);


        if~any(strcmp(varargin(1),{'Close','Create'}))
            return;
        end



        if strcmp(varargin(1),'Create')
            if(isempty(args))
                return;
            end
        elseif strcmp(varargin(1),'Close')
            closeEditor=true;
        end
    else
        Simulink.typeeditor.init;
        return;
    end

    ed=Simulink.typeeditor.app.Editor.getInstance;
    if(~closeEditor)

        if~isempty(args)
            if length(args)==2
                if isa(args{2},'Simulink.data.BaseWorkspace')||isa(args{2},'Simulink.data.DataDictionary')
                    context=args{2};
                else
                    return;
                end
            else
                context=Simulink.data.BaseWorkspace;
            end

            if~ed.isVisible
                ed.open;
            end

            edSource=ed.getSource;
            if isa(context,'Simulink.data.DataDictionary')
                fileSpec=context.DataSource.filespec;
                [~,name,~]=fileparts(fileSpec);
                sourceIdx=edSource.findIdx(name);
                if isempty(sourceIdx)
                    Simulink.typeeditor.actions.openDictionary(fileSpec,true);
                    root=edSource.Children(end);
                else
                    root=edSource.Children(sourceIdx);
                end
            else
                root=edSource.Children(1);
            end



            drawnow;
            nodeToSelect=Simulink.typeeditor.utils.getNodeFromPath(root,args{1});
            typeEditorFeatureOff=(slfeature('TypeEditorStudio')==0);
            varTypeExists=~isempty(args)&&~isempty(args{1})&&context.exist(args{1});
            varTypeSatisfiedTEOff=typeEditorFeatureOff&&...
            varTypeExists&&...
            (context.evalin(['isa(',args{1},', ''',ed.DefaultBaseType,''')'])||...
            context.evalin(['isa(',args{1},', ''',ed.AdditionalBaseType,''')']));
            varTypeSatisfiedTEOn=~typeEditorFeatureOff&&...
            varTypeExists&&...
            any(cellfun(@(type)context.evalin(['isa(',args{1},', ''',type,''')']),...
            Simulink.typeeditor.app.Editor.AcceptableTypes(:,1)'));
            varTypeSatisfied=varTypeSatisfiedTEOff||varTypeSatisfiedTEOn;
            if varTypeSatisfied
                if~isempty(nodeToSelect)
                    ed.open(root,nodeToSelect);
                    return;
                end
            end
            if~isempty(root)
                ed.open(root,[]);
            end
        else
            ed.open;
        end
    else
        ed.close;
        return;
    end