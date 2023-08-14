function paramNames=getUsableParameterNamesSortedOntoTabs(blockHandle,sortFlag)



    if~exist('sortFlag','var')
        sortFlag=true;
    end
    if ishandle(blockHandle)
        name=get_param(blockHandle,'Name');
        parent=get_param(blockHandle,'Parent');
        blockName=[parent,'/',name];
    else
        blockName=blockHandle;
    end
    if sortFlag
        componentPath=get_param(blockName,'ComponentPath');
    else
        componentPath='';
    end
    switch componentPath
    case{'ee.semiconductors.sp_nmos','ee.semiconductors.sp_pmos'}


        paramNames.vt=lGetActive(blockHandle,{'gamma','phib2ref'});
        paramNames.dc=lGetActive(blockHandle,{'betaref','thesatref','alpha'...
        ,'Vp','thesrref','Rdref','Isref','n'});
        paramNames.ac=lGetActive(blockHandle,{'Cox','Cgso','Cgdo','Vbi'...
        ,'Cj0','TT'});
        paramNames.t=lGetActive(blockHandle,{'etabet','Stvfb','Stphib'...
        ,'etasat','etasr','etar','etais','Tsim'});
        paramNames.fixed=lGetActive(blockHandle,{'Tref','Rgref'});
        paramNames.extras=lGetActive(blockHandle,{'Vfbref','m','Rsref'});




























    otherwise


        componentPath=get_param(blockName,'ComponentPath');
        schemaParams={physmod.schema.internal.blockComponentSchema(...
        blockName,componentPath).info().Members.Parameters.ID};
        paramNames.all=lGetActive(blockHandle,schemaParams);
    end
end

function active=lGetActive(blk,ids)
    import pm.sli.internal.getMaskParameterRecursive
    isActive=false(size(ids));
    for idx=1:numel(ids)
        p=getMaskParameterRecursive(blk,ids{idx});
        if~isempty(p)
            isActive(idx)=strcmp(p.Evaluate,'on');
        end
    end
    active=ids(isActive);
end
