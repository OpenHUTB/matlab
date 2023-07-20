function status=set_symbol_db_element(symbol)

















    symbolTemplateDB=rtwprivate('rtwattic','AtticData','symbolTemplateDB');
    status=0;
    try
        symName=symbol.symbolName;

        info=[];





        for i=1:length(symbolTemplateDB)
            m=strcmp(symbolTemplateDB{i}.symbolName,symName);
            if m==1

                symbolTemplateDB{i}=symbol;
                return;
            end
        end

        symbolTemplateDB{end+1}=symbol;
    catch
        status=-1;
    end
    rtwprivate('rtwattic','AtticData','symbolTemplateDB',symbolTemplateDB);
