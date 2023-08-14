function HtoIL_generate_report(models,reportName,report_path,broken_connections,removed_blocks,parameter_warnings,missing_properties_block)










    numFiles=length(models);


    model_strs=cell(numFiles,1);
    for m=1:numFiles
        model_strs{m}=get_fileName_html(models{m});
    end



    removed_blocks_html_str=[];
    for m=1:numFiles
        if~isempty(removed_blocks{m})
            removed_blocks_html_str_m=convert_array_to_block_message_table(removed_blocks{m},models{m});
        else
            removed_blocks_html_str_m='<html>No blocks removed.<br><br></html>';
        end
        removed_blocks_html_str=[removed_blocks_html_str,model_strs{m},removed_blocks_html_str_m];
    end




    interface_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Hydraulic/Hydraulic Utilities'''' ); hilite_system( ''''fl_lib/Hydraulic/Hydraulic Utilities/Interface (H-IL)'''' )" > Interface (H-IL) block </a>';
    interface_note=['Use the ',interface_hyperlink,' to connect unconverted Hydraulic blocks to Isothermal Liquid blocks.'];
    broken_connections_html_str=[];
    for m=1:numFiles
        model_m=models{m};
        broken_connections_m=broken_connections{m};
        if~isempty(broken_connections_m)
            broken_connections_html_str_table_html=convert_array_to_block_message_table(broken_connections_m,model_m);
            broken_connections_html_str_m=['<html>',interface_note,'<br><br></html>',broken_connections_html_str_table_html];
        else
            broken_connections_html_str_m='<html>No broken connections detected.<br><br></html>';
        end
        broken_connections_html_str=[broken_connections_html_str,model_strs{m},broken_connections_html_str_m];
    end




    parameter_warnings_html_str=[];
    for m=1:numFiles
        parameter_warnings_m=parameter_warnings{m};
        if~isempty(parameter_warnings_m)
            parameter_warnings_html_str_m=convert_array_to_block_message_table(parameter_warnings_m,models{m});
        else
            parameter_warnings_html_str_m='<html>No warnings to display.<br><br></html>';
        end


        if missing_properties_block{m}
            properties_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" > Isothermal Liquid Properties (IL) block </a>';
            properties_block_note=['<html><font color="red">Add an',properties_hyperlink,' to specify the fluid properties. Default properties in the Isothermal Liquid domain differ from the Hydraulic domain.</font><br><br></html>'];

            if isempty(parameter_warnings_m)

                parameter_warnings_html_str_m=properties_block_note;
            else
                parameter_warnings_html_str_m=[properties_block_note,parameter_warnings_html_str_m];
            end
        end
        parameter_warnings_html_str=[parameter_warnings_html_str,model_strs{m},parameter_warnings_html_str_m];
    end





    code_to_eval=['HtoIL_report(''',broken_connections_html_str,''',''',removed_blocks_html_str,''',''',parameter_warnings_html_str,''')'];
    publish('HtoIL_report','showCode',false,'codeToEvaluate',code_to_eval,'outputDir',report_path);


    if~strcmp(reportName,'HtoIL_report')
        movefile([report_path,filesep,'HtoIL_report.html'],[report_path,filesep,reportName,'.html'],'f');
    end


    web([report_path,filesep,reportName,'.html'])

end



function html_str=convert_array_to_block_message_table(block_message_array,model)







    block_message_array_temp={};
    messages_present=0;
    for i=1:length(block_message_array)
        subsystem=block_message_array(i).subsystem;
        num_messages_for_subsystem_i=length(block_message_array(i).messages);
        if num_messages_for_subsystem_i>0
            for j=1:length(block_message_array(i).messages)
                if~isempty(block_message_array(i).messages{j})
                    messages_present=1;
                end
                block_message_array_temp(end+1,1:2)={subsystem,block_message_array(i).messages{j}};%#ok<AGROW>
            end
        else
            block_message_array_temp(end+1,1)={subsystem};%#ok<AGROW>
        end
    end
    block_message_array=block_message_array_temp;



    num_messages=size(block_message_array,1);
    if messages_present
        first_row_str='<tr><th> Block </th><th> Message </th></tr>';
        parameter_warnings_mat=([repmat({model},num_messages,2),repmat(block_message_array(:,1),1,3),block_message_array(:,2)])';
        parameter_warnings_mat=regexprep(parameter_warnings_mat,'[\n\r]+',' ');
        body_str=sprintf('<tr><td> <a href= "matlab: if ~bdIsLoaded(''''%s''''), load_system(''''%s''''); end; hilite_system(''''%s'''')"  title= %s> %s </a></td><td> %s </td></tr>',parameter_warnings_mat{:});
    else
        first_row_str='<tr><th> Block </th></tr>';
        parameter_warnings_mat=([repmat({model},num_messages,2),repmat(block_message_array(:,1),1,3)])';
        parameter_warnings_mat=regexprep(parameter_warnings_mat,'[\n\r]+',' ');
        body_str=sprintf('<tr><td> <a href= "matlab: if ~bdIsLoaded(''''%s''''), load_system(''''%s''''); end; hilite_system(''''%s'''')"  title= %s> %s </a></td></tr>',parameter_warnings_mat{:});
    end

    html_str=['<html><table>',first_row_str,body_str,'</table><br><br></html>'];
end

function html_str=get_fileName_html(model)
    oldFileName=get_param(model,'FileName');
    [~,name,ext]=fileparts(oldFileName);
    html_str=['<html><h6 style="color:rgb(210, 120, 0);">',[name,ext],'</h6></html>'];
end

