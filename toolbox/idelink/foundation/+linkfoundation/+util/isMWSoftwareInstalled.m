function x=isMWSoftwareInstalled(product)




    narginchk(1,1);

    product=convertStringsToChars(product);

    switch product
    case 'idelink'
        x=true;
        return;
    case 'target'
        x=true;
        return;
    case 'rtw-ec'
        x=(exist('ecoderinstalled.m','file')==2)&&ecoderinstalled;
        return;
    case 'rtw'
        alias='simulinkcoder';
        licenseName='Real-Time_Workshop';
    case 'simulink'
        alias='simulink';
        licenseName='Simulink';
    otherwise
        DAStudio.error('ERRORHANDLER:utils:UnrecognizedMWSoftwareAlias',product,...
        upper(mfilename),'rtw-ec, rtw, simulink');
    end

    x=~isempty(ver(alias))&&...
    license('test',licenseName);


