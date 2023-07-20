function connection=getTransformerConnection(blockName,number)











    if isempty(regexp(get_param(blockName,'ComponentPath'),'(\w*)_winding_transformer.(\w*)abc$','match'))



        windingsStringWithEnding=regexp(get_param(blockName,'ComponentPath'),...
        '(\w*).(\w*)abc$','match');

        windingsStringWithZ=regexp(windingsStringWithEnding,'^\w*','match');


        windingsString_tmp=regexprep(windingsStringWithZ{1},'Z','Y');


        windingsString=regexprep(windingsString_tmp,'D','delta');

        windings=regexp(windingsString,'delta11|delta1|delta|Y','match');

        connection=ee.enum.Connection(windings{1}(number));
    else
        windingconnection=strcat('winding',num2str(number),'connection');
        windingsString_tmp=get_param(blockName,windingconnection);
        windingsString=erase(windingsString_tmp,'ee.enum.windingconnection.');
        if strcmp(windingsString,'Yg')
            windings='Y';
        elseif strcmp(windingsString,'Yn')
            windings='Y';
        elseif strcmp(windingsString,'Y')
            windings='Y';
        elseif strcmp(windingsString,'delta1')
            windings='delta1';
        elseif strcmp(windingsString,'delta11')
            windings='delta11';
        end
        connection=ee.enum.Connection(windings);
    end

