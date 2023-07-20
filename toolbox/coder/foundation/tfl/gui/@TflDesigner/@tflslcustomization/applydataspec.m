function applydataspec(this,dlghandle)





    if this.speccount>0
        for i=1:length(this.object)
            obj=this.object(i);

            obj.SupportedLanguages=eval(formcell(...
            dlghandle.getWidgetValue(['Tfldesigner_SupportLanguages_',num2str(i)])));

            index=dlghandle.getWidgetValue(['Tfldesigner_AlignmentPosition_',num2str(i)]);
            pentries={'DATA_ALIGNMENT_PREDIRECTIVE',...
            'DATA_ALIGNMENT_POSTDIRECTIVE',...
            'DATA_ALIGNMENT_PRECEDING_STATEMENT',...
            'DATA_ALIGNMENT_FOLLOWING_STATEMENT'};
            obj.AlignmentPosition=pentries{index+1};

            obj.AlignmentSyntaxTemplate=strtrim(...
            dlghandle.getWidgetValue(['Tfldesigner_AlignmentSyntax_',num2str(i)]));


            tentries={'DATA_ALIGNMENT_LOCAL_VAR',...
            'DATA_ALIGNMENT_STRUCT_FIELD',...
            'DATA_ALIGNMENT_WHOLE_STRUCT',...
            'DATA_ALIGNMENT_GLOBAL_VAR'};

            index=dlghandle.getWidgetValue(['Tfldesigner_AlignmentType_',num2str(i)]);
            index=index+1;
            val={};

            for j=1:length(index)
                val=[val,tentries{index(j)}];%#ok
            end

            obj.AlignmentType=val;

            this.object(i)=obj;
        end
    end


    function val=formcell(str)

        str=strrep(str,'{','');
        str=strrep(str,'}','');
        val='{';

        [list,remain]=strtok(str,',');
        val=[val,'''',strtrim(list),''''];

        while~isempty(remain)
            [list,remain]=strtok(remain,',');%#ok
            val=[val,',','''',strtrim(list),''''];%#ok
        end
        val=[val,'}'];