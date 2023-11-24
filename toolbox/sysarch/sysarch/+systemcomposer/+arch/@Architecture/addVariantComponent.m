function cVarList=addVariantComponent(this,varCompNames,varargin)
    this.validateAPISupportForAUTOSAR('addVariantComponent');

    compPos=[];
    for k=1:2:numel(varargin)
        if strcmpi(varargin{k},"Position")
            compPos=varargin{k+1};
        else
            error('systemcomposer:API:APIInvalidOption',message(...
            'SystemArchitecture:API:APIInvalidOption',varargin{k}).getString);
        end
    end

    varCompNames=string(varCompNames);


    if~isempty(compPos)
        [posM,posN]=size(compPos);
        if length(varCompNames)~=posM||posN~=4
            error('systemcomposer:API:ComponentPositionsInvalid',message(...
            'SystemArchitecture:API:ComponentPositionsInvalid').getString);
        end
    end



    [sortedCompNames,sortIdxs]=sort(varCompNames);




    sortedCompsToAdd=systemcomposer.internal.arch.internal.calculateMissingLayers(this.Model,...
    this.getQualifiedName,sortedCompNames);

    t=this.MFModel.beginTransaction;
    bhs=cell(1,length(sortedCompNames));
    idx=0;
    mdlH=this.SimulinkModelHandle;

    for k=1:length(sortedCompsToAdd)
        thisCompName=sortedCompsToAdd(k);
        txnSuspender=systemcomposer.internal.SubdomainBlockValidationSuspendTransaction(mdlH);

        try
            compPath=string(this.getQualifiedName).append("/").append(thisCompName);
            bh=add_block('simulink/Ports & Subsystems/Variant Subsystem',...
            compPath,'TreatAsAtomicUnit','off');
            set_param(bh,'VariantControlMode','Label');


            delete_block(compPath.append("/In1"));
            delete_block(compPath.append("/Out1"));


            variantChildren=find_system(bh,'MatchFilter',@Simulink.match.allVariants,...
            'BlockType','SubSystem');

            for i=1:numel(variantChildren)


                if~(variantChildren(i)==bh)
                    varSSPath=[get_param(variantChildren(i),'Parent'),'/'...
                    ,get_param(variantChildren(i),'Name')];
                    delete_block([varSSPath,'/In1']);
                    delete_block([varSSPath,'/Out1']);
                    varSSName=strrep(get_param(variantChildren(i),'Name'),'Subsystem','Component');
                    set_param(variantChildren(i),'Name',varSSName);
                end
            end

            if(ismember(thisCompName,sortedCompNames))
                idx=idx+1;
                originalIdx=sortIdxs(idx);
                bhs(originalIdx)={bh};
            end
        catch

            systemcomposer.internal.arch.internal.processBatchedPluginEvents(mdlH);
            t.commit;
            error('systemcomposer:API:ComponentExists',message(...
            'SystemArchitecture:API:ComponentExists',thisCompName).getString);
        end
        delete(txnSuspender);
    end

    systemcomposer.internal.arch.internal.processBatchedPluginEvents(mdlH);

    cImplList=cell(1,length(sortedCompNames));
    for idx=1:numel(bhs)
        bh=bhs(idx);
        cImplList{idx}=systemcomposer.utils.getArchitecturePeer(bh{:});
        if~isempty(compPos)
            set_param(bh{:},'Position',compPos(idx,:));
        end
    end

    t.commit;


    cVarList=cell(1,length(cImplList));
    for i=1:numel(cImplList)
        cVarList{i}=systemcomposer.internal.getWrapperForImpl(cImplList{i},'systemcomposer.arch.VariantComponent');
    end
    cVarList=[cVarList{:}];
end
