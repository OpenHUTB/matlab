function pvs=UpdateParamUnitsToSlUnitsPVs(block)






    pvs={};

    mpstr=get_param(block,'MaskPropertyNameString');
    mps=regexp(mpstr,'\|','split');
    for i=1:length(mps)
        mp=mps{i};
        if regexp(mp,'\w+_unit')==1
            itemName=mp(1:end-length('_unit'));
            if any(strcmp(itemName,mps))
                pmUnit=strrep(get_param(block,mp),' ','');



                tmpUnit=localConvertCommensurateCdegC(block,itemName,pmUnit);


                excludeCdegC=true;
                slUnit=pm_remapunits(tmpUnit,pm_unitreplacement(excludeCdegC));


                if~strcmp(slUnit,pmUnit)
                    pvs=[pvs,{mp,slUnit}];
                end
            end
        end
    end

end



function res=localIsCommensurate(unitA,unitB)



    try
        res=pm_commensurate(unitA,unitB);
    catch
        res=false;
    end
end



function res=localConvertCommensurateCdegC(block,itemName,specifiedUnit)





    res=pm_remapunits(specifiedUnit,containers.Map({'C','degC'},{'degC','C'}));
    if strcmp(res,specifiedUnit)

        return
    end


    schemaNames=simscape.internal.variantsAndNames(block);
    schemaUnit='';
    for j=1:length(schemaNames)
        cs=physmod.schema.internal.blockComponentSchema(block,strtrim(schemaNames{j})).info;
        plv=strcmp({cs.Members.Parameters.ID},itemName);
        if any(plv)
            p=cs.Members.Parameters(plv);
            schemaUnit=p(1).Default.Unit;
            break;
        end
        vlv=strcmp({cs.Members.Variables.ID},itemName);
        if any(vlv)
            v=cs.Members.Variables(vlv);
            schemaUnit=v(1).Default.Value.Unit;
            break;
        end
    end
    assert(~isempty(schemaUnit),'Internal error: no schema item found');


    res=specifiedUnit;
    if localIsCommensurate(res,schemaUnit)
        return
    end


    res=pm_remapunits(specifiedUnit,containers.Map('C','degC'));
    if localIsCommensurate(res,schemaUnit)
        return
    end



    res=pm_remapunits(specifiedUnit,containers.Map('degC','C'));
    if localIsCommensurate(res,schemaUnit)
        return
    end


    res=pm_remapunits(specifiedUnit,containers.Map({'C','degC'},{'degC','C'}));
    if localIsCommensurate(res,schemaUnit)
        return
    end


    res=specifiedUnit;
end

