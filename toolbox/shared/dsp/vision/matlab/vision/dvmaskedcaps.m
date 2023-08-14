function subsysCap=dvmaskedcaps(block)







    if~strcmpi(get_param(block,'Mask'),'on')
        DAStudio.error('Simulink:bcst:ErrOnlyMasks',mfilename);
    end

    maskType=get_param(block,'MaskType');


    [maskStr,trans]=getMaskStr(maskType,block);


    subsysCap=bcstCreateCap(maskType,maskStr,trans);



    function[subsysCapStr,trans]=getMaskStr(maskType,block)

        persistent maskTable transTable;
        if isempty(maskTable)
            [maskTable,transTable]=getMaskTable;
        end

        if isempty(maskType)||(strcmpi(get_param(block,'BlockType'),'SubSystem')&&isempty(get_param(block,'Blocks')))

            subsysCapStr='';
            trans=transTable;
        else

            findMask=find(strcmp(maskType,maskTable(:,2)));
            if~isempty(findMask)

                subsysCapStr=maskTable{findMask,1};
                trans=transTable;
            else
                DAStudio.error('Simulink:bcst:ErrMaskNotFound',maskType,mfilename);
            end
        end



        function[maskTable,transTable]=getMaskTable



            transTable.d='double';

            transTable.s='single';

            transTable.b='boolean';

            transTable.i='integer';
            transTable.is='integerSgn';
            transTable.iu='integerUns';
            transTable.depends.is='i';
            transTable.depends.iu='i';

            transTable.f='fixedpt';
            transTable.fs='fixedptSgn';
            transTable.fu='fixedptUns';
            transTable.depends.fs='f';
            transTable.depends.fu='f';


            transTable.e='enumerated';
            transTable.B='bus';

            transTable.c='codegen';
            transTable.p='production';

            transTable.m='multidimension';

            transTable.I='foreach';
            transTable.v='variablesize';
            transTable.S='symbolicdimension';
            transTable.t='string';
            transTable.z='zerocrossing';
            transTable.D='directfeedthrough';


































            maskTable={...
...
...
...
            'd;s;i.dsp_Fns3216u8;c.dsp_FnHostPCOnly;p;','From Multimedia File';...
            'd;s;i.dsp_Fns3216u8;c.dsp_FnHostPCOnly;p;','To Multimedia File';};


