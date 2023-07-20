function setupblockmask(hBlk,paramAttributes)






    mo=get_param(hBlk,'MaskObject');
    if isempty(mo)
        mo=Simulink.Mask.create(hBlk);
    end




    aMaskDialogRefreshHandler=Simulink.MaskDialogRefreshHandler(mo);%#ok<NASGU>
    lResetDialogSource(hBlk);



    mo.Initialization='simscape.engine.sli.internal.preinitcomponentmask(gcb)';
    mo.Help='web(nesl_help(gcbh))';


    simscape.engine.sli.internal.setComponentBlockCallbacks(hBlk);

    sourceFile=simscape.getBlockComponent(hBlk);
    sourcePath=which(sourceFile);

    if isempty(sourceFile)



        mo.Type='';
        mo.Description='';
        mo.removeAllParameters();
        mo.IconUnits='autoscale';

        if bdIsLibrary(bdroot(hBlk))
            mo.Display=...
            simscape.engine.sli.internal.componentmaskdisplay('SimscapeComponentName');
        else
            mo.Display=...
            simscape.engine.sli.internal.componentmaskdisplay('UnspecifiedComponentName');

            pmsl_checklicense(pmsl_defaultproduct);
        end
    elseif isempty(sourcePath)

        if~bdIsLibrary(bdroot(hBlk))
            pmsl_checklicense(pmsl_defaultproduct);
        end


        mo.Display=...
        simscape.engine.sli.internal.componentmaskdisplay('UnresolvedComponentName');





        instanceData=get_param(hBlk,'InstanceData');
        if~isempty(instanceData)
            lCreateDummyParameters(mo,instanceData);
        end


        pm_error('physmod:simscape:engine:sli:block:FileNotOnPath',sourceFile);
    else






        isLoading=~isempty(mo.Type)&&isempty(mo.Parameters);




        compPath=mo.getParameter('ComponentPath');
        if isempty(compPath)||~strcmp(compPath.Value,sourceFile)
            isSourceChanging=true;
        else
            isSourceChanging=false;
        end




        oldParams=[];
        if~isSourceChanging||isLoading
            oldParams=lGetMaskParams(hBlk);
        end


        try

            lValidateModel(sourceFile);
            cs=physmod.schema.internal.blockComponentSchema(hBlk,sourceFile);
            simscape.engine.sli.internal.setupmask(hBlk,...
            {sourceFile},...
            {cs.metaInfo().Name});
        catch ME



            instanceData=get_param(hBlk,'InstanceData');
            if~isempty(instanceData)
                lCreateDummyParameters(mo,instanceData);
            end
            mo.Initialization='simscape.engine.sli.internal.preinitcomponentmask(gcb)';
            ME.throwAsCaller();
        end




        mo.Initialization='simscape.engine.sli.internal.preinitcomponentmask(gcb)';



        lRestoreParamValues(mo,oldParams);



        lSetTimeStamp(mo,sourcePath);


        if isempty(paramAttributes)
            paramAttributes=derived_mask_attributes(hBlk);
        end
        simscape.gl.sli.internal.setMaskParamAttributes(hBlk,paramAttributes);




        try
            lCheckoutLicense(mo,sourceFile,isSourceChanging,isLoading);
        catch ME
            ME.throwAsCaller();
        end

    end

    lRefreshBlockIcon(hBlk);
end

function paramsStruct=lGetMaskParams(hBlock)


    id=get_param(hBlock,'InstanceData');
    mo=get_param(hBlock,'MaskObject');
    if~isempty(id)
        paramsStruct=id;
    elseif~isempty(mo)
        paramsStruct=repmat(struct(),0,0);
        for idx=1:mo.numParameters
            paramsStruct(idx).Name=mo.Parameters(idx).Name;
            paramsStruct(idx).Value=mo.Parameters(idx).Value;
        end
    end
end

function lRestoreParamValues(mo,paramStruct)

    if~isempty(paramStruct)

        oldNames={paramStruct(:).Name};
        oldValues={paramStruct(:).Value};
        newNames={mo.Parameters(:).Name};

        [restoreNames,~,iB]=intersect(newNames,oldNames);
        restoreOldValues=oldValues(iB);

        for idx=1:numel(restoreNames)
            mo.getParameter(restoreNames{idx}).Value=restoreOldValues{idx};
        end

    end
end

function lCreateDummyParameters(mo,paramStruct)


    mo.removeAllParameters();
    neverRestoreParams={'ComponentPathTimeStamp'};
    for idx=1:numel(paramStruct)
        if~ismember(paramStruct(idx).Name,neverRestoreParams)
            mo.addParameter('Name',paramStruct(idx).Name,...
            'Value',paramStruct(idx).Value,...
            'Tunable','off',...
            'Evaluate','off',...
            'Hidden','on');
        end
    end
end

function lCheckoutLicense(mo,sourceFile,isSourceChanging,isLoading)


    theProduct=simscape.engine.sli.internal.getcomponentproduct(sourceFile);
    editMode=simscape.engine.sli.internal.getmaskeditingmode(mo);


    if isempty(theProduct)
        tmpProduct=pmsl_defaultproduct;
        if~pmsl_checklicense(tmpProduct)
            pm_error('physmod:pm_sli:RTM:RunTimeModule:error:user:NoPlatformProductLicense');
        end
    else
        tmpProduct=theProduct;
    end

    isRestrictedMode=strcmp(editMode,'Restricted');
    if~isRestrictedMode&&~pmsl_checklicense(tmpProduct)
        simscape.engine.sli.internal.setupmaskeditingmode(mo,'Restricted',tmpProduct);
        pm_error('physmod:simscape:engine:sli:block:CannotCheckoutComponentLicense',...
        tmpProduct,sourceFile);
    elseif isRestrictedMode&&isSourceChanging&&~isLoading
        pm_error('physmod:simscape:engine:sli:block:CannotSetComponentInRestrictedMode',...
        mo.getOwner().getFullName());
    else






        simscape.engine.sli.internal.setupmaskeditingmode(mo,editMode,theProduct);
    end

end

function lResetDialogSource(hBlock)





    obj=get_param(hBlock,'Object');
    dlgSource=obj.getDialogSource;
    if isa(dlgSource,'PMDialogs.DynDlgSource')
        dlgSource.BuilderObj=[];
    end

end

function lRefreshBlockIcon(hBlock)

    iconKey=SLBlockIcon.getEffectiveBlockIconKey(hBlock);
    DVG.Registry.refreshIcon(iconKey);
end

function lSetTimeStamp(mo,sourcePath)



    dateString=simscape.engine.sli.internal.getfiletimestamp(sourcePath);


    paramString='ComponentPathTimeStamp';
    ts=mo.getParameter(paramString);
    if isempty(ts)
        mo.addParameter('Name','ComponentPathTimeStamp',...
        'Value',dateString,'Hidden','on','Evaluate','off',...
        'NeverSave','on','ToolTip','off','Tunable','off');
    else
        ts.Value=dateString;
    end
end

function lValidateModel(srcFile)




    simscape.loadClassicSchema(srcFile);
end