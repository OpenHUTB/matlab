
function insertTraceInfoForComp(this,hC)
    shandle=hC.SimulinkHandle;
    if shandle>=0
        obj=get_param(shandle,'Object');
        if~isa(obj,'Simulink.Annotation')
            if this.DUTMdlRefHandle>0
                origFullPath=regexprep(obj.getFullName,this.ModelName,this.OrigStartNodeName,'once');
                try
                    shandle=get_param(origFullPath,'handle');
                catch me



                    if(~strcmpi(me.identifier,'Simulink:Commands:InvSimulinkObjectName'))
                        rethrow me
                    end
                end
            end
            sName='';
            h=shandle;


            while isempty(sName)
                try
                    sName=coder.internal.getNameForBlock(h);
                catch me %#ok<NASGU>



                    h=get_param(h,'Parent');
                    if isempty(h)
                        rethrow me
                    end
                end
            end




            traceStyle=this.getParameter("TraceabilityStyle");
            isLLTrace=strcmpi(traceStyle,'Line Level');
            isSynthComp=false;
            blkPathHasApostrophe=false;
            isOrigHidden=false;
            if isLLTrace

                isSynthComp=hC.Synthetic;
                isParentBusExpansionSubsystem=hC.Owner.isBusExpansionSubsystem;





                if~isSynthComp
                    blk=get_param(hC.SimulinkHandle,'object');
                    origHandle=blk.getOriginalBlock;
                    if origHandle>0
                        isOrigHidden=strcmp(get_param(origHandle,'hidden'),'on');
                    end
                end

                parent=get_param(shandle,'Parent');
                blkName=get_param(shandle,'Name');
                blkPathHasApostrophe=(contains(parent,'''')||contains(blkName,''''));

                sName=['''',sName,''''];
            end

            if~(isLLTrace&&(isSynthComp||blkPathHasApostrophe||isOrigHidden||isParentBusExpansionSubsystem))
                hC.addComment(sName);
            end
        end
    end
end