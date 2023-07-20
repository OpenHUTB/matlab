function schema





    pk=findpackage('filtstates');
    c=schema.class(pk,'dfiir');


    c.Handle='off';


    p=schema.prop(c,'Numerator','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p.FactoryValue=0;
    p.AccessFlags.AbortSet='Off';



    p=schema.prop(c,'Denominator','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';

    p.FactoryValue=0;
    p.AccessFlags.AbortSet='Off';



    function S=chkstates(h,S,str)





        msgObj=message('signal:filtstates:dfiir:schema:invalidDataTypeDouble',str,'double');

        if license('test','Fixed_Point_Toolbox')&&license('test','Signal_Blocks')
            msgObj=message('signal:filtstates:dfiir:schema:invalidDataType',str,'double','single','embedded.fi');
        elseif license('test','Signal_Blocks')
            msgObj=message('signal:filtstates:dfiir:schema:invalidDataTypeFloating',str,'double','single');
        end

        if~any([isa(S,'double'),isa(S,'single'),isa(S,'embedded.fi')])
            error(msgObj);
        end




