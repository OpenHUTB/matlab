function termBlkDiagram(mdlH,mdlWasCompiled)



    if mdlWasCompiled
        mdlName=get_param(mdlH,'Name');
        try
            evalc('feval(mdlName,[],[],[],''term'');');
        catch Mex
            newExc=MException('Sldv:xform:MdlInfo:termBlkDiagram:FailedToTerminate',...
            'Failed to terminate compilation of  ''%s''',mdlName);
            newExc=newExc.addCause(Mex);
            throw(newExc);
        end
    end
end