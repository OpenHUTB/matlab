



classdef AnnotationPropertySchema<handle

    properties(SetAccess=private)
        source='';
    end

    methods
        function this=AnnotationPropertySchema(h)
            if isa(h,'Simulink.Annotation')
                this.source=h;
            else
                ME=MException('AnnotationPropertySchema:InvalidSourceType',...
                'The source type is not an annotation');
                throw(ME);
            end
        end

        function tabview=supportTabView(~)
            tabview=false;
        end

        function mode=rootNodeViewMode(~,~)
            mode='SlimDialogView';
        end

        function showPropertyHelp(obj,~)
            h=obj.source;
            switch h.annotationType
            case{'note_annotation','area_annotation'}
                helpview([docroot,'/mapfiles/simulink.map'],'annotation_props_dlg');
            case 'image_annotation'
                helpview([docroot,'/mapfiles/simulink.map'],'image_props_dlg');
            end
        end

        function ret=setPropertyValues(obj,pairs,~)
            ret='';
            parent=get_param(obj.source.Handle,'Parent');
            pHandle=get_param(parent,'Handle');
            editor=SLM3I.SLDomain.getLastActiveEditorFor(pHandle);

            if isempty(editor)
                setPropertyValuesHelper(obj,pairs);
            else
                h=obj.source;
                switch h.annotationType
                case 'note_annotation'
                    commandStr='Simulink:dialog:AnnotationUndoRedoCommand';
                case 'image_annotation'
                    commandStr='Simulink:dialog:ImageUndoRedoCommand';
                case 'area_annotation'
                    commandStr='Simulink:dialog:AreaUndoRedoCommand';
                end
                editor.createMCommand(commandStr,DAStudio.message(commandStr),@setPropertyValuesHelper,{obj,pairs});
            end
        end

        function setPropertyValuesHelper(obj,pairs)
            prop=pairs{1,1};
            value=pairs{1,2};
            switch prop
            case 'Font'
                vals=strsplit(value,':');
                set_param(obj.source.Handle,'FontName',vals{1},'FontSize',vals{2},...
                'FontAngle',vals{3},'FontWeight',vals{4});
            otherwise
                set_param(obj.source.Handle,prop,value);
            end
        end

        function type=getObjectType(obj)
            h=obj.source;
            switch h.annotationType
            case 'note_annotation'
                type=DAStudio.message('Simulink:dialog:AnnotationTypeAnnotation');
            case 'image_annotation'
                type=DAStudio.message('Simulink:dialog:AnnotationTypeImage');
            case 'area_annotation'
                type=DAStudio.message('Simulink:dialog:AnnotationTypeArea');

            end
        end
    end
end
