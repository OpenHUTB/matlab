function[entry]=fullPathToHTML(ft,fullPath,varargin)




    if~isempty(varargin)&&~isempty(regexp(varargin{1},':0$','once'))
        entry=ModelAdvisor.Text('');

    else


        if strcmp(ft.FormatType,'ListTemplate')
            textLimit=75;
        else
            textLimit=40;
        end
        if(length(fullPath)>textLimit)


            slashIndex=strfind(fullPath,'/');
            if isempty(slashIndex)
                text=ModelAdvisor.Text(['....',fullPath(end-textLimit+1:end)]);
            else
                truncatedPath='';
                for i=1:length(slashIndex)
                    if length(fullPath)-slashIndex(i)<=textLimit
                        truncatedPath=fullPath(slashIndex(i)+1:end);
                        break
                    end
                end
                if isempty(truncatedPath)
                    truncatedPath=['....',fullPath(end-textLimit+1:end)];
                else
                    truncatedPath=['..../',truncatedPath];
                end
                text=ModelAdvisor.Text(truncatedPath);
            end
        else
            text=ModelAdvisor.Text(fullPath);
        end
        text.title=fullPath;
        if isempty(varargin)
            slCB=ModelAdvisor.getSimulinkCallback('hilite_system',fullPath);
        else




            slCB=['matlab: modeladvisorprivate hiliteSystem USE_SID:',varargin{1}];

        end

        text.setHyperlink(slCB);
        entry=text;
    end
end
