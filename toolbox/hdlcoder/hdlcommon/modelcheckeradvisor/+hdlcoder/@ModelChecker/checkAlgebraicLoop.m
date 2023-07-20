function flag=checkAlgebraicLoop(this)




    flag=true;

    mdlName=this.m_sys;
    mdlObj=get_param(mdlName,'Object');
    blocklist=getCompiledBlockList(mdlObj);
    blocklistnames=getfullname(blocklist);
    if~iscell(blocklistnames)
        blocklistnames={blocklistnames};
    end

    startNodePath=this.m_DUT;

    for i=1:size(blocklistnames,1)
        obj=get_param(blocklist(i),'ObjectAPI_FP');
        if(obj.isSynthesized)
            blklistname=blocklistnames{i};
            isAlgLoop=~isempty(regexp(blklistname,sprintf('^%s',[mdlName,'/<< Synthesized_Atomic_Subsystem_For_Alg_Loop']),'once'));
            if isAlgLoop


                subblocklist=getCompiledBlockList(get_param(blklistname,'ObjectAPI_FP'));
                subblocklistname=getfullname(subblocklist);
                if~iscell(subblocklistname)
                    subblocklistname={subblocklistname};
                end
                for j=1:size(subblocklist,1)

                    if~isempty(regexp(subblocklistname{j},sprintf('^%s',startNodePath),'once'))

                        flag=false;
                        break;
                    end
                end
            end
        end
    end

    if~flag
        message=DAStudio.message('HDLShared:hdlmodelchecker:algebraic_loop_error');
        this.addCheck('warning',message,startNodePath,0);
    end
end



