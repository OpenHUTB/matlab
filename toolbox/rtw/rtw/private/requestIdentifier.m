function identifier=requestIdentifier(modelName,identifier_name,isGlobal,isFixed,len,isCalledByTLC)









    narginchk(2,6);

    if(nargin<3)
        isGlobal=true;
        isFixed=true;
        isCalledByTLC=false;
        len=0;
    end

    if(nargin<4)
        isFixed=true;
        isCalledByTLC=false;
        len=0;
    end

    if(nargin<5)
        isCalledByTLC=false;
        len=0;
    end

    if(nargin<6)
        isCalledByTLC=false;
    end

    if(isGlobal==1)
        isGlobal=true;
    else
        isGlobal=false;
    end

    if(isFixed==1)
        isFixed=true;
    else
        isFixed=false;
    end

    if(isCalledByTLC==1)
        isCalledByTLC=true;
    else
        isCalledByTLC=false;
    end

    idService=get_param(modelName,'IdentifierService');
    if(idService.codeGenerationContextExists())
        if(len>0)
            identifier=idService.requestIdentifierWithLength(identifier_name,isGlobal,isFixed,len);
        else
            identifier=idService.requestIdentifier(identifier_name,isGlobal,isFixed);
        end
    else
        DAStudio.error('Simulink:Engine:RTWIdentifierServiceCodeGenNotStarted');
    end
    if(~isCalledByTLC&&isempty(identifier))
        DAStudio.error('RTW:tlc:IdentifierClash',identifier_name);
    end
