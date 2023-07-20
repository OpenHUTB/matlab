


function[out,me]=checkExportedFcnsCondition(system)
    [mdl,sys]=strtok(system,'/');
    if~isempty(sys)
        try
            subsys=get_param(system,'Handle');
            this=coder.internal.RightClickBuild.create(bdroot(subsys),subsys,'ExportFunctions',true);
            this.useCompBusStruct=false;
            this.runChecks;
            out=true;
            me=[];
        catch me
            out=false;
        end
    else
        out=strcmp(get_param(mdl,'isexportfunctionmodel'),'on');
    end
end
