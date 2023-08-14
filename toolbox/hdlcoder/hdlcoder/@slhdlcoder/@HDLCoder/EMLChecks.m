
function checks=EMLChecks(this,hPir)%#ok<INUSL>









    checks=[];
    mdlName=regexp(hPir.getTopNetwork.FullPath,'/','split');
    mdlName=mdlName{1};

    r=sfroot;
    m=r.find('-isa','Stateflow.Machine','Name',mdlName);
    c=[];
    if~isempty(m)
        c=m.find('-isa','Stateflow.EMChart');
    end


    for itr=1:length(c)
        if(regexp(c(itr).Path,['^',this.getEntityTop()]))
            eml_blk_script=c(itr).Script;

            chk=hdlcodingstd.STARCrules.find_and_flag_while_break_cont_ret_parfor_stmts(eml_blk_script,c(itr).Path);


            checks=cat(2,checks,chk);
        end
    end

    return
end
