function schemas=getInterface(whichMenu,cbinfo)

    schemas={};
    err={};
    try
        switch(whichMenu)
        case 'MenuBar'

        case 'ToolStrip'
            schemas={};
        case 'ToolBars'
            schemas=SLStudio.CustomToolBar(cbinfo);
        case ''
            schemas={};
        otherwise


            if isa(cbinfo.domain,'SLM3I.SLDomain')
                schemas=SLStudio.ContextMenus(whichMenu,cbinfo);
            elseif isa(cbinfo.domain,'StateflowDI.SFDomain')
                schemas=SFStudio.ContextMenus(whichMenu,cbinfo);
            elseif isa(cbinfo.domain,'SLM3I.SLCommonDomain')
                schemas=SLStudio.CommonContextMenus(whichMenu,cbinfo);
            end
            if isempty(schemas)
                schemas=SLStudio.getCustomSchemas(whichMenu);
            end
        end
    catch Err
        err=Err;
    end


    if~isempty(err)
        error_gen=feval('studiotestprivate','dig_get_error_gen','container',err);
        schemas={error_gen};
    end
end




