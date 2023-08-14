function out=migratedToCoderDictionary(sourceDD,checkClosure)












    if nargin<2
        checkClosure=false;
        slRoot=slroot;
        if slRoot.isValidSlObject(sourceDD)
            cs=getActiveConfigSet(sourceDD);
            if isa(cs,'Simulink.ConfigSetRef')...
                &&~strcmp(cs.getSourceLocation,'Base Workspace')


                checkClosure=true;
            end
        end
    end
    import coder.internal.CoderDataStaticAPI.*;

    if isempty(sourceDD)||(isnumeric(sourceDD)&&any(sourceDD==0))
        out=false;
        return;
    end
    out=false;
    hlp=getHelper();
    try

        slRoot=slroot;
        if slRoot.isValidSlObject(sourceDD)
            dd=hlp.openDD(sourceDD,'C',true);
            if checkClosure
                dataDict=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(sourceDD,'Handle'));
                if~isempty(dataDict)
                    dataDictDD=hlp.openDD(dataDict);
                    out=out||~isempty(hlp.getCoderData(dataDictDD,'SoftwareComponentTemplate'));
                end
            end
            if strcmp(get_param(sourceDD,'IsERTTarget'),'on')
                out=out||~isempty(hlp.getCoderData(dd,'SoftwareComponentTemplate'));
            else


                mapping=Simulink.CodeMapping.getCurrentMapping(sourceDD);
                hasMapping=~isempty(mapping);
                out=out||(~isempty(hlp.getCoderData(dd,'SoftwareComponentTemplate'))&&hasMapping);
            end
        else
            dd=hlp.openDD(sourceDD);
            out=out||~isempty(hlp.getCoderData(dd,'SoftwareComponentTemplate'));
        end

    catch


    end
end


