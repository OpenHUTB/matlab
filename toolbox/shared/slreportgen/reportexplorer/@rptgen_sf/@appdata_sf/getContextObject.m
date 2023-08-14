function[parentID,sfContext]=getContextObject(adSF,sfContext,adSL)








    if nargin<2||strncmpi(objType,'auto',4)
        sfContext=adSF.Context;
    end

    if~isempty(sfContext)&&~strcmpi(sfContext,'None')
        parentID=get(adSF,['Current',sfContext]);
    else
        if nargin<3
            adSL=rptgen_sl.appdata_sl;
        end

        switch lower(adSL.Context)
        case 'model'
            parentID=rptgen_sf.model2machine(adSL.CurrentModel);
            sfContext='Machine';
        case 'system'
            parentID=[];
            sfContext='Chart';
            if~isempty(adSL.CurrentSystem)
                parentID=rptgen_sf.block2chart(...
                find_system(adSL.CurrentSystem,...
                'SearchDepth',1,...
                'MaskType','Stateflow'));
            end
        case 'block'
            if~isempty(adSL.CurrentBlock)&&Stateflow.SLUtils.isStateflowBlock(adSL.CurrentBlock)
                parentID=rptgen_sf.block2chart(adSL.CurrentBlock);
            else
                parentID=[];
            end
            sfContext='Chart';
        case{'signal','annotation','configset'}
            parentID=[];
            sfContext='Chart';

        otherwise

            sfContext='';
            if isempty(meta.package.fromName('Stateflow'))


                parentID=[];
            else
                parentID=slroot;
            end
        end
    end
