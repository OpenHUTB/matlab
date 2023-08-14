

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

            buttonName=questdlg(getString(message('images:volumeViewer:importDifferentSizedLabeledVolume')),...
            getString(message('images:volumeViewer:importingLabeledVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

        else

            buttonName=questdlg(getString(message('images:volumeViewer:replaceVolume')),...
            getString(message('images:volumeViewer:importingVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));
        end

    case 2
        if strcmp(newVolType,'volume')&&sameSize


        elseif strcmp(newVolType,'volume')&&~sameSize

            buttonName=questdlg(getString(message('images:volumeViewer:importDifferentSizedVolume')),...
            getString(message('images:volumeViewer:importingVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

        else

            buttonName=questdlg(getString(message('images:volumeViewer:replaceLabeledVolume')),...
            getString(message('images:volumeViewer:importingLabeledVolume')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));
        end

    case 3
        if strcmp(newVolType,'volume')
            if sameSize

                buttonName=questdlg(getString(message('images:volumeViewer:importSameSizedVolumeTwoVols')),...
                getString(message('images:volumeViewer:importingVolume')),...
                getString(message('images:volumeViewer:replaceVolumeOnly')),...
                getString(message('images:volumeViewer:replaceAll')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            else

                buttonName=questdlg(getString(message('images:volumeViewer:importDifferentSizedVolume')),...
                getString(message('images:volumeViewer:importingVolume')),...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            end
        else
            if sameSize

                buttonName=questdlg(getString(message('images:volumeViewer:importSameSizedLabeledVolumeTwoVols')),...
                getString(message('images:volumeViewer:importingLabeledVolume')),...
                getString(message('images:volumeViewer:replaceLabeledVolumeOnly')),...
                getString(message('images:volumeViewer:replaceAll')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            else

                buttonName=questdlg(getString(message('images:volumeViewer:importDifferentSizedLabeledVolume')),...
                getString(message('images:volumeViewer:importingLabeledVolume')),...
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
    case getString(message('images:volumeViewer:replaceVolume'))
        refreshValue='Volume';
    case getString(message('images:volumeViewer:replaceLabeledVolume'))
        refreshValue='LabeledVolume';
    case getString(message('images:volumeViewer:viewAsOverlay'))
        refreshValue='Overlay';
    case{getString(message('images:volumeViewer:replaceAll')),...
        getString(message('images:commonUIString:yes'))}
        refreshValue='App';
    end


