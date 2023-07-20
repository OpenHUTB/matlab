




function varargout=constraint_manager(varargin)

    mlock;
    persistent DIALOG_USERDATA;

    narginchk(1,Inf);


    aAction=varargin{1};
    aArgs=varargin(2:end);

    switch(aAction)
    case 'Create'

        aBlockHandle=[];
        if~isempty(aArgs)
            if ishandle(aArgs{1})
                aBlockHandle=aArgs{1};
            else
                aBlockHandle=get_param(aArgs{1},'Handle');
            end
        end


        iIdx=[];
        if~isempty(DIALOG_USERDATA)
            iIdx=find([DIALOG_USERDATA.BlockHandle]==aBlockHandle);
        end

        if isempty(iIdx)
            aDialog=constraint_manager.ConstraintManagerInstance(aBlockHandle);
            DIALOG_USERDATA(end+1).BlockHandle=aBlockHandle;
            DIALOG_USERDATA(end).Dialog=aDialog;
        else
            aDialog=DIALOG_USERDATA(iIdx).Dialog;
        end

        aDialog.show();

    case 'Save'
        blockHandle=aArgs{1};
        environment=aArgs{2};
        if strcmp(environment,"MASKEDITOR")
            maskeditor('Save',blockHandle);
        else
            aDialog=constraint_manager('Get',blockHandle);
            constraint_manager.SaveConstraints(aDialog,environment);
        end

    case 'LoadMATFileConstraint'
        environment=aArgs{1};
        blockHandle=aArgs{2};
        matFileName=aArgs{3};
        matFilePath=aArgs{4};

        sharedConstraintList=aArgs{5};
        product='';

        if strcmp(environment,"MASKEDITOR")
            aDialog=maskeditor('Get',blockHandle);
        else
            aDialog=constraint_manager('Get',blockHandle);
        end


        aDialog.addSharedConstraintToModel(sharedConstraintList,product,matFileName,matFilePath);


        aDialog.show();

    case 'Get'
        aDialog=[];
        aBlockHandle=aArgs{1};
        if~isempty(DIALOG_USERDATA)
            idx=find([DIALOG_USERDATA.BlockHandle]==aBlockHandle);
            if~isempty(idx)
                aDialog=DIALOG_USERDATA(idx).Dialog;
            end
        end
        varargout{1}=aDialog;

    case{'Delete','Cancel'}
        aBlockHandle=aArgs{1};

        if~isempty(DIALOG_USERDATA)
            iIdx=find([DIALOG_USERDATA.BlockHandle]==aBlockHandle);
            if~isempty(iIdx)
                aDialog=DIALOG_USERDATA(iIdx).Dialog;
                aDialog.delete();

                DIALOG_USERDATA(iIdx)=[];
            end
        end

    case 'DeleteAll'

        if~isempty(DIALOG_USERDATA)
            aBlockHandles=[DIALOG_USERDATA.BlockHandle];
            for i=1:length(aBlockHandles)
                maskeditor('Delete',aBlockHandles(i));
            end

            DIALOG_USERDATA=[];
        end
    end
end
