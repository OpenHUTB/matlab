
function privhdlrestoreparams(dut,varargin)




    narginchk(1,2);

    if nargin>0
        dut=convertStringsToChars(dut);
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    restoreBlockDefaults(dut);
    restoreModelRefBlockDefaults(dut);
    restoreModelDefaults(dut);

    if nargin==2
        filename=varargin{1};
        fid=fopen(filename,'r');
        if isempty(fid)||fid<0
            error(message('hdlcoder:engine:FileNotFound',filename));
        end
        fclose(fid);

        run(filename);
    end
end


function restoreModelDefaults(dut)
    modelName=getModelName(dut);

    mP=slprops.hdlmdlprops({'HDLSubsystem',modelName});
    set_param(modelName,'HDLParams',mP);


    set_param(modelName,'dirty','on');
end


function restoreBlockDefaults(dut)

    modelName=getModelName(dut);


    allblks=find_system(dut,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','on');
    for ii=1:length(allblks)
        try


            if~isempty(get_param(allblks{ii},'HDLData'))
                set_param(allblks{ii},'HDLData',[]);
            end
        catch
        end
    end

    set_param(modelName,'dirty','on');
end


function restoreModelRefBlockDefaults(dut)



    models=find_system(dut,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','ModelReference');
    models=unique(models);

    for i=1:length(models)


        name=get_param(models{i},'ModelName');
        load_system(name);


        cleanupFcn=coder.internal.infoMATInitializeFromSTF...
        (get_param(name,'SystemTargetFile'),name);

        refs=slprivate...
        ('get_ordered_model_references',...
        name,...
        true,...
        'ModelReferenceTargetType','RTW');


        delete(cleanupFcn)

        for j=1:length(refs)
            model=refs(j).modelName;
            load_system(model);
            restoreBlockDefaults(model);
        end
    end
end


function mdlname=getModelName(dut)
    try
        mdlname=bdroot(dut);
    catch me
        error(message('hdlcoder:engine:invalidchipname',dut));
    end

    if isempty(mdlname)
        error(message('hdlcoder:engine:invalidchipname',dut));
    end
end
