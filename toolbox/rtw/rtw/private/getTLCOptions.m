function tlcOptions=getTLCOptions(aModelName,aModelReferenceTargetType)









    cs=getActiveConfigSet(aModelName);
    tlcOptions=cs.getStringRepresentation('tlc_options');


    tlcOptions=reQuoteValue(tlcOptions,'TargetPreCompLibLocation');














    inlinePrmsAsCodeGenOnlyOptionFeatOn=slfeature('InlinePrmsAsCodeGenOnlyOption');
    if(strcmp(aModelReferenceTargetType,'NONE'))
        stf=get_param(aModelName,'SystemTargetFile');
        if ismember(stf,{'accel.tlc','raccel.tlc'})
            tlcOptions=strrep(tlcOptions,'-aInlineParameters=2','-aInlineParameters=0');
            if inlinePrmsAsCodeGenOnlyOptionFeatOn
                tlcOptions=strrep(tlcOptions,'-aInlineParameters=1','-aInlineParameters=0');
                if isequal(stf,'raccel.tlc')
                    tlcOptions=strrep(tlcOptions,'-aInlineParameters=0','-aInlineParameters=2');
                end
            end
        end
    elseif(inlinePrmsAsCodeGenOnlyOptionFeatOn&&...
        strcmp(aModelReferenceTargetType,'SIM'))
        assert(~contains(tlcOptions,'-aInlineParameters=0'));
        tlcOptions=strrep(tlcOptions,'-aInlineParameters=1','-aInlineParameters=2');
    end











    eval(['CurlyBracketOperator set ',tlcOptions,';']);

    tlcOptions=CurlyBracketOperator('get');
end

function tlcArgs=reQuoteValue(tlcArgs,arg)


    oldStr=regexp(tlcArgs,['(',arg,'=.*?\s-)'],'match');
    if~isempty(oldStr)
        oldStr=oldStr{1};
        oldStr=oldStr(1:end-2);
    else


        oldStr=regexp(tlcArgs,['(',arg,'=.*?$)'],'match');
        if~isempty(oldStr)
            oldStr=oldStr{1};
        else
            return;
        end
    end


    oldStr=strtrim(oldStr);
    quoteLoc=regexp(oldStr,'="','once');
    alreadyQuoted=~isempty(quoteLoc);

    if alreadyQuoted
        return;
    end
    repStr=[strrep(oldStr,'=','="'),'"'];

    tlcArgs=strrep(tlcArgs,oldStr,repStr);

end

function y=CurlyBracketOperator(action,varargin)
    persistent tmp;
    if strcmp(action,'set')
        tmp=varargin;
        y=[];
        return;
    end

    y=tmp;
    tmp=[];
end
