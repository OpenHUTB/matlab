function out=align_names(itemsArray)




    in=itemsArray;

    try
        lblArray=cell(0);

        lbl.Name='';
        lbl.Type='text';
        lbl.RowSpan=[];
        lbl.ColSpan=[];
        lbl.Tag='AlignNameLbl';

        for i=1:length(itemsArray)
            if(strcmp(itemsArray{i}.Type,'edit')||strcmp(itemsArray{i}.Type,'combobox'))
                lblArray{end+1}=lbl;%#ok
                needBeautify=true;


                if isfield(itemsArray{i},'KeepOrigPrompt')
                    needBeautify=~itemsArray{i}.KeepOrigPrompt;
                    itemsArray{i}=rmfield(itemsArray{i},'KeepOrigPrompt');
                end
                if needBeautify
                    lblArray{end}.Name=beautifyPrompt(itemsArray{i}.Name);
                else
                    lblArray{end}.Name=itemsArray{i}.Name;
                end
                lblArray{end}.Tag=lblArray{end}.Name;
                lblArray{end}.RowSpan=itemsArray{i}.RowSpan;
                lblArray{end}.ColSpan=[itemsArray{i}.ColSpan(1),itemsArray{i}.ColSpan(1)];
                if isfield(itemsArray{i},'Visible')
                    lblArray{end}.Visible=itemsArray{i}.Visible;
                end
                if isfield(itemsArray{i},'Enabled')
                    lblArray{end}.Enabled=itemsArray{i}.Enabled;
                end

                itemsArray{i}.HideName=true;
                itemsArray{i}.ColSpan=[itemsArray{i}.ColSpan(1)+1,itemsArray{i}.ColSpan(2)];
            end
        end

        out=[itemsArray,lblArray];
    catch e %#ok

        out=in;
    end


    function out=beautifyPrompt(prompt)


        if endsWith(prompt,':')
            out=prompt;
        else
            out=[prompt,':'];
        end
