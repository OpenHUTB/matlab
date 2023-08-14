function dlgstruct=getUpdateFirmwareSchema(hStep,dlgstruct)




    leader.Type='text';
    leader.RowSpan=[1,1];
    leader.ColSpan=[1,4];
    leader.Visible=true;
    leader.Tag=[hStep.ID,'_Step_Description'];

    instSpPkg=matlabshared.supportpkg.getInstalled;

    fwUpdateDisplayList=getFirmwareUpdateEntries(hStep);
    isFirmwareUpdateAvl=~isempty(fwUpdateDisplayList);

    if isempty(instSpPkg)&&~isFirmwareUpdateAvl

        leader.Name=hStep.StepData.Labels.DescriptionNone;
    elseif~isFirmwareUpdateAvl

        leader.Name=hStep.StepData.Labels.DescriptionNotRequired;
    else

        leader.Name=hStep.StepData.Labels.AvailableDescription;
    end



    choice.Name=hStep.StepData.Labels.Choose;
    choice.Type='combobox';
    choice.RowSpan=[2,2];
    choice.ColSpan=[1,1];
    choice.Tag=[hStep.ID,'_Step_Choice'];
    choice.MatlabMethod='dialogCallback';
    choice.MatlabArgs={hStep,'Choice','%tag','%value'};
    choice.Value=hStep.StepData.Choice;
    choice.Entries=fwUpdateDisplayList;
    choice.DialogRefresh=true;
    choice.Visible=~isempty(choice.Entries);

    dlgstruct.Items{1}=leader;






    dlgstruct.Items{2}.Visible=false;


    dlgstruct.Items{3}.Visible=false;


    dlgstruct.Items{4}.Visible=isFirmwareUpdateAvl;


    dlgstruct.Items{5}.Visible=~isFirmwareUpdateAvl;



    dlgstruct.Items{end+1}=choice;
end


function fwUpdateDisplayList=getFirmwareUpdateEntries(hStep)
    hSetup=hStep.getSetup();
    hFwUpdater=hSetup.FwUpdater;
    try

        [hStep.StepData.List,fwUpdateDisplayList,hStep.StepData.BaseCodeList]=hFwUpdater.getFirmwareUpdateList();
        if(hStep.StepData.Choice<0)



            if(~isempty(hStep.StepData.List))
                hStep.StepData.Choice=length(hStep.StepData.List)-1;
            else
                hStep.StepData.Choice=0;
            end
        end

    catch ex
        warning(ex.identifier,ex.message);
        hStep.StepData.List={};
    end

end
