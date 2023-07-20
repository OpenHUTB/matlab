function[ret,firstIO,secondIO]=foundCombinedIOWithCGVCE(hSrc,r,data,val,inpH,outpH)




    ret=false;
    thisPortType=data(r+1).SLObjectType;
    for i=0:(length(data)-1)
        if i~=r
            curPortType=data(i+1).SLObjectType;

            if strcmp(data(i+1).ArgName,val)
                if~strcmp(curPortType,thisPortType)


                    firstConflictPortIdx=data(r+1).PortNum+1;
                    secondConflictPortIdx=data(i+1).PortNum+1;
                    if strcmp(thisPortType,'Inport')
                        firstCGVCE=get_param(inpH(firstConflictPortIdx),'CompiledLocalCGVCE');
                        firstIO=get_param(inpH(firstConflictPortIdx),'Name');
                    else
                        firstCGVCE=get_param(outpH(firstConflictPortIdx),'CompiledLocalCGVCE');
                        firstIO=get_param(outpH(firstConflictPortIdx),'Name');
                    end
                    if strcmp(curPortType,'Inport')
                        secondCGVCE=get_param(inpH(secondConflictPortIdx),'CompiledLocalCGVCE');
                        secondIO=get_param(inpH(secondConflictPortIdx),'Name');
                    else
                        secondCGVCE=get_param(outpH(secondConflictPortIdx),'CompiledLocalCGVCE');
                        secondIO=get_param(outpH(secondConflictPortIdx),'Name');
                    end

                    if(~isempty(firstCGVCE)&&~strcmp(firstCGVCE,'false'))||...
                        (~isempty(secondCGVCE)&&~strcmp(secondCGVCE,'false'))

                        ret=true;
                    end
                end
            end
        end
    end
end



