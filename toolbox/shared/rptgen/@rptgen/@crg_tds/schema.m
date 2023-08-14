function schema







    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'crg_tds',pkgRG.findclass('rptcomponent'));


    rptgen.makeProp(h,'isprefix','bool',true,...
    getString(message('rptgen:r_crg_tds:includeTextLabel')));


    rptgen.makeProp(h,'prefixstring','ustring',getString(message('rptgen:r_crg_tds:createdLabel')),'');


    rptgen.makeProp(h,'istime','bool',true,...
    getString(message('rptgen:r_crg_tds:includeCurrentTimeLabel')));


    rptgen.makeProp(h,'timeformat',{
    '12',getString(message('rptgen:r_crg_tds:twelveHourLabel'))
    '24',getString(message('rptgen:r_crg_tds:twentyFourHourLabel'))
    },'12',...
    getString(message('rptgen:r_crg_tds:timeDisplayLabel')));


    rptgen.makeProp(h,'timesec','bool',false,...
    getString(message('rptgen:r_crg_tds:includeSecondsLabel')));


    rptgen.makeProp(h,'timesep',{
    'SPACE',getString(message('rptgen:r_crg_tds:blankSpaceLabel'))
    ':',getString(message('rptgen:r_crg_tds:colonLabel'))
    '.',getString(message('rptgen:r_crg_tds:periodLabel'))
    'NONE',getString(message('rptgen:r_crg_tds:noneLabel'))
    },':',...
    getString(message('rptgen:r_crg_tds:timeSeparator')));


    rptgen.makeProp(h,'isdate','bool',true,...
    getString(message('rptgen:r_crg_tds:includeCurrentLabel')));


    rptgen.makeProp(h,'dateorder',{
    'DMY',getString(message('rptgen:r_crg_tds:dmyLabel'))
    'MDY',getString(message('rptgen:r_crg_tds:mdyLabel'))
    'YMD',getString(message('rptgen:r_crg_tds:ymdLabel'))
    },'DMY',...
    getString(message('rptgen:r_crg_tds:dateOrderLabel')));


    rptgen.makeProp(h,'datesep',{
    'SPACE',getString(message('rptgen:r_crg_tds:blankSpaceLabel'))
    ':',getString(message('rptgen:r_crg_tds:colonLabel'))
    '/',getString(message('rptgen:r_crg_tds:slashLabel'))
    '.',getString(message('rptgen:r_crg_tds:periodLabel'))
    'NONE',getString(message('rptgen:r_crg_tds:noneLabel'))
    },'SPACE',...
    getString(message('rptgen:r_crg_tds:dateSeparatorLabel')));


    rptgen.makeProp(h,'datemonth',{
    'LONG',getString(message('rptgen:r_crg_tds:longMonthLabel'))
    'SHORT',getString(message('rptgen:r_crg_tds:shortMonthLabel'))
    'NUM',getString(message('rptgen:r_crg_tds:numericLabel'))
    },'LONG',...
    getString(message('rptgen:r_crg_tds:monthLabel')));


    rptgen.makeProp(h,'dateyear',{
    'LONG',getString(message('rptgen:r_crg_tds:longLabel'))
    'SHORT',getString(message('rptgen:r_crg_tds:shortLabel'))
    },'LONG',...
    getString(message('rptgen:r_crg_tds:yearLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getdate'
'gettime'
    });