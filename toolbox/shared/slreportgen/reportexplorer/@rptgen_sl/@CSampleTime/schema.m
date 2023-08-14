function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CSampleTime',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'Title',rptgen.makeStringType,'Sample Times',getString(message('RptgenSL:rsl_CSampleTime:titleLabel')));


    rptgen.prop(h,'isPgwide','bool',true,getString(message('RptgenSL:rsl_CSampleTime:spansPageWidthLabel')));


    p=rptgen.prop(h,'ColumnWidths','MATLAB array',[1,2,3,3],getString(message('RptgenSL:rsl_CSampleTime:columnWidthsLabel')));

    p.SetFunction=@setColumnWidths;



    rptgen.prop(h,'AllAlign',rptgen.enumTableHorizAlign,'left',...
    'Alignment');


    rptgen.prop(h,'isBorder','bool',true,getString(message('RptgenSL:rsl_CSampleTime:gridLinesLabel')));


    rptgen.prop(h,'ImageSize','MATLAB array',[20,20],getString(message('RptgenSL:rsl_CSampleTime:imageSizeLabel')));


    rptgen.prop(h,'ImageFormat',rptgen.makeStringType,'bmp',getString(message('RptgenSL:rsl_CSampleTime:imageFormatLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });


    function proposedValue=setColumnWidths(this,proposedValue)

        if((length(proposedValue)~=4)||any(proposedValue<=0))
            error(message('Simulink:rptgen_sl:InvalidColumnWidths'));
        end


