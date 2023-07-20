function out=getSourceSubsystem








    out=[];
    adSL=rptgen_sl.appdata_sl;
    currModel=adSL.CurrentModel;


    if~isempty(adSL.ReportedSystemList)
        srcsys=adSL.ReportedSystemList{1};
        if~strcmp(currModel,srcsys)

            try
                srcsys=get_param(srcsys,'Name');
            catch
                return;
            end

            spc=sprintf(' \n\t/*?');
            out=strtok(srcsys,spc);
        end
    end
