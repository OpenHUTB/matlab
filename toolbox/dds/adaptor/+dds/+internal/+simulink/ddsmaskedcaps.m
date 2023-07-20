function subsysCap=ddsmaskedcaps(block)










    maskType=get_param(block,'MaskType');


    [maskStr,trans]=getMaskStr(maskType);


    subsysCap=bcstCreateCap(block,maskStr,trans);


end


function[subsysCapStr,trans]=getMaskStr(maskType)

    persistent maskTable transTable;
    if isempty(maskTable)
        [maskTable,transTable]=getMaskTable;
    end

    if isempty(maskType)

        subsysCapStr='';
        trans=transTable;
    else

        findMask=find(strcmp(maskType,maskTable(:,2)));
        if~isempty(findMask)

            if length(findMask)>1
                subsysCapStr=maskTable(findMask,1);
            else
                subsysCapStr=maskTable{findMask,1};
            end
            trans=transTable;
        else
            subsysCapStr='';
        end
    end
end



function[maskTable,transTable]=getMaskTable



    transTable.d='double';
    transTable.s='single';
    transTable.b='boolean';
    transTable.i='integer';
    transTable.f='fixedpt';
    transTable.e='enumerated';
    transTable.B='bus';
    transTable.c='codegen';
    transTable.p='production';
    transTable.m='multidimension';
    transTable.v='variablesize';
    transTable.I='foreach';
    transTable.S='symbolicdimension';
    transTable.t='string';
    transTable.z='zerocrossing';
    transTable.D='directfeedthrough';
    transTable.C='simcgdiagnostic';
    transTable.h='half';
    transTable.E='eventsemantics';


























    maskTable={...
...
    'B;c;p','Take DDS Sample';...
    'B;c;p','Write DDS Sample';...
    };


end
