function errorString=internalValidateDialog(hThis,hBlock)







    errorString='';
    try
        if simscape.engine.sli.internal.iscomponentblock(hBlock)




            if simscape.schema.internal.standalonePI()
                return
            end


            isValid=nesl_private('nesl_isvalidcomponentblock');










            if~strcmp(get_param(hBlock,'LinkStatus'),'none')
                errorString=getString(message('physmod:simscape:engine:sli:block:InvalidImplicitLink',...
                getfullname(hBlock)));
            elseif isValid(hBlock)
                try
                    Simulink.Block.eval(hBlock);
                catch ME


                    if~strcmp(ME.identifier,'Simulink:Parameters:InvParamSetting')
                        ME.rethrow();
                    end
                end
            else
                hThis.RequestChooser=true;
            end

        else


            cmpPath=simscape.compiler.sli.internal.functionstringfromblock(hBlock);

            if~isempty(cmpPath)

                cs=physmod.schema.internal.blockComponentSchema(hBlock,cmpPath);
                maskItems=simscape.schema.internal.derivedParameters(cs);




                missingParams=setdiff(maskItems,lRootNames(hBlock));

                if~isempty(missingParams)
                    str=sprintf('''%s''',missingParams{1});
                    for idx=2:numel(missingParams)
                        str=sprintf('%s, ''%s''',str,missingParams{idx});
                    end
                    errorString=getString(message('physmod:ne_sli:dialog:MissingParameters',str));
                end
            end
        end
    catch e
        errorString=getReport(lStripStack(e));
    end
end

function mStripped=lStripStack(ME)
    mStripped=MException(ME.identifier,ME.message);
    if~isempty(ME.cause)
        for idx=1:numel(ME.cause)
            mStripped=mStripped.addCause(lStripStack(ME.cause{idx}));
        end
    end
end

function names=lRootNames(hBlock)
    names={};
    rootMask=pm.sli.internal.rootMask(hBlock);
    if~isempty(rootMask)
        names={rootMask.Parameters.Name};
    end
end
