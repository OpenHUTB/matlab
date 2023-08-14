classdef ChangeLogDialog<handle




    properties(Access='public')
        ContinueSaving;
        ModelName;
    end

    methods(Access='public')
        function obj=ChangeLogDialog(modelname)
            if nargin>0&&~isempty(modelname)
                obj.ModelName=bdroot(modelname);
            else
                obj.ModelName=bdroot;
            end
            assert(bdIsLoaded(obj.ModelName),'Model must be loaded');
        end

        function dlgstruct=getDialogSchema(obj,~)


            assert(bdIsLoaded(obj.ModelName),'Model must be loaded');

            text.Type='editarea';
            text.Name=DAStudio.message('Simulink:utility:changelogModifiedComment');
            text.Value=i_get_text(obj);
            text.Tag='text';
            text.RowSpan=[1,1];

            add_comment.Type='checkbox';
            add_comment.Name=DAStudio.message('Simulink:utility:changelogIncludeModified');
            add_comment.Tag='add_comment';
            add_comment.Value=true;
            add_comment.RowSpan=[2,2];
            add_comment.ObjectMethod='controlCallback';
            add_comment.MethodArgs={'%dialog'};
            add_comment.ArgDataTypes={'handle'};

            prompt_next_time.Type='checkbox';
            prompt_next_time.Name=DAStudio.message('Simulink:utility:changelogShowAgain');
            prompt_next_time.Tag='prompt_next_time';
            prompt_next_time.Value=true;
            prompt_next_time.RowSpan=[3,3];
            prompt_next_time.ObjectMethod='controlCallback';
            prompt_next_time.MethodArgs={'%dialog'};
            prompt_next_time.ArgDataTypes={'handle'};

            dlgstruct.DialogTitle=DAStudio.message('Simulink:utility:changelogWindowName',obj.ModelName);
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.LayoutGrid=[3,1];
            dlgstruct.Items={text,add_comment,prompt_next_time};
            dlgstruct.DialogTag='ChangeLog';
            dlgstruct.Sticky=true;

            dlgstruct.PostApplyMethod='dlgCallback';
            dlgstruct.PostApplyArgs={'%dialog','save'};
            dlgstruct.PostApplyArgsDT={'handle','string'};

            dlgstruct.CloseMethod='dlgCallback';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};

        end

        function controlCallback(~,dlg)


            add_comment=dlg.getWidgetValue('add_comment');
            dlg.setEnabled('text',add_comment);
        end

        function[success,msg]=dlgCallback(obj,dlg,action)
            if strcmp(action,'save')

                assert(bdIsLoaded(obj.ModelName),'Model must be loaded');
                set_param(obj.ModelName,'UpdateHistoryNextTime',i_onoff(dlg,'prompt_next_time'));
                set_param(obj.ModelName,'Includelog',i_onoff(dlg,'add_comment'))
                set_param(obj.ModelName,'ModifiedComment',dlg.getWidgetValue('text'));
                obj.ContinueSaving=true;

            elseif strcmp(action,'cancel')

                obj.ContinueSaving=false;
            end

            success=true;
            msg='';

            function str=i_onoff(dlg,key)
                b=dlg.getWidgetValue(key);
                if b
                    str='on';
                else
                    str='off';
                end
            end
        end
    end

    methods(Access='private')
        function text=i_get_text(obj)
            modelname=obj.ModelName;


            modifiedComment=get_param(modelname,'ModifiedComment');
            modifiedHistory=get_param(modelname,'ModifiedHistory');
            if~isempty(modifiedComment)&&~contains(modifiedHistory,modifiedComment)
                text=modifiedComment;
            else
                authorString=get_param(modelname,'ModifiedBy');
                dateString=get_param(modelname,'ModifiedDate');
                versionString=Simulink.ModelVersionFormat(modelname).increment();
                text=[authorString,' -- ',dateString,' -- Version ',versionString];
            end
        end
    end
end