function oType=loop_getObjectType(this,obj,ps)











    if(nargin<2||isempty(obj))
        objProps={
        'isAndOrStates',getString(message('RptgenSL:rsf_csf_state_loop:andOrStateLabel'))
        'isBoxStates',getString(message('RptgenSL:rsf_csf_state_loop:boxLabel'))
        'isFcnStates',getString(message('RptgenSL:rsf_csf_state_loop:functionLabel'))
        'isTruthTables',getString(message('RptgenSL:rsf_csf_state_loop:truthTableLabel'))
        'isEMFunctions',getString(message('RptgenSL:rsf_csf_state_loop:emFunctionLabel'))
        'isSLFunctions',getString(message('RptgenSL:rsf_csf_state_loop:slFunctionLabel'))
        };

        objVal=get(this,objProps(:,1));
        objVal=[objVal{:}];
        trueProps=find(objVal);
        if length(trueProps)==1


            oType=objProps{trueProps,2};
        else

            oType=getString(message('RptgenSL:rsf_csf_state_loop:stateLabel'));
        end
    else
        if nargin<3
            ps=this.loop_getPropSrc;
        end
        oType=ps.getObjectType(obj);
    end