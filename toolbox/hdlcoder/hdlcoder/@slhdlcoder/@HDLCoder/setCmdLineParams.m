function setCmdLineParams(this,params)









    property_values=struct();
    for itr=1:2:length(params)
        property_values.(upper(params{itr}))=params{itr+1};
    end
    if(isfield(property_values,'HDLSUBSYSTEM'))
        DUT=getfield(property_values,'HDLSUBSYSTEM');%#ok<GFLD>
        checkTopLevelNamesForI18n(this,DUT);
    end

    this.CmdLineParams=params;
end

function checks=checkTopLevelNamesForI18n(this,DUTname)






    checks=[];
    if(any(DUTname>127))
        errorMsg=message('hdlcoder:validate:i18nDUT',DUTname);
        checks=struct('level','Error',...
        'path',getfullname(DUTname),...
        'type','block',...
        'message',errorMsg.getString(),...
        'MessageID',errorMsg.Identifier);

        this.addCheck(this.ModelName,'error',errorMsg)
        error(errorMsg)
    end
end
