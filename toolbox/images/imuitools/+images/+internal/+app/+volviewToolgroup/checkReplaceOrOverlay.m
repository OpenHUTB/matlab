

function refreshValue=checkReplaceOrOverlay(data)

    newVolType=data.NewVolType;
    currVolumeSize=data.CurrVolSize;
    hasVolumeData=data.HasVolumeData;
    hasLabeledVolumeData=data.HasLabeledVolumeData;


    newVolSize=data.NewVolSize;
    newVolSize([1,2])=newVolSize([2,1]);





    value=double(hasVolumeData)+(double(hasLabeledVolumeData)*2);
    if value
        sameSize=isequal(newVolSize,currVolumeSize);
    end

    refreshValue='None';
    buttonName='None';
    switch value
    case 0
        return;
    case 1
        if strcmp(newVolType,'labels')&&sameSize


        elseif strcmp(newVolType,'labels')&&~sameSize

            buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importDifferentSizedLabeledVolume')),...
            getString(message('images:volumeViewerToolgroup:importingLabeledVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

        else

            buttonName=questdlg(getString(message('images:volumeViewerToolgroup:replaceVolume')),...
            getString(message('images:volumeViewerToolgroup:importingVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));
        end

    case 2
        if strcmp(newVolType,'volume')&&sameSize


        elseif strcmp(newVolType,'volume')&&~sameSize

            buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importDifferentSizedVolume')),...
            getString(message('images:volumeViewerToolgroup:importingVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

        else

            buttonName=questdlg(getString(message('images:volumeViewerToolgroup:replaceLabeledVolume')),...
            getString(message('images:volumeViewerToolgroup:importingLabeledVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));
        end

    case 3
        if strcmp(newVolType,'volume')
            if sameSize

                buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importSameSizedVolumeTwoVols')),...
                getString(message('images:volumeViewerToolgroup:importingVolume')),...
                getString(message('images:volumeViewerToolgroup:replaceVolumeOnly')),...
                getString(message('images:volumeViewerToolgroup:replaceAll')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            else

                buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importDifferentSizedVolume')),...
                getString(message('images:volumeViewerToolgroup:importingVolume')),...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            end
        else
            if sameSize

                buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importSameSizedLabeledVolumeTwoVols')),...
                getString(message('images:volumeViewerToolgroup:importingLabeledVolume')),...
                getString(message('images:volumeViewerToolgroup:replaceLabeledVolumeOnly')),...
                getString(message('images:volumeViewerToolgroup:replaceAll')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            else

                buttonName=questdlg(getString(message('images:volumeViewerToolgroup:importDifferentSizedLabeledVolume')),...
                getString(message('images:volumeViewerToolgroup:importingLabeledVolume')),...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));
            end
        end
    end

    if isempty(buttonName)
        buttonName=getString(message('images:commonUIString:cancel'));
    end

    switch buttonName
    case getString(message('images:commonUIString:cancel'))
        refreshValue='Cancel';
    case getString(message('images:volumeViewerToolgroup:replaceVolume'))
        refreshValue='Volume';
    case getString(message('images:volumeViewerToolgroup:replaceLabeledVolume'))
        refreshValue='LabeledVolume';
    case getString(message('images:volumeViewerToolgroup:viewAsOverlay'))
        refreshValue='Overlay';
    case{getString(message('images:volumeViewerToolgroup:replaceAll')),...
        getString(message('images:commonUIString:yes'))}
        refreshValue='App';
    end


