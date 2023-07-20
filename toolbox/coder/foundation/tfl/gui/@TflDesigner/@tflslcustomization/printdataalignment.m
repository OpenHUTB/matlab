function printdataalignment(this,file)




    if this.speccount==0
        return;
    end


    fprintf(file,'da = RTW.DataAlignment;\n\n');

    for i=1:length(this.object)
        obj=this.object(i);

        fprintf(file,'as = RTW.AlignmentSpecification;\n');

        if~isempty(obj.AlignmentType)
            fprintf(file,'as.AlignmentType = ');
            fprintf(file,'%s;\n',formcell(obj.AlignmentType,true));
        end

        if~isempty(obj.AlignmentSyntaxTemplate)
            fprintf(file,'as.AlignmentSyntaxTemplate = ');
            k=strrep(obj.AlignmentSyntaxTemplate,'''','');
            fprintf(file,'''%s'';\n',k);
        end

        fprintf(file,'as.AlignmentPosition = ');
        fprintf(file,'''%s'';\n',obj.AlignmentPosition);

        if~isempty(obj.SupportedLanguages)
            fprintf(file,'as.SupportedLanguages = ');
            fprintf(file,'%s;\n',formcell(obj.SupportedLanguages,false));
        end

        fprintf(file,'da.addAlignmentSpecification(as);\n\n');
    end
    fprintf(file,'tc = RTW.TargetCharacteristics;\n');
    fprintf(file,'tc.DataAlignment = da;\n');
    fprintf(file,'this(1).TargetCharacteristics = tc;\n');



    function val=formcell(cellA,addnewline)

        if iscell(cellA)
            k=strrep(cellA{1},'''','');
            val=['{','''',k,''''];
            for i=2:length(cellA)
                k=strrep(cellA{i},'''','');
                if addnewline
                    t=sprintf(', ...\n''%s''',k);
                    val=[val,t];%#ok
                else
                    val=[val,', ','''',k,''''];%#ok
                end
            end
        else
            k=strrep(cellA,'''','');
            val=['{','''',k,''''];
        end
        val=[val,'}'];


