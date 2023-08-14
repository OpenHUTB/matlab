function ft=findTerms(ft)
















    nTerms=length(ft);
    if nTerms==0|nTerms==1
        ft={};
        return;
    elseif mod(nTerms,2)==1
        ft=ft(1:end-1);
        nTerms=nTerms-1;
    end

    for i=1:nTerms/2
        valIdx=i*2;
        propIdx=valIdx-1;

        tryDoubleConversion=true;

        propName=char(ft{propIdx});
        if strncmp(propName,'.',1)

            propName=propName(2:end);
        elseif strcmp(propName,'-function')
            try
                val=evalin('base',ft{valIdx});
            catch
                val=[];
            end

            if~isa(val,'function_handle')
                rptgen.displayMessage(sprintf(...
                getString(message('RptgenSL:rptgen_sf:invalidFunctionHandleLabel')),...
                ft{valIdx}),2);
                val=@alwaysTrue;
            end
            ft{valIdx}=val;
            tryDoubleConversion=false;
        end

        if tryDoubleConversion


            strAsDouble=str2double(ft{valIdx});
            if~isnan(strAsDouble)
                ft{valIdx}=strAsDouble;
            end
        end
    end


    function tf=alwaysTrue(varargin)

        tf=true;
