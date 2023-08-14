classdef DialogParameter<lutdesigner.data.source.DataSource

    methods
        function this=DialogParameter(parameterOwner,parameterName)
            this=this@lutdesigner.data.source.DataSource(...
            'dialog',...
            regexprep(getfullname(parameterOwner),'\s',' '),...
            parameterName);
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction.empty();
        end

        function restrictions=getWriteRestrictionsImpl(this)
            import lutdesigner.data.restriction.WriteRestriction

            if isParameterProtected(this.Source,this.Name)
                restrictions=WriteRestriction(message('lutdesigner:data:protectedParameter',this.Name));
                return;
            end

            rootModel=bdroot(this.Source);
            if ismember(get_param(rootModel,'SimulationStatus'),{...
                'updating','initializing','running','paused','terminating'})
                restrictions=WriteRestriction('lutdesigner:data:runtimeTuningLimitation');
            elseif strcmp(get_param(rootModel,'Lock'),'on')
                restrictions=WriteRestriction('lutdesigner:data:parameterOwnerInLockedLibrary');
            elseif~isempty(findLinkedParent(this.Source))
                restrictions=WriteRestriction('lutdesigner:data:parameterOwnerInLinkedSystem');
            else
                restrictions=WriteRestriction.empty();
            end
        end

        function data=readImpl(this)
            data=lutdesigner.utilities.resolveParameterString(...
            this.Source,this.Name,get_param(this.Source,this.Name));
        end

        function writeImpl(this,data)
            if isa(data,'double')||islogical(data)
                fmat2str=@(data)mat2str(data);
            else
                fmat2str=@(data)mat2str(data,'class');
            end

            if ismatrix(data)
                valstr=fmat2str(data);
            else
                valstr=sprintf("reshape(%s, %s)",fmat2str(data(:)'),mat2str(size(data)));
            end

            set_param(this.Source,this.Name,valstr);
        end
    end
end

function tf=isParameterProtected(parameterOwner,parameterName)

    maskObject=Simulink.Mask.get(parameterOwner);
    if~isempty(maskObject)
        maskParameter=maskObject.getParameter(parameterName);
        tf=isempty(maskParameter)||strcmp(maskParameter.Visible,'off')||...
        (strcmp(maskParameter.ReadOnly,'on')||strcmp(maskParameter.Enabled,'off'));
        return;
    end

    dialogParameters=get_param(parameterOwner,'DialogParameters');
    tf=ismember('read-only',dialogParameters.(parameterName).Attributes);
end

function linkedParent=findLinkedParent(parameterOwner)
    linkedParent='';
    parent=get_param(parameterOwner,'Parent');
    while~isempty(parent)
        if isLinked(get_param(parent,'Object'))
            linkedParent=parent;
            break;
        end
        parent=get_param(parent,'Parent');
    end
end
